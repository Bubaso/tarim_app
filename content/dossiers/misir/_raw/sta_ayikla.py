#!/usr/bin/env python3
"""Türkiye–Mısır STA Protokol II → sta_ekler.json — TARIM TAVİZLERİ

KAYNAK: `indirilen_ek/misir_sta_ekler.rar` içindeki `protokolII.doc`.

ARŞİV NASIL AÇILDI: `unrar`, `unar` ve `7z` bu makinede yok ve `sudo`
kullanılamıyor (hesap sudoers'da değil). GEREKMEDİ — macOS'un kendi `tar`'ı
bsdtar/libarchive 3.7.4 üzerine kurulu ve RAR okuyor:
    tar -xf indirilen_ek/misir_sta_ekler.rar
.doc dosyaları da macOS'un kendi `textutil`'i ile çevrildi:
    textutil -convert txt -encoding UTF-8 -output <çıktı>.txt <girdi>.doc
İkisi de kurulum gerektirmiyor. Bu not duruyor ki sonraki tur "açılamadı"
sanmasın.

ARŞİVDE NE VAR, NE YOK — ÖLÇÜLDÜ (19 dosya):
  · protokolII.doc       → TARIM, İŞLENMİŞ TARIM VE BALIKÇILIK tavizleri.
                           Dosyanın kullanacağı TEK tarım belgesi bu.
  · protokolI.doc        → gümrük vergilerinin kaldırılması, SANAYİ.
  · Liste1-4.doc         → Protokol I'in takvim listeleri. SANAYİ:
                           Liste 1 tuz/mineral ile başlıyor (2.082 satır),
                           Liste 4 elektrik motoru ve otomobil (35 satır).
  · ekler.xls            → Liste 1/2/3'ün "y." (ex-) kod ayrıntısı, SANAYİ.
  · EK I.doc             → Madde 3 ve 9'un ürün listesi (mannitol, sorbitol,
                           gliserin, 33.01) — tarım/sanayi sınırı.
  · Protokol III.doc     → menşe kuralları.
  · Ek IIIa/IIIb, EK IVa/IVb, EK II → menşe belgesi formları ve ekleri.

BU YÜZDEN: Protokol I'deki takvim asimetrisi (Türkiye yürürlükle BİRLİKTE
sıfırlıyor, Mısır Liste 1-4 ile 2020'ye kadar kademeli iniyor) SANAYİ
ürünlerine ait. Dosya tarım dosyası; bu asimetri metne girerse "sanayi"
diye etiketlenecek, tarım tavizi gibi yazılmayacak.

MİKTAR GRUPLARI: Tabloda birleştirilmiş hücreler var — birden çok tarife
pozisyonu TEK kotayı paylaşıyor. textutil çevirisinde bu, kotası olmayan
satır olarak görünüyor. Aşağıda her grup kendi `kodlar` listesiyle duruyor;
toplam KOTA BAŞINA bir kez sayılıyor, pozisyon başına değil. Elle toplamak
yerine hesaplanıyor.
"""
from __future__ import annotations
import json, pathlib

KOK = pathlib.Path(__file__).parent

# ── PROTOKOL II · TABLO A — Türkiye menşeli ürünler Mısır'a ───────────────
TABLO_A = [
    (["0802.21", "0802.22"], "Fındıklar (Corylus spp)", 2000, 100),
    (["0804.20"], "İncirler", 500, 100),
    (["0809.20"], "Kirazlar (vişneler dahil)", 500, 100),
    (["0813.10"], "Kurutulmuş kayısılar", 500, 100),
    (["1507.90.91"], "Soya-fasulyesi yağı, yarı rafine, dökme", 10000, 100),
    (["1512.11", "1512.19.91"], "Ham ayçiçeği/aspir yağı ve yarı rafine ayçiçeği yağı", 20000, 100),
    (["1515.21"], "Ham mısır yağı", 10000, 100),
    (["1517"], "Margarin ve yenilen katı/sıvı yağ karışımları", 1000, 100),
    (["1704"], "Kakao içermeyen şeker mamulleri", 2000, 15),
    (["1806"], "Çikolata ve kakao içeren gıda müstahzarları", 1000, 15),
    (["1902"], "Makarna ve benzerleri, kuskus", 1000, 15),
    (["1905"], "Ekmek, pasta, kek, bisküvi ve ekmekçi mamulleri", 1000, 15),
    (["2001.10"], "Hıyar ve kornişon, sirkeyle hazırlanmış", 1000, 15),
    (["2008"], "Meyva ve sert kabuklu meyva müstahzarları", 500, 15),
    (["2009"], "Meyva ve sebze suları", 500, 15),
    (["2102.10"], "Canlı mayalar", 3000, 15),
]

