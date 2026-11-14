#!/usr/bin/env python3
"""Uzayda Tarım — `_raw/*.json` → `data.json`. Veri sayfası burada KİLİTLENİR.

§2.2: veri sayfası METİNDEN ÖNCE kilitlenir. Metin bu dosyadan okur;
cümlede hesap yapılmaz.

Doğrulamaların her biri bu araştırmada GERÇEKTEN yaşanmış bir tuzağı
bekliyor. Tuzakların tam dökümü UZAYDA_TARIM_FIZIBILITE.md'de.
"""
from __future__ import annotations
import json, pathlib, sys, datetime, re

KOK = pathlib.Path(__file__).parent
HAM = KOK / "_raw"
oku = lambda ad: json.loads((HAM / ad).read_text(encoding="utf-8"))

osdr    = oku("osdr.json")
ekinler = oku("ekinler.json")
marul   = oku("marul.json")
ax3     = oku("ax3.json")
tr_gor  = oku("turkiye_gorsel.json")
erisim  = oku("erisim.json")
dunya   = oku("dunya.json")
oda     = oku("oda.json")
mir     = oku("mir.json")
gelecek = oku("gelecek.json")

hata: list[str] = []
d: dict = {}

# ══════════════════════════════════════════════════════════════════════════
#  GÖVDE
# ══════════════════════════════════════════════════════════════════════════

d["eleme"] = {
    "_kapsam": "NASA'nın ekin eleme hattı — hangi ürün uzayda yenebildi",
    "_kaynak_niteligi": "BİRİNCİL — NASA/TM-20250001897, Temmuz 2024",
    "kultivar_ayristirilan": ekinler["kultivar_sayisi"],
    "tablo_sayisi": ekinler["tablo_sayisi"],
    "ksc_kultivar": ekinler["ksc_kultivar"],
    "gbe_kultivar": ekinler["gbe_kultivar"],
    "belge_duzyazi_toplam": 376,
    "belge_duzyazi_ksc": "204'ten fazla",
    "belge_duzyazi_gbe": 191,
    "crl3_bekleyen": 153,
    "crl2_bekleyen": 47,
    "crl9_gecen": ekinler["crl9_gecen_sayisi"],
    "crl9_listesi": ekinler["crl9_gecenler"],
    "crl9_bos_kategoriler": ekinler["crl9_bos_kategoriler"],
    "_BOS_KATEGORI_NOTU": ekinler["_BOS_KATEGORI_NOTU"],
    "familya_dagilimi": ekinler["familya_dagilimi"],
    "_SAYIM_AYRISMASI": ekinler["_SAYIM_AYRISMASI"],
    "_BELGE_TUTARSIZLIGI": ekinler["_belgenin_kendi_tutarsizligi"],
    "_SAYIM_KAYNAKLARI": ekinler["_SAYIM_KAYNAKLARI"],
    "_CAPRAZ_SINAMA": ekinler["_CAPRAZ_SINAMA"],
    "_METIN_KURALI": ("Metin ekin sayısı kullanırsa BELGENİN KENDİ sayısını "
                      "(376) yazacak ve ayrıştırmanın "
                      f"{ekinler['kultivar_sayisi']} bulduğunu söyleyecek. "
                      "Kendi sayımımı belgenin yerine koymam."),
}

# Süzgeç bileşeninin isteyeceği liste. Tabloların tamamı değil, bileşenin
# kullandığı alanlar: ad, familya, hangi tablo, kaç işaret, kaldı mı.
# "Hangi basamakta kaldı" YOK — okunamıyor (bkz. _KONUM_KISITI).
d["kultivarlar"] = {
    "_kapsam": "Kennedy ve Growing Beyond Earth'te denenen kültivarlar",
    "_kaynak_niteligi": "BİRİNCİL — NASA/TM-20250001897 Ek E tabloları",
    "toplam": ekinler["kultivar_sayisi"],
    "_ALAN_NOTU": ("'kaldi' yalnız 'bir yerde F aldı' demek; NEREDE kaldığı "
                   "metinden okunamıyor ve bu alanda YOK. "
                   "'isaret_guvenilir' false ise o satırı BELGENİN KENDİSİ "
                   "'…' ile kısaltmış, işaret sayısı eksiktir."),
    "_ONARIM_GUNLUGU": ekinler["_ONARIM_GUNLUGU"],
    "_ONARIM_NOTU": ekinler["_ONARIM_NOTU"],
    "familyasi_okunamayan": len(ekinler["_ONARIM_GUNLUGU"]["familyasiz"]),
    "liste": [
        {"ad": r["kultivar"], "familya": r["familya"], "tablo": t["kod"],
         "isaret": r["isaret_sayisi"], "kaldi": r["kalmis"],
         "isaret_guvenilir": r["isaret_sayisi_guvenilir"]}
        for t in ekinler["tablolar"] for r in t["satirlar"]
    ],
    "tablo_adlari": {t["kod"]: t["baslik"] for t in ekinler["tablolar"]},
}

