#!/usr/bin/env python3
"""DSİ — çekilen her kaynağın KİMLİĞİNİ sınar.

NEDEN AYRI BİR BETİK. §8.14.2'de dizinin en tehlikeli sessiz hatası yazılı:
Resmî Gazete nüshasında iki kanun yan yana duruyordu, ikisi de aynı cümleyle
açılıyordu ve arama yanlış kanunun maddesini buldu. Oradaki kural: doğrulayıcı
üreticiden fonksiyon İÇE AKTARMAZ — normalleştirmeyi de baştan yazar. Ortak
yardımcı paylaşılsaydı ikisi de aynı yönde yanılırdı.

NE SINANIYOR
  · PDF gerçekten beklenen kanun mu (kanun numarası + kabul tarihi + RG)
  · Faaliyet raporu gerçekten DSİ'nin ve beklenen yılın mı
  · HTML sayfası YUMUŞAK 404 mü — kurum siteleri bilinmeyen adreste
    anasayfayı 200 ile veriyor (§8.14.1). Boyut yetmez; sayfanın kendi
    başlığı aranır.

Çalıştırma:  ~/tarim_ai_pipeline/venv/bin/python dogrula_kaynak.py
"""
import pathlib
import re
import sys

from pypdf import PdfReader

KOK = pathlib.Path(__file__).parent


def duzelt(s: str) -> str:
    """PDF çıkarıcısının bozdukları. §8.14.2'nin altıncı tuzağı: kelime
    ortasına İŞARETSİZ boşluk giriyor ('kurulmas ına'). Yumuşak tirenin
    aksine silinecek bir karakter yok, o yüzden sıkı eşleşmede bütün
    boşluklar atılır. Burada yalnızca normalleştirme var; dilimleme yok."""
    s = s.replace("\xad", "")               # yumuşak tire
    s = re.sub(r"[ \t]+", " ", s)
    return s


def harfler(s: str) -> str:
    return re.sub(r"\s+", "", s).lower()


def pdf_metni(ad: str, sayfa: int = 3) -> str:
    r = PdfReader(KOK / ad)
    return duzelt("\n".join(p.extract_text() or "" for p in r.pages[:sayfa]))


hata, rapor = [], []

# ── Kanunlar ──────────────────────────────────────────────────────────────
KANUNLAR = {
    "kanun_6200.pdf": {
        "no": "6200", "kabul": "18/12/1953",
        "rg_tarih": "25/12/1953", "rg_sayi": "8592",
        "baslik": "DEVLET SU İŞLERİ GENEL MÜDÜRLÜĞÜNCE YÜRÜTÜLEN",
        "komsu_olmamali": "SULAMA BİRLİKLERİ KANUNU",
    },
    "kanun_6172_sulama_birlikleri.pdf": {
        "no": "6172", "kabul": "8/3/2011",
        "rg_tarih": "22/3/2011", "rg_sayi": "27882",
        "baslik": "SULAMA BİRLİKLERİ KANUNU",
        "komsu_olmamali": "DEVLET SU İŞLERİ GENEL MÜDÜRLÜĞÜNCE",
    },
}

for ad, b in KANUNLAR.items():
    if not (KOK / ad).exists():
        hata.append(f"{ad}: dosya yok"); continue
    t = pdf_metni(ad)
    h = harfler(t)
    if harfler(b["baslik"]) not in h:
        hata.append(f"{ad}: başlık bulunamadı — beklenen '{b['baslik'][:40]}'")
    # KOMŞU BELGE SINAMASI (§8.14.2): dilimin yanlış kanuna kaymadığını
    # kanıtlıyor. İki kanun aynı nüshada olmasa da kural aynı kalıyor.
    if harfler(b["komsu_olmamali"]) in h:
        hata.append(f"{ad}: ÖTEKİ kanunun başlığı da bu metinde — belge karışmış")
    for alan, desen in (("no", rf"Kanun\s*Numaras[ıi]\s*[:.]?\s*{b['no']}\b"),
                        ("kabul", rf"Kabul\s*Tarihi\s*[:.]?\s*{re.escape(b['kabul'])}"),
                        ("rg", rf"Tarih\s*[:.]?\s*{re.escape(b['rg_tarih'])}.{{0,30}}"
                               rf"Say[ıi]\s*[:.]?\s*{b['rg_sayi']}")):
        if not re.search(desen, t):
            hata.append(f"{ad}: {alan} doğrulanamadı")
    rapor.append(f"  {ad:<34s} {b['no']} · kabul {b['kabul']} · RG {b['rg_tarih']}/{b['rg_sayi']}")

# ── Faaliyet raporları ────────────────────────────────────────────────────
for yil in (2025, 2022, 2019):
    ad = f"faaliyet_{yil}.pdf"
    if not (KOK / ad).exists():
        hata.append(f"{ad}: dosya yok"); continue
    r = PdfReader(KOK / ad)
    t = duzelt("\n".join(p.extract_text() or "" for p in r.pages[:6]))
    if "DEVLET SU İŞLERİ" not in t.upper() and "DSİ" not in t.upper():
        hata.append(f"{ad}: DSİ belgesi olduğu doğrulanamadı")
    if str(yil) not in t:
        hata.append(f"{ad}: {yil} yılı metinde geçmiyor")
    rapor.append(f"  {ad:<34s} {len(r.pages)} sayfa")

# ── HTML sayfaları — yumuşak 404 ──────────────────────────────────────────
# site_tarihce.html DİYE BİR ŞEY YOK. /Sayfa/Detay/754'ü "tarihçe" diye
# indirmiştim; doğrulayıcı reddetti ve sayfanın aslında "Toprak Su
# Kaynakları" olduğu çıktı. Kurumsal tarih ayrı bir sayfada değil,
# hakkımızda'nın içinde (1914 → 1925 → 1929 → 1953 silsilesi).
# Dosya adı neyi taşıdığını söylemek zorunda; varsayımla ad verilmez.
SAYFALAR = {
    "site_toprak_su_kaynaklari.html": "toprak su kaynakları",
    "site_hakkimizda.html": "hakkımızda",
    "site_sulama_dairesi.html": "sulama",
    "site_istatistik.html": "istatistik",
}
for ad, ibare in SAYFALAR.items():
    if not (KOK / ad).exists():
        hata.append(f"{ad}: dosya yok"); continue
    t = (KOK / ad).read_text(encoding="utf-8", errors="replace")
    govde = re.sub(r"<(script|style)[^>]*>.*?</\1>", " ", t, flags=re.S | re.I)
    govde = re.sub(r"<[^>]+>", " ", govde).lower()
    if ibare.lower() not in govde:
        hata.append(f"{ad}: '{ibare}' sayfada geçmiyor — YUMUŞAK 404 olabilir")
    rapor.append(f"  {ad:<34s} {len(t):,} bayt")

print("\n".join(rapor))
if hata:
    print("\nKAYNAK SINAMASI BAŞARISIZ:", file=sys.stderr)
    for h in hata:
        print("  ✗ " + h, file=sys.stderr)
    sys.exit(1)
print(f"\n✓ {len(rapor)} kaynağın kimliği doğrulandı")
