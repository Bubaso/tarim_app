#!/usr/bin/env python3
"""DSİ — ham kaynaklardan `cikarim.json` üretir.

EKSEN: kurum kuraklıktan doğdu, ülkenin su altyapısını kurdu ve kurduğunun
İŞLETMESİNİ elli üç yılda devretti.

TUR 12'DE İKİ ŞEY ÇIKARILDI (kullanıcı kararı, 2 Kasım 2026):
 · "Kanundan kararnameye" ekseni. 2018'de cumhurbaşkanlığı sistemine
   geçilirken BÜTÜN kurumların kuruluş hükümleri kararnamelere taşındı;
   bu DSİ'ye özgü bir bulgu değil, genel bir idari değişiklik. Dosyanın
   eksenine konması yanlıştı.
 · USBR karşılaştırması. Bkz. README tur 12.

"Yapıyor ama işletmiyor" DENMİYOR: DSİ'nin kendi işlettiği ulusal alan hiçbir
kaynakta tek rakam olarak yok (README tur 3/3). İddia devrin ÖLÇEĞİ ve
SÜRESİ ile sınırlı.

HER ALINTI METNE BAĞLANIYOR. Bir ibare kaynakta harfi harfine bulunamazsa
çıkarım DURUR — §2.2'nin "getir, hatırlama" kuralının koddaki karşılığı.
Boşluk toleransı var çünkü PDF çıkarıcısı kelime ortasına işaretsiz boşluk
sokuyor ('kurulmas ına'), §8.14.2'nin altıncı tuzağı.

Çalıştırma: ~/tarim_ai_pipeline/venv/bin/python cikar.py
"""
from __future__ import annotations

import json
import pathlib
import re
import sys

from pypdf import PdfReader

KOK = pathlib.Path(__file__).parent
hata = []


def duz(s: str) -> str:
    return re.sub(r"[ \t]+", " ", s.replace("\xad", ""))


def harf(s: str) -> str:
    """Boşluksuz harf dizisi — PDF'in kelime ortasına soktuğu boşluk
    yüzünden tam eşleşme kırılıyor."""
    return re.sub(r"\s+", "", s).lower()


def pdf(ad: str, bas: int = 0, son: int | None = None) -> str:
    r = PdfReader(KOK / ad)
    say = r.pages[bas:son] if son else r.pages[bas:]
    return duz("\n".join(p.extract_text() or "" for p in say))


def bagla(kaynak: str, ibare: str, iz: str) -> str:
    """Alıntıyı kaynağa bağlar. Bulunamazsa çıkarım durur."""
    if harf(ibare) not in harf(kaynak):
        hata.append(f"ALINTI BAĞLANMADI · {iz} · '{ibare[:60]}'")
    return ibare


# ══ 1. Kanun 6200 — BİRİNCİL ══════════════════════════════════════════════
k6200 = pdf("kanun_6200.pdf")
mulga = sorted({m.group(1) for m in re.finditer(
    r"Madde\s*(\d+)\s*[-–]\s*\(Mülga:\s*2/7/2018\s*[–-]\s*KHK-?703/69", k6200)},
    key=int)
ek_mulga = sorted({m.group(1) for m in re.finditer(
    r"Ek Madde\s*(\d+)\s*[-–].{0,60}?Mülga:\s*2/7/2018\s*[–-]\s*KHK-?703/69", k6200)},
    key=int)
gecici_mulga = sorted({m.group(1) for m in re.finditer(
    r"Geçici Madde\s*(\d+)\s*[-–].{0,60}?Mülga:\s*2/7/2018\s*[–-]\s*KHK-?703/69", k6200)},
    key=int)

