#!/usr/bin/env python3
"""
Yapay Zeka ve Dijital Tarım — PDF içindeki bir şekli kırpıp WebP yapar (karar 58).

    ~/tarim_ai_pipeline/venv/bin/python -I gorsel_kirp.py <kimlik> <pdf yolu ya da adresi> <sayfa> <x0,y0,x1,y1>

Ayrı görsel dosyası olmayan şekiller (makale PDF'inin içinde) için:
sayfa `pdf_sayfa.swift` ile (macOS PDFKit) yüksek çözünürlükte çizilir,
kutu (sayfa boyunun 0-1 kesirleri) kırpılır, en çok 1600 piksel genişliğe
küçültülüp `web/yz/gorsel/<kimlik>.webp` olarak yazılır. Şeklin kendisine
dokunulmaz (yalnız kırpma ve boyut). Adres verilirse PDF geçici, boş bir
klasöre indirilir (robots.txt'ye uyulur, genel tarayıcı kimliği; oturum ya
da bot koruması aşılmaz). Çıktı gorsel_al.py'ninkiyle aynı JSON.
"""
import hashlib
import io
import json
import subprocess
import sys
import tempfile
import urllib.request
from datetime import date
from pathlib import Path

from PIL import Image

UA = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120 Safari/537.36"
BURASI = Path(__file__).resolve().parent
DEPO = BURASI.parents[2]
HEDEF = DEPO / "web" / "yz" / "gorsel"
EN_BUYUK_BAYT = 40_000_000


def main() -> int:
    if len(sys.argv) != 5:
        print(__doc__)
        return 2
    kimlik, kaynak, sayfa = sys.argv[1], sys.argv[2], int(sys.argv[3])
    kutu = [float(x) for x in sys.argv[4].split(",")]
    with tempfile.TemporaryDirectory(prefix="yz_pdf_") as klasor:
        if kaynak.startswith("https://") or kaynak.startswith("http://"):
            import importlib.util
            sp = importlib.util.spec_from_file_location("gorsel_al", BURASI / "gorsel_al.py")
            ga = importlib.util.module_from_spec(sp)
            sp.loader.exec_module(ga)
            if not ga.robots_izin(kaynak):
                print("✗ robots.txt bu adresi yasaklıyor ya da okunamadı — alınmadı"); return 1
            istek = urllib.request.Request(kaynak, headers={"User-Agent": UA, "Accept": "application/pdf"})
            with urllib.request.urlopen(istek, timeout=60) as y:
                govde = y.read(EN_BUYUK_BAYT + 1)
            if len(govde) > EN_BUYUK_BAYT or not govde.startswith(b"%PDF"):
                print("✗ yanıt PDF değil ya da çok büyük"); return 1
            pdf = Path(klasor) / "belge.pdf"
            pdf.write_bytes(govde)
        else:
            pdf = Path(kaynak)
        png = Path(klasor) / "sayfa.png"
        c = subprocess.run(["swift", str(BURASI / "pdf_sayfa.swift"), str(pdf), str(sayfa), "2800", str(png)],
                           capture_output=True, text=True, timeout=300)
        if c.returncode != 0 or not png.exists():
            print(f"✗ sayfa çizilemedi: {c.stderr.strip()[:200]}"); return 1
        with Image.open(png) as g:
            g.load()
            w, h = g.size
            g = g.crop((round(kutu[0] * w), round(kutu[1] * h), round(kutu[2] * w), round(kutu[3] * h))).convert("RGB")
            if g.width > 1600:
                g = g.resize((1600, round(g.height * 1600 / g.width)), Image.LANCZOS)
            tampon = io.BytesIO()
            g.save(tampon, "WEBP", quality=85, method=6)
            HEDEF.mkdir(parents=True, exist_ok=True)
            cikis = HEDEF / f"{kimlik}.webp"
            cikis.write_bytes(tampon.getvalue())
            print(json.dumps({
                "dosya": str(cikis.relative_to(DEPO)),
                "genislik": g.width, "yukseklik": g.height,
                "sha256": hashlib.sha256(tampon.getvalue()).hexdigest(),
                "gorsel_adresi": kaynak if kaynak.startswith("http") else "",
                "indirme_gunu": date.today().isoformat(),
                "bayt": len(tampon.getvalue()),
            }, ensure_ascii=False))
    return 0


if __name__ == "__main__":
    sys.exit(main())