# ── PROTOKOL II · TABLO B — Mısır menşeli ürünler Türkiye'ye ──────────────
# `None` kota = belgede "Sınırsız". Sıfır DEĞİL: sınır yok demek.
TABLO_B = [
    (["Fasıl 3"], "Balıklar, kabuklu hayvanlar, yumuşakçalar (0301 hariç)", None, 50),
    (["0602"], "Diğer canlı bitkiler, çelik ve daldırma, mantar miselleri", None, 100),
    (["0603"], "Kesme çiçekler ve çiçek tomurcukları", 15, 100),
    (["0701.90"], "Diğer patatesler, taze veya soğutulmuş", 400, 100),
    (["0703.20"], "Sarımsak, taze veya soğutulmuş", 100, 100),
    (["0705", "0706", "0709", "0710", "0711", "0712"],
     "Marul, havuç ve diğer kökler, diğer sebzeler, dondurulmuş, geçici "
     "konserve ve kurutulmuş sebzeler — ALTI POZİSYON TEK KOTAYI PAYLAŞIYOR",
     600, 100),
    (["0804.10"], "Hurma, taze veya kurutulmuş", 5000, 100),
    (["0804.50"], "Guava, mango ve mangost", 1000, 100),
    (["0810.10"], "Çilekler, taze", 200, 100),
    (["0909"], "Anason, rezene, kişniş, kimyon tohumları, ardıç", 100, 100),
    (["0910"], "Zencefil, safran, zerdeçal, kekik, defne, köri, baharat", 100, 100),
    (["1006.20"], "Kavuzu çıkarılmış (kahverengi) pirinç", 30000, 100),
    (["1006.30"], "Yarı/tam değirmenden geçirilmiş pirinç", 10000, 50),
    (["1202"], "Yer fıstığı, kavrulmamış", 500, 100),
    (["1704"], "Kakao içermeyen şeker mamulleri", 2000, 15),
    (["1806"], "Çikolata ve kakao içeren gıda müstahzarları", 1000, 15),
    (["1902"], "Makarna ve benzerleri, kuskus", 1000, 15),
    (["1905"], "Ekmek, pasta, kek, bisküvi ve ekmekçi mamulleri", 1000, 15),
    (["2001.10"], "Hıyar ve kornişon, sirkeyle hazırlanmış", 1000, 15),
    (["2008"], "Meyva ve sert kabuklu meyva müstahzarları", 500, 15),
    (["2009"], "Meyva ve sebze suları", 500, 15),
    (["2102.10"], "Canlı mayalar", 3000, 15),
]

# 1704, 1806, 1902, 1905 ve 2102.10 için belgenin kendi dipnotu
DIPNOT = ("1704, 1806, 1902, 1905 ve 2102.10 AS kodlarının altında yer alan "
          "ürünlerde ad-valorem vergiler kaldırılacak ve indirimler tarım "
          "payı üzerindeki vergilerden yapılacaktır.")


def duz(tablo):
    return [{"kodlar": k, "urun": u, "kota_ton": q, "indirim_yuzde": p}
            for k, u, q, p in tablo]


def topla(tablo):
    """Kota BAŞINA bir kez. Sınırsız satırlar toplama girmiyor, sayılıyor."""
    belirli = sum(q for _, _, q, _ in tablo if q is not None)
    sinirsiz = sum(1 for _, _, q, _ in tablo if q is None)
    return belirli, sinirsiz


a_top, a_sinirsiz = topla(TABLO_A)
b_top, b_sinirsiz = topla(TABLO_B)

# Dosyanın kullanacağı iki kapı
pirinc = sum(q for k, _, q, _ in TABLO_B if k[0].startswith("1006"))
yag = sum(q for k, _, q, _ in TABLO_A
          if k[0].startswith(("1507", "1512", "1515", "1517")))

