import os

def replace_in_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()
    
    new_content = content.replace("edvoyage", "edzkool")
    new_content = new_content.replace("EdVoyage", "Edzkool")
    new_content = new_content.replace("EDVOYAGE", "EDZKOOL")
    new_content = new_content.replace("Edvoyage", "Edzkool")
    new_content = new_content.replace("EDvoyage", "Edzkool")
    
    if new_content != content:
        with open(filepath, 'w') as f:
            f.write(new_content)
        print(f"Updated {filepath}")

for root, _, files in os.walk('.'):
    if 'node_modules' in root or '.git' in root or '.next' in root:
        continue
    for file in files:
        if file.endswith(('.tsx', '.ts', '.mjs', '.md', '.json', '.sh')):
            replace_in_file(os.path.join(root, file))
