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


cikti = {
    "_dosya": "DSİ — Kurum Dosyası Sayı 05 · ham çıkarım",
    "_uretim": "cikar.py — elle düzenlenmez",
    "kanun": kanun,
    "kararname": kararname,
    "devir_dagilimi": devir,
    "devir_serisi": devir_serisi,
    "kurulus_silsilesi": silsile,
    "olcek": olcek,
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