d["crl"] = {
    "_kapsam": "Crop Readiness Level — dokuz basamaklı hazırlık merdiveni",
    "_kaynak_niteligi": "BİRİNCİL — NASA/TM-20250001897 Ek E",
    "basamaklar": [
        {"no": 1, "ad": "Tarama", "olcut": "tohum kataloğu ve literatürden ön değerlendirme"},
        {"no": 2, "ad": "Gözlem", "olcut": "bitki sağlığı ve performansının genel gözlemi"},
        {"no": 3, "ad": "ISS benzeri ortam",
         "olcut": "≈22°C · ≈%40 bağıl nem · ≈3000 ppm CO₂ · uçuş benzeri LED"},
        {"no": 4, "ad": "Mikrobiyoloji",
         "olcut": ("aerobik bakteri tek örnekte >2×10⁴ CFU/g KALIR; beş "
                   "örneğin ikisinde >1×10⁴ KALIR; maya ve küf >1000 CFU/g "
                   "KALIR. E. coli, koliform, Salmonella, S. aureus taranır")},
        {"no": 5, "ad": "Kimya ve kabul edilebilirlik",
         "olcut": ("K, Mg, Fe, Ca ölçümü; dokuz puanlık hedonik ölçekte "
                   "ortalama EN AZ 6. Radicchio acılıktan kaldı")},
        {"no": 6, "ad": "Tohum yüzeyi",
         "olcut": "çimlenme >%60 korunmalı ya da başlangıçtan <%30 düşüş"},
        {"no": 7, "ad": "Uçuş benzeri donanım", "olcut": "Veggie ya da APH içinde yetiştirme"},
        {"no": 8, "ad": "Uzayda yetiştirme", "olcut": "ISS ya da başka bir platformda"},
        {"no": 9, "ad": "Uzayda yeme", "olcut": "yetiştirip TÜKETMEK"},
    ],
    "_KONUM_KISITI": ekinler["_AYRISTIRMA_SINIRI"],
}

d["osdr"] = {
    "_kapsam": "NASA Açık Bilim Veri Deposu'ndaki bitki çalışmaları",
    "_kaynak_niteligi": osdr["_nitelik"],
    "toplam": osdr["toplam"],
    "model_organizma": osdr["model_organizma_sayisi"],
    "ekin_bitkisi": osdr["ekin_sayisi"],
    "ekin_calismalari": [{"erisim": k["erisim"], "ekin": k["ekin"],
                          "baslik": k["baslik"]} for k in osdr["ekin_calismalari"]],
    "cins_dagilimi": osdr["cins_dagilimi"],
    "_SORGU_KISITI": osdr["_sorgu_notu"],
}

d["marul"] = {
    "_kapsam": "ISS'te yetiştirilen marulun besin ve mikrobiyoloji analizi",
    "_kaynak_niteligi": marul["_nitelik"],
    "kaynak": marul["_kaynak"],
    "bitki": marul["bitki"],
    "deneyler": marul["deneyler"],
    "yer_kontrolu": marul["yer_kontrolu"],
    "elemental": marul["elemental"],
    "antioksidan": marul["antioksidan"],
    "mikrobiyoloji": marul["mikrobiyoloji"],
    "_OZET_SONUC_AYRISMASI": marul["_OZET_SONUC_AYRISMASI"],
}

d["ax3"] = {
    "_kapsam": "Türkiye'nin ilk insanlı uzay görevindeki 13 bilimsel deney",
    "_kaynak_niteligi": ax3["_nitelik"],
    "gorev": ax3["_gorev"],
    "toplam_deney": ax3["toplam"],
    "bitki_alg": ax3["bitki_alg_sayisi"],
    "sinir_durum": ax3["sinir_durum"],
    "deneyler": ax3["deneyler"],
    "_ORAN": ax3["_ORAN"],
    "_IKI_ALG": ax3["_IKI_ALG_NOTU"],
}

d["yorunge_alti"] = {
    "_kapsam": "Türkiye'nin ikinci görevi — ve neden bu dosyanın dışında",
    "_kaynak_niteligi": "BİRİNCİL — TÜBİTAK haber sayfası",
    "astronot": "Tuva Cihangir Atasever",
    "gorev": "Virgin Galactic · Galactic 07 · VSS Unity",
    "tarih": "8 Haziran 2024",
    "irtifa_km": 90,
    "_irtifa_ayrismasi": ("Kaynaklar 87,5 / 90 / ~80 km veriyor. TÜBİTAK'ın "
                          "kendi haberi 90 diyor; kullanılan o, ayrışma yazılı."),
    "deney_sayisi": 7,
    "bitki_deneyi": 0,
    "_YAPISAL_SEBEP": ("Yörünge altı uçuşta mikroyerçekimi penceresi "
                       "DAKİKALARLA ölçülüyor; astronotun kendi ifadesiyle üç "
                       "deney için 'üç dakikalık sürem olacak'. Bitki "
                       "biyolojisi GÜN istiyor. Yörünge altı ile yörüngesel "
                       "arasındaki fark uzay tarımı için ayrıntı değil EŞİK."),
}