cikti = {
    "_kaynak": ("Türkiye Cumhuriyeti ile Mısır Arap Cumhuriyeti Arasında Bir "
                "Serbest Ticaret Alanı Tesis Eden Anlaşma · PROTOKOL II "
                "(Madde 10'da atıfta bulunulan)"),
    "_belge": "indirilen_ek/misir_sta_ekler.rar → Mısır STA Türkçe/protokolII.doc",
    "_nitelik": "BİRİNCİL — anlaşmanın Türkçe nüshasının eki",
    "_resmi_gazete": "30 Ocak 2007 · sayı 26419 MÜKERRER",
    "_yururluk": "1 Mart 2007",
    "_acilma_notu": ("Arşiv macOS'un kendi tar'ı (bsdtar/libarchive 3.7.4) ile "
                     "açıldı, .doc dosyaları textutil ile çevrildi. unrar/unar/"
                     "7z gerekmedi; sudo kullanılamıyor (hesap sudoers'da değil)."),
    "_tarim_disi_ekler": ("Protokol I, Liste 1-4, ekler.xls ve EK I SANAYİ "
                          "ürünlerine ait — Liste 1 tuz ve mineralle başlıyor, "
                          "Liste 4 otomobil ve elektrik motoru. Protokol I'in "
                          "takvim asimetrisi (Türkiye yürürlükle birlikte "
                          "sıfırlıyor, Mısır 2020'ye kadar kademeli iniyor) bu "
                          "yüzden TARIM tavizi değil ve metinde öyle "
                          "yazılmayacak."),
    "tablo_a": {
        "_ne": "Türkiye menşeli ürünlerin Mısır'a ithalatında tavizler",
        "kalemler": duz(TABLO_A),
        "kota_grubu_sayisi": len(TABLO_A),
        "tarife_pozisyonu_sayisi": sum(len(k) for k, _, _, _ in TABLO_A),
        "toplam_kota_ton": a_top,
        "sinirsiz_satir": a_sinirsiz,
    },
    "tablo_b": {
        "_ne": "Mısır menşeli ürünlerin Türkiye'ye ithalatında tavizler",
        "kalemler": duz(TABLO_B),
        "kota_grubu_sayisi": len(TABLO_B),
        "tarife_pozisyonu_sayisi": sum(len(k) for k, _, _, _ in TABLO_B),
        "toplam_kota_ton": b_top,
        "sinirsiz_satir": b_sinirsiz,
    },
    "turetilmis": {
        "pirinc_kotasi_ton": pirinc,
        "pirinc_payi_tablo_b_yuzde": round(100 * pirinc / b_top, 1),
        "yag_kotasi_ton": yag,
        "yag_payi_tablo_a_yuzde": round(100 * yag / a_top, 1),
        "sebze_kotasi_ton": next(q for k, _, q, _ in TABLO_B if k[0] == "0705"),
        "sebze_pozisyon_sayisi": len(next(k for k, _, _, _ in TABLO_B if k[0] == "0705")),
    },
    "_dipnot": DIPNOT,
    "_simetrik_blok": ("1704, 1806, 1902, 1905, 2001.10, 2008, 2009 ve 2102.10 "
                       "iki tabloda da AYNI kota ve AYNI %15 indirimle "
                       "duruyor — işlenmiş gıdada taviz birebir aynalı."),
}

(KOK / "sta_ekler.json").write_text(
    json.dumps(cikti, ensure_ascii=False, indent=1) + "\n", encoding="utf-8")

print("PROTOKOL II — TARIM TAVİZLERİ")
print(f"  Tablo A (Türkiye → Mısır): {cikti['tablo_a']['kota_grubu_sayisi']} kota grubu · "
      f"{cikti['tablo_a']['tarife_pozisyonu_sayisi']} pozisyon · "
      f"{a_top:,} ton · sınırsız satır {a_sinirsiz}")
print(f"  Tablo B (Mısır → Türkiye): {cikti['tablo_b']['kota_grubu_sayisi']} kota grubu · "
      f"{cikti['tablo_b']['tarife_pozisyonu_sayisi']} pozisyon · "
      f"{b_top:,} ton · sınırsız satır {b_sinirsiz}")
t = cikti["turetilmis"]
print(f"\n  PİRİNÇ   {t['pirinc_kotasi_ton']:,} ton = Tablo B'nin %{t['pirinc_payi_tablo_b_yuzde']}'i")
print(f"  YAĞ      {t['yag_kotasi_ton']:,} ton = Tablo A'nın %{t['yag_payi_tablo_a_yuzde']}'i")
print(f"  SEBZE    {t['sebze_kotasi_ton']:,} ton, {t['sebze_pozisyon_sayisi']} pozisyon PAYLAŞIYOR")
print("\n✓ sta_ekler.json")
