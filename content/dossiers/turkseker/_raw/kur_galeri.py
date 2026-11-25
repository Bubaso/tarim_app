#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""galeri_kunye.json + galeri_altyazilar.json → _raw/galeri.json.

build_data.py bunu okuyup data.json'un `galeri` bloğuna koyuyor. Doğrudan
data.json'a yazmıyor: data.json'un TEK yazarı build_data.py ve on altı
tutarlılık sınaması orada; ikinci bir yazar o sınamaları atlatırdı.

Alan adları bölüm görseliyle AYNI (`url`, `atif`, `lisans`, `alt_tr`,
`alt_en`): istemci tarafında galeri kareleri de `DossierGorsel` ile
çözülüyor, ayrı bir kap yok.
"""
import json, pathlib
from PIL import Image

RAW = pathlib.Path(__file__).parent
KUNYE = json.loads((RAW / "gorseller" / "galeri_kunye.json").read_text(encoding="utf-8"))["kareler"]
ALT = json.loads((RAW / "galeri_altyazilar.json").read_text(encoding="utf-8"))
SECIM = json.loads((RAW / "galeri_secim.json").read_text(encoding="utf-8"))

KOK_URL = "https://tarimportali.net/dosya/turkseker"

# Galerinin AKIŞI. Öbek sırası bir yayın kararı ve şekerin kendi yolunu
# izliyor: başladığı yer → geçmişi → tarla → onu kaldıran eller → hasat →
# fabrikaya taşınması → fabrikalar → kurumun kendi makinesini yaptığı yer →
# çıkan şeker → fabrikanın çevresinde kurulan hayat.
#
# Yıkım kareleri (cevresi) sondaki öbekte duruyor ama öbeğin kendisi
# mahalleyle açılıyor: sonda duran kare galeriye kapanış sözü söyletir ve
# §8.2 bu dosyaya yargı değil tanıtım diyor.
# ÇİFTÇİ 24 Kasım 2026'da eklendi: kullanıcı bu yönü adıyla istedi ve
# mevcut öbeklerin hiçbirine oturmuyordu — tarla toprağı, isci fabrikayı
# anlatıyor. Akışta tarlanın hemen ardında: toprak → onu eken insan →
# fabrikadaki el.
OBEK_SIRASI = ["alpullu", "tarih", "tarla", "ciftci", "isci", "hasat",
               "yukleme", "fabrikalar", "fabrika_ici", "kendi_makinesi",
               "urun", "cevresi"]

kareler, hata = [], []

# ASIL KAYNAK SEÇİM, KÜNYE DEĞİL. Döngü önce künye dosyasını geziyordu ve
# seçimden bir kare çıkarıldığında künyede kalan satır KeyError veriyordu:
# künye indirmenin çıktısı, galerinin tanımı değil. Seçimden düşen kare
# burada da düşüyor; künyesi diskte kalsa bile galeriye girmiyor.
sira = {k["kimlik"]: i for i, k in enumerate(SECIM["kareler"])}
secili = [k["kimlik"] for k in SECIM["kareler"]]

# PARTİ, ÖBEKTEN ÖNCE GELİYOR. Kullanıcı 24 Kasım 2026'da ikinci partiyi
# "şuanki son resimden (79) sonra" istedi. Öbek sırası tek ölçüt kalsaydı
# yeni kareler eski öbeklerin ARASINA girer ve galerinin gözden geçirilmiş
# ilk yarısı dağılırdı.
parti = {k["kimlik"]: k.get("parti", 1) for k in SECIM["kareler"]}
eksik = [k for k in secili if k not in KUNYE]
if eksik:
    raise SystemExit("✗ künyesi olmayan kare (galeri_indir.py koşmalı): "
                     + ", ".join(eksik))

for kimlik in sorted(secili, key=lambda k: (parti[k],
                                            OBEK_SIRASI.index(KUNYE[k]["obek"]),
                                            sira[k])):
    k = KUNYE[kimlik]
    a = ALT.get(kimlik)
    if not a:
        hata.append(f"{kimlik}: altyazı yok")
        continue
    atif = (k["atif"] or "").strip()
    lis = (k["lisans"] or "").strip()
    # Atıf biçimi "Üreten — Lisans".
    #
    # TEKRAR İKİ YÖNLÜ OLABİLİYOR. Koşul önce yalnız "lisans atıfın içinde mi"
    # diye bakıyordu; kurum karelerinde TERSİ geçerli — atıf
    # "Türkiye Şeker Fabrikaları A.Ş.", lisans ise "Türkiye Şeker Fabrikaları
    # A.Ş. — kurumun kendi yayını". Önizlemede satır kurum adını iki kez
    # yazdı. Artık hangi taraf ötekini içeriyorsa UZUN OLAN kalıyor.
    if lis:
        if atif.lower() in lis.lower():
            atif = lis
        elif lis.lower() not in atif.lower():
            atif = f"{atif} — {lis}"
    dosya = RAW / "gorseller" / k["dosya"]
    with Image.open(dosya) as im:
        g, y = im.size
    kareler.append({
        "url": f"{KOK_URL}/{k['dosya']}",
        # Izgara boyu kopya. Asıl dosya tam ekran için duruyor; ızgara
        # 173 gözde 1600 px indirmiyor (kur_yayin_gorselleri.py üretiyor).
        "kucuk": f"{KOK_URL}/k/{k['dosya']}",
        "atif": atif,
        "lisans": lis,
        "alt_tr": a["tr"],
        "alt_en": a["en"],
        "en_boy": round(g / y, 4),
        "kaynak": k["sayfa"],
        "_kimlik": kimlik,
        "_obek": k["obek"],
        "_kaynak_turu": k["kaynak_turu"],
        "_dayanak": a["_dayanak"],
    })

if hata:
    raise SystemExit("✗ " + "\n  ".join(hata))

cikti = {
    "_amac": "Dosya sonundaki kare galerisi. Bölüm görselleri yerinde duruyor; "
             "bunlar onların dışında, sonradan bulunan kareler.",
    "_kural": "Atıfsız kare yayımlanmıyor (§2.4). Atıf ızgarada açıkta, "
              "dokunuşun ardında değil.",
    "_kaynaklar": "İki kaynak: Wikimedia Commons (atıf ve lisans API'den) ve "
                  "turkseker.gov.tr (kurumun kendi yayını; kullanıcı "
                  "23 Kasım 2026'da yetkilendirdi).",
    "baslik_tr": "Yüzüncü yıl galerisi",
    "baslik_en": "The centenary gallery",
    "kareler": kareler,
}
(RAW / "galeri.json").write_text(json.dumps(cikti, ensure_ascii=False, indent=2),
                                 encoding="utf-8")

from collections import Counter
ob = Counter(k["_obek"] for k in kareler)
pa = Counter(parti[k["_kimlik"]] for k in kareler)
kt = Counter(k["_kaynak_turu"] for k in kareler)
li = Counter(k["lisans"] for k in kareler)
print(f"  ✓ {len(kareler)} kare · galeri.json yazıldı")
print("  parti:   " + " · ".join(f"{a} → {b} kare" for a, b in sorted(pa.items())))
print("  öbekler: " + " · ".join(f"{o} {ob[o]}" for o in OBEK_SIRASI))
print("  kaynak:  " + " · ".join(f"{a} {b}" for a, b in kt.items()))
print("  lisans:  " + " · ".join(f"{a[:34]} {b}" for a, b in sorted(li.items())))
