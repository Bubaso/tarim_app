import os
import re

lib_dir = '/Users/BURHAN/Desktop/tarim_app/lib'
files_to_update = []

# Regex to match push(createFadeRoute(...))
# We will use re.sub with a function to process matches.
pattern1 = re.compile(r'Navigator\.of\(context\)\.push\(\s*createFadeRoute\((.*?)\)\s*\)', re.DOTALL)
pattern2 = re.compile(r'Navigator\.of\(context\)\.push\(\s*(?:Cupertino|Material)PageRoute\(\s*builder:\s*\([^)]*\)\s*=>\s*(.*?)\)\s*\)', re.DOTALL)

for root, _, files in os.walk(lib_dir):
    for file in files:
        if file.endswith('.dart'):
            path = os.path.join(root, file)
            with open(path, 'r') as f:
                content = f.read()
            
            new_content = content
            
            new_content = pattern1.sub(lambda m: f'pushScreen(context, {m.group(1)})', new_content)
            new_content = pattern2.sub(lambda m: f'pushScreen(context, {m.group(1)})', new_content)
            
            if new_content != content:
                if "fade_page_route.dart" not in new_content:
                    lines = new_content.split('\n')
                    for j, l in enumerate(lines):
                        if l.startswith("import "):
                            lines.insert(j + 1, "import 'package:tarim_app/core/utils/fade_page_route.dart';")
                            break
                    new_content = '\n'.join(lines)
                with open(path, 'w') as f:
                    f.write(new_content)
                print(f"Updated {path}")
