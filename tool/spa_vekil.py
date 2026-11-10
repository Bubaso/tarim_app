#!/usr/bin/env python3
"""`flutter run -d web-server` önüne SPA vekili koyar.

NEDEN VAR. Dosya önizlemesi `--dart-define=DOSYA_ONIZLEME=<slug>` ile
açılıyor ve bu bayrak yalnız `flutter run`'a geçirilebiliyor. Ama flutter'ın
kendi web sunucusu YOL TABANLI yönlendirmeyi bilmiyor: `/kurum/tigem` diskte
bir dosya değil ve 404 dönüyor. Dosya sayfası yerel önizlemede hiç açılmıyor.

`tool/spa_sunucu.py` bu işi yapıyor ama `build/web`'i sunuyor, yani önce
`flutter build web --dart-define=...` gerekiyor. O derleme `build/web`'i
önizleme bayrağıyla doldurur ve orada unutulursa bir sonraki dağıtımda
üretime sızar. Bu vekil derleme yapmıyor: flutter'ın çalışan sunucusuna
bağlanıyor, uzantısız ve bulunamayan yolları `/index.html`e düşürüyor.

Kullanım:
    flutter run -d web-server --web-port=8137 --dart-define=DOSYA_ONIZLEME=tigem
    python3 tool/spa_vekil.py 8139 8137     # vekil portu, flutter portu
"""
import sys
import urllib.error
import urllib.request
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

VEKIL = int(sys.argv[1]) if len(sys.argv) > 1 else 8139
HEDEF = int(sys.argv[2]) if len(sys.argv) > 2 else 8137


class Vekil(BaseHTTPRequestHandler):
    protocol_version = "HTTP/1.1"

    def do_GET(self):  # noqa: N802
        yol = self.path
        son = yol.split("?")[0].rsplit("/", 1)[-1]
        gelen = self._cek(yol)
        # Uzantısız ve bulunamayan yol bir SAYFA adresi: index.html'e düşer,
        # yönlendirmeyi uygulama yapar.
        if gelen is None and "." not in son:
            gelen = self._cek("/index.html")
        if gelen is None:
            self.send_error(404)
            return
        govde, tip = gelen
        self.send_response(200)
        self.send_header("Content-Type", tip)
        self.send_header("Content-Length", str(len(govde)))
        self.send_header("Cache-Control", "no-store")
        self.end_headers()
        self.wfile.write(govde)

    def _cek(self, yol):
        try:
            with urllib.request.urlopen(f"http://127.0.0.1:{HEDEF}{yol}", timeout=30) as r:
                return r.read(), r.headers.get("Content-Type", "application/octet-stream")
        except (urllib.error.HTTPError, urllib.error.URLError, OSError):
            return None

    def log_message(self, *a):
        pass


print(f"SPA vekili :{VEKIL} → flutter :{HEDEF}")
ThreadingHTTPServer(("127.0.0.1", VEKIL), Vekil).serve_forever()
