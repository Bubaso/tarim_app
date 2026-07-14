import re

with open('lib/core/utils/fade_page_route.dart', 'r') as f:
    fade_content = f.read()

# Replace pushScreen
fade_content = fade_content.replace(
    "Navigator.of(context).pushNamed<T>(",
    "// Navigator.of(context).pushNamed<T>("
)

fade_content = fade_content.replace(
    "'/${page.runtimeType.toString()}',",
    "// '/${page.runtimeType.toString()}',"
)

fade_content = fade_content.replace(
    "arguments: page,",
    "// arguments: page,"
)

fade_content = fade_content.replace(
    "  );",
    """  );
  if (page is Widget) {
     GoRouter.of(context).push<T>('/page/${page.runtimeType.toString()}', extra: page);
     return Future.value(null);
  }
  return Future.value(null);"""
)

# Replace pushReplacementScreen
fade_content = fade_content.replace(
    "Navigator.of(context).pushReplacementNamed<T, TO>(",
    "// Navigator.of(context).pushReplacementNamed<T, TO>("
)

fade_content = fade_content.replace(
    "result: result,",
    "// result: result,"
)

fade_content = fade_content.replace(
    "  );",
    """  );
  if (page is Widget) {
     GoRouter.of(context).pushReplacement('/page/${page.runtimeType.toString()}', extra: page);
     return Future.value(null);
  }
  return Future.value(null);"""
)

# Add import
if "import 'package:go_router/go_router.dart';" not in fade_content:
    fade_content = "import 'package:go_router/go_router.dart';\n" + fade_content

with open('lib/core/utils/fade_page_route.dart', 'w') as f:
    f.write(fade_content)

print("Modified fade_page_route.dart")
