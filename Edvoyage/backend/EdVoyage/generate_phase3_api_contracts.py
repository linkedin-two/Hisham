import argparse
import importlib
import inspect
import json
import os
from collections import OrderedDict
from typing import Any, Dict, List, Optional, Tuple


def _json_safe(val: Any) -> Any:
    if val is None:
        return None
    # Coerce Django lazy translation proxy objects (and similar) to string
    try:
        from django.utils.encoding import force_str

        if val.__class__.__name__ == "__proxy__":
            return force_str(val)
    except Exception:
        # Django may not be importable before setup; fall through.
        if val.__class__.__name__ == "__proxy__":
            return str(val)

    try:
        json.dumps(val)
        return val
    except Exception:
        # Last resort: represent as string (prefer str over repr for user-facing text)
        try:
            return str(val)
        except Exception:
            return repr(val)


def _field_choices(field) -> Optional[List[Any]]:
    try:
        choices = getattr(field, "choices", None)
        if not choices:
            return None
        if isinstance(choices, dict):
            return [k for k in choices.keys()]
        return list(choices)
    except Exception:
        return None


def _field_default(field) -> Any:
    try:
        from rest_framework.fields import empty

        default = getattr(field, "default", empty)
        if default is empty:
            return None
        if callable(default):
            return {"callable": getattr(default, "__name__", repr(default))}
        return _json_safe(default)
    except Exception:
        return None


def _collect_validators(field) -> List[str]:
    out: List[str] = []
    try:
        validators = getattr(field, "validators", []) or []
        for v in validators:
            out.append(v.__class__.__name__)
    except Exception:
        pass
    return out


def _field_meta(field) -> Dict[str, Any]:
    meta: Dict[str, Any] = {
        "type": field.__class__.__name__,
        "required": getattr(field, "required", None),
        "read_only": getattr(field, "read_only", None),
        "write_only": getattr(field, "write_only", None),
        "allow_null": getattr(field, "allow_null", None),
        "default": _field_default(field),
        "source": _json_safe(getattr(field, "source", None)),
        "help_text": _json_safe(getattr(field, "help_text", None)),
        "validators": _collect_validators(field),
    }

    for attr in [
        "allow_blank",
        "max_length",
        "min_length",
        "max_value",
        "min_value",
        "decimal_places",
        "max_digits",
    ]:
        if hasattr(field, attr):
            meta[attr] = _json_safe(getattr(field, attr))

    choices = _field_choices(field)
    if choices is not None:
        meta["choices"] = [_json_safe(c) for c in choices]

    # Nested/collection hints
    try:
        from rest_framework.serializers import ListSerializer

        if isinstance(field, ListSerializer):
            meta["many"] = True
            meta["child"] = getattr(field.child.__class__, "__name__", None)
    except Exception:
        pass

    # ManyRelatedField/PrimaryKeyRelatedField etc can expose queryset/model
    if hasattr(field, "queryset") and getattr(field, "queryset") is not None:
        try:
            qs = getattr(field, "queryset")
            model = getattr(qs, "model", None)
            if model is not None:
                meta["related_model"] = f"{model.__module__}.{model.__name__}"
        except Exception:
            pass

    return meta


def _serializer_validation_methods(cls) -> List[str]:
    names: List[str] = []
    for name, member in inspect.getmembers(cls, predicate=inspect.isfunction):
        if not (name == "validate" or name.startswith("validate_")):
            continue
        # Only include methods defined on this class (exclude inherited DRF internals)
        qual = getattr(member, "__qualname__", "")
        if not qual.startswith(f"{cls.__name__}."):
            continue
        names.append(name)
    return sorted(set(names))


def _load_serializers(django_settings_module: str, modules: List[str]) -> Tuple[Dict[str, Any], List[str]]:
    os.environ.setdefault("DJANGO_SETTINGS_MODULE", django_settings_module)

    errors: List[str] = []
    try:
        import django

        django.setup()
    except Exception as e:
        raise RuntimeError(f"Failed to django.setup(): {e}")

    from rest_framework import serializers as drf_serializers

    catalog: Dict[str, Any] = {}

    for module_name in modules:
        try:
            mod = importlib.import_module(module_name)
        except Exception as e:
            errors.append(f"Failed to import {module_name}: {e}")
            continue

        for attr_name, obj in vars(mod).items():
            if not inspect.isclass(obj):
                continue
            if obj.__module__ != module_name:
                continue
            try:
                if not issubclass(obj, drf_serializers.BaseSerializer):
                    continue
            except Exception:
                continue

            dotted = f"{obj.__module__}.{obj.__name__}"
            try:
                instance = obj()
                fields = OrderedDict()
                for fname, field in instance.fields.items():
                    fields[fname] = _field_meta(field)

                catalog[dotted] = {
                    "module": obj.__module__,
                    "name": obj.__name__,
                    "bases": [b.__name__ for b in obj.__mro__[1:4]],
                    "validation_methods": _serializer_validation_methods(obj),
                    "fields": fields,
                }
            except Exception as e:
                errors.append(f"Failed to introspect {dotted}: {e}")

    return catalog, errors


