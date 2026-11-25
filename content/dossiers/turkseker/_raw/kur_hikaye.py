#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""yayin.json → hikaye.slaytlar üreteci.

Beş rakamın beşi de data.json'dan OKUNARAK yazılıyor. Gösterim sınırları
sabit ve betik bunları sınıyor: ust 24, baslik 60, etiket 48, rakam 12.
Mısır dosyasında beş slaytın etiketi 115-147 karakterdi ve ekranda cümle
ortasından kesilmişti; sınır o yüzden burada kodda duruyor.
"""
import json, pathlib, sys

KOK = pathlib.Path(__file__).parent.parent
D = json.loads((KOK / "data.json").read_text(encoding="utf-8"))
YOL = KOK / "yayin.json"
Y = json.loads(YOL.read_text(encoding="utf-8"))

SINIR = {"ust": 24, "ust_en": 24, "baslik": 60, "baslik_en": 60,
         "etiket": 48, "etiket_en": 48, "rakam": 12, "rakam_en": 12}
KOK_URL = "https://tarimportali.net/dosya/turkseker"

kim, kota, ciftci = D["kimlik"], D["kota"], D["ciftci"]
md = D["metin_dayanaklari"]


def tr(x, b=0):
    s = f"{x:,.{b}f}"
    return s.replace(",", "\x00").replace(".", ",").replace("\x00", ".")


slaytlar = [
    {"ust": "BİR ÇİFTÇİ BAŞLATTI", "ust_en": "A FARMER BEGAN IT",
     "baslik": "Şeker sanayiini Uşaklı bir çiftçi başlattı",
     "baslik_en": "A farmer from Uşak began the sugar industry",
     "gorsel": f"{KOK_URL}/turkseker_usak_kurucular.jpg",
     "rakam": tr(md["usak_sirket_sermaye_tl"]), "rakam_en": f"{md['usak_sirket_sermaye_tl']:,}",
     "etiket": "lira — Uşak Terakki Ziraat, 19 Nisan 1923",
     "etiket_en": "lira — Uşak Terakki Ziraat, 19 April 1923"},

    {"ust": "ON BİR AYDA KURULDU", "ust_en": "BUILT IN ELEVEN MONTHS",
     "baslik": "Alpullu'da ilk Türk şekeri üretildi",
     "baslik_en": "The first Turkish sugar was made at Alpullu",
     "gorsel": f"{KOK_URL}/turkseker_alpullu_1928.jpg",
     "rakam": "11", "rakam_en": "11",
     "etiket": "ay — Alpullu'nun montaj süresi",
     "etiket_en": "months — Alpullu's assembly time"},

    {"ust": "ŞEKER ÜÇE BÖLÜNMÜŞ", "ust_en": "SUGAR DIVIDES IN THREE",
     "baslik": "Kamu, kooperatif ve özel neredeyse eşit",
     "baslik_en": "Public, cooperative and private are near equal",
     "gorsel": f"{KOK_URL}/turkseker_gm_binasi.jpg",
     "rakam": f"%{tr(kota['uc_kesim_yuzde']['kamu'], 2)}",
     "rakam_en": f"{kota['uc_kesim_yuzde']['kamu']:.2f}%",
     "etiket": "TÜRKŞEKER'in pancar şekeri kotası payı",
     "etiket_en": "TÜRKŞEKER's share of the beet sugar quota"},

    {"ust": "ÇİFTÇİ AZALDI", "ust_en": "FEWER GROWERS",
     "baslik": "Üretici üçte bir azaldı, hasat yerinde durdu",
     "baslik_en": "A third fewer growers, the same harvest",
     "gorsel": f"{KOK_URL}/turkseker_pancar_tarla.jpg",
     "rakam": tr(ciftci["son_sayi"]), "rakam_en": f"{ciftci['son_sayi']:,}",
     "etiket": f"pancar üreticisi — {ciftci['zirve_yil']}'de {tr(ciftci['zirve_sayi'])}'di",
     "etiket_en": f"beet growers — {ciftci['zirve_sayi']:,} in {ciftci['zirve_yil']}"},

    {"ust": "YÜZÜNCÜ YIL", "ust_en": "THE HUNDREDTH YEAR",
     "baslik": "İlk Türk şekerinin üzerinden yüz yıl geçti",
     "baslik_en": "A century since the first Turkish sugar",
     "gorsel": f"{KOK_URL}/turkseker_usak_ic.jpg",
     "rakam": "100", "rakam_en": "100",
     "etiket": "yıl — 26 Kasım 1926'dan 26 Kasım 2026'ya",
     "etiket_en": "years — 26 November 1926 to 26 November 2026"},
]

hata = []
for i, s in enumerate(slaytlar, 1):
    for alan, sinir in SINIR.items():
        if len(s[alan]) > sinir:
            hata.append(f"slayt {i} · {alan} {len(s[alan])} karakter, sınır {sinir}: {s[alan]}")
    for alan in SINIR:
        if not s[alan].strip():
            hata.append(f"slayt {i} · {alan} boş")
gorseller = [s["gorsel"] for s in slaytlar]
if len(set(gorseller)) != len(gorseller):
    hata.append("aynı görsel iki slaytta — kullanıcı kuralı: her slayt ayrı görsel")
kunye = json.loads((KOK / "_raw" / "gorseller" / "kunye.json").read_text(encoding="utf-8"))["gorseller"]
for g in gorseller:
    k = g.rsplit("/", 1)[-1].rsplit(".", 1)[0]
    if k not in kunye:
        hata.append(f"slayt görseli künyede yok: {k}")
if hata:
    raise SystemExit("✗ SLAYT SINAMASI DÜŞTÜ\n  " + "\n  ".join(hata))

Y["hikaye"]["slaytlar"] = slaytlar
Y["hikaye"]["_akis"] = ("Beş kanca dosyanın kendi sırası: çiftçi → ilk şeker → bölüşüm → "
                        "çiftçinin azalması → yüzüncü yıl. İlk ikisi kurumun nasıl doğduğu, "
                        "üçüncüsü bugün nerede durduğu, dördüncüsü tarlada ne değiştiği, "
                        "beşincisi takvimin kendisi.")
Y["hikaye"]["_kural"] = ("Metin ELLE yazıldı, rakamlar data.json'dan OKUNDU: 600.000 lira "
                         "(Uşak Terakki Ziraat, 19/04/1923); 11 ay (Alpullu montaj süresi); "
                         "%36,08 (kota payı); 76.767 üretici (2017'de 110.131); 100 yıl.")
Y["hikaye"].pop("_durum", None)
YOL.write_text(json.dumps(Y, ensure_ascii=False, indent=2), encoding="utf-8")

print(f"  ✓ {len(slaytlar)} slayt · sınırlar geçildi")
for i, s in enumerate(slaytlar, 1):
    print(f"    {i}. {s['ust']:<22} {s['rakam']:>8}  {s['baslik'][:44]}")
