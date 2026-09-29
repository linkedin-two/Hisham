import argparse
import ast
import json
import os
from collections import defaultdict, deque
from dataclasses import dataclass, field
from typing import Any, Dict, List, Optional, Tuple


def _node_to_name(node: ast.AST) -> Optional[str]:
    if isinstance(node, ast.Name):
        return node.id
    if isinstance(node, ast.Attribute):
        base = _node_to_name(node.value)
        if base:
            return f"{base}.{node.attr}"
        return node.attr
    return None


def _safe_literal(node: ast.AST) -> Any:
    if isinstance(node, ast.Constant):
        return node.value
    if isinstance(node, ast.List):
        return [_safe_literal(elt) for elt in node.elts]
    if isinstance(node, ast.Tuple):
        return tuple(_safe_literal(elt) for elt in node.elts)
    if isinstance(node, ast.Dict):
        return {_safe_literal(k): _safe_literal(v) for k, v in zip(node.keys, node.values)}
    if isinstance(node, ast.UnaryOp) and isinstance(node.op, ast.USub):
        val = _safe_literal(node.operand)
        if isinstance(val, (int, float)):
            return -val
    if isinstance(node, ast.BinOp) and isinstance(node.op, ast.Add):
        left = _safe_literal(node.left)
        right = _safe_literal(node.right)
        if isinstance(left, str) and isinstance(right, str):
            return left + right
    if isinstance(node, ast.Name):
        if node.id in {"True", "False", "None"}:
            return {"True": True, "False": False, "None": None}[node.id]
        return {"name": node.id}
    if isinstance(node, ast.Attribute):
        name = _node_to_name(node)
        return {"attr": name} if name else None
    if isinstance(node, ast.Call):
        func = _node_to_name(node.func) or "<call>"
        args = [_safe_literal(a) for a in node.args]
        kwargs = {kw.arg: _safe_literal(kw.value) for kw in node.keywords if kw.arg is not None}
        return {"call": func, "args": args, "kwargs": kwargs}
    return {"unparsed": ast.dump(node)}


def _get_kw(call: Dict[str, Any], key: str, default: Any = None) -> Any:
    return (call.get("kwargs") or {}).get(key, default)


def _call_type(call: Any) -> Optional[str]:
    if isinstance(call, dict) and "call" in call:
        return str(call["call"])
    return None


def _normalize_model_name(name: str) -> str:
    return name.lower()


def _default_table_name(app_label: str, model_name: str) -> str:
    return f"{app_label}_{model_name.lower()}"


@dataclass
class Column:
    name: str
    field_type: str
    null: Optional[bool] = None
    blank: Optional[bool] = None
    primary_key: Optional[bool] = None
    unique: Optional[bool] = None
    db_index: Optional[bool] = None
    default: Any = None
    max_length: Any = None
    related_to: Optional[Dict[str, Any]] = None
    raw: Dict[str, Any] = field(default_factory=dict)


@dataclass
class Table:
    app_label: str
    model_name: str
    db_table: str
    columns: Dict[str, Column] = field(default_factory=dict)
    options: Dict[str, Any] = field(default_factory=dict)
    indexes: List[Dict[str, Any]] = field(default_factory=list)
    constraints: List[Dict[str, Any]] = field(default_factory=list)


def _parse_field(field_call: Any) -> Column:
    ftype = _call_type(field_call) or "unknown"
    kwargs = field_call.get("kwargs", {}) if isinstance(field_call, dict) else {}
    null = kwargs.get("null")
    blank = kwargs.get("blank")
    primary_key = kwargs.get("primary_key")
    unique = kwargs.get("unique")
    db_index = kwargs.get("db_index")
    default = kwargs.get("default")
    max_length = kwargs.get("max_length")

    related_to = None
    if ftype.endswith("ForeignKey") or ftype.endswith("OneToOneField"):
        args = field_call.get("args", [])
        to = args[0] if args else kwargs.get("to")
        on_delete = kwargs.get("on_delete")
        related_to = {"type": "fk" if ftype.endswith("ForeignKey") else "one_to_one", "to": to, "on_delete": on_delete}
    elif ftype.endswith("ManyToManyField"):
        args = field_call.get("args", [])
        to = args[0] if args else kwargs.get("to")
        through = kwargs.get("through")
        related_to = {"type": "m2m", "to": to, "through": through}

    return Column(
        name="",
        field_type=ftype,
        null=null,
        blank=blank,
        primary_key=primary_key,
        unique=unique,
        db_index=db_index,
        default=default,
        max_length=max_length,
        related_to=related_to,
        raw={"field": field_call},
    )