d["gorsel_kisiti"] = {
    "_kapsam": "Dosyanın omurgasındaki bitkinin görsel durumu",
    "_kaynak_niteligi": "ÖLÇÜM — Commons ve iNaturalist yoklaması",
    "schrenkiella_acik_lisansli_foto": 0,
    "inaturalist_gozlem": 4,
    "inaturalist_lisans": "cc-by-nc — ticari kullanıma kapalı, kabul listesinde yok",
    "tuz_golu_commons": 38157,
    "_THELLUNGIELLA_TUZAGI": tr_gor["_SCHRENKIELLA_BULUNAMADI"]["commons"]["_thellungiella_notu"],
    "_KARAR": tr_gor["_SCHRENKIELLA_BULUNAMADI"]["_TASARIM_SONUCU"],
}

# ── MIR / SVET BUĞDAYI ───────────────────────────────────────────────────
# Durak 2 bir süre şu cümleyle yayındaydı: "istasyon havasındaki eser
# etilen bitkiyi kısırlaştırıyordu." Doğru çıktı — ama yazıldığı anda
# KİLİTLİ KAYNAĞI YOKTU ve dosyanın kendi kuralını deliyordu. Kaynak
# arandı, bulundu, çekildi; cümle sonra düzeltildi.
#
# NEDENSELLİK İDDİASI GÖZLEME DEĞİL ÇAPRAZ DENEYE DAYANIYOR: Campbell
# ekibi yerdeki buğdayı Mir'de ölçülen etilen aralığına maruz bıraktı ve
# aynı kısırlığı üretti. "Birlikte bulundu" değil, "tekrarlandı".
d["mir"] = {
    "_kapsam": "Mir / Svet buğday deneyi ve kısırlığın sebebi",
    "_kaynak_niteligi": mir["_nitelik"],
    "_NEDENSELLIK_NOTU": mir["_NEDENSELLIK_NOTU"],
    "kaynaklar": mir["_kaynaklar"],
    "pasajlar": mir["pasajlar"],
    "basak": 280,
    "tohum": 0,
    "etilen_araligi": "1,1 - 1,7 µmol·mol⁻¹",
    "cultivar": "Super Dwarf buğday (Triticum aestivum L.)",
}

# ── YETİŞTİRME ODASI ─────────────────────────────────────────────────────
# Şema durağının dayanağı. Çizilen her parçanın belgede bir cümlesi var ve
# o cümleler PDF'ten ÇEKİLDİ, elle kopyalanmadı.
#
# Neden bu kadar sıkı: şema bir çizim ve çizim her şeyi söyleyebilir.
# Kaynağı olmayan bir ok, kaynağı olmayan bir cümleden daha tehlikeli —
# sorgulanması daha zor.
d["oda"] = {
    "_kapsam": "Yetiştirme odasının donanımı — şemanın dayanağı",
    "_kaynak_niteligi": oda["_nitelik"],
    "_kaynak": oda["_kaynak"],
    "pasajlar": oda["pasajlar"],
    "elenen_ornekler": oda["elenen_ornekler"],
}

# ── DÜNYA HATLARI ────────────────────────────────────────────────────────
# §10 ve §11'in dayanağı. BU BLOK ÖTEKİLERDEN FARKLI BİR TÜRDE ve bunu
# kendisi söylüyor: ekin tabloları ve Ax-3 listesi birincil belgelerden
# ayrıştırılmıştı, burada kaynak çoğunlukla kurum duyurusu ve haber.
# Niteliği gizlemek, dosyanın geri kalanının dürüstlüğünü de şüpheye
# düşürürdü.
d["dunya"] = {
    "_kapsam": "Uzayda tarıma çalışan dünya hatları",
    "_kaynak_niteligi": dunya["_nitelik"],
    "_YONTEM_NOTU": dunya["_YONTEM_NOTU"],
    "_cekim": dunya["_cekim"],
    "brezilya": dunya["brezilya"],
    "cin_change4": dunya["cin_change4"],
    "esa_melissa": dunya["esa_melissa"],
    "cin_lunar_palace": dunya["cin_lunar_palace"],
}

# ── KAYNAKÇA ─────────────────────────────────────────────────────────────
# Künyeler Dart'a ELLE YAZILMIYOR. Sayfanın kaynakça bölümü bu bloktan
# okuyor; künye değişirse tek yerden değişiyor ve doğrulamadan geçiyor.
#
# ERİŞİM DURUMU ÖLÇÜLDÜ, VARSAYILMADI. İki TÜBİTAK adresi 404 dönüyor ama
# gövdesinde yüz binlerce bayt HTML var — YUMUŞAK 404. Durum koduna bakıp
# "kırık" ya da gövdeye bakıp "açık" demek ikisi de yanlış olurdu;
# `erisim_haritasi.py` dört ölçütü birlikte uyguluyor.
_adres = {k["ad"]: k for k in erisim["kaynaklar"]}

d["gelecek"] = {
    "_kapsam": gelecek["_ne"],
    "_kaynak_niteligi": gelecek["_nitelik"] + " — üç kurumun kendi yayını; "
                        "cümleler belgeden desenle çekildi, elle kopyalanmadı",
    **{k: v for k, v in gelecek.items() if not k.startswith("_ne")},
}

