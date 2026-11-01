#!/usr/bin/env python3
"""DSİ — ham kaynaklardan `cikarim.json` üretir.

EKSEN (tur 3 sonunda kilitlendi): kurum kuraklıktan doğdu, ülkenin su
altyapısını kurdu, kurduğunun İŞLETMESİNİ elli dört yılda devretti, ve
2018'de kendi KURULUŞ METNİ de kanundan kararnameye devredildi.

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

# ══ 8. USBR — BİRİNCİL (Reclamation Manual) ═══════════════════════════════
# §9'un karşılaştırması. ÖNEMLİ DÜZELTME: README tur 7 "üçte iki oranını
# birincil belgede DOĞRULAYAMADIM, metne girmez" diye kaydetmişti. Oran
# FAC 01-09'un 1/C fıkrasında harfi harfine duruyor ve belge zaten
# indirilmişti — arama sonuçlarına değil, elimizdeki PDF'in kendisine
# bakılmamıştı. §2.2'nin "getir, hatırlama" kuralı burada ters yönde
# çalıştı: doğru bilgi vardı, bellekteki "doğrulanamadı" notu onu bloke etti.
usbr = {
    "_kaynak_niteligi": "BİRİNCİL — Bureau of Reclamation, Reclamation Manual FAC 01-09",
    "_kapsam": "ABD · yürürlükteki yönerge (04/04/2017, revizyon 02/25/2026)",
    "belge": "FAC 01-09 — Reporting Deferred Maintenance and Repairs",
    "reserved_works_tanimi": bagla(
        pdf("usbr_fac01-09.pdf"),
        "Reserved Works. Reclamation-owned facilities for which Reclamation "
        "manages and performs O&M",
        "usbr.reserved"),
    "transferred_works_tanimi": bagla(
        pdf("usbr_fac01-09.pdf"),
        "Transferred Works. Reclamation-owned facilities for which the "
        "responsibility to manage and perform O&M has been transferred by "
        "contract or agreement to a non-federal operating entity",
        "usbr.transferred"),
    "oran_cumlesi": bagla(
        pdf("usbr_fac01-09.pdf"),
        "Approximately one-third of Reclamation’s constructed assets, referred "
        "to as reserved works",
        "usbr.oran"),
    "oran_cumlesi_devami": bagla(
        pdf("usbr_fac01-09.pdf"),
        "The remaining two-thirds of Reclamation’s constructed assets, referred "
        "to as transferred works",
        "usbr.oran2"),
    "reserved_pay": "üçte bir",
    "transferred_pay": "üçte iki",
    "_oran_notu": "Oran belgenin kendi cümlesinde 'approximately' ile veriliyor; "
                  "metinde de yaklaşık olarak yazılır, yüzdeye çevrilmez.",
    "om_operating_entities": bagla(
        pdf("usbr_fac01-09.pdf"),
        "O&M is planned and managed by operating entities",
        "usbr.om"),
    "_mulkiyet_vurgusu": "İki tanım da 'Reclamation-owned facilities' diye başlıyor: "
                         "devredilen O&M, mülkiyet kurumda kalıyor. 6172'de mülkiyet "
                         "kelimesinin HİÇ geçmemesiyle aynı yere çıkıyor — biri "
                         "söyleyerek, öteki susarak.",
}

# İkinci USBR belgesi. Devirden SONRA merkezî kurumda ne kaldığını
# gösteriyor: köprü denetimi sorumluluğu devredilmiş tesislerde de
# Reclamation'da. 6172'nin "sınırları DSİ belirler" maddesinin karşılığı.
_u7 = pdf("usbr_fac07-01.pdf")
usbr["belge_2"] = "FAC 07-01 — Transportation Program"
usbr["kopru_denetimi"] = bagla(
    _u7,
    "inform operating entities, under their jurisdiction, of Reclamation’s "
    "bridge inspection responsibilities",
    "usbr.kopru")
usbr["_kopru_notu"] = ("Devredilmiş tesiste bile köprü denetimi merkezî kurumda. "
                       "Devir bir kopuş değil, sorumluluğun bölünmesi.")


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
    "usbr": usbr,
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