kanun = {
    "_kaynak_niteligi": "BİRİNCİL — Kanun 6200, mevzuat.gov.tr tasdikli metin",
    "_kapsam": "Türkiye · yürürlükteki metin",
    "no": 6200,
    "ad": bagla(k6200, "DEVLET SU İŞLERİ GENEL MÜDÜRLÜĞÜNCE YÜRÜTÜLEN", "6200.ad"),
    "kabul_tarihi": "18/12/1953",
    "rg_tarih": "25/12/1953",
    "rg_sayi": 8592,
    "mulga_maddeler": [int(x) for x in mulga],
    "mulga_ek_maddeler": [int(x) for x in ek_mulga],
    "mulga_gecici_maddeler": [int(x) for x in gecici_mulga],
    "mulga_dayanak": "2/7/2018 – KHK-703/69 md.",
    "_mulga_onemi": ("Mülga olanlar arasında Madde 1 (kuruluş), Madde 2 (vazife ve "
                     "salahiyetler) ve Madde 3-7 (teşkilat) var. Kanun kurumun adını "
                     "taşımaya devam ediyor; kurucu maddeleri taşımıyor."),
    "ad_degisikligi_2011": bagla(
        k6200, "Devlet Su İşleri Umum Müdürlüğü Teşkilat ve Vazifeleri Hakkında Kanun",
        "6200.eski_ad"),
}
kanun["mulga_toplam"] = (len(mulga) + len(ek_mulga) + len(gecici_mulga))
for m in (1, 2, 3, 4, 5, 6, 7):
    if m not in kanun["mulga_maddeler"]:
        hata.append(f"6200: Madde {m} mülga listesinde yok — metin değişmiş olabilir")

# ══ 2. CBK 4 — BİRİNCİL ═══════════════════════════════════════════════════
c4 = pdf("cbk_4_bagli_kuruluslar.pdf")
kararname = {
    "_kaynak_niteligi": "BİRİNCİL — Cumhurbaşkanlığı Kararnamesi No. 4",
    "_kapsam": "Türkiye · yürürlükteki metin",
    "no": 4,
    "ad": bagla(c4, "BAKANLIKLARA BAĞLI, İLGİLİ, İLİŞKİLİ KURUM VE KURULUŞLAR", "cbk4.ad"),
    "bolum": "Onuncu Bölüm",
    "madde_amac": 119,
    "madde_kurulus": 120,
    "madde_gorev": 121,
    "kurulus_cumlesi": bagla(
        c4, "Devlet Su İşleri Genel Müdürlüğü kurulmuştur", "cbk4.kurulus"),
    "bagli_oldugu": bagla(c4, "Tarım ve Orman Bakanlığına bağlı", "cbk4.bagli"),
    "_elenen_yol": ("Önce CBK 1'e (Cumhurbaşkanlığı Teşkilatı) bakıldı; 'Su İşleri' "
                    "orada SIFIR kez geçiyor. Metin çıkarımı sağlamdı — 294 sayfa, "
                    "metin çıkmayan sayfa yok. DSİ ana teşkilat kararnamesinde değil."),
}

# ══ 3. Devir dağılımı — KURUMUN BEYANI ════════════════════════════════════
f2025 = PdfReader(KOK / "faaliyet_2025.pdf")
s46 = duz(f2025.pages[46].extract_text() or "")
satirlar = []
for ad in ("Sulama Birliği", "Kooperatif", "Belediye", "Köy Tüzel Kişiliği", "Diğer"):
    m = re.search(rf"{re.escape(ad)}\s+(\d+)\s+(\d+)\s+([\d.]+)\s+([\d,]+)", s46)
    if not m:
        hata.append(f"devir tablosu: '{ad}' satırı okunamadı"); continue
    satirlar.append({
        "devralan": ad,
        "adet": int(m.group(1)),
        "adet_yuzde": int(m.group(2)),
        "alan_ha": int(m.group(3).replace(".", "")),
        "alan_yuzde": float(m.group(4).replace(",", ".")),
    })
mt = re.search(r"TOPLAM\s+(\d+)\s+100\s+([\d.]+)\s+100", s46)
devir = {
    "_kaynak_niteligi": "KURUMUN BEYANI — DSİ 2025 Faaliyet Raporu, Tablo 14, s. 47",
    "_kapsam": "Türkiye · BÜTÜN sulama tesisleri · 31.12.2025",
    "tarih": "2025-12-31",
    "satirlar": satirlar,
    "toplam_adet": int(mt.group(1)) if mt else None,
    "toplam_alan_ha": int(mt.group(2).replace(".", "")) if mt else None,
}

# ══ 4. Devir serisi — KURUMUN BEYANI, KAPSAMI DAR ═════════════════════════
b = PdfReader(KOK / "istatistik_2021.pdf")
s62 = duz(b.pages[62].extract_text() or "")
seri = {}
for m in re.finditer(r"\b(19[6-9]\d|20[0-2]\d)\s+(\d{1,4})\s+(\d{1,5})\s+([\d.]+)\b", s62):
    y, u, _, a = m.groups()
    seri[int(y)] = {"unite": int(u), "alan_ha": int(a.replace(".", ""))}
