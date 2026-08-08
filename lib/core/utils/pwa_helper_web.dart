import 'dart:html' as html;
import 'dart:js' as js;

bool isStandalone() {
  bool matchMedia = false;
  try {
    matchMedia = html.window.matchMedia('(display-mode: standalone)').matches ||
                 html.window.matchMedia('(display-mode: fullscreen)').matches;
  } catch (_) {}

  bool isIosStandalone = false;
  try {
    final nav = js.context['navigator'];
    if (nav != null && nav.hasProperty('standalone')) {
      isIosStandalone = nav['standalone'] == true;
    }
  } catch (_) {}
  
  return matchMedia || isIosStandalone;
}
