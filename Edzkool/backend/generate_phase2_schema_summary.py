import argparse
import json
from collections import defaultdict
from pathlib import Path


def _target_to_str(target):
    if isinstance(target, dict):
        if 'app' in target and 'model' in target:
            return f"{target['app']}.{target['model']}"
        if 'ref' in target:
            return str(target['ref'])
        return json.dumps(target, ensure_ascii=False)
    return str(target)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument('--input', default='phase2_db_schema.json')
    parser.add_argument('--output', default='phase2_db_schema_summary.md')
    args = parser.parse_args()

    input_path = Path(args.input)
    output_path = Path(args.output)

    data = json.loads(input_path.read_text(encoding='utf-8'))
    tables = data.get('tables', {}) or {}

    by_app = defaultdict(list)
    for full_name, t in tables.items():
        app = t.get('app_label') or (full_name.split('.', 1)[0] if '.' in full_name else 'unknown')
        by_app[app].append((full_name, t))

    lines = []
    lines.append('# Phase 2 DB Schema Summary (from Django migrations)')
    lines.append('')
    lines.append(f'**Source JSON:** `{input_path.name}`')
    lines.append('')
    lines.append(f'**Total models/tables:** {len(tables)}')
    lines.append('')

    for app in sorted(by_app.keys()):
        models = sorted(by_app[app], key=lambda x: x[0].lower())
        lines.append(f'## App: `{app}` ({len(models)} models)')
        lines.append('')

        for full_name, t in models:
            model_name = t.get('model_name') or (full_name.split('.', 1)[1] if '.' in full_name else full_name)
            db_table = t.get('db_table')
            cols = t.get('columns', {}) or {}

            pks = [cname for cname, c in cols.items() if c.get('primary_key')]
            if not pks and 'id' in cols:
                pks = ['id']

            fks = []
            o2o = []
            m2m = []

            for cname, c in cols.items():
                rel = c.get('related_to')
                if not isinstance(rel, dict):
                    continue

                rtype = rel.get('type')
                target = rel.get('target') or rel.get('to')
                target_str = _target_to_str(target)

                if rtype == 'fk':
                    fks.append((cname, target_str))
                elif rtype == 'one_to_one':
                    o2o.append((cname, target_str))
                elif rtype == 'm2m':
                    through = rel.get('through')
                    through_str = _target_to_str(through) if through is not None else None
                    m2m.append((cname, target_str, through_str))

            lines.append(f'### `{model_name}`')
            lines.append('')
            lines.append(f'- **db_table**: `{db_table}`')
            lines.append(f'- **primary key**: `{", ".join(pks) if pks else "(none detected)"}`')
            lines.append(f'- **columns**: {len(cols)}')

            if fks:
                lines.append('- **foreign keys**:')
                for cname, target_str in sorted(fks, key=lambda x: x[0]):
                    lines.append(f'  - `{cname}` -> `{target_str}`')
            else:
                lines.append('- **foreign keys**: (none)')

            if o2o:
                lines.append('- **one-to-one**:')
                for cname, target_str in sorted(o2o, key=lambda x: x[0]):
                    lines.append(f'  - `{cname}` -> `{target_str}`')
            else:
                lines.append('- **one-to-one**: (none)')

            if m2m:
                lines.append('- **many-to-many**:')
                for cname, target_str, through_str in sorted(m2m, key=lambda x: x[0]):
                    extra = f" (through `{through_str}`)" if through_str else ''
                    lines.append(f'  - `{cname}` -> `{target_str}`{extra}')
            else:
                lines.append('- **many-to-many**: (none)')

            lines.append('')

    output_path.write_text('\n'.join(lines), encoding='utf-8')


if __name__ == '__main__':
    main()