devir_serisi = {
    "_kaynak_niteligi": "KURUMUN BEYANI — DSİ 2021 Haritalı İstatistik Bülteni, s. 62",
    "_kapsam": ("Türkiye · YALNIZCA YERALTISUYU (YAS) tesisleri · kat'i devir "
                "sözleşmesi imzalananların kümülatifi"),
    "_kapsam_uyarisi": ("Bu seri devir_dagilimi ile TOPLANMAZ ve onun yerine "
                        "KULLANILMAZ. Sütun başlığı 'Devredilen Kuyu Sayısı'; bu "
                        "YAS tesisleri, ötekiyse bütün sulama tesisleri."),
    "_isletilen_devredilen_ayrimi_sayfa": 64,
    "_ayrim_notu": "Bülten s. 64 (Çizelge 15-4) DSİ'ce işletilen ve devredilen "
                   "sulamaları ayrı ayrı listeliyor ama tesis tesis; ulusal "
                   "toplam yayımlanmıyor. Kaynakçada bu sayfa anılıyor.",
    "_atlanan": ("1999 satırının ünite değeri (151) kaynakta HATALI: 1998'de 1.187, "
                 "2000'de 1.295. Kümülatif seride düşüş imkânsız. Alan sütunu "
                 "düzgün ilerliyor, o kullanılıyor; ünite değeri metne girmiyor."),
    "kayitlar": [{"yil": y, **seri[y]} for y in sorted(seri)],
}
if 1999 in seri:
    devir_serisi["kayitlar"] = [
        {**k, "unite": None} if k["yil"] == 1999 else k
        for k in devir_serisi["kayitlar"]]

# ══ 5. Kuruluş silsilesi — KURUMUN BEYANI ═════════════════════════════════
ham = (KOK / "site_hakkimizda.html").read_text(encoding="utf-8", errors="replace")
govde = re.sub(r"<(script|style)[^>]*>.*?</\1>", " ", ham, flags=re.S | re.I)
govde = re.sub(r"\s+", " ", re.sub(r"<[^>]+>", " ", govde))
SILSILE_GOVDE = govde

silsile = {
    "_kaynak_niteligi": "KURUMUN BEYANI — dsi.gov.tr/Sayfa/Detay/692 (Hakkımızda)",
    "_kapsam": "Türkiye · kurumsal silsile",
    "_not": ("Kuruluş tarihi kanun metniyle BAĞIMSIZ OLARAK örtüşüyor: kanun "
             "18/12/1953 kabul diyor, kurum 18 Aralık 1953 diyor. İki ayrı "
             "kaynak, aynı tarih."),
    "adimlar": [
        {"yil": 1914, "ad": bagla(govde, "Nafıa Nezareti", "silsile.1914"),
         "aciklama": "su işlerinin örgütlü biçimde ele alınması"},
        {"yil": 1925, "ad": bagla(govde, "Sular Fen Heyeti", "silsile.1925"),
         "aciklama": "Umur-u Nafıa Müdüriyet-i Umumiyesi'ne bağlı"},
        {"yil": 1929, "ad": bagla(govde, "Sular Umum Müdürlüğü", "silsile.1929"),
         "aciklama": bagla(govde, "şiddetli kuraklık ve kıtlık", "silsile.1929.sebep")},
        {"yil": 1953, "ad": "Devlet Su İşleri Genel Müdürlüğü",
         "aciklama": bagla(govde, "18 Aralık 1953", "silsile.1953")},
    ],
    "teskilatlanma_yili": 1954,
}

# ══ 6. Ölçek — KURUMUN BEYANI ═════════════════════════════════════════════
f25 = duz("\n".join((q.extract_text() or "") for q in f2025.pages))

def sayi(desen, iz, ondalik=False):
    m = re.search(desen, f25, re.I)
    if not m:
        hata.append(f"ÖLÇEK OKUNAMADI · {iz}"); return None
    ham_s = m.group(1)
    return (float(ham_s.replace(".", "").replace(",", "."))
            if ondalik else int(ham_s.replace(".", "")))

