#!/usr/bin/env python3
"""Avustralya — metni sınar.

BEŞ AVCI
1. SAYI KÖKENİ. Metindeki her rakam data.json'da bulunmalı. Türkçe binlik
   ayıracı ("1.262") ve İngilizce biçimi ("1,262") ayrı ayrı havuzda.
2. META CÜMLE. Dosyanın nasıl hazırlandığı metne girmez.
3. REKLAM DİLİ. "Öncü", "lider", "en gelişmiş" ancak tırnak içinde geçer.
4. BU DOSYANIN TUZAKLARI. Kuraklık "ilan edildi" denmez; su payı "tapu"
   denmez; kanunda olmayan bir cümle kanundan alıntılanmaz; bildirisiz ay
   ile kullanım oranı arasında nedensellik kurulmaz; sık ticaret yapanlara
   spekülasyon imâsı yapılmaz.
5. KAPSAM BEYANI. Piyasa rakamı geçen bölüm kapsamı söylemeli.

AVCI 1'İN GÖREMEDİĞİ ŞEY: kaynağı olmayan NİTEL iddia. İspanya'da dokuz
tanesi metne sızdı ve hiçbiri rakam içermiyordu. Bu betik onları
yakalayamaz; okuma gerekir.

İKİ DESEN BİLEREK DAR: yokluğu SÖYLEMEK ve nedenselliği REDDETMEK serbest.
İlk sürüm bunları da işaretliyordu — metni desene uydurmak yerine desen
düzeltildi.
"""
import json, re, sys
from pathlib import Path

KOK = Path(__file__).parent
VERI = json.loads((KOK / "data.json").read_text(encoding="utf-8"))
hata, uyari = [], []
havuz = set()

def gez(d):
    if isinstance(d, dict):
        for k, v in d.items():
            if not k.startswith("_"): havuz.add(str(k))
            gez(v)
    elif isinstance(d, list):
        for x in d: gez(x)
    elif isinstance(d, (int, float)) and not isinstance(d, bool):
        for s in (f"{d:.0f}", f"{d:,.0f}".replace(",", "."), f"{d:,.0f}".replace(",", " "),
                  f"{d:,.0f}", str(d), f"{d:.1f}".replace(".", ","), f"{d:.2f}".replace(".", ",")):
            havuz.add(s)
        if float(d).is_integer(): havuz.add(str(int(d)))
    elif isinstance(d, str):
        for m in re.finditer(r"\d[\d.,]*", d):
            havuz.add(m.group(0))
            havuz.add(m.group(0).replace(",", ".").rstrip("."))
            havuz.add(m.group(0).replace(".", "").replace(",", "."))
gez(VERI)

META = [r"bu dosya(?:da|nın)? (?:hazırlan|yazıl|derlen)", r"kaynak (?:bulunamadı|aranırken)",
        r"araştırma sırasında", r"veri (?:katmanı|çıkarıl)", r"\bbetik\b",
        r"doğrula(?:ma|yıcı)", r"\bturda\b", r"grafikler\.json", r"data\.json"]
REKLAM = [r"\böncü\b", r"\blider\b", r"en gelişmiş", r"en iyi\b", r"\bmükemmel\b",
          r"\bdevrim\b", r"\bbaşarı öyküsü\b"]
TUZAK = [
 (r"kuraklık (?:ilan|ilân) ed", "Büro kuraklık İLAN ETMİYOR — kendi ifadesi"),
 (r"\btapu(?:su|ya|nun|lu)?\b", "'tapu' kullanılmayacak; kanunun kelimesi 'sicil'"),
 # Yokluğu SÖYLEMEK serbest; VAR gibi yazmak değil.
 (r"kanun[^.]{0,60}(?:topraktan ayrıdır|ayrı olduğunu söyl)(?![^.]{0,80}(?:yok|bulunmuyor|değil|bekler))",
  "kanunda böyle bir beyan cümlesi YOK — var gibi yazılmış"),
 # Nedenselliği REDDETMEK serbest; KURMAK değil.
 (r"(?:Büro sus|bildiri yayımlanmayınca|bildirisiz)[^.]{0,80}(?:yüzünden|sebebiyle|için)[^.]{0,40}(?:kullanım|düş)",
  "bildirisiz ay ile kullanım oranı arasında nedensellik kurulmuş"),
 (r"(?:spekülas|vurgun|manipül|fırsatçı)", "sicil fiyat farkı bulgusu YOK diyor"),
 (r"Avustralya'da suyun yarısı", "YARISI kuzey Victoria'da; ülke geneli değil"),
]
# İki dilin kapsam ibareleri. Yalnız Türkçe arayan bir desen İngilizce metinde
# sekiz hatalı uyarı üretiyordu — metin kapsamı söylüyordu, betik göremiyordu.
KAPSAM = (r"(?:kuzey Victoria|Victoria'(?:da|nın|nun)|bölge|eyalet"
          r"|northern Victoria|Victoria's|\bregion\b|\bstate\b)")

for ad in ("metin_tr.md", "metin_en.md"):
    yol = KOK / ad
    if not yol.exists():
        uyari.append(f"{ad} yok"); continue
    ham = yol.read_text(encoding="utf-8")
    bas = ham.find("\n## 1.")
    kural, bolumler = ham[:bas], re.split(r"^##\s+(\d+)\.\s+(.+?)\s*$", ham[bas:], flags=re.M)
    for i in range(1, len(bolumler), 3):
        no, govde = bolumler[i], bolumler[i + 2]
        iz = f"{ad} §{no}"
        for m in re.finditer(r"\d[\d.,]*", govde):
            s = m.group(0).rstrip(".,")
            if not s or s in havuz: continue
            if re.fullmatch(r"(?:19|20)\d{2}(?:-\d{2})?", s) and (
                    s[:4] in havuz or s.replace("-", "") in havuz): continue
            hata.append(f"{iz}: '{s}' data.json'da yok — kaynağı belirsiz sayı")
        for p in META:
            if re.search(p, govde, re.I): hata.append(f"{iz}: META CÜMLE — '{p}'")
        for p in REKLAM:
            for m in re.finditer(p, govde, re.I):
                onc = govde[max(0, m.start() - 90):m.start()]
                if onc.count('"') % 2 == 0 and "“" not in onc[-40:]:
                    hata.append(f"{iz}: REKLAM DİLİ — '{m.group(0)}'")
        for p, neden in TUZAK:
            if re.search(p, govde, re.I): hata.append(f"{iz}: TUZAK — {neden}")
        if re.search(r"gigalitre|megalitre|\$|dolar", govde) and not re.search(KAPSAM, govde) \
           and no not in ("16", "18"):
            uyari.append(f"{iz}: piyasa rakamı var ama kapsam ibaresi yok")
    if "Hiçbir rakam hafızadan yazılmaz" not in kural and "No figure is written from memory" not in kural:
        hata.append(f"{ad}: yazım kuralları bloğu eksik")

if hata:
    print("METİN SINAMASI BAŞARISIZ:\n", file=sys.stderr)
    for h in hata: print("  ✗ " + h, file=sys.stderr)
    for u in uyari: print("  ⚠ " + u, file=sys.stderr)
    sys.exit(1)
print(f"✓ metin sınaması geçti · sayı havuzu {len(havuz)} yazım")
for u in uyari: print("  ⚠ " + u)
