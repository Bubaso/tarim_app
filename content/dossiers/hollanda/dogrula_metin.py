#!/usr/bin/env python3
"""metin_tr.md içindeki her sayının data.json'da karşılığı var mı?

Bu betik dosyanın en can alıcı denetimi. `dogrula_veri.py` veri katmanının
kendi içinde tutarlı olduğunu sınıyor; bu betik METNİN o katmandan saptığı
yeri arıyor. Bir cümleye elle yazılmış tek bir rakam buradan geçemez.

Yöntem: metindeki bütün sayılar çıkarılıyor, data.json'daki bütün sayılar
(ve onlardan türeyen makul biçimler — bin/milyon ölçeği, yuvarlama, oran,
yüzde) bir havuzda toplanıyor, ikisi karşılaştırılıyor.

    python3 content/dossiers/hollanda/dogrula_metin.py
"""
import json
import pathlib
import re
import sys

DIR = pathlib.Path(__file__).parent
data = json.loads((DIR / "data.json").read_text(encoding="utf-8"))
metin = (DIR / "metin_tr.md").read_text(encoding="utf-8")

# Yazım kuralları başlığı metnin kendisi değil; oradaki sayılar madde numarası.
# Gövde ilk numaralı bölümden başlıyor.
import re as _re
_m = _re.search(r"^## 1\. ", metin, _re.M)
if not _m:
    raise SystemExit("metin_tr.md içinde '## 1.' bölümü bulunamadı")
govde = metin[_m.start():]


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
    for x in (v, -v, v / 1e3, -v / 1e3, v / 1e6, -v / 1e6, v / 1e9, v * 100):
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

# Metinden sayıları çıkar. Türkçe biçim: binlik ayıracı nokta, ondalık virgül.
bulunan = re.findall(r"(?<![\w.,])(\d{1,3}(?:\.\d{3})+(?:,\d+)?|\d+(?:,\d+)?)(?![\w])", govde)

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

eksik, gecen = [], 0
for s in bulunan:
    t = s.replace(".", "").replace(",", ".")
    try:
        v = float(t)
    except ValueError:
        continue
    if v in YOKSAY:
        continue
    if any(abs(v - h) < 0.011 for h in (round(v, 2), round(v, 1), round(v))) and (
        round(v, 2) in havuz or round(v, 1) in havuz or round(v) in havuz
    ):
        gecen += 1
    else:
        eksik.append(s)

print(f"metindeki sayı: {len(bulunan)}   veri katmanında karşılığı bulunan: {gecen}")
if eksik:
    from collections import Counter

    print(f"\nkarşılığı BULUNAMAYAN {len(eksik)} sayı:")
    for s, n in Counter(eksik).most_common():
        print(f"   {s}" + (f"  (×{n})" if n > 1 else ""))
    print("\nHer biri elle incelenmeli: ya türetilmiş bir orandır ya da HATADIR.")
    sys.exit(1)
print("\nTemiz: metinde veri katmanına dayanmayan sayı yok.")