olcek = {
    "_kaynak_niteligi": "KURUMUN BEYANI — DSİ 2025 Faaliyet Raporu",
    "_kapsam": "Türkiye · 2025 yıl sonu, kümülatif",
    "sulanabilir_arazi_milyon_ha": 8.5,
    "_sulanabilir_alinti": bagla(
        f25, "sulanabilir tarım arazisi miktarı", "olcek.sulanabilir"),
    "hedef_2028_brut_milyon_ha": 5.56,
    "_hedef_alinti": bagla(
        f25, "sulama şebekesi tamamlanan alan brüt", "olcek.hedef"),
    "baraj_adet": sayi(r"inşa edilen baraj sayısı\s*\(kümülatif\)\s*Adet\s*[\d.]+\s+([\d.]+)", "baraj"),
    "golet_adet": sayi(r"inşa edilen gölet sayısı\s*\(kümülatif\)\s*Adet\s*[\d.]+\s+([\d.]+)", "gölet"),
    "sulama_tesisi_adet": sayi(r"Tamamlanacak sulama tesisi \(kümülatif\)\s*Adet\s*[\d.]+\s+([\d.]+)", "tesis"),
    "depolama_hm3": sayi(r"Su depolama kapasitesi \(kümülatif\)\s*hm3\s*[\d.,]+\s+([\d.,]+)", "depolama", True),
}

# ══ 7. Kanun 6172 — BİRİNCİL ══════════════════════════════════════════════
# Tur 7 sonunda eklendi. §7 ve §9'un omurgası buradan geliyor ve dosyanın
# EN GÜÇLÜ bulgusu bir VARLIK değil bir YOKLUK: kanunun tamamında "mülkiyet"
# kelimesi hiç geçmiyor. Yokluk da ölçülebilir bir kalemdir — sayılıyor ve
# sayı veri katmanında duruyor ki metin onu bellekten iddia etmesin.
k6172 = pdf("kanun_6172_sulama_birlikleri.pdf")

mulkiyet_sayisi = len(re.findall(r"[Mm]ülkiyet", k6172))
if mulkiyet_sayisi:
    # Bulunursa iddia ÇÜRÜR; metin yazılmadan önce durmalı.
    hata.append(f"6172'de 'mülkiyet' {mulkiyet_sayisi} kez geçiyor — §7'nin iddiası yanlış")

kanun_6172 = {
    "_kaynak_niteligi": "BİRİNCİL — Kanun 6172, mevzuat.gov.tr tasdikli metin",
    "_kapsam": "Türkiye · yürürlükteki metin",
    "no": 6172,
    "ad": "SULAMA BİRLİKLERİ KANUNU",
    "kabul_tarihi": "8/3/2011",
    "rg_tarih": "22/3/2011",
    "rg_sayi": 27882,
    "mulkiyet_gecis_sayisi": mulkiyet_sayisi,
    "_mulkiyet_notu": "SIFIR. Kanun devri tanımlıyor ama devredilen şeyler arasında mülkiyet yok.",
    "devir_tanimi": bagla(
        k6172,
        "işletme, bakım, onarım ve yönetim sorumluluğunun",
        "6172.devir_tanimi"),
    "devir_tanimi_tam": bagla(
        k6172,
        "Devir: DSİ tarafından inşa edilmiş veya halen inşa edilmekte olan ya da "
        "inşa edilmesi planlanan sulama maksatlı tesislerin işletme, bakım, onarım "
        "ve yönetim sorumluluğunun, DSİ ve birlik arasında imzalanan sözleşme "
        "hükümleri uyarınca birliklere devredilmesini",
        "6172.devir_tanimi_tam"),
    "_devir_tanimi_yeri": "Madde 2/e (Tanımlar)",
    "sinir_dsi_belirler": bagla(
        k6172,
        "sınırları, kapsamı ve ismi DSİ tarafından belirlenir",
        "6172.sinir"),
    "_sinir_yeri": "Madde 3/1 — devirden sonra da görev alanını DSİ çiziyor",
    "kar_gayesi": bagla(
        k6172, "kâr gayesi güdülemez", "6172.kar_gayesi"),
    "_kar_gayesi_yeri": "Madde 10/2",
    "yatirim_bedeli_geri_odeme": bagla(
        k6172,
        "Devraldığı tesislerin yatırım bedellerini geri ödemek",
        "6172.yatirim_bedeli"),
    "_yatirim_bedeli_yeri": "Madde 3/4-c — devralan taraf tesisin yatırım bedelini de geri ödüyor",
    "gelir_tahsisi": bagla(
        k6172,
        "işletme, bakım, onarım ve yönetim sorumluluğu devralınan tesis için sarf edilir",
        "6172.gelir_tahsisi"),
    "_gelir_tahsisi_yeri": "Madde 10/3 — toplanan paranın tamamı o tesise geri dönüyor",
    # § 7'nin gündelik karşılığı. EK MADDE 1 — 2011 kanununda YOKTU,
    # 19/4/2018 tarihli 7139 s. Kanunla eklendi. Aynı yıl 6200'ün kuruluş
    # maddeleri de mülga oldu; 2018 bu dosyada iki kere geçiyor.
    "uyelik_zorunlu": bagla(
        k6172,
        "Birlik görev alanında yer alan her su kullanıcısı gerçek ve tüzel kişi "
        "sulama tesisinden faydalanabilmek için o birliğe üye olmak zorundadır",
        "6172.uyelik"),
    "_uyelik_yeri": "Ek Madde 1/1 (Ek: 19/4/2018-7139/51 md.)",
    "katilim_payi": bagla(
        k6172,
        "İlk üyelik kaydı sırasında bir defaya mahsus olmak üzere",
        "6172.katilim_payi"),
    "_katilim_payi_yeri": "Ek Madde 1/2",
    "ekim_planlamasi": bagla(
        k6172,
        "su yetersizliğine bağlı olarak yapılan ekim planlamasına uymak",
        "6172.ekim_planlamasi"),
    "munavebe": bagla(
        k6172,
        "sulama planlaması ve su dağıtım ve münavebe programlarına katılmak",
        "6172.munavebe"),
    "arazi_girisi": bagla(
        k6172,
        "arazisine girilmesine izin vermek",
        "6172.arazi_girisi"),
    # § 7'nin para tarafı. Birliğin gelir kalemleri Madde 11'de sayılı;
    # devredilen tesisin masrafını kimin karşıladığını bunlar söylüyor.
    "gelir_katilim_payi": bagla(k6172, "Katılım payı", "6172.gelir_a"),
    "gelir_su_hizmet_bedeli": bagla(
        k6172, "Su kullanım hizmet bedeli", "6172.gelir_b"),
    "gelir_yatirim_geri_odeme": bagla(
        k6172, "Yatırım bedellerine ilişkin geri ödeme katkı payı", "6172.gelir_c"),
    "gelir_idari_para_cezasi": bagla(
        k6172, "idari para cezaları", "6172.gelir_d"),
    "_gelir_yeri": "Madde 11/1 — altı kalem; dördü doğrudan su kullanıcısından",
    "_ek_madde_notu": "Üyelik, ekim planına uyma ve araziye giriş izni aynı fıkrada. "
                      "Kurumla karşılaşma noktası burası: çiftçi suyu birlikten alıyor, "
                      "birliğe üye olmak zorunda, ve suyun azaldığı yıl ne ekeceği "
                      "planlamaya bağlanıyor.",
}

