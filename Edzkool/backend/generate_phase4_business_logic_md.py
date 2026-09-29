import argparse
import json
import re
from pathlib import Path
from typing import Any, Dict, List, Tuple


_DB_KEYWORDS = [
    (re.compile(r"\bcreate\b", re.I), "CREATE"),
    (re.compile(r"\bget_or_create\b", re.I), "GET_OR_CREATE"),
    (re.compile(r"\bupdate_or_create\b", re.I), "UPDATE_OR_CREATE"),
    (re.compile(r"\bupdate\b", re.I), "UPDATE"),
    (re.compile(r"\bsave\b", re.I), "UPDATE (save)"),
    (re.compile(r"\bdelete\b", re.I), "DELETE"),
    (re.compile(r"\bfilter\b", re.I), "READ (filter)"),
    (re.compile(r"\bget\b", re.I), "READ (get)"),
    (re.compile(r"\bcount\b", re.I), "READ (count)"),
    (re.compile(r"\baggregate\b|\bannotate\b", re.I), "READ (aggregate/annotate)"),
    (re.compile(r"\border_by\b", re.I), "READ (order_by)"),
]


def _as_list(val: Any) -> List[Any]:
    if val is None:
        return []
    if isinstance(val, list):
        return val
    return [val]


def _infer_db_ops(steps: List[str], side_effects: List[str]) -> List[str]:
    ops: List[str] = []

    def add(op: str) -> None:
        if op not in ops:
            ops.append(op)

    for s in steps + side_effects:
        if not isinstance(s, str):
            continue
        for rx, label in _DB_KEYWORDS:
            if rx.search(s):
                add(label)

    # If we saw mutations, surface as write.
    return ops


def _extract_conditionals(steps: List[str], errors: List[Dict[str, Any]]) -> List[str]:
    out: List[str] = []
    for s in steps:
        if isinstance(s, str) and s.strip().lower().startswith("if "):
            out.append(s.strip())
        elif isinstance(s, str) and " if " in s.lower():
            # keep short, avoid huge lines
            out.append(s.strip())

    for e in errors:
        when = e.get("when")
        if isinstance(when, str) and when:
            out.append(f"Error condition: {when}")

    # de-dupe preserving order
    seen = set()
    deduped: List[str] = []
    for x in out:
        if x not in seen:
            seen.add(x)
            deduped.append(x)
    return deduped


def _extract_helpers(handler: str, steps: List[str]) -> List[str]:
    helpers: List[str] = []

    def add(x: str) -> None:
        if x and x not in helpers:
            helpers.append(x)

    if handler:
        add(handler)

    call_rx = re.compile(r"\bCall\s+([A-Za-z0-9_\.]+)\b")
    for s in steps:
        if not isinstance(s, str):
            continue
        m = call_rx.search(s)
        if m:
            add(m.group(1))

    return helpers


def _fmt_errors(errors: List[Dict[str, Any]]) -> List[str]:
    lines: List[str] = []
    for e in errors:
        status = e.get("status")
        when = e.get("when")
        resp = e.get("response")
        if status is None and when is None and resp is None:
            continue
        chunk = f"- **{status}**"
        if when:
            chunk += f" when {when}"
        if resp:
            chunk += f" -> {resp}"
        lines.append(chunk)
    return lines


def generate_md(phase4: Dict[str, Any]) -> str:
    api_groups = phase4.get("api_groups", {}) or {}

    md: List[str] = []
    md.append("# Phase 4 — Business Logic Extraction (Endpoint-wise)")
    md.append("")
    md.append("This document is a human-readable behavior spec. It intentionally does **not** introduce any new logic or optimizations.")
    md.append("")

    for group_name in sorted(api_groups.keys()):
        group = api_groups[group_name] or {}
        endpoints = group.get("endpoints", []) or []

        md.append(f"## API Group: `{group_name}`")
        md.append("")

        for ep in endpoints:
            path = ep.get("path")
            methods = ep.get("methods", {}) or {}

            for method in sorted(methods.keys()):
                info = methods.get(method, {}) or {}
                handler = info.get("handler") or ep.get("handler") or ""

                steps = _as_list(info.get("logic_steps") or info.get("steps"))
                side_effects = _as_list(info.get("side_effects"))
                errors = _as_list(info.get("errors"))

                # Normalize errors to dicts
                errors_dicts: List[Dict[str, Any]] = [e for e in errors if isinstance(e, dict)]

                md.append(f"### `{method}` `{path}`")
                md.append("")
                if handler:
                    md.append(f"- **View / function**: `{handler}`")
                else:
                    md.append("- **View / function**: (not specified)")

                md.append("")
                md.append("#### Business logic steps (in order)")
                if steps:
                    for i, s in enumerate(steps, start=1):
                        md.append(f"{i}. {s}")
                else:
                    md.append("1. (not specified)")

                md.append("")
                md.append("#### DB operations (inferred)")
                db_ops = _infer_db_ops([str(s) for s in steps], [str(s) for s in side_effects])
                if db_ops:
                    for op in db_ops:
                        md.append(f"- {op}")
                else:
                    md.append("- (none inferred)")

                md.append("")
                md.append("#### Conditional logic & edge cases")
                conds = _extract_conditionals([str(s) for s in steps], errors_dicts)
                if conds:
                    for c in conds:
                        md.append(f"- {c}")
                else:
                    md.append("- (none detected)")

                md.append("")
                md.append("#### Error cases & status codes")
                err_lines = _fmt_errors(errors_dicts)
                if err_lines:
                    md.extend(err_lines)
                else:
                    md.append("- (none listed)")

                md.append("")
                md.append("#### Shared helpers / utilities referenced")
                helpers = _extract_helpers(handler, [str(s) for s in steps])
                if helpers:
                    for h in helpers:
                        md.append(f"- `{h}`")
                else:
                    md.append("- (none detected)")

                md.append("")

    return "\n".join(md)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--phase4", default="phase4_api_logic.json")
    parser.add_argument("--output", default="phase4_business_logic.md")
    args = parser.parse_args()

    phase4_path = Path(args.phase4)
    out_path = Path(args.output)

    phase4 = json.loads(phase4_path.read_text(encoding="utf-8"))
    out_path.write_text(generate_md(phase4), encoding="utf-8")


if __name__ == "__main__":
    main()