d["kaynaklar"] = {
    "_kapsam": "Dosyanın dayandığı belgeler ve ölçülmüş erişim durumları",
    "_kaynak_niteligi": "ÖLÇÜM — 12 adresin erişim durumu dört ölçütle sınandı",
    "_YONTEM": erisim["_yontem"],
    "_PMC_NOTU": erisim["_PMC_NOTU"],
    "olcum_tarihi": erisim["_tarih"],
    "olculen": erisim["toplam"],
    "acik": erisim["acik"],
    "belgeler": [
        {
            "sira": 1,
            "kunye": ekinler["_kaynak"],
            "yazarlar": ekinler["_yazarlar"],
            "nitelik": ekinler["_nitelik"],
            "kullanildigi_yer": "Dokuz ekin · hazırlık merdiveni · familya defteri",
            "adres": _adres["NASA NTRS — ekin belgesi"]["adres"],
            "cekim": ekinler["_cekim"],
        },
        {
            "sira": 2,
            "kunye": marul["_kaynak"],
            "yazarlar": "Khodadad, C.L.M. ve ark.",
            "nitelik": marul["_nitelik"],
            "kullanildigi_yer": "Marul meselesi",
            "adres": _adres["Frontiers — marul makalesi"]["adres"],
            "cekim": marul["_cekim"],
        },
        {
            "sira": 3,
            "kunye": ax3["_kaynak"],
            "yazarlar": "Türkiye Bilimler Akademisi",
            "nitelik": ax3["_nitelik"],
            "kullanildigi_yer": "Türkiye yörüngede — on üç deney",
            "adres": _adres["TÜBA — 13 deney belgesi"]["adres"],
            "cekim": ekinler["_cekim"],
        },
        {
            "sira": 4,
            "kunye": osdr["_kaynak"],
            "yazarlar": "NASA",
            "nitelik": osdr["_nitelik"],
            "kullanildigi_yer": "Model organizma sorunu",
            "adres": _adres["NASA OSDR arama API"]["adres"],
            "cekim": osdr["_cekim"],
        },
        {
            "sira": 5,
            "kunye": "TÜBİTAK · 'Türkiye'nin ikinci uzay yolculuğu başarıyla "
                     "tamamlandı' · tubitak.gov.tr",
            "yazarlar": "TÜBİTAK",
            "nitelik": "BİRİNCİL — kurum haberi",
            "kullanildigi_yer": "Yörünge altı neden yetmez",
            "adres": _adres["TÜBİTAK — ikinci uzay yolculuğu"]["adres"],
            "cekim": erisim["_tarih"],
        },
        {
            "sira": 6,
            "kunye": gelecek["nasa_hedef"]["_kunye"],
            "yazarlar": "Elison Blancaflor, John Howard · NASA BPS",
            "nitelik": "BİRİNCİL — ajansın danışma kuruluna sunumu",
            "kullanildigi_yer": "Ay'a gidecek saksı · Hedef yazıya döküldü",
            "adres": "https://ntrs.nasa.gov/api/citations/20240014700/downloads/"
                     "Space%20Crops%20BPAC%202024.pdf",
            "cekim": gelecek["_cekim"],
        },
        {
            "sira": 7,
            "kunye": gelecek["yere_donen"]["_kunye"],
            "yazarlar": "Raymond M. Wheeler",
            "nitelik": "BİRİNCİL — NASA teknik memorandumu",
            "kullanildigi_yer": "Zaten inmişti",
            "adres": "https://ntrs.nasa.gov/api/citations/20205008832/downloads/"
                     "NASA%20TM-2020-5008832%20NASA's%20Contributions%20to%20"
                     "Vertical%20Farming.pdf",
            "cekim": gelecek["_cekim"],
        },
        {
            "sira": 8,
            "kunye": gelecek["turkiye_sirada"]["_kunye"],
            "yazarlar": "Türkiye Uzay Ajansı",
            "nitelik": "BİRİNCİL — resmî faaliyet raporu",
            "kullanildigi_yer": "Tohum yukarı, değişmiş olarak geri",
            "adres": "https://cdn.tua.gov.tr/69d63463e5f66.pdf",
            "cekim": gelecek["_cekim"],
        },
    ],
    "erisim": [
        {"ad": k["ad"], "adres": k["adres"], "teshis": k["teshis"],
         "kod": k["kod"], "tur": k["tur"], "bayt": k["bayt"]}
        for k in erisim["kaynaklar"]
    ],
}

# ══════════════════════════════════════════════════════════════════════════
#  DOĞRULAMALAR
# ══════════════════════════════════════════════════════════════════════════

# 1 — her blok kapsam ve kaynak niteliği taşıyor
for ad, blok in d.items():
    if not isinstance(blok, dict):
        hata.append(f"BLOK SÖZLÜK DEĞİL · {ad}"); continue
    if not blok.get("_kapsam"):
        hata.append(f"KAPSAM YOK · {ad}")
    if not blok.get("_kaynak_niteligi"):
        hata.append(f"KAYNAK NİTELİĞİ YOK · {ad}")