# ══ 9. Büyük projeler — KURUMUN BEYANI ════════════════════════════════════
# Kullanıcı isteği (2 Kasım 2026): "DSİ'nin tarihe damgasını vuran çok büyük
# baraj ve bölge sulandırma projeleri var, yıllar aldı bu projeler" — bunların
# hepsini taşıyan ayrı bir bölüm.
#
# YILLARI NEREDEN ALDIK, ÖNEMLİ: tek tek barajların işletmeye açılış yılları
# elimizdeki hiçbir belgede tablo hâlinde YOK (bülten 793 sayfa tarandı, baraj
# envanteri çizelgesi bulunmuyor). Uydurmak yerine kurumun KENDİ TEŞKİLAT
# ÇİZELGESİ kullanıldı: Ek Çizelge 2-1 her taşra biriminin kuruluş tarihini
# veriyor ve bu birimler projelerin adını taşıyor. "Aşağı Fırat Projesi 15.
# Bölge Müdürlüğü · 24.05.1976" bir baraj açılışı değil ama o projenin ne
# zaman kendi idaresini kurduğunu BELGELİ olarak söylüyor. Metinde de böyle
# yazılır: açılış yılı diye sunulmaz.
f25 = pdf("faaliyet_2025.pdf")
teskilat = pdf("istatistik_2021.pdf", 93, 104)
tsk = (KOK / "site_toprak_su_kaynaklari.html").read_text(
    encoding="utf-8", errors="replace")
tsk = re.sub(r"<(script|style)[^>]*>.*?</\1>", " ", tsk, flags=re.S | re.I)
tsk = re.sub(r"\s+", " ", re.sub(r"<[^>]+>", " ", tsk))


def _birim(ibare: str, tarih: str, iz: str) -> dict:
    bagla(teskilat, ibare, f"proje.{iz}")
    bagla(teskilat, tarih, f"proje.{iz}.tarih")
    g, a, y = tarih.split(".")
    return {"birim": ibare, "tarih": tarih, "yil": int(y)}