def _extract_migration_info(path: str) -> Optional[Dict[str, Any]]:
    try:
        with open(path, "r", encoding="utf-8") as f:
            src = f.read()
    except OSError:
        return None

    try:
        tree = ast.parse(src, filename=path)
    except SyntaxError:
        return None

    migration_class: Optional[ast.ClassDef] = None
    for node in tree.body:
        if isinstance(node, ast.ClassDef) and node.name == "Migration":
            migration_class = node
            break

    if not migration_class:
        return None

    deps = []
    ops = []

    for stmt in migration_class.body:
        if isinstance(stmt, ast.Assign) and len(stmt.targets) == 1 and isinstance(stmt.targets[0], ast.Name):
            name = stmt.targets[0].id
            if name == "dependencies":
                deps = _safe_literal(stmt.value) or []
            elif name == "operations":
                ops = _safe_literal(stmt.value) or []

    return {"dependencies": deps, "operations": ops}


def _find_migration_files(project_root: str) -> Dict[Tuple[str, str], str]:
    out: Dict[Tuple[str, str], str] = {}
    for dirpath, dirnames, filenames in os.walk(project_root):
        if os.path.basename(dirpath) != "migrations":
            continue
        app_label = os.path.basename(os.path.dirname(dirpath))
        for fn in filenames:
            if not fn.endswith(".py"):
                continue
            if fn == "__init__.py":
                continue
            migration_name = fn[:-3]
            out[(app_label, migration_name)] = os.path.join(dirpath, fn)
    return out


def _toposort(migrations: Dict[Tuple[str, str], Dict[str, Any]]) -> List[Tuple[str, str]]:
    graph: Dict[Tuple[str, str], List[Tuple[str, str]]] = defaultdict(list)
    indeg: Dict[Tuple[str, str], int] = {k: 0 for k in migrations}

    for key, info in migrations.items():
        for dep in info.get("dependencies", []) or []:
            if isinstance(dep, (list, tuple)) and len(dep) == 2:
                dep_key = (str(dep[0]), str(dep[1]))
                if dep_key in migrations:
                    graph[dep_key].append(key)
                    indeg[key] += 1

    q = deque([k for k, d in indeg.items() if d == 0])
    ordered: List[Tuple[str, str]] = []

    while q:
        n = q.popleft()
        ordered.append(n)
        for nxt in graph.get(n, []):
            indeg[nxt] -= 1
            if indeg[nxt] == 0:
                q.append(nxt)

    if len(ordered) != len(migrations):
        remaining = [k for k in migrations if k not in set(ordered)]
        ordered.extend(remaining)

    return ordered


def _coerce_target(to_value: Any, current_app: str) -> Optional[Dict[str, str]]:
    if isinstance(to_value, str):
        if "." in to_value:
            app, model = to_value.split(".", 1)
            return {"app": app, "model": model}
        return {"app": current_app, "model": to_value}
    if isinstance(to_value, dict) and "attr" in to_value:
        return {"ref": to_value["attr"]}
    if isinstance(to_value, dict) and "name" in to_value:
        return {"ref": to_value["name"]}
    return None