def _choose_request_response_serializers(serializer_list: List[str], method: str) -> Tuple[List[str], List[str]]:
    if not serializer_list:
        return [], []

    req: List[str] = []
    resp: List[str] = []

    def _is_query_serializer(name: str) -> bool:
        base = name.split(".")[-1]
        return base.endswith("SearchSerializer") or base.endswith("FilterSerializer")

    # Heuristic: Create/Update serializers are request; non-Create/Update are response
    create = [s for s in serializer_list if s.endswith("CreateSerializer")]
    update = [s for s in serializer_list if s.endswith("UpdateSerializer")]

    if method in {"GET", "DELETE"}:
        # Generally: no request body for GET/DELETE.
        # Exception: endpoints that explicitly use query serializers (e.g., CourseSearchSerializer).
        req = [s for s in serializer_list if _is_query_serializer(s)]
        resp = [s for s in serializer_list if s not in req] or []
        return req, resp

    if method in {"POST"} and create:
        req = create
        resp = [s for s in serializer_list if s not in create] or create
    elif method in {"PUT", "PATCH"} and update:
        req = update
        resp = [s for s in serializer_list if s not in update] or update
    else:
        # default: same serializer for both
        req = serializer_list
        resp = serializer_list

    return req, resp


def _render_fields_md(catalog: Dict[str, Any], serializer_name: str, mode: str) -> List[str]:
    # mode: 'request' or 'response' (used for highlighting read/write-only)
    entry = catalog.get(serializer_name)
    if not entry:
        return [f"- (serializer not found in catalog: `{serializer_name}`)"]

    fields: Dict[str, Any] = entry.get("fields", {})
    lines: List[str] = []
    for fname, meta in fields.items():
        required = meta.get("required")
        ro = meta.get("read_only")
        wo = meta.get("write_only")
        default = meta.get("default")
        ftype = meta.get("type")

        if mode == "request" and ro is True:
            continue
        if mode == "response" and wo is True:
            continue

        qualifiers: List[str] = []
        if required is True:
            qualifiers.append("required")
        elif required is False:
            qualifiers.append("optional")
        if ro:
            qualifiers.append("read_only")
        if wo:
            qualifiers.append("write_only")
        if default is not None:
            qualifiers.append(f"default={_json_safe(default)}")

        q = f" ({', '.join(qualifiers)})" if qualifiers else ""
        lines.append(f"- `{fname}`: `{ftype}`{q}")
    return lines or ["- (no fields)"]


def build_contracts(phase4_path: str, catalog: Dict[str, Any]) -> str:
    data = json.loads(open(phase4_path, "r", encoding="utf-8").read())
    api_groups = (data.get("api_groups") or {})

    lines: List[str] = []
    lines.append("# Phase 3 — API Contracts (Serializers & Validation)")
    lines.append("")
    lines.append(f"**Source endpoints:** `{os.path.basename(phase4_path)}`")
    lines.append("")
    lines.append("This document is derived from DRF serializer definitions (fields + validation methods).")
    lines.append("It does not include business logic beyond serializer validation.")
    lines.append("")

    for group_name in sorted(api_groups.keys()):
        group = api_groups[group_name] or {}
        endpoints = group.get("endpoints") or []

        lines.append(f"## API Group: `{group_name}`")
        lines.append("")

        for ep in endpoints:
            path = ep.get("path")
            methods = ep.get("methods") or {}

            for method in sorted(methods.keys()):
                method_info = methods[method] or {}
                serializer_list = method_info.get("serializers") or ep.get("serializers") or []
                if not isinstance(serializer_list, list):
                    serializer_list = []

                req_serializers, resp_serializers = _choose_request_response_serializers(serializer_list, method)

                lines.append(f"### `{method}` `{path}`")
                lines.append("")

                if method_info.get("request"):
                    lines.append("**Request (non-serializer hints)**")
                    lines.append("\n```json\n" + json.dumps(method_info["request"], indent=2, ensure_ascii=False) + "\n```\n")

                # Request
                if req_serializers:
                    lines.append("**Request serializer(s)**")
                    for s in req_serializers:
                        lines.append(f"- `{s}`")
                        lines.extend(["  " + l for l in _render_fields_md(catalog, s, mode="request")])
                    lines.append("")
                else:
                    lines.append("**Request serializer(s)**")
                    lines.append("- (none)\n")

                # Response
                if resp_serializers:
                    lines.append("**Response serializer(s)**")
                    for s in resp_serializers:
                        lines.append(f"- `{s}`")
                        lines.extend(["  " + l for l in _render_fields_md(catalog, s, mode="response")])
                    lines.append("")
                else:
                    lines.append("**Response serializer(s)**")
                    lines.append("- (none)\n")

                # Validation methods
                serializer_methods: List[str] = []
                for s in set(req_serializers + resp_serializers):
                    entry = catalog.get(s)
                    if entry:
                        for m in entry.get("validation_methods", []) or []:
                            serializer_methods.append(f"{s}.{m}")

                serializer_methods = sorted(set(serializer_methods))
                lines.append("**Validation rules (serializer-level)**")
                if serializer_methods:
                    for m in serializer_methods:
                        lines.append(f"- `{m}`")
                else:
                    lines.append("- (none detected)")

                lines.append("")

    return "\n".join(lines)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--settings", default="edvoayge.settings")
    parser.add_argument("--phase4", default="phase4_api_logic.json")
    parser.add_argument("--catalog-output", default="phase3_serializers_catalog.json")
    parser.add_argument("--contracts-output", default="phase3_api_contracts.md")
    args = parser.parse_args()

    modules = [
        "users.serializers",
        "universities.serializers",
        "courses.serializers",
        "applications.serializers",
        "payments.serializers",
        "quizzes.serializers",
        "content.serializers",
    ]

    catalog, errors = _load_serializers(args.settings, modules)

    with open(args.catalog_output, "w", encoding="utf-8") as f:
        json.dump({"serializers": catalog, "errors": errors}, f, indent=2, ensure_ascii=False)

    contracts_md = build_contracts(args.phase4, catalog)
    with open(args.contracts_output, "w", encoding="utf-8") as f:
        f.write(contracts_md)


if __name__ == "__main__":
    main()