buyuk_projeler = {
    "_kaynak_niteligi": ("KURUMUN BEYANI — DSİ 2025 Faaliyet Raporu, 2021 "
                         "Haritalı İstatistik Bülteni Ek Çizelge 2-1, ve "
                         "dsi.gov.tr Toprak ve Su Kaynakları sayfası"),
    "_kapsam": "Türkiye · bölgesel projeler 2025, teşkilat tarihleri Şubat 2020",

    # ── Üç bölgesel proje ──────────────────────────────────────────────────
    "gap": {
        "ad": "Güneydoğu Anadolu Projesi",
        "il_sayisi": 9,
        "nufus_milyon": 9.59,
        "demet_sayisi": 13,
        "demet_firat": 7,
        "demet_dicle": 6,
        "kurulu_guc_mw": 7461,
        "yillik_enerji_milyar_kwh": 27.3,
        "hedef_sulama_milyon_ha": 1.058,
        "enerji_gerceklesme_yuzde": 91,
        "sulama_gerceklesme_yuzde": 64,
        "_alinti": bagla(f25, "13 adet proje demetinden oluşmaktadır", "gap.demet"),
        "_firat_barajlari": ["Keban", "Karakaya", "Atatürk", "Birecik", "Karkamış"],
        "_dicle_barajlari": ["Batman", "Kralkızı", "Dicle", "Ilısu"],
        "_barajlar_alinti": bagla(
            f25,
            "Fırat Nehri üzerinde Keban, Karakaya, Atatürk, Birecik, "
            "Karkamış Baraj ve HES\u2019leri ile Dicle Nehri ve kolları üzerinde "
            "ise Batman, Kralkızı, Dicle, Ilısu Baraj ve HES\u2019leri",
            "gap.barajlar"),
    },
    "dap": {
        "ad": "Doğu Anadolu Projesi",
        "il_sayisi": 15,
        "nufus_milyon": 6.53,
        "hedef_sulama_ha": 1377656,
        "isletmede_ha": 602436,
        "isletmede_yuzde": 44,
        "insaat_ha": 263857,
        "planlama_ha": 511363,
        "sulanabilir_arazi_payi_yuzde": 16,
        "_alinti": bagla(
            f25, "1.377.656 hektar alanın sulamaya açılması", "dap.hedef"),
    },
    "kop": {
        "ad": "Konya Ovası Projesi",
        "il_sayisi": 8,
        "alan_km2": 96627,
        "turkiye_yuzolcumu_payi_yuzde": 12.4,
        "nufus_milyon": 4.68,
        "yillik_yagis_mm": 400,
        "turkiye_ortalamasindan_eksik_yuzde": 30,
        "toplam_sulama_ha": 1647239,
        "isletmede_yus_ha": 717817,
        "isletmede_yas_ha": 519601,
        "kalan_ha": 409821,
        "_transfer_alinti": bagla(
            f25, "Mavi Tünel vasıtasıyla su aktarılması", "kop.tunel"),
        "yaklasik_sulanan_yuzde": 75,
        "_sulanan_alinti": bagla(
            f25, "yaklaşık %75", "kop.sulanan"),
        "_sulanan_notu": "Raporun KENDİ yuvarlaması. Dilimlerden hesaplanan "
                         "değer %75,1; metinde raporun rakamı kullanılıyor.",
        "_yagis_alinti": bagla(
            f25, "Türkiye ortalamasından yaklaşık %30 daha eksik yağış",
            "kop.yagis"),
    },

    # ── En büyük rezervuarlar (yüzey alanı) ────────────────────────────────
    # DİKKAT: bunlar YÜZEY ALANI, depolama hacmi değil. İkisi karıştırılırsa
    # sıralama değişir ve hata sessiz olur.
    "en_genis_rezervuarlar": [
        {"ad": "Atatürk", "yuzey_km2": 817},
        {"ad": "Keban", "yuzey_km2": 675},
        {"ad": "Ilısu", "yuzey_km2": 313},
        {"ad": "Karakaya", "yuzey_km2": 268},
        {"ad": "Hirfanlı", "yuzey_km2": 263},
    ],
    "_rezervuar_alinti": bagla(
        tsk,
        "Atatürk Barajı 817 km2, Keban Barajı 675 km2, Ilısu Barajı 313 km2, "
        "Karakaya Barajı 268 km2, Hirfanlı Barajı 263 km2 yüzey alanına "
        "sahiptir",
        "rezervuar"),
    "isletmedeki_baraj_adet": 861,
    "_isletmedeki_baraj_uyarisi": (
        "861 İŞLETMEDEKİ baraj sayısı (kurumun Toprak ve Su Kaynakları "
        "sayfası). Faaliyet raporundaki 1.081 ise İNŞA EDİLEN kümülatif "
        "sayı. İKİSİ AYNI ŞEY DEĞİL ve aynı cümlede yan yana yazılmaz — "
        "§2.2.1'in klasik sessiz hatası."),

    # ── Projelerin takvimi: kurumun kendi teşkilat çizelgesinden ───────────
    "teskilat_takvimi": [
        _birim("Aşağı Seyhan Ovası Sulaması İşletme ve Bakım Şube Müdürlüğü",
               "7.06.1967", "seyhan"),
        _birim("Konya Ovası Sulaması İşletme ve Bakım Şube Müdürlüğü",
               "3.07.1968", "konya"),
        _birim("DSİ Aşağı Fırat Projesi 15.Bölge Müdürlüğü",
               "24.05.1976", "firat"),
        _birim("Aşağı Ceyhan Ovası Sulaması İşletme ve Bakım Şube Müdürlüğü",
               "27.06.1977", "ceyhan"),
        _birim("Keban Barajı Su Ürünleri Şube Müdürlüğü", "1.09.1980", "keban"),
        _birim("Şanlıurfa Ovaları Sulaması Şube Müdürlüğü", "10.01.1986", "urfa"),
        _birim("Şanlıurfa Tüneli ve Harran Kanalı Başmühendisliği",
               "10.07.1993", "tunel"),
        _birim("DSİ Çoruh Projeleri 26.Bölge Müdürlüğü", "13.06.1998", "coruh"),
        _birim("DSİ Ilısu Projesi 16.Bölge Müdürlüğü", "10.11.2008", "ilisu"),
        _birim("Atatürk Barajı İşletme Başmühendisliği", "2.02.2012", "ataturk"),
        _birim("Silvan Proje Müdürlüğü", "24.09.2014", "silvan"),
    ],
    "_takvim_notu": ("Bunlar BİRİM KURULUŞ tarihleridir, baraj açılış tarihleri "
                     "DEĞİL. Metinde de öyle yazılır. Kurum bir projeye kendi "
                     "idaresini kurduğunda o projenin artık sürekli bir iş "
                     "olduğunu kabul etmiş oluyor; ölçtüğümüz şey bu."),

    # ── İlk iki bölge müdürlüğü baraj yerindeydi ───────────────────────────
    "_ilk_bolgeler_alinti": bagla(
        SILSILE_GOVDE,
        "Seyhan ve Hirfanlı\u2019da da 2 adet olmak üzere toplam 12 adet Bölge "
        "Müdürlüğü",
        "ilk_bolgeler"),
    "ilk_bolge_sayisi": 12,
    "yururluge_giris": "28.02.1954",
}

