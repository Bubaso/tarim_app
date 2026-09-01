#!/usr/bin/env python3
"""metin_tr.md — sayı izi ve meta cümle denetimi.

Bu betik dosyanın en can alıcı denetimi. `dogrula_veri.py` veri katmanının
kendi içinde tutarlı olduğunu sınıyor; bu betik METNİN o katmandan saptığı
yeri arıyor. Bir cümleye elle yazılmış tek bir rakam buradan geçemez.

Yöntem: metindeki bütün sayılar çıkarılıyor, data.json'daki bütün sayılar
(ve onlardan türeyen makul biçimler — bin/milyon ölçeği, yuvarlama, oran,
yüzde) bir havuzda toplanıyor, ikisi karşılaştırılıyor.

İKİNCİ İŞ: İNGİLİZCE METİN. Çeviri sırasında rakam kaymaları en sessiz hata
türü — biçim de değişiyor (TR "1.225" ↔ EN "1,225"), gözle fark edilmiyor.
İki metin de aynı havuza karşı sınanıyor, her biri kendi sayı biçimiyle.

ÜÇÜNCÜ İŞ: META CÜMLE AVI. Kurum dosyası dizisi bir kez bu yüzden rafa
kalktı — ilk TMO metni araştırmacının notlarıyla doluydu ve iddianameye
dönmüştü (CLAUDE.md §8.2, §2.10). Aşağıdaki kalıplar yazarın SÜRECİNİ
anlatıyor; okurun işine yaramıyor. Yayına çıkmadan burada yakalanıyorlar.

    python3 content/dossiers/ziraat-bankasi/dogrula_metin.py
"""
import json
import pathlib
import re
import sys

DIR = pathlib.Path(__file__).parent
data = json.loads((DIR / "data.json").read_text(encoding="utf-8"))
metin = (DIR / "metin_tr.md").read_text(encoding="utf-8")
metin_en = (DIR / "metin_en.md").read_text(encoding="utf-8")

# Yazım kuralları başlığı metnin kendisi değil; oradaki sayılar madde numarası.
# Gövde ilk numaralı bölümden başlıyor.
import re as _re
def govde_al(ham, ad):
    m = _re.search(r"^## 1\. ", ham, _re.M)
    if not m:
        raise SystemExit(f"{ad} içinde '## 1.' bölümü bulunamadı")
    return ham[m.start():]


govde = govde_al(metin, "metin_tr.md")
govde_en = govde_al(metin_en, "metin_en.md")


def sayilar(o, out):
    """data.json'daki bütün sayısal değerleri topla.

    Metinlerin içindeki sayılar da alınıyor: kararname numarası, rapor kodu,
    ülke kodu gibi TANIMLAYICILAR ölçüm değil ama metinde geçiyorlar ve
    kaynakları veri katmanındaki dize alanlarda duruyor. Uydurulmadıklarının
    kanıtı orada olduğu için havuza giriyorlar.
    """
    if isinstance(o, str):
        for m in re.findall(r"\d[\d.]*", o):
            try:
                out.add(float(m.replace(".", "")))
            except ValueError:
                pass
        return
    if isinstance(o, dict):
        for k, v in o.items():
            if isinstance(v, (int, float)) and not isinstance(v, bool):
                out.add(float(v))
            # anahtarlar da yıl olabiliyor: {"1992": 46170}
            if re.fullmatch(r"(18|19|20)\d{2}", str(k)):
                out.add(float(k))
            sayilar(v, out)
    elif isinstance(o, list):
        for v in o:
            sayilar(v, out)
    elif isinstance(o, (int, float)) and not isinstance(o, bool):
        out.add(float(o))


ham = set()
sayilar(data, ham)

# Türetilmiş biçimler: 1.234.567 → 1,23 milyon / 1.235 bin gibi yazılabiliyor.
havuz = set()
for v in ham:
    # Denge kalemleri veride NEGATİF duruyor (denge_usd = −6.732.000.000),
    # metinde ise tabloda "−6.732" diye yazılıp işaret ayrı okunuyor.
    # Ölçek dönüşümü İKİ YÖNLÜ olmak zorunda. Türkçe "924 bin" yazıyor,
    # İngilizce "924,000" — aynı sayı, farklı ölçek. Yalnızca bölmeye izin
    # veren havuz İngilizce metnin yarısını yanlış işaretliyordu.
    for x in (v, -v, v / 1e3, -v / 1e3, v / 1e6, -v / 1e6, v / 1e9,
              v * 1e3, v * 1e6, v * 100):
        if x == 0:
            continue
        havuz.add(round(x, 2))
        havuz.add(round(x, 1))
        havuz.add(round(x))
# İki değerin oranı da metne girebiliyor (kat, yüzde).
buyukler = sorted(x for x in ham if x > 1000)[-400:]
for i, a in enumerate(buyukler):
    for b in buyukler[i + 1 :]:
        if b and a / b > 0.001:
            havuz.add(round(a / b, 2))
            havuz.add(round(a / b, 1))
            havuz.add(round(100 * a / b, 1))
            havuz.add(round(100 * a / b))

