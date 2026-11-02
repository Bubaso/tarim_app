#!/usr/bin/env python3
"""web/dosya/ altındaki dosya görsellerini yayın boyutuna indirir.

YENİDEN YAZILDI (1 Kasım 2026). Özgün betik 4 Ekim 2026'daki kayıpta gitti;
hiç commit edilmemişti (§40.5'teki desenin aynısı). Buradaki değerler ve
davranış CLAUDE.md §22.1'in tarifinden kurulmuştur:

  - 1440 px uzun kenar — okuma oluğunun (720 px, §4) iki katı
  - JPEG kalite 78, `optimize` + `progressive`
  - format JPEG KALIR: WebP 1440 px'te üstünlük sağlamıyor ve uzantı
    değişikliği yayin.json / cover_url / dossier_sections.gorsel /
    portal_stories.gorsel_url içindeki bütün adresleri kırardı.

ÖZGÜN BETİĞİN HATASI VE DÜZELTMESİ DE TARİFTE YAZILI, burada baştan var:
ilk sürüm zaten küçük olan üç görseli BÜYÜTMÜŞTÜ — kaynak sıkıştırması
q78'den ekonomik olduğunda yeniden kodlama zarar veriyor, ve toplamda kazanç
göründüğü için fark edilmiyordu. Bu yüzden çıktı önce belleğe yazılıyor,
diske yalnızca GERÇEKTEN küçüldüyse geçiyor. Betik tekrar çalıştırıldığında
hiçbir şeyi bozmaz.

Kullanım:
    python3 scripts/dosya_gorsel_optimize.py            # web/dosya/ tamamı
    python3 scripts/dosya_gorsel_optimize.py dsi        # tek dosya klasörü
"""

from __future__ import annotations

import io
import sys
from pathlib import Path

from PIL import Image, ImageOps

KOK = Path(__file__).resolve().parent.parent / "web" / "dosya"
UZUN_KENAR = 1440
KALITE = 78


def optimize(yol: Path) -> tuple[int, int, str]:
    """(önceki bayt, sonraki bayt, not) döndürür. Diske yalnızca küçüldüyse yazar."""
    onceki = yol.stat().st_size

    with Image.open(yol) as im:
        # EXIF YÖNELİMİ PİKSELE İŞLENİYOR — yoksa sessizce TERS yayınlanır.
        # Pillow, Image.open'da yönelimi UYGULAMAZ; bilgi yalnız etikette
        # durur. Yeniden kodlarken etiket düşer, pikseller olduğu gibi kalır
        # ve görsel 180 derece dönük yayına çıkar. Irak dosyasında bir hurma
        # bahçesi fotoğrafı Orientation=3 ile geldi; yayındaki görsellerin
        # tamamı tarandı, hiçbirinde yönelim yoktu, yani ilk kurban o
        # olacaktı (2 Kasım 2026).
        im = ImageOps.exif_transpose(im) or im
        im = im.convert("RGB")
        g, y = im.size
        if max(g, y) > UZUN_KENAR:
            if g >= y:
                yeni = (UZUN_KENAR, round(y * UZUN_KENAR / g))
            else:
                yeni = (round(g * UZUN_KENAR / y), UZUN_KENAR)
            im = im.resize(yeni, Image.LANCZOS)

        tampon = io.BytesIO()
        im.save(tampon, "JPEG", quality=KALITE, optimize=True, progressive=True)

    sonraki = tampon.tell()
    if sonraki >= onceki:
        # Kaynak zaten daha ekonomik. Dokunmak zarar verir (bkz. başlık).
        return onceki, onceki, "dokunulmadı"

    yol.write_bytes(tampon.getvalue())
    return onceki, sonraki, "küçültüldü"


def main() -> int:
    hedef = KOK / sys.argv[1] if len(sys.argv) > 1 else KOK
    if not hedef.exists():
        print(f"YOK: {hedef}")
        return 1

    dosyalar = sorted(
        p for p in hedef.rglob("*") if p.suffix.lower() in {".jpg", ".jpeg"}
    )
    if not dosyalar:
        print(f"Görsel bulunamadı: {hedef}")
        return 1

    top_once = top_sonra = 0
    for p in dosyalar:
        once, sonra, not_ = optimize(p)
        top_once += once
        top_sonra += sonra
        with Image.open(p) as im:
            g, y = im.size
        print(f"  {p.relative_to(KOK)}  {once/1024:7.0f} KB → {sonra/1024:7.0f} KB"
              f"  {g}×{y}  {not_}")

    kazanc = 100 * (1 - top_sonra / top_once) if top_once else 0
    print(f"\nTOPLAM  {top_once/1024/1024:.2f} MB → {top_sonra/1024/1024:.2f} MB"
          f"  (%{kazanc:.1f})")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