# ══ 10. Dünyada benzeri — BİRİNCİL (FAO) ══════════════════════════════════
# Bu blok TUR 13'te eklendi ve bir önceki denemenin yerine geçti.
#
# TUR 7'DE YANLIŞ SORU SORULMUŞTU. ABD'nin Bureau of Reclamation'ı alınıp
# "reserved works / transferred works" hukuki ayrımı üzerinden bir bölüm
# yazılmıştı; kullanıcı haklı olarak zorlama buldu. Sorulması gereken şey
# basitti: BAŞKA ÜLKELERDE DSİ'NİN KARŞILIĞI VAR MI?
#
# Cevap: var, ve DSİ'nin yaptığı devrin uluslararası bir adı var —
# "irrigation management transfer" (IMT). FAO'nun 2007 tarihli sonuç
# raporunun 1 numaralı eki, aynı devri yapmış ülkeleri tek tabloda
# sayıyor ve TÜRKİYE DE O TABLODA.
#
# İlk denemede bulunamamasının sebebi yöntemdi: yalnızca kurumların ana
# sayfaları curl ile denenmişti (çoğu JavaScript kabuğu), arama hiç
# yapılmamıştı. Ders README tur 13'te.
fao_k = pdf("fao_devir_kilavuz.pdf")
fao_s = PdfReader(KOK / "fao_devir_sonuclar.pdf")
# Ek 1'in sayfası "Turkey" ile "govt" birlikte geçen tek sayfa; "Annex 1"
# ibaresi çıkarıcıda satır sonlarına bölünebiliyor, o yüzden ona bakılmıyor.
ek1 = next(duz(x) for x in ((p.extract_text() or "") for p in fao_s.pages)
           if "Turkey" in x and "govt" in x)