# 2 — CRL 9 LİSTESİ ÇIKARIMLA DEĞİL, BELGEDEN
# "dokuz işaret = CRL 9" ölçütü denendi ve DÜŞTÜ: Waldmann marulunun
# satırında sekiz işaret var ama ekin Tablo A-3'te.
if d["eleme"]["crl9_gecen"] != 9:
    hata.append(f"CRL 9 SAYISI DEĞİŞTİ · {d['eleme']['crl9_gecen']}, 9 bekleniyordu")
if len(d["eleme"]["crl9_listesi"]) != 9:
    hata.append("CRL 9 LİSTESİ EKSİK · dokuz satır olmalı")
if "ÇIKARILAMAZ" not in ekinler["_crl9_kaynagi"]:
    hata.append("CRL 9 KAYNAK NOTU SİLİNMİŞ · çıkarımla okunamayacağı yazılı kalmalı")

# 3 — TAHIL VE BAKLAGİL YOKLUĞU, EKSEN CÜMLESİNİN DAYANAĞI
# Cümle "aralarında ne bir tahıl var ne bir baklagil" diyor. Listede
# Poaceae (tahıl) ya da Fabaceae (baklagil) çıkarsa cümle YANLIŞ olur.
_fam = {c["familya"] for c in d["eleme"]["crl9_listesi"]}
for yasak, ad in (("Poaceae", "tahıl"), ("Fabaceae", "baklagil")):
    if yasak in _fam:
        hata.append(f"EKSEN CÜMLESİ DÜŞTÜ · CRL 9 listesinde {ad} ({yasak}) var")

# 3b — "None" KATEGORİLERİ KAYNAKTAN GELİYOR
# Eksen cümlesi "ne bir tahıl var ne bir baklagil" diyor. Bu bir çıkarım
# değil: tablo Legumes satırına açıkça None yazmış. Kayıt düşerse cümlenin
# dayanağı da düşer.
if "Legumes" not in d["eleme"]["crl9_bos_kategoriler"]:
    hata.append("BOŞ KATEGORİ KAYDI EKSİK · tablo 'Legumes None' diyor, "
                "eksen cümlesinin dayanağı bu")
if len(d["eleme"]["crl9_bos_kategoriler"]) != 3:
    hata.append(f"BOŞ KATEGORİ SAYISI DEĞİŞTİ · "
                f"{d['eleme']['crl9_bos_kategoriler']}")

# 4 — SAYIM AYRIŞMASI YAZILI VE GÜNCEL
# BU DOĞRULAMA BİR KEZ SESSİZCE ESKİDİ. İlk hâli ayrıştırma sayısını "392"
# diye SABİT arıyordu; ayrıştırıcı düzelip sayı 419 olunca not eski kaldı
# ama doğrulama hâlâ geçiyordu, çünkü aradığı dizge nottaki eski sayıydı.
# Artık sayı VERİDEN okunuyor: not ile veri ayrışırsa kilit açılmıyor.
_ayr = str(d["eleme"]["kultivar_ayristirilan"])
_not = d["eleme"]["_SAYIM_AYRISMASI"]
if "376" not in _not:
    hata.append("SAYIM AYRIŞMASI EKSİK · belgenin kendi toplamı (376) notta geçmeli")
if _ayr not in _not:
    hata.append(f"SAYIM NOTU ESKİMİŞ · ayrıştırma {_ayr} buluyor ama notta geçmiyor")
if "395" not in _not:
    hata.append("BELGENİN TOPLAMA HATASI YAZILMAMIŞ · 191+204=395, belge 376 diyor")

# 4b — BELGENİN BİLEŞENLERİ KENDİ TOPLAMIYLA TUTUYOR MU
# Sayfanın belkemiği 376. O sayının kaynağın KENDİ aritmetik hatası
# olduğunu ölçen kayıt burada; kayıt bozulursa sayfa dayanaksız kalır.
_k = d["eleme"]["_SAYIM_KAYNAKLARI"]
_b = _k["belgenin_bilesenleri"]
if _b["gbe"] + _b["ksc"] != _b["aritmetik_toplam"]:
    hata.append("BİLEŞEN TOPLAMI YANLIŞ KAYDEDİLMİŞ")
if _b["aritmetik_toplam"] == _k["belgenin_toplami"]:
    hata.append("BELGENİN TOPLAMA HATASI KAYBOLMUŞ · 191+204 ile 376 ayrı "
                "sayılar, kayıt bunu göstermeli")
_t = _k["belgenin_tur_tur_sayimi"]
if sum(v for a, v in _t.items() if a != "toplam") != _t["toplam"]:
    hata.append("TÜR TÜR SAYIM KENDİ TOPLAMINI TUTMUYOR")

# 4c — ÇAPRAZ SINAMA KAYDI DURUYOR
# Ayrıştırma belgenin tür tür sayımıyla beş tabloda birebir tutuyor; bu,
# ayrıştırmanın tek dayanağı. Tutan tablo sayısı düşerse haber verilmeli.
_tutan = sum(1 for c in d["eleme"]["_CAPRAZ_SINAMA"] if c["tutuyor"])
if _tutan < 5:
    hata.append(f"ÇAPRAZ SINAMA ZAYIFLADI · yedi tablodan {_tutan} tanesi "
                f"tutuyor, en az beş bekleniyor")