# Metinden sayıları çıkar.
#   TR biçimi: binlik ayıracı NOKTA, ondalık VİRGÜL   → 1.225 / 18,1
#   EN biçimi: binlik ayıracı VİRGÜL, ondalık NOKTA   → 1,225 / 18.1
# Aynı deseni iki dile uygulamak "1,225"i 1,225 diye okurdu; ayraçlar dile göre
# ters çevriliyor.
KALIP = {
    "tr": r"(?<![\w.,])(\d{1,3}(?:\.\d{3})+(?:,\d+)?|\d+(?:,\d+)?)(?![\w])",
    "en": r"(?<![\w.,])(\d{1,3}(?:,\d{3})+(?:\.\d+)?|\d+(?:\.\d+)?)(?![\w])",
}


def coz_sayi(s, dil):
    if dil == "tr":
        return float(s.replace(".", "").replace(",", "."))
    return float(s.replace(",", ""))


bulunan = re.findall(KALIP["tr"], govde)

# Sayı sayılmayacaklar: bölüm numaraları, yıllar, tarih parçaları, HS kodları,
# tablo hizalama artıkları ve metinde açıkça anlatılan küçük tam sayılar.
YOKSAY = {
    # yıllar zaten havuzda ama emniyet için
    *{float(y) for y in range(1960, 2031)},
    # bölüm/madde numaraları ve metinde geçen küçük sayaçlar
    *{float(n) for n in range(0, 21)},
    70.0,  # damper formülündeki %70 — kurumlar.ihracat_vergisi.hesap
    100.0,
}

from collections import Counter

sayi_hatasi = False
for dil, g, ad in (("tr", govde, "metin_tr.md"), ("en", govde_en, "metin_en.md")):
    bulunan = re.findall(KALIP[dil], g)
    eksik, gecen = [], 0
    for s in bulunan:
        try:
            v = coz_sayi(s, dil)
        except ValueError:
            continue
        if v in YOKSAY:
            continue
        if round(v, 2) in havuz or round(v, 1) in havuz or round(v) in havuz:
            gecen += 1
        else:
            eksik.append(s)
    print(f"{ad}: sayı {len(bulunan)}   karşılığı bulunan {gecen}")
    if eksik:
        sayi_hatasi = True
        print(f"  karşılığı BULUNAMAYAN {len(eksik)} sayı:")
        for s, n in Counter(eksik).most_common():
            print(f"     {s}" + (f"  (×{n})" if n > 1 else ""))

if sayi_hatasi:
    print("\nHer biri elle incelenmeli: ya türetilmiş bir orandır ya da HATADIR.")
    sys.exit(1)
print("\nTemiz: iki metinde de veri katmanına dayanmayan sayı yok.")

# ── META CÜMLE DENETİMİ ────────────────────────────────────────────────────
# Yalnızca GÖVDE taranıyor: "Yazım kuralları" bloğu yayına çıkmıyor (numarasız
# ## başlığını seed betiği bölüm saymıyor) ve zaten bu kuralları anlatıyor.
META = [
    # "Bu dosya ... anlatıyor" okura yol gösteren bir cümle ve dizide yerleşik
    # (TMO'nun 1. bölümü de öyle bitiyor). Yasak olan, dosyanın NASIL YAPILDIĞI:
    # hazırlanırken, yazarken, araştırılırken. Ayrım fiilde.
    (r"bu (dosya|metin)\w*\s+\S*\s*(hazırlan|yazıl|yazarken|kurul|derlen|araştır)",
     "dosyanın yapılış sürecinden söz ediyor"),
    (r"bu (dosyayı|metni) (yazarken|hazırlarken)", "yazım süreci"),
    (r"doğrulan(a?ma|amadı)", "doğrulama notu"),
    (r"erişile?me(di|yen)", "kaynağa erişim notu"),
    (r"kaynak bulunama", "kaynak notu"),
    (r"araştırma (sırasında|sürecinde)", "araştırma süreci"),
    (r"hazırlığı sırasında", "hazırlık süreci"),
    (r"(kurum|banka) (cevap|yanıt) verme", "yanıtsız kaynak notu"),
    (r"buraya kadar[ıi]", "bölüm özeti kalıbı"),
    (r"asıl bulgu", "bulgu dili"),
    (r"veri (katmanı|sayfası)", "veri katmanından söz ediyor"),
]
# İngilizce metin de aynı yasağa tabi; çeviri sırasında yeniden girebiliyor.
META_EN = [
    (r"(this|the) (dossier|text) \w*\s*(was (written|prepared|compiled)|"
     r"could not|while (writing|preparing))", "process note"),
    (r"could not be (verified|reached|found|obtained)", "verification note"),
    (r"(was|were) (not )?(available|accessible) (at the time|during)", "access note"),
    (r"during (our|the) research", "research process"),
    (r"(the institution|the bank) did not (respond|reply)", "unanswered source"),
]

meta_bulgu = []
for kalip, ad, g, dil in ([(k, a, govde, "tr") for k, a in META] +
                          [(k, a, govde_en, "en") for k, a in META_EN]):
    for m in re.finditer(kalip, g, re.I):
        bas = g.rfind("\n", 0, m.start()) + 1
        son = g.find("\n", m.end())
        meta_bulgu.append((dil, ad, g[bas:son if son > 0 else None].strip()[:150]))

if meta_bulgu:
    print(f"\nMETA CÜMLE — {len(meta_bulgu)} bulgu, metinden çıkarılmalı:")
    for dil, ad, satir in meta_bulgu:
        print(f"   [{dil} · {ad}] {satir}")
    sys.exit(1)
print("Temiz: iki metinde de meta cümle yok.")