def _apply_operations(schema: Dict[Tuple[str, str], Table], app_label: str, operations: List[Any]) -> None:
    for op in operations or []:
        if not isinstance(op, dict) or "call" not in op:
            continue

        op_type = str(op["call"])
        kwargs = op.get("kwargs", {})
        args = op.get("args", [])

        if op_type.endswith("CreateModel"):
            model_name = kwargs.get("name") if "name" in kwargs else (args[0] if args else None)
            if not isinstance(model_name, str):
                continue

            fields = kwargs.get("fields", [])
            options = kwargs.get("options", {}) or {}
            db_table = options.get("db_table") if isinstance(options, dict) else None
            if not isinstance(db_table, str) or not db_table:
                db_table = _default_table_name(app_label, model_name)

            tkey = (app_label, _normalize_model_name(model_name))
            table = Table(app_label=app_label, model_name=model_name, db_table=db_table, options=options if isinstance(options, dict) else {})

            if isinstance(fields, list):
                for fld in fields:
                    if not isinstance(fld, (list, tuple)) or len(fld) != 2:
                        continue
                    fname, fcall = fld
                    if not isinstance(fname, str):
                        continue
                    col = _parse_field(fcall) if isinstance(fcall, dict) else Column(name="", field_type="unknown", raw={"field": fcall})
                    col.name = fname

                    if col.related_to and col.related_to.get("to") is not None:
                        target = _coerce_target(col.related_to.get("to"), app_label)
                        if target is not None:
                            col.related_to["target"] = target

                    table.columns[fname] = col

            schema[tkey] = table

        elif op_type.endswith("DeleteModel"):
            model_name = kwargs.get("name") if "name" in kwargs else (args[0] if args else None)
            if not isinstance(model_name, str):
                continue
            tkey = (app_label, _normalize_model_name(model_name))
            schema.pop(tkey, None)

        elif op_type.endswith("AddField") or op_type.endswith("AlterField"):
            model_name = kwargs.get("model_name")
            name = kwargs.get("name")
            field_call = kwargs.get("field")
            if not isinstance(model_name, str) or not isinstance(name, str):
                continue
            tkey = (app_label, _normalize_model_name(model_name))
            table = schema.get(tkey)
            if not table:
                continue
            col = _parse_field(field_call) if isinstance(field_call, dict) else Column(name="", field_type="unknown", raw={"field": field_call})
            col.name = name
            if col.related_to and col.related_to.get("to") is not None:
                target = _coerce_target(col.related_to.get("to"), app_label)
                if target is not None:
                    col.related_to["target"] = target
            table.columns[name] = col

        elif op_type.endswith("RemoveField"):
            model_name = kwargs.get("model_name")
            name = kwargs.get("name")
            if not isinstance(model_name, str) or not isinstance(name, str):
                continue
            tkey = (app_label, _normalize_model_name(model_name))
            table = schema.get(tkey)
            if not table:
                continue
            table.columns.pop(name, None)

        elif op_type.endswith("RenameField"):
            model_name = kwargs.get("model_name")
            old_name = kwargs.get("old_name")
            new_name = kwargs.get("new_name")
            if not isinstance(model_name, str) or not isinstance(old_name, str) or not isinstance(new_name, str):
                continue
            tkey = (app_label, _normalize_model_name(model_name))
            table = schema.get(tkey)
            if not table:
                continue
            col = table.columns.pop(old_name, None)
            if col:
                col.name = new_name
                table.columns[new_name] = col

        elif op_type.endswith("RenameModel"):
            old_name = kwargs.get("old_name")
            new_name = kwargs.get("new_name")
            if not isinstance(old_name, str) or not isinstance(new_name, str):
                continue
            old_key = (app_label, _normalize_model_name(old_name))
            new_key = (app_label, _normalize_model_name(new_name))
            table = schema.pop(old_key, None)
            if table:
                table.model_name = new_name
                if table.db_table == _default_table_name(app_label, old_name):
                    table.db_table = _default_table_name(app_label, new_name)
                schema[new_key] = table

        elif op_type.endswith("AddIndex"):
            model_name = kwargs.get("model_name")
            index = kwargs.get("index")
            if not isinstance(model_name, str) or not isinstance(index, dict):
                continue
            tkey = (app_label, _normalize_model_name(model_name))
            table = schema.get(tkey)
            if not table:
                continue
            table.indexes.append(index)

        elif op_type.endswith("AddConstraint"):
            model_name = kwargs.get("model_name")
            constraint = kwargs.get("constraint")
            if not isinstance(model_name, str) or not isinstance(constraint, dict):
                continue
            tkey = (app_label, _normalize_model_name(model_name))
            table = schema.get(tkey)
            if not table:
                continue
            table.constraints.append(constraint)


def build_schema(project_root: str) -> Dict[str, Any]:
    migration_files = _find_migration_files(project_root)
    migrations: Dict[Tuple[str, str], Dict[str, Any]] = {}

    for key, path in migration_files.items():
        info = _extract_migration_info(path)
        if info is None:
            continue
        migrations[key] = info

    ordered = _toposort(migrations)

    schema_tables: Dict[Tuple[str, str], Table] = {}

    for (app_label, mig_name) in ordered:
        info = migrations.get((app_label, mig_name))
        if not info:
            continue
        ops = info.get("operations", [])
        _apply_operations(schema_tables, app_label, ops)

    out_tables: Dict[str, Any] = {}
    for (app_label, model_key), table in sorted(schema_tables.items(), key=lambda x: (x[0][0], x[0][1])):
        table_id = f"{app_label}.{table.model_name}"
        out_tables[table_id] = {
            "app_label": table.app_label,
            "model_name": table.model_name,
            "db_table": table.db_table,
            "options": table.options,
            "columns": {
                name: {
                    "field_type": col.field_type,
                    "null": col.null,
                    "blank": col.blank,
                    "primary_key": col.primary_key,
                    "unique": col.unique,
                    "db_index": col.db_index,
                    "default": col.default,
                    "max_length": col.max_length,
                    "related_to": col.related_to,
                    "raw": col.raw,
                }
                for name, col in table.columns.items()
            },
            "indexes": table.indexes,
            "constraints": table.constraints,
        }

    return {
        "meta": {
            "source": "django_migrations",
            "project_root": os.path.abspath(project_root),
        },
        "tables": out_tables,
    }


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--project-root", default=".")
    parser.add_argument("--output", default="phase2_db_schema.json")
    args = parser.parse_args()

    schema = build_schema(args.project_root)

    with open(args.output, "w", encoding="utf-8") as f:
        json.dump(schema, f, indent=2, ensure_ascii=False)


if __name__ == "__main__":
    main()
