#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""yayin.json denetimi — Türkşeker, Kurum Dosyası Sayı 07."""
import json, pathlib, re, sys

KOK = pathlib.Path(__file__).parent
Y = json.loads((KOK / "yayin.json").read_text(encoding="utf-8"))
G = json.loads((KOK / "grafikler.json").read_text(encoding="utf-8"))["grafikler"]
TR = (KOK / "metin_tr.md").read_text(encoding="utf-8")
EN = (KOK / "metin_en.md").read_text(encoding="utf-8")
KUNYE = json.loads((KOK / "_raw" / "gorseller" / "kunye.json").read_text(encoding="utf-8"))["gorseller"]
hata, uyari = [], []

BOLUM = [n for n in Y["_bolum_basliklari"] if not n.startswith("_")]
# SON İKİ BÖLÜM baş görsel almıyor: galeri ve kaynakça. Numara sabit
# değil — Tur 9'da 15/16 iken 28/29 oldu.
GOVDE = [n for n in BOLUM if n not in set(sorted(BOLUM, key=int)[-2:])]
GOR = {k: v for k, v in Y["bolum_gorselleri"].items() if not k.startswith("_")}

# 1 · HER BÖLÜMDE BİR GÖRSEL (kullanıcı kuralı)
for n in GOVDE:
    if n not in GOR:
        hata.append(f"1 · §{n} görselsiz")

# 2 · her altyazının dayanağı var
for n, g in GOR.items():
    if not g.get("_dayanak"):
        hata.append(f"2 · §{n} altyazısının dayanağı yazılmamış")

# 3 · atıf ve lisans eksiksiz (§2.4 — atıfsız görsel yayımlanmaz)
for n, g in GOR.items():
    for alan in ("url", "atif", "lisans", "alt_tr", "alt_en"):
        if not g.get(alan):
            hata.append(f"3 · §{n} görselinde '{alan}' boş")

# 4 · görsel dosyaları diskte duruyor ve resim
for n, g in GOR.items():
    y = KOK / "_raw" / "gorseller" / g["url"].rsplit("/", 1)[-1]
    if not y.exists():
        hata.append(f"4 · §{n} görsel dosyası yok: {y.name}")
    elif y.stat().st_size < 20_000:
        uyari.append(f"4 · §{n} görseli küçük ({y.stat().st_size // 1024} KB)")

# 5 · ALTYAZI KÜNYEDİR, TAHLİL DEĞİL
# Kadraj tarifine kayan ifadeler aranıyor. Kullanıcı bu düzeltmeyi iki kez
# verdi; kural metne değil, altyazıya özgü.
TAHLIL = [r"\bgörülüyor\b", r"\bgörülmekte\b", r"\barka planda\b", r"\bön planda\b",
          r"\bkadraj\w*\b", r"\bsolda\b", r"\bsağda\b", r"\bdikkat çek\w+",
          r"\bcan be seen\b", r"\bin the background\b", r"\bin the foreground\b",
          r"\bon the left\b", r"\bon the right\b"]
for n, g in GOR.items():
    for dil, alan in (("tr", "alt_tr"), ("en", "alt_en")):
        metin = g.get(alan)
        if not metin:
            hata.append(f"5 · §{n} görselinde '{alan}' yok")
            continue
        for kalip in TAHLIL:
            if re.search(kalip, metin, re.I):
                hata.append(f"5 · §{n}/{dil} altyazısı kareyi tarif ediyor: {metin[:60]}")

# 6 · grafik kimlikleri grafikler.json ile birebir
plan = {x for b, l in Y["bolum_grafikleri"].items() if not b.startswith("_") for x in l}
if plan ^ set(G):
    hata.append(f"6 · grafik kimlikleri ayrışıyor: {sorted(plan ^ set(G))}")

# 7 · metindeki bölüm sayısı künye ile tutuyor
for ad, m in (("tr", TR), ("en", EN)):
    nolar = [b.split(".")[0].strip() for b in re.findall(r"^## (.+)$", m, re.M)]
    if nolar != BOLUM:
        hata.append(f"7 · {ad} metni bölümleri künyeyle tutmuyor")

# 8 · hikâye: beş slayt, sınırlar, ayrı görseller
S = Y["hikaye"]["slaytlar"]
if len(S) != 5:
    hata.append(f"8 · hikâye {len(S)} slayt taşıyor, 5 olmalı")
SINIR = {"ust": 24, "ust_en": 24, "baslik": 60, "baslik_en": 60,
         "etiket": 48, "etiket_en": 48, "rakam": 12, "rakam_en": 12}
for i, s in enumerate(S, 1):
    for alan, sin in SINIR.items():
        if len(s.get(alan, "")) > sin:
            hata.append(f"8 · slayt {i} · {alan} {len(s[alan])} > {sin}")
