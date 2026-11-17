#!/usr/bin/env python3
"""
Yapay Zeka ve Dijital Tarım — görseli indirir, WebP'ye çevirir (karar 58).

    ~/tarim_ai_pipeline/venv/bin/python -I gorsel_al.py <kimlik> <gorsel_adresi> [en_genis]

Görsel geçici, boş bir klasöre indirilir (yalnız GET, genel bir tarayıcı
kimliği; kullanıcının ya da sitenin adı gitmez). robots.txt adresi
yasaklıyorsa ya da yanıt görsel değilse DURUR; oturum, captcha, bot
koruması aşılmaz. Görsel en çok `en_genis` (varsayılan 1600) piksel
genişliğe küçültülüp `web/yz/gorsel/<kimlik>.webp` olarak yazılır; çıktı,
`gorseller.json`'a eklenecek alanları JSON olarak basar (dosya, en/boy,
sha256, indirme günü). Künye ve kaynak satırını kayda elle yazmak gerekiyor.
"""
import hashlib
import io
import json
import sys
import tempfile
import urllib.request
import urllib.robotparser
from datetime import date
from pathlib import Path
from urllib.parse import urlparse

from PIL import Image

UA = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120 Safari/537.36"
EN_BUYUK_BAYT = 25_000_000
DEPO = Path(__file__).resolve().parents[3]
HEDEF = DEPO / "web" / "yz" / "gorsel"


def robots_izin(adres: str) -> bool:
    u = urlparse(adres)
    rp = urllib.robotparser.RobotFileParser()
    rp.set_url(f"{u.scheme}://{u.netloc}/robots.txt")
    try:
        rp.read()
    except Exception:
        return True                      # robots.txt okunamıyorsa yasak yok sayılır
    return rp.can_fetch("*", adres)


def main() -> int:
    if len(sys.argv) < 3:
        print(__doc__)
        return 2
    kimlik, adres = sys.argv[1], sys.argv[2]
    en_genis = int(sys.argv[3]) if len(sys.argv) > 3 else 1600
    if not adres.startswith("https://") and not adres.startswith("http://"):
        print("✗ adres http(s) değil"); return 1
    if not robots_izin(adres):
        print("✗ robots.txt bu adresi yasaklıyor — alınmadı"); return 1
    istek = urllib.request.Request(adres, headers={"User-Agent": UA, "Accept": "image/*"})
    with tempfile.TemporaryDirectory(prefix="yz_gorsel_") as klasor:
        with urllib.request.urlopen(istek, timeout=40) as y:
            tur = y.headers.get("Content-Type", "")
            govde = y.read(EN_BUYUK_BAYT + 1)
        if len(govde) > EN_BUYUK_BAYT:
            print("✗ dosya çok büyük"); return 1
        if not tur.startswith("image/"):
            print(f"✗ yanıt görsel değil ({tur})"); return 1
        ham = Path(klasor) / "ham"
        ham.write_bytes(govde)
        Image.MAX_IMAGE_PIXELS = 80_000_000
        with Image.open(ham) as g:
            g.load()
            g = g.convert("RGBA" if g.mode in ("RGBA", "LA", "P") else "RGB")
            if g.width > en_genis:
                g = g.resize((en_genis, round(g.height * en_genis / g.width)), Image.LANCZOS)
            HEDEF.mkdir(parents=True, exist_ok=True)
            cikis = HEDEF / f"{kimlik}.webp"
            tampon = io.BytesIO()
            g.save(tampon, "WEBP", quality=82, method=6)
            cikis.write_bytes(tampon.getvalue())
            print(json.dumps({
                "dosya": str(cikis.relative_to(DEPO)),
                "genislik": g.width, "yukseklik": g.height,
                "sha256": hashlib.sha256(tampon.getvalue()).hexdigest(),
                "gorsel_adresi": adres, "indirme_gunu": date.today().isoformat(),
                "bayt": len(tampon.getvalue()),
            }, ensure_ascii=False))
    return 0


if __name__ == "__main__":
    sys.exit(main())