# Tablodaki her ülke adı belgeye tek tek bağlanıyor; elle liste yazıp
# "orada vardır" demek §2.2'nin yasakladığı şey.
_ulkeler = [
    "Albania", "Argentina", "Armenia", "Australia", "Bangladesh", "Bulgaria",
    "China", "Colombia", "Costa Rica", "Dominican Republic", "Ecuador",
    "Ghana", "India", "Indonesia", "Kyrgyz Republic", "Mali", "Mexico",
    "Morocco", "Nepal", "New Zealand", "Niger", "Pakistan", "Peru",
    "Philippines", "Romania", "Senegal", "Sri Lanka", "Sudan", "Tunisia",
    "Turkey", "United States of America", "Uzbekistan", "Zimbabwe",
]
for u in _ulkeler:
    bagla(ek1, u, f"dunya.ulke.{u}")

dunya = {
    "_kaynak_niteligi": ("BİRİNCİL — FAO, Transfer of irrigation management "
                         "services: guidelines (x2586e) ve Irrigation "
                         "management transfer: results (a1520e, Ek 1)"),
    "_kapsam": "Dünya · FAO'nun ülke profili anketi",
    "tanim": bagla(
        fao_k,
        "The term ‘irrigation management transfer’ means the relocation of "
        "responsibility and authority for irrigation management from "
        "government agencies to non-governmental organizations, such as "
        "water users’ associations",
        "dunya.tanim"),
    "_tanim_yeri": "Guidelines, Giriş — 'WHAT IS IRRIGATION MANAGEMENT TRANSFER'",
    "ayrim": bagla(
        fao_k,
        "IMT is the transfer of responsibility for irrigation management from "
        "one organization to another",
        "dunya.ayrim"),
    "_ayrim_notu": ("FAO devri ÂDEM-İ MERKEZİYETTEN ayırıyor: âdem-i merkeziyet "
                    "kararı aynı teşkilatın içinde aşağı taşır, devir onu "
                    "BAŞKA bir tüzel kişiye verir. 6172'nin yaptığı ikincisi."),
    "ulkeler": _ulkeler,
    "ulke_sayisi": len(_ulkeler),
    "turkiye_satiri": bagla(
        ek1, "Turkey National All govt. schemes Distributary Full",
        "dunya.turkiye"),
    "_turkiye_satiri_okunusu": ("Ulusal düzeyde · bütün kamu tesisleri · "
                                "devredilen en üst hidrolik kademe: tersiyer "
                                "(distributary) · işletme-bakım yetkisi: TAM"),
    "tablo_basligi": bagla(ek1, "Types of IMT programmes in", "dunya.baslik"),
    "filipinler": bagla(
        fao_k,
        "the Philippines converted its National Irrigation Administration into "
        "a financial autonomous entity in the 1970s",
        "dunya.filipinler"),
    "_filipinler_notu": ("Filipinler'in kurumu adıyla geçiyor: National "
                         "Irrigation Administration. FAO aynı yerde kurumun "
                         "tahsilatının %70'i aştığını yazmıyor — kendini tam "
                         "finanse edemediğini yazıyor."),
}


cikti = {
    "_dosya": "DSİ — Kurum Dosyası Sayı 05 · ham çıkarım",
    "_uretim": "cikar.py — elle düzenlenmez",
    "kanun": kanun,
    "kararname": kararname,
    "devir_dagilimi": devir,
    "devir_serisi": devir_serisi,
    "kurulus_silsilesi": silsile,
    "olcek": olcek,
    "kanun_6172": kanun_6172,
    "buyuk_projeler": buyuk_projeler,
    "dunya": dunya,
}

if hata:
    print("ÇIKARIM DURDU:\n", file=sys.stderr)
    for h in hata:
        print("  ✗ " + h, file=sys.stderr)
    sys.exit(1)

(KOK / "cikarim.json").write_text(
    json.dumps(cikti, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
print(f"✓ cikarim.json · 6200 mülga {kanun['mulga_toplam']} madde · "
      f"devir {devir['toplam_adet']} tesis / {devir['toplam_alan_ha']:,} ha · "
      f"seri {len(devir_serisi['kayitlar'])} yıl".replace(",", "."))
