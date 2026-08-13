/// Web dışı platformlarda service worker yok; dinleyici sessizce hiçbir şey
/// yapmaz.
void listenNotificationClicks(
  void Function(String path, String? kind) onClick,
) {}
