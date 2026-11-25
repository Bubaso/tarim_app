#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Şeker sanayiinin zaman çizelgesi.

TASARIM KARARI: düzyazıdan kalıpla tarih çekmek yerine çizelge ELLE
kuruldu, ama her madde kendi DAYANAK cümlesini taşıyor ve betik o
cümlenin kaynak metinde birebir durduğunu sınıyor. Böylece uydurma
tarih çizelgeye giremez: dayanağı tutmayan madde betiği düşürür.
Kaynak metindeki satır kırıkları ve PDF'ten gelen çift boşluklar
karşılaştırmadan önce tek boşluğa indiriliyor.
"""
import json, pathlib, re, unicodedata

KOK = pathlib.Path(__file__).parent
KAYNAK = {
    "sektor": KOK / "kaynak_dosyalari" / "sektor_raporu_2025.txt",
    "plan":   KOK / "kaynak_dosyalari" / "stratejik_plan_2024.txt",
}


# PDF'ten gelen metin kıvrık kesme işareti kullanıyor (15’e, A.Ş’ye);
# elle yazılan dayanaklarda düz kesme var. İlk koşuda iki madde yalnız
# bu yüzden düştü. Tipografik eşleme sayıyı ya da sözcüğü değiştirmiyor,
# o yüzden karşılaştırmadan önce tek biçime indiriliyor.
KESME = str.maketrans({"’": "'", "‘": "'", "ʼ": "'",
                       "“": '"', "”": '"'})


def duzle(s: str) -> str:
    """Satır kırığı, çoklu boşluk, PDF boşlukları ve kesme işareti biçimi."""
    s = unicodedata.normalize("NFC", s).translate(KESME)
    return re.sub(r"\s+", "", s)


METIN = {ad: duzle(y.read_text(encoding="utf-8")) for ad, y in KAYNAK.items()}

# (yıl, tarih, başlık, dayanak cümlesi, kaynak)
CIZELGE = [
    (1925, "6 Kasım 1925", "Uşak'ta ilk şeker fabrikasının temeli atıldı",
     "6 Kasım 1925 tarihinde ilk şeker fabrikasının temeli atılmıştır.", "sektor"),
    (1925, "22 Aralık 1925", "Alpullu'nun temeli atıldı",
     "22 Aralık 1925 tarihinde Alpullu Şeker Fabrikasının temeli atılarak", "sektor"),
    (1926, "26 Kasım 1926", "Alpullu'da ilk Türk şekeri üretildi",
     "26 Kasım 1926 tarihinde fabrika işletmeye açılarak ilk Türk şekeri üretilmiştir.", "sektor"),
    (1926, "17 Aralık 1926", "Uşak Şeker Fabrikası işletmeye açıldı",
     "Uşak Şeker Fabrikası ise 17 Aralık 1926 tarihinde işletmeye açılmıştır.", "sektor"),
    (1933, "5 Aralık 1933", "Eskişehir Şeker Fabrikası açıldı",
     "05/12/1933 tarihinde Eskişehir Şeker Fabrikası", "sektor"),
    (1934, "19 Ekim 1934", "Turhal Şeker Fabrikası açıldı",
     "19/10/1934 tarihinde Turhal Şeker Fabrikası işletmeye açılmıştır.", "sektor"),
    (1935, "6 Temmuz 1935", "Dört fabrika tek şirkette birleşti: Türkiye Şeker Fabrikaları A.Ş.",
     "6 Temmuz 1935 tarihinde, üç milli bankamızın eşit paylarla ortak oldukları tek bir "
     "şirket çatısı altında toplanarak Türkiye Şeker Fabrikaları A.Ş. kurulmuştur.", "sektor"),
    (1956, "1956", "Fabrika sayısı 15'e ulaştı",
     "1956 yılında fabrika sayısı 15'e ulaşmıştır.", "sektor"),
    (1956, "22 Haziran 1956", "6747 sayılı Şeker Kanunu",
     "22 Haziran 1956 tarihli ve 6747 sayılı Şeker Kanunu", "sektor"),
    (2001, "19 Nisan 2001", "4634 sayılı Şeker Kanunu yürürlüğe girdi",
     "19 Nisan 2001 tarihinde 4634 sayılı Şeker Kanununun yürürlüğe girmesinden önce", "sektor"),
    (2017, "20 Kasım 2017", "Şeker Kurumu kaldırıldı",
     None, None),
    (2018, "2018", "On şeker fabrikası özelleştirildi",
     "Afyon, Alpullu, Bor, Çorum, Elbistan, Erzincan, Erzurum, Kırşehir, Muş, Turhal Şeker "
     "Fabrikaları ise Özelleştirme İdaresi Başkanlığı tarafından satışı yapılarak 2018 yılında "
     "özelleştirilmiştir.", "sektor"),
    (2021, "29 Nisan 2021", "Sermayenin tamamı Türkiye Varlık Fonu'na geçti",
     "29/04/2021 tarihli ve 3923 sayılı Cumhurbaşkanı Kararı ile özelleştirme kapsam ve programından",
     "plan"),
    (2025, "2025", "Çarşamba Şeker Fabrikası MKE'ye devredildi",
     "Çarşamba Şeker Fabrikasının taşınmazları ve üzerinde bulunan yapıların Makine ve Kimya "
     "Endüstrisi A.Ş'ye (MKE) devredilmesine karar verilmiş, 2025 yılında devir işlemi "
     "tamamlanmıştır.", "sektor"),
]

hata, maddeler = [], []
for yil, tarih, baslik, dayanak, kaynak in CIZELGE:
    m = {"yil": yil, "tarih": tarih, "baslik": baslik}
    if dayanak is None:
        m["_dayanak"] = ("KHK-696/74, 20 Kasım 2017 — Resmî Gazete. Bu madde Türkşeker'in "
                         "kendi iki belgesinde GEÇMİYOR; dayanağı mevzuattır.")
        m["_belge_disi"] = True
    else:
        if duzle(dayanak) not in METIN[kaynak]:
            hata.append(f"{tarih} · dayanak cümlesi {kaynak} metninde bulunamadı:\n      {dayanak[:90]}")
            continue
        m["_dayanak"] = dayanak
        m["_kaynak"] = {"sektor": "TÜRKŞEKER, Şeker Sektör Raporu 2025",
                        "plan": "TÜRKŞEKER, 2024-2028 Stratejik Plan"}[kaynak]
    maddeler.append(m)

if hata:
    raise SystemExit("✗ DAYANAK TUTMADI\n  " + "\n  ".join(hata))

d = {
    "_dosya": "Şeker sanayii zaman çizelgesi",
    "_yontem": ("Her madde kaynak metinden birebir bir cümleye bağlı; tarih_kur.py o cümlenin "
                "metinde durduğunu sınıyor. Dayanağı tutmayan madde çizelgeye giremiyor."),
    "_cekim": "2026-11-23",
    "maddeler": sorted(maddeler, key=lambda m: m["yil"]),
    "ilk_seker": {
        "tarih": "26 Kasım 1926", "yer": "Alpullu",
        "yuzuncu_yil": 2026,
        "_not": ("Uşak'ın temeli 6 Kasım 1925'te, Alpullu'nunki 22 Aralık 1925'te atıldı; "
                 "Alpullu onbir ayda bitti ve ilk şekeri o üretti. Uşak 17 Aralık 1926'da açıldı."),
    },
    "fabrika_sayisi": {
        "1956": 15, "1990_oncesi_turkseker": 30, "2025_26_turkseker": 14,
        "_dusus_dayanagi": ("Stratejik Plan (2024-2028) 15 fabrika diyor, Sektör Raporu 2025 ise 14. "
                            "Fark Çarşamba'dır: 25/12/2024 tarihli 9315-9316 sayılı Cumhurbaşkanı "
                            "kararlarıyla MKE'ye devredildi, devir 2025'te tamamlandı."),
    },
}
(KOK / "tarih.json").write_text(json.dumps(d, ensure_ascii=False, indent=2), encoding="utf-8")

print(f"  ✓ {len(maddeler)} madde · hepsinin dayanağı kaynak metinde doğrulandı")
for m in d["maddeler"]:
    isaret = "⚠ belge dışı" if m.get("_belge_disi") else "✓"
    print(f"    {isaret} {m['tarih']:<16} {m['baslik']}")
