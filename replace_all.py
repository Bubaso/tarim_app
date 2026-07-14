import os

def replace_navigator_in_content(content):
    changed = False
    
    # We want to replace instances of:
    # Navigator.of(context).push(createFadeRoute(...))
    # Navigator.of(context).push(CupertinoPageRoute(builder: (context) => ...))
    # Navigator.of(context).push(MaterialPageRoute(builder: (context) => ...))
    # with:
    # pushScreen(context, ...)
    
    # We will do a character-by-character parse to handle nested parentheses.
    search_str = "Navigator.of(context).push("
    idx = 0
    while True:
        idx = content.find(search_str, idx)
        if idx == -1:
            break
            
        start_args = idx + len(search_str)
        
        # Find the matching closing parenthesis for the .push(
        depth = 1
        end_idx = start_args
        while end_idx < len(content) and depth > 0:
            if content[end_idx] == '(':
                depth += 1
            elif content[end_idx] == ')':
                depth -= 1
            end_idx += 1
            
        if depth != 0:
            idx += 1
            continue
            
        # The arguments to push() are in content[start_args:end_idx-1]
        args_str = content[start_args:end_idx-1].strip()
        
        replacement = None
        
        # Check if args_str is createFadeRoute(...)
        if args_str.startswith("createFadeRoute("):
            inner_start = len("createFadeRoute(")
            inner_end = len(args_str) - 1
            if args_str.endswith(")"):
                widget_str = args_str[inner_start:inner_end].strip()
                replacement = f"pushScreen(context, {widget_str})"
                
        # Check if args_str is MaterialPageRoute or CupertinoPageRoute
        elif "PageRoute(" in args_str and "builder:" in args_str:
            # Simple heuristic: find '=>'
            arrow_idx = args_str.find("=>")
            if arrow_idx != -1:
                widget_str = args_str[arrow_idx+2:].strip()
                # remove trailing commas or spaces
                if widget_str.endswith(","):
                    widget_str = widget_str[:-1].rstrip()
                # remove the trailing parenthesis of the PageRoute itself
                if widget_str.endswith(")"):
                    widget_str = widget_str[:-1].strip()
                replacement = f"pushScreen(context, {widget_str})"

        if replacement:
            content = content[:idx] + replacement + content[end_idx:]
            changed = True
        else:
            idx += 1

    return changed, content

lib_dir = '/Users/BURHAN/Desktop/tarim_app/lib'
for root, _, files in os.walk(lib_dir):
    for file in files:
        if file.endswith('.dart'):
            path = os.path.join(root, file)
            with open(path, 'r') as f:
                content = f.read()
            
            was_changed, new_content = replace_navigator_in_content(content)
            if was_changed:
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