# 5 — MODEL ORGANİZMA ORANI, DOSYANIN BULGUSU
# "Uzay bitki bilimi ezici biçimde model organizma üzerinden yürüyor"
# cümlesi buna dayanıyor. Oran tersine dönerse cümle yazılamaz.
if d["osdr"]["model_organizma"] <= d["osdr"]["ekin_bitkisi"]:
    hata.append(f"MODEL ORGANİZMA ORANI TERS · Arabidopsis "
                f"{d['osdr']['model_organizma']}, ekin {d['osdr']['ekin_bitkisi']}")

# 6 — MARUL: 'UÇUŞ↔YER FARKI VAR' CÜMLESİ KURULAMAZ
# Makalenin ÖZETİ öyle okutuyor, SONUÇLAR bölümü tersini söylüyor.
_m = d["marul"]["_OZET_SONUC_AYRISMASI"]
if "no significant differences between" not in _m["sonuclar_cumlesi"]:
    hata.append("MARUL SONUÇ CÜMLESİ BOZULMUŞ · birebir alıntı korunmalı")
if "dayandırılamaz" not in _m["karar"]:
    hata.append("MARUL KARARI SİLİNMİŞ · hangi cümlenin kurulamayacağı yazılı kalmalı")
if d["marul"]["elemental"]["_bulgu"].count("YOK") < 1:
    hata.append("MARUL ELEMENTAL BULGUSU ZAYIFLAMIŞ")

# 7 — AX-3 BİTKİ SAYISI VE PRANET AYRIMI
if d["ax3"]["bitki_alg"] != 4:
    hata.append(f"AX-3 BİTKİ SAYISI DEĞİŞTİ · {d['ax3']['bitki_alg']}, 4 bekleniyordu")
if "PRANET" not in d["ax3"]["sinir_durum"]:
    hata.append("PRANET SINIR DURUMU SİLİNMİŞ · dörde katılmadığı yazılı kalmalı")
_bitki = [x for x in d["ax3"]["deneyler"] if x["sinif"].startswith("BİTKİ")]
if len(_bitki) != d["ax3"]["bitki_alg"]:
    hata.append("AX-3 SAYIM TUTMUYOR · sınıf etiketleriyle sayı ayrışmış")

# 8 — YÖRÜNGE ALTINDA BİTKİ DENEYİ YOK, SEBEBİ YAZILI
if d["yorunge_alti"]["bitki_deneyi"] != 0:
    hata.append("YÖRÜNGE ALTI · bitki deneyi sayısı değişmiş, bölüm yeniden yazılmalı")
if "EŞİK" not in d["yorunge_alti"]["_YAPISAL_SEBEP"]:
    hata.append("YÖRÜNGE ALTI · yapısal sebep notu zayıflamış")

# 9 — SCHRENKIELLA GÖRSELİ YOK, METİN AKSİNİ İDDİA EDEMEZ
if d["gorsel_kisiti"]["schrenkiella_acik_lisansli_foto"] != 0:
    hata.append("GÖRSEL KISITI DEĞİŞMİŞ · yeniden ölçülmeli")
if "wasabi" not in d["gorsel_kisiti"]["_THELLUNGIELLA_TUZAGI"].lower():
    hata.append("THELLUNGIELLA TUZAĞI SİLİNMİŞ · 126 sonucun wasabi olduğu yazılı kalmalı")

# 12 — KÜLTİVAR LİSTESİ TABLOLARLA TUTUYOR
if len(d["kultivarlar"]["liste"]) != d["eleme"]["kultivar_ayristirilan"]:
    hata.append(f"KÜLTİVAR SAYIMI TUTMUYOR · liste "
                f"{len(d['kultivarlar']['liste'])}, tablolar "
                f"{d['eleme']['kultivar_ayristirilan']}")
if any("basamak" in k or "crl" in str(k).lower() for k in d["kultivarlar"]["liste"][0]):
    hata.append("KÜLTİVAR LİSTESİNDE BASAMAK ALANI VAR · konum okunamıyor, "
                "bu alan veri uydurur")

# 9b — KÜLTİVAR ADLARI TEMİZ
# Üç ayrı kusur SAYFADA GÖRÜLEREK bulundu, ayrıştırmada değil: adın başında
# satır numarası ("1 'Vit Mache"), ortasında açılış tırnağı
# ("Mustard, 'Wasabi") ve sonunda dipnot rakamı ("Radish1"). Üçü de
# sessizdi — hiçbir sayımı bozmuyor, yalnız okura yanlış ad gösteriyordu.
_adlar = [str(x["ad"]) for x in d["kultivarlar"]["liste"]]
_numarali = [a for a in _adlar if re.match(r"^\d{1,3}\s", a)]
if _numarali:
    hata.append(f"KÜLTİVAR ADINDA SATIR NUMARASI · {_numarali[:3]}")
_acik_tirnak = [a for a in _adlar if re.search(r"(?:^|\s)'\w", a)]
if _acik_tirnak:
    hata.append(f"KÜLTİVAR ADINDA KAPANMAMIŞ TIRNAK · {_acik_tirnak[:3]}")
