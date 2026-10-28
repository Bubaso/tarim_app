#!/usr/bin/env python3
"""Haber görsellerini WebP'ye çevirir ve eski dosyayı siler.

    python3 compress_images.py            # kuru çalışma: ne yapacağını yazar
    python3 compress_images.py --apply    # gerçekten dönüştürür
    python3 compress_images.py --apply --limit 200   # partiyi sınırla

Ölçüm (28 Ekim 2026): `article-images` 1.317 MB. Kullanılan dosyalardan
1.988'i `.jpg` (454 MB, ortalama 228 KB), 935'i `.webp` (71 MB, ortalama
76 KB). Yani kalan jpg'leri çevirmek ~250 MB kazandırıyor ve Free planın
1 GB sınırının altına inmeyi tek başına sağlıyor.

--------------------------------------------------------------------------
ÖNCEKİ sürümün iki hatası (ikisi de burada kapatıldı):

1. `.select()` LİMİTSİZDİ → PostgREST en çok 1.000 satır döndürüyor.
   1.080 webp'ye karşı 5.751 jpg kalmasının sebebi büyük olasılıkla bu:
   betik ilk 1.000 haberi işleyip "bitti" demiş.

2. `story_image_url` GÜNCELLENMİYORDU. Aynı dosyaya iki alan işaret
   edebiliyor; betik yalnızca `image_url`i güncelleyip eski dosyayı silince
   `story_image_url` ÖLÜ ADRESE düşüyordu. Artık dönüştürülen her yol için
   ona işaret eden BÜTÜN satır/alan çiftleri güncelleniyor, dosya ancak
   ondan sonra siliniyor.
"""
import io
import os
import sys
import urllib.parse

import requests
from PIL import Image

sys.path.append(os.environ.get("TARIM_PIPELINE",
                               "/Users/BURHAN/Desktop/tarim_ai_pipeline"))
from src.config import supabase_client as supabase  # noqa: E402

BUCKET = "article-images"
ALANLAR = ("image_url", "story_image_url")
SAYFA = 1000

# Haber okuma oluğu 800 px (CLAUDE.md §4); yüksek yoğunluklu ekran için iki
# katı. Önceki sürüm 1000 px'e indiriyordu — görsel dönüştürme uç noktası
# AÇIKKEN sorun değildi, çünkü sunucu istenen boyutu üretiyordu. Dönüştürme
# Free planda kapalı (bkz. image_fallback_helper.dart) ve artık ham dosya
# gösteriliyor; 1000 px masaüstü manşette gözle görülür yumuşama yapar.
EN_FAZLA = int(os.environ.get("WEBP_GENISLIK", "1600"))
KALITE = int(os.environ.get("WEBP_KALITE", "80"))


def yol(u):
    if not u:
        return None
    u = u.split("?")[0]
    m = f"/{BUCKET}/"
    return urllib.parse.unquote(u.split(m, 1)[1]) if m in u else None


def haberleri_oku():
    """id + adres alanlarını sayfalayarak okur, sayı sağlamasıyla."""
    sayim = supabase.table("articles").select("id", count="exact") \
        .limit(1).execute().count
    satirlar, off = [], 0
    while True:
        res = supabase.table("articles").select("id," + ",".join(ALANLAR)) \
            .range(off, off + SAYFA - 1).execute()
        if not res.data:
            break
        satirlar += res.data
        if len(res.data) < SAYFA:
            break
        off += SAYFA
    print(f"Tablo sayımı: {sayim} · okunan: {len(satirlar)}")
    if sayim is not None and len(satirlar) != sayim:
        sys.exit(f"✗ DURDU: {sayim} satır var, {len(satirlar)} okundu. "
                 f"Eksik okumayla dosya silinmez.")
    return satirlar


def main(uygula, limit):
    satirlar = haberleri_oku()

    # yol → o yola işaret eden (haber id, alan) çiftleri
    kullanim = {}
    for r in satirlar:
        for alan in ALANLAR:
            p = yol(r.get(alan))
            if p:
                kullanim.setdefault(p, []).append((r["id"], alan))

    hedefler = [p for p in kullanim
                if p.lower().endswith((".jpg", ".jpeg", ".png"))]
    hedefler.sort()
    if limit:
        hedefler = hedefler[:limit]
    print(f"Dönüştürülecek dosya: {len(hedefler)}")
    if not uygula:
        print("KURU ÇALIŞMA — dönüştürme yok. Uygulamak için: --apply\n")

    onceki = sonraki = 0
    for i, p in enumerate(hedefler, 1):
        yeni_yol = p.rsplit(".", 1)[0] + ".webp"
        ham = supabase.storage.from_(BUCKET).get_public_url(p).split("?")[0]
        try:
            r = requests.get(ham, timeout=60)
            if r.status_code != 200:
                print(f"[{i}/{len(hedefler)}] ✗ indirilemedi ({r.status_code}) {p}")
                continue
            with Image.open(io.BytesIO(r.content)) as img:
                if img.width > EN_FAZLA or img.height > EN_FAZLA:
                    img.thumbnail((EN_FAZLA, EN_FAZLA))
                if img.mode not in ("RGB", "RGBA"):
                    img = img.convert("RGB")
                tampon = io.BytesIO()
                img.save(tampon, "WEBP", quality=KALITE, method=6)
            yeni = tampon.getvalue()
        except Exception as e:
            print(f"[{i}/{len(hedefler)}] ✗ çevrilemedi {p}: {e}")
            continue

        # Yeniden kodlama KAZANÇ sağlamıyorsa dokunmuyoruz. Dosya görsel
        # hattında bir kez büyütülmüştü (CLAUDE.md §22.1): zaten ekonomik
        # sıkıştırılmış dosyalarda q80 webp daha büyük çıkabiliyor.
        if len(yeni) >= len(r.content):
            print(f"[{i}/{len(hedefler)}] = atlandı, küçülmüyor "
                  f"({len(r.content)/1e3:.0f} → {len(yeni)/1e3:.0f} KB) {p}")
            continue

        onceki += len(r.content)
        sonraki += len(yeni)
        print(f"[{i}/{len(hedefler)}] {len(r.content)/1e3:6.0f} → "
              f"{len(yeni)/1e3:6.0f} KB  {p}")
        if not uygula:
            continue

        supabase.storage.from_(BUCKET).upload(
            file=yeni, path=yeni_yol,
            file_options={"content-type": "image/webp", "upsert": "true"})
        yeni_adres = supabase.storage.from_(BUCKET).get_public_url(yeni_yol) \
            .split("?")[0]

        # ÖNCE bütün referanslar, SONRA silme. Ters sırada tek bir alan
        # güncellenmemiş kalsa o alan ölü adrese düşerdi.
        for hid, alan in kullanim[p]:
            supabase.table("articles").update({alan: yeni_adres}) \
                .eq("id", hid).execute()
        supabase.storage.from_(BUCKET).remove([p])

    print(f"\n=== {onceki/1e6:.1f} MB → {sonraki/1e6:.1f} MB "
          f"(kazanç {(onceki-sonraki)/1e6:.1f} MB) ===")
    if not uygula:
        print("KURU ÇALIŞMA — hiçbir şey değişmedi.")


if __name__ == "__main__":
    lim = 0
    if "--limit" in sys.argv:
        lim = int(sys.argv[sys.argv.index("--limit") + 1])
    main("--apply" in sys.argv, lim)
