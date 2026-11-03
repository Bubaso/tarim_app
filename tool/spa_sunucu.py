#!/usr/bin/env python3
"""build/web'i SPA olarak sunar — bulunamayan yol index.html'e düşüyor.

`python3 -m http.server` yetmiyor: uygulama yol tabanlı yönlendirme
kullanıyor, yani /haber/<id> adresi diskte bir dosya DEĞİL. Düz sunucu 404
veriyor ve haber sayfası yerel önizlemede hiç açılmıyor.

`firebase serve` de kullanılabilirdi ama o Functions'ı taklit etmeye
çalışıyor ve SSR yolunu araya giriyor; burada sınanmak istenen şey Flutter'ın
kendi çizimi.
"""
import os
import sys
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer

KOK = os.path.join(
    os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "build", "web"
)


class Sunucu(SimpleHTTPRequestHandler):
    def __init__(self, *a, **k):
        super().__init__(*a, directory=KOK, **k)

    def send_head(self):
        yol = self.translate_path(self.path)
        # Uzantısı olmayan ve diskte bulunmayan yol bir SAYFA adresi:
        # index.html'e düşüyor, yönlendirmeyi uygulama yapıyor.
        if not os.path.exists(yol) and "." not in os.path.basename(yol):
            self.path = "/index.html"
        return super().send_head()

    def end_headers(self):
        # Önbellek kapalı: yeni derlemeyi görmek için zorla yenileme
        # gerekmesin.
        self.send_header("Cache-Control", "no-store")
        super().end_headers()

    def log_message(self, *a):
        pass


if __name__ == "__main__":
    port = int(sys.argv[1]) if len(sys.argv) > 1 else int(os.environ.get("PORT", 8131))
    print(f"SPA sunucusu: http://localhost:{port}  kok={KOK}", flush=True)
    ThreadingHTTPServer(("127.0.0.1", port), Sunucu).serve_forever()
