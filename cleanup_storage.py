#!/usr/bin/env python3
"""Supabase Storage'daki yetim dosyaları temizler.

Yetim = hiçbir `articles` satırının işaret etmediği dosya.

VARSAYILAN DAVRANIŞ KURU ÇALIŞMA. Üretim verisinde geri alınamaz silme yapan
bir betiğin ilk davranışı silmek olmamalı:

    python3 cleanup_storage.py            # yalnızca raporlar, hiçbir şey silmez
    python3 cleanup_storage.py --apply    # gerçekten siler

--------------------------------------------------------------------------
Bu betiğin ÖNCEKİ sürümü canlı görselleri silerdi. Üç hata vardı (28 Ekim
2026'da ölçüldü), üçü de burada kapatıldı:

1. `story_image_url` HİÇ OKUNMUYORDU — yalnızca `audio_url, image_url`.
   Ölçüm: 1.274 dosya (351,9 MB) yalnızca `story_image_url`'de geçiyor.
   Hepsi "yetim" sayılıp silinecekti.

2. `.select()` LİMİTSİZ çağrılıyordu. PostgREST limitsiz sorguda en çok
   1.000 satır döndürüyor; o gün tabloda 1.698 satır vardı, yani 698 haber
   hiç görülmeyecek ve onların görselleri de yetim sayılacaktı.

3. Storage `list()` SAYFALANMIYORDU (varsayılan 100). Kök dizinde 6.868
   dosya var; betik 100 tanesine bakıp "tamam" diyordu.

2. maddenin tekrarlamaması için aşağıda SAYI SAĞLAMASI var: okunan satır
sayısı tablonun gerçek sayımıyla uyuşmazsa betik SİLMEZ, durur. Eksik
okunmuş bir referans listesiyle silme yapmak, hiç silmemekten beterdir.
"""
import os
import sys

sys.path.append(os.environ.get("TARIM_PIPELINE",
                               "/Users/BURHAN/Desktop/tarim_ai_pipeline"))
from src.config import supabase_client as supabase  # noqa: E402

BUCKETS = ("article-audios", "article-images")
# Haber kaydında dosya adresi taşıyan BÜTÜN alanlar. Buraya yeni bir alan
# eklenirse (örn. bir kapak varyantı) listeye de eklenmeli; eksik bırakılan
# her alan, o alandaki dosyaların yetim sanılması demek.
URL_ALANLARI = ("audio_url", "image_url", "story_image_url")
SAYFA = 1000


def db_adresleri():
    """Tablodaki bütün dosya adreslerini sayfalayarak toplar."""
    sayim = supabase.table("articles").select("id", count="exact") \
        .limit(1).execute().count
    adresler, satir, off = set(), 0, 0
    while True:
        res = supabase.table("articles").select(",".join(URL_ALANLARI)) \
            .range(off, off + SAYFA - 1).execute()
        if not res.data:
            break
        for row in res.data:
            for alan in URL_ALANLARI:
                u = row.get(alan)
                if u:
                    adresler.add(u.split("?")[0])
        satir += len(res.data)
        if len(res.data) < SAYFA:
            break
        off += SAYFA

    print(f"Tablo sayımı: {sayim} satır · okunan: {satir} satır")
    if sayim is not None and satir != sayim:
        sys.exit(f"✗ DURDU: {sayim} satır var, {satir} okundu. Eksik bir "
                 f"referans listesiyle silme yapılmaz.")
    print(f"Referanslanan tekil adres: {len(adresler)}")
    return adresler


def bucket_dosyalari(bucket, prefix="", derinlik=0):
    """Bucket'ı sayfalayarak ve klasörlere inerek gezer."""
    cikti, off = [], 0
    while True:
        items = supabase.storage.from_(bucket).list(
            prefix, {"limit": SAYFA, "offset": off,
                     "sortBy": {"column": "name", "order": "asc"}})
        if not items:
            break
        for it in items:
            ad = f"{prefix}/{it['name']}" if prefix else it["name"]
            if it.get("id") is None and it.get("metadata") is None:
                # klasör — içine in (çok derin ağaç beklenmiyor)
                if derinlik < 3:
                    cikti += bucket_dosyalari(bucket, ad, derinlik + 1)
            else:
                if it["name"] == ".emptyFolderPlaceholder":
                    continue
                cikti.append((ad, (it.get("metadata") or {}).get("size") or 0))
        if len(items) < SAYFA:
            break
        off += SAYFA
    return cikti


def main(uygula):
    adresler = db_adresleri()
    toplam_yetim = toplam_boyut = 0

    for bucket in BUCKETS:
        dosyalar = bucket_dosyalari(bucket)
        yetim = []
        for yol, boyut in dosyalar:
            acik = supabase.storage.from_(bucket).get_public_url(yol).split("?")[0]
            if acik not in adresler:
                yetim.append((yol, boyut))

        boy = sum(b for _, b in yetim)
        print(f"\n### {bucket}: {len(dosyalar)} dosya · "
              f"{len(yetim)} yetim · {boy / 1e6:.1f} MB")
        for yol, b in sorted(yetim, key=lambda kv: -kv[1])[:10]:
            print(f"    {b / 1e6:7.2f} MB  {yol}")
        if len(yetim) > 10:
            print(f"    … ve {len(yetim) - 10} dosya daha")

        toplam_yetim += len(yetim)
        toplam_boyut += boy

        if uygula and yetim:
            yollar = [y for y, _ in yetim]
            for i in range(0, len(yollar), 100):
                supabase.storage.from_(bucket).remove(yollar[i:i + 100])
            print(f"    ✓ {len(yollar)} dosya silindi")

    print(f"\n=== {toplam_yetim} yetim dosya · {toplam_boyut / 1e6:.1f} MB ===")
    if not uygula:
        print("KURU ÇALIŞMA — hiçbir şey silinmedi. Silmek için: --apply")


if __name__ == "__main__":
    main("--apply" in sys.argv)