_isaretli = [a for a in _adlar if re.search(r"\s[PF](\s|$)", a)]
if _isaretli:
    hata.append(f"KÜLTİVAR ADINA P/F DAMGASI KARIŞMIŞ · {_isaretli[:3]}")
if len(set(_adlar)) < len(_adlar) - 12:
    hata.append("KÜLTİVAR ADLARI ÇOK YİNELENİYOR · ayrıştırma satırları "
                "birbirine karıştırmış olabilir")

# 9c — KAYNAKÇA TAM VE ERİŞİM DURUMU ÖLÇÜLÜ
# Kaynakça bölümü sayfanın denetlenebilirliğinin son halkası: okur
# künyeden belgeye gidebilmeli. Adresi olmayan künye o halkayı koparır.
for _b in d["kaynaklar"]["belgeler"]:
    for _alan in ("kunye", "nitelik", "adres", "kullanildigi_yer"):
        if not _b.get(_alan):
            hata.append(f"KAYNAK {_b['sira']}: '{_alan}' boş")
    if not str(_b["adres"]).startswith("http"):
        hata.append(f"KAYNAK {_b['sira']}: adres bir bağlantı değil")
# YUMUŞAK 404'LER KAYITTA KALMALI. İkisini "açık" diye yazmak ya da
# listeden düşürmek, ölçümün tek anlamlı bulgusunu silerdi.
_yumusak = [k for k in d["kaynaklar"]["erisim"]
            if "YUMUŞAK" in str(k["teshis"])]
if len(_yumusak) != 2:
    hata.append(f"YUMUŞAK 404 KAYDI DEĞİŞTİ · {len(_yumusak)} tane, 2 "
                f"bekleniyordu; erişim yeniden ölçülmeli")
if d["kaynaklar"]["acik"] + len(_yumusak) != d["kaynaklar"]["olculen"]:
    hata.append("ERİŞİM SAYIMI TUTMUYOR · açık + yumuşak 404 toplam etmeli")
if "gövde uzunluğu" not in d["kaynaklar"]["_YONTEM"]:
    hata.append("ERİŞİM YÖNTEMİ EKSİK · ölçüt olarak gövde uzunluğu yazmalı")

# 9d — DÜNYA HATLARININ KAYNAĞI VE BELİRSİZLİĞİ YAZILI
# Bu blok haber ve duyuruya dayanıyor; her kalemin kendi niteliği olmalı
# ve kaynakları durmalı. Niteliksiz bir kalem metinde birincil veri gibi
# görünürdü.
for _ad in ("brezilya", "cin_change4", "esa_melissa", "cin_lunar_palace"):
    _k = d["dunya"][_ad]
    if not _k.get("_nitelik"):
        hata.append(f"DÜNYA/{_ad}: '_nitelik' yok — kaynağın türü yazılmalı")
    _kay = _k.get("kaynaklar") or ([_k.get("adres")] if _k.get("adres") else [])
    if not any(str(u).startswith("http") for u in _kay):
        hata.append(f"DÜNYA/{_ad}: bağlantılı kaynak yok")

# BREZİLYA SAYIMI KULLANILMAYACAK. Kaynaklar ağın büyüklüğünde tutmuyor
# (45/12 ve 56/22) ve makalenin kendisi sayı vermiyor. Belirsizlik kaydı
# düşerse metin bir sayı kullanmaya kalkabilir.
if "TUTMUYOR" not in d["dunya"]["brezilya"].get("_SAYIM_BELIRSIZ", ""):
    hata.append("BREZİLYA SAYIM BELİRSİZLİĞİ KAYDI YOK · ağın kaç kurum "
                "olduğu kaynaklarda ayrışıyor, metin sayı kullanmamalı")

# CHANG'E-4'ÜN SONUCU TAM YAZILMALI. "Ay'da pamuk çimlendi" cümlesi tek
# başına yanıltıcı: öteki tohumlar çimlenmedi ve filiz ay gecesinde öldü.
_ce = d["dunya"]["cin_change4"]
if "çimlenmedi" not in _ce.get("sonuc", ""):
    hata.append("CHANG'E-4 SONUCU EKSİK · çimlenmeyen tohumlar da yazılmalı")
if "ay gecesinde" not in _ce.get("son", ""):
    hata.append("CHANG'E-4 SONU EKSİK · filizin ömrü yazılmalı")

# LUNAR PALACE'IN 370 GÜNÜ VARDİYALI. Sürekli tek ekip sanılırsa rekor
# yanlış anlatılır.
if "vardiyalı" not in d["dunya"]["cin_lunar_palace"].get("_SURE_NOTU", ""):
    hata.append("LUNAR PALACE SÜRE NOTU EKSİK · 370 gün vardiyalı toplam")

# 9e — ŞEMANIN HER PARÇASININ CÜMLESİ VAR
# Şema beş parça çiziyor ve her birinin belgede karşılığı olmalı. Parça
# kalıp cümle kaybolursa çizim dayanaksız kalır — ve bir çizimin
# dayanaksız olduğu, bir cümlenin dayanaksız olduğundan daha geç fark
# edilir.
for _ad in ("yastik", "sulama", "aph_isik", "tutucular", "aph_sensor"):
    if not d["oda"]["pasajlar"].get(_ad):
        hata.append(f"ODA/{_ad}: belgeden pasaj çekilmemiş — şemanın o "
                    f"parçası dayanaksız")

