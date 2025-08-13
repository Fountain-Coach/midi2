import json
import pathlib
import re

SCHEMA_PATH = pathlib.Path('midi2.full.closed.schema.json')
SOURCES_DIR = pathlib.Path('Sources')

schema = json.loads(SCHEMA_PATH.read_text())
defs = schema.get('$defs', {})

# Build mapping from swift type name to description
mapping = {}
for key, val in defs.items():
    desc = val.get('description')
    if not desc:
        continue
    swift_name = key.split('.')[-1]
    mapping[swift_name] = desc

for swift_name, desc in mapping.items():
    # Search for Swift source files matching the type name
    for file in SOURCES_DIR.rglob(f'{swift_name}.swift'):
        text = file.read_text()
        # regex to find struct or enum definition
        pattern = re.compile(r'(\n|\A)(?P<indent>\s*)(?:///.*\n)*(?P<keyword>public\s+(struct|enum)\s+' + re.escape(swift_name) + r'\b)', re.MULTILINE)
        m = pattern.search(text)
        if not m:
            continue
        indent = m.group('indent')
        keyword = m.group('keyword')
        # Build doc comment
        doc = '/// ' + desc.replace('\n', '\n' + indent + '/// ')
        replacement = '\n' + indent + doc + '\n' + indent + keyword
        new_text = pattern.sub(replacement, text, count=1)
        file.write_text(new_text)
        print(f'Updated {file}')
