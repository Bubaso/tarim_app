import 'dart:html' as html;

bool isStandalone() {
  // Check standard display-mode: standalone
  final matchMedia = html.window.matchMedia('(display-mode: standalone)').matches;
  // Check legacy iOS web app capable status
  // Wait, html.window.navigator doesn't have 'standalone' property exposed typed in dart:html.
  // We can use JS interop or simply cast it to dynamic to access it.
  final dynamic nav = html.window.navigator;
  bool isIosStandalone = false;
  try {
    isIosStandalone = nav.standalone == true;
  } catch (_) {}
  
  return matchMedia || isIosStandalone;
}
