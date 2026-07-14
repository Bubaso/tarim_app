import os

def replace_navigator(content):
    import re
    # We will do a simple string search and replace line by line for the common patterns.
    # Since most pushes are on a single line like:
    # Navigator.of(context).push(createFadeRoute(ArticleDetailScreen(article: a))),
    
    lines = content.split('\n')
    changed = False
    
    for i, line in enumerate(lines):
        if "Navigator.of(context).push(createFadeRoute(" in line:
            # Replace 'Navigator.of(context).push(createFadeRoute(' with 'pushScreen(context, '
            line = line.replace("Navigator.of(context).push(createFadeRoute(", "pushScreen(context, ")
            # Now we need to remove ONE closing parenthesis from the end of the statement.
            # Usually it ends with '));' or ')),'
            if line.endswith("));"):
                line = line[:-3] + ");"
            elif line.endswith(")),"):
                line = line[:-3] + "),"
            elif ")))" in line:
                line = line.replace(")))", "))") # naive, but usually works for trailing
            elif "))" in line:
                line = line.replace("))", ")") # if it was just ))
            lines[i] = line
            changed = True
            
        elif "Navigator.of(context).push(" in line and "PageRoute(builder:" in line:
            # e.g. Navigator.of(context).push(MaterialPageRoute(builder: (_) => FinancialTerminalScreen())),
            match = re.search(r"Navigator\.of\(context\)\.push\(\s*(?:Material|Cupertino)PageRoute\(\s*builder:\s*\([^)]*\)\s*=>\s*(.*)\)\s*\)(;|,)?", line)
            if match:
                widget = match.group(1).strip()
                if widget.endswith(")"): # Remove trailing parenthesis if regex caught it
                    # widget is something like FinancialTerminalScreen())
                    # Actually group(1) would catch FinancialTerminalScreen()) if we're not careful.
                    pass
            # Instead of regex, let's use a simpler approach for the other ones manually if there are only a few.
            
    if changed:
        # Check if import is present
        new_content = '\n'.join(lines)
        if "fade_page_route.dart" not in new_content:
            # insert import at the top
            imports_end = 0
            for j, l in enumerate(lines):
                if l.startswith("import "):
                    imports_end = j
            lines.insert(imports_end + 1, "import 'package:tarim_app/core/utils/fade_page_route.dart';")
        return True, '\n'.join(lines)
    return False, content

lib_dir = '/Users/BURHAN/Desktop/tarim_app/lib'
for root, _, files in os.walk(lib_dir):
    for file in files:
        if file.endswith('.dart'):
            path = os.path.join(root, file)
            with open(path, 'r') as f:
                content = f.read()
            
            was_changed, new_content = replace_navigator(content)
            if was_changed:
                with open(path, 'w') as f:
                    f.write(new_content)
                print(f"Updated {path}")