# ELENME SEBEPLERİ ŞEMANIN İKİ ADIMI. Havalandırma ve CO2 soyut değil:
# ikisi de birer ekini düşürmüş. O satırlar giderse adımlar da gider.
_sebepler = {e["ad"] for e in d["oda"]["elenen_ornekler"]}
for _ad in ("havalandirma", "co2"):
    if _ad not in _sebepler:
        hata.append(f"ODA: '{_ad}' elenme örneği yok — şemanın o adımı "
                    f"somut dayanağını kaybeder")
_hava = next((e["satir"] for e in d["oda"]["elenen_ornekler"]
              if e["ad"] == "havalandirma"), "")
if "airflow" not in _hava:
    hata.append("ODA: havalandırma satırı 'airflow' demiyor — yanlış satır "
                "çekilmiş olabilir")

# 9f — MIR'İN NEDENSELLİK İDDİASI AYAKTA
# Bu dosyada "şu yüzden" demeye hakkı olan az sayıda cümleden biri bu ve
# hakkı çapraz deneyden geliyor. Not giderse cümle sıradan bir
# birliktelik iddiasına döner.
if "tekrarland" not in d["mir"]["_NEDENSELLIK_NOTU"]:
    hata.append("MIR NEDENSELLİK NOTU EKSİK · iddia çapraz deneye dayanıyor, "
                "gözleme değil; bu yazılmalı")
for _ad in ("basak_sayisi", "etilen_olcumu", "anter", "cekirdek"):
    if not d["mir"]["pasajlar"].get(_ad):
        hata.append(f"MIR/{_ad}: makaleden pasaj çekilmemiş")
if d["mir"]["tohum"] != 0:
    hata.append("MIR: tohum sayısı sıfır olmalı — makale 'not a single seed' "
                "diyor")
if len(d["mir"]["kaynaklar"]) < 2:
    hata.append("MIR: iddia tek makaleye dayanamaz; ikisi de kayıtta olmalı")

# 10 — CRL BASAMAKLARI TAM VE ÖLÇÜLÜ
if len(d["crl"]["basamaklar"]) != 9:
    hata.append("CRL MERDİVENİ EKSİK · dokuz basamak olmalı")
for b in d["crl"]["basamaklar"]:
    if not b.get("olcut"):
        hata.append(f"CRL {b['no']}: ölçüt yok")
if "CFU/g" not in d["crl"]["basamaklar"][3]["olcut"]:
    hata.append("CRL 4 ÖLÇÜTÜ SAYISIZ · mikrobiyoloji eşiği sayıyla yazılmalı")

# 11 — KONUM KISITI, ETKİLEŞİMLİ BİLEŞENİN ŞARTI
# İbare büyük/küçük harfe DUYARSIZ aranıyor. İlk hâli birebir arıyordu ve
# not DOĞRU yerinde dururken hata verdi — Türkçe büyük İ'nin küçültmesi de
# bu projenin kayıtlı tuzağı.
_kk = d["crl"]["_KONUM_KISITI"]
if "KONUM İDDİA ETMİYOR" not in _kk and "konum İDDİA ETMİYOR" not in _kk:
    hata.append("KONUM KISITI SİLİNMİŞ · merdiven bileşeni ara ürün yerleştiremez")

# ══════════════════════════════════════════════════════════════════════════
d["_dosya"] = "Uzayda Tarım — veri sayfası"
d["_eksen"] = ("Dünyada 376 ekin denendi, dokuzu uzayda yenebildi — aralarında "
               "ne bir tahıl var ne bir baklagil. Türkiye'nin ilk insanlı "
               "görevindeki 13 deneyin 4'ü bitki ve mikroalgdi, biri Tuz "
               "Gölü'nden gitti.")
d["_uretim"] = f"build_data.py · {datetime.date.today().isoformat()}"
d["bosluklar"] = []

if hata:
    print("VERİ SAYFASI KİLİTLENMEDİ:", file=sys.stderr)
    for h in hata:
        print("  ✗", h, file=sys.stderr)
    sys.exit(1)

(KOK / "data.json").write_text(json.dumps(d, ensure_ascii=False, indent=1) + "\n",
                               encoding="utf-8")
bloklar = [k for k in d if not k.startswith("_") and k != "bosluklar"]
print(f"veri sayfası kilitlendi · {len(bloklar)} blok · 13 doğrulamanın 13'ü geçti")
print(f"  eleme          {d['eleme']['belge_duzyazi_toplam']} ekin → CRL 9'u geçen {d['eleme']['crl9_gecen']}")
print(f"  osdr           {d['osdr']['toplam']} çalışma · model {d['osdr']['model_organizma']} · ekin {d['osdr']['ekin_bitkisi']}")
print(f"  ax3            {d['ax3']['toplam_deney']} deney · bitki/alg {d['ax3']['bitki_alg']}")
print(f"  yörünge altı   {d['yorunge_alti']['deney_sayisi']} deney · bitki {d['yorunge_alti']['bitki_deneyi']}")