if len({s["gorsel"] for s in S}) != len(S):
    hata.append("8 · iki slayt aynı görseli taşıyor")

# 9 · hikâye görselleri künyede kayıtlı
for s in S:
    k = s["gorsel"].rsplit("/", 1)[-1].rsplit(".", 1)[0]
    if k not in KUNYE:
        hata.append(f"9 · slayt görseli künyede yok: {k}")

# 10 · anahtar kelimeler: ya ÖLÇÜLMÜŞ ya da açıkça ölçülmemiş işaretli
ak = Y.get("anahtar_kelimeler")
if ak:
    if "ÖLÇÜLDÜ" not in (Y.get("_anahtar_kelimeler_notu") or "").upper():
        hata.append("10 · anahtar kelime listesi dolu ama ölçüm notu yok (§8.10/1)")
    for t in ak:
        if t.strip().lower() in ("şeker", "sugar", "pancar", "beet"):
            hata.append(f"10 · tek başına kullanılamayacak anahtar kelime: {t}")
else:
    uyari.append("10 · anahtar kelimeler HENÜZ ÖLÇÜLMEDİ — yayından önce ölçülmeli (§8.10/1)")

# 11 · künye alanları
if Y.get("tur") != "kurum":
    hata.append("11 · tur 'kurum' değil")
if not isinstance(Y.get("edition"), int):
    hata.append("11 · edition tam sayı değil")
if (Y.get("pencere") or {}).get("gun") != 14:
    hata.append("11 · kurum penceresi 14 gün olmalı (§8.1)")
if Y.get("status") not in ("draft", "published", "archived"):
    hata.append(f"11 · status geçersiz: {Y.get('status')}")

# 12 · iki dilli alanlar eksiksiz
def gez(o, yol=""):
    if isinstance(o, dict):
        if set(o) in ({"tr"}, {"en"}):
            hata.append(f"12 · tek dilli alan: {yol}")
        for k, v in o.items():
            if not k.startswith("_"):
                gez(v, f"{yol}.{k}")
    elif isinstance(o, list):
        for i, v in enumerate(o):
            gez(v, f"{yol}[{i}]")
gez(Y.get("bolum_gorselleri", {}), "bolum_gorselleri")

# 13 · BÖLÜM TÜRÜ VERİTABANI KISITINA UYUYOR MU
#
# NEDEN VAR. Galeri türü dört yere tanıtılmıştı — Flutter modeli,
# seed_dossier.mjs, galeri denetçisi, yayın denetçisi — ama BEŞİNCİSİ,
# dossier_sections_tur_check, atlanmıştı. 24 Kasım 2026'da `supabase db
# push` tam bu yüzden düştü ve hata ancak veritabanına yazarken çıktı.
# Kısıt depoda yazılı; burada okunup metinle karşılaştırılıyor.
#
# KISIT EN SON NEREDE TANIMLIYSA O GEÇERLİ: uygulanmış göçler ve
# beklemede duranlar damga sırasına göre taranıyor.
_depo = KOK.parent.parent.parent
_gocler = sorted(list((_depo / "supabase" / "migrations").glob("*.sql"))
                 + list((KOK / "beklemede").glob("*.sql")),
                 key=lambda x: x.name)
_kalip = re.compile(r"dossier_sections_tur_check\s*\n?\s*check\s*\(\s*tur\s+in\s*\(([^)]*)\)",
                    re.I | re.S)
_izin = None
for _g in _gocler:
    _m = _kalip.search(_g.read_text(encoding="utf-8"))
    if _m:
        _izin = set(re.findall(r"'([^']+)'", _m.group(1)))
if _izin is None:
    # DENETÇİ KÖR OLMASIN: kısıt bulunamadıysa sessizce geçmek, kuralı
    # hiç yazmamakla aynı şey.
    hata.append("13 · dossier_sections_tur_check göçlerde bulunamadı")
else:
    _kullanilan = {v for k, v in Y["bolum_turleri"].items() if not k.startswith("_")}
    _disarda = sorted(_kullanilan - _izin)
    if _disarda:
        hata.append("13 · veritabanı kısıtının tanımadığı bölüm türü: "
                    + ", ".join(_disarda) + " (izinli: " + ", ".join(sorted(_izin)) + ")")

print(f"  {len(GOVDE)} bölüm · {len(GOR)} görsel · {len(G)} grafik · {len(S)} slayt · 13 kural")
for u in uyari:
    print(f"  ⚠ {u}")
if hata:
    print("\n  ✗ " + "\n  ✗ ".join(hata[:14]))
    sys.exit(1)
print("\n  ✓ denetim temiz")
