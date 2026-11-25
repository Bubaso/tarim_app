#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Türkşeker'in ikili ham kaynaklarını _ortak/ham_kaynaklar.json'a işler.

PDF ve CSV'ler .gitignore ile depodan dışarıda (bkz. .gitignore §"Dosya ham
kaynakları"). Diskte duruyorlar; kaydı bu dosya tutuyor. Her kalem yolu,
boyutu, sha256'sı ve bulunduğu adresle yazılıyor ki bir yıl sonra dosyanın
aynı dosya olduğu sınanabilsin.
"""
import hashlib, json, pathlib

KOK = pathlib.Path(__file__).resolve().parents[4]          # ~/Developer/tarim_app (_raw→turkseker→dossiers→content→kök)
RAW = pathlib.Path(__file__).parent
KAYIT = KOK / "content" / "dossiers" / "_ortak" / "ham_kaynaklar.json"

# erisim.json'daki adreslerden künye kuruluyor; adres orada yoksa elle verilen
# değer kullanılıyor ve kaynağı olmayan kalem ayrıca sayılıyor.
erisim = json.loads((RAW / "erisim.json").read_text(encoding="utf-8"))
adres_ara = {k["ad"]: k["adres"] for k in erisim["kaynaklar"]}

KALEMLER = [
    ("kaynak_dosyalari/sektor_raporu_2025.pdf", "Türkşeker — 2025 sektör raporu",
     "TÜRKŞEKER (Türkiye Şeker Fabrikaları A.Ş.)", "Kamu kurumu yayını"),
    ("kaynak_dosyalari/stratejik_plan_2024.pdf", "Türkşeker — stratejik plan",
     "TÜRKŞEKER (Türkiye Şeker Fabrikaları A.Ş.)", "Kamu kurumu yayını"),
    ("kaynak_dosyalari/ana_statu.pdf", "Türkşeker — ana statü",
     "TÜRKŞEKER (Türkiye Şeker Fabrikaları A.Ş.)", "Kamu kurumu yayını"),
    ("kaynak_dosyalari/seker_kanunu_4634.pdf", "Mevzuat Bilgi Sistemi — 4634 Şeker Kanunu",
     "T.C. Resmî Gazete", "Mevzuat"),
    ("x/psd_sugar.csv", "USDA PSD — şeker toplu CSV",
     "USDA Foreign Agricultural Service", "Kamu malı (ABD federal kurumu)"),
]

d = json.loads(KAYIT.read_text(encoding="utf-8"))
mevcut = {x["yol"] for x in d["dosyalar"]}
eklenen, atlanan, adressiz = [], [], []

for göreli, ad, atif, lisans in KALEMLER:
    disk = RAW / göreli
    if not disk.exists():
        atlanan.append(f"{göreli} — diskte yok")
        continue
    yol = str(disk.relative_to(KOK))
    adres = adres_ara.get(ad)
    if not adres:
        adressiz.append(ad)
    ham = disk.read_bytes()
    kayit = {"yol": yol, "bayt": len(ham),
             "sha256": hashlib.sha256(ham).hexdigest(),
             "kaynak": {"adres": adres, "atif": atif, "lisans": lisans,
                        "lisans_adresi": None}}
    # ÜZERİNE YAZILIYOR, ATLANMIYOR. İlk koşuda adlar erisim.json'dakilerle
    # tutmadığı için beş kalem adressiz kaydedildi; "zaten kayıtlı" diye
    # atlansaydı düzeltme bir daha giremezdi.
    eski = next((x for x in d["dosyalar"] if x["yol"] == yol), None)
    if eski is None:
        d["dosyalar"].append(kayit)
        eklenen.append((göreli, len(ham), adres, "yeni"))
    elif eski != kayit:
        d["dosyalar"][d["dosyalar"].index(eski)] = kayit
        eklenen.append((göreli, len(ham), adres, "güncellendi"))
    else:
        atlanan.append(f"{göreli} — kayıt zaten doğru")

# ── Görseller ───────────────────────────────────────────────────────
# .gitignore ikili görselleri de dışarıda tutuyor; künyeleri kunye.json'da,
# kaydı burada. Atıf ve lisans Commons API'sinden geldi, elle yazılmadı.
_kunyeler = [(RAW / "gorseller" / "kunye.json", "gorseller"),
             (RAW / "gorseller" / "galeri_kunye.json", "kareler")]
for _ku, _alan in _kunyeler:
    if not _ku.exists():
        continue
    for kimlik, g in json.loads(_ku.read_text(encoding="utf-8"))[_alan].items():
        disk = RAW / "gorseller" / g["dosya"]
        if not disk.exists():
            atlanan.append(f"{g['dosya']} — diskte yok")
            continue
        yol = str(disk.relative_to(KOK))
        ham = disk.read_bytes()
        kayit = {"yol": yol, "bayt": len(ham),
                 "sha256": hashlib.sha256(ham).hexdigest(),
                 "kaynak": {"adres": g["sayfa"], "atif": g["atif"],
                            "lisans": g["lisans"], "lisans_adresi": g["lisans_adresi"] or None}}
        eski = next((x for x in d["dosyalar"] if x["yol"] == yol), None)
        if eski is None:
            d["dosyalar"].append(kayit)
            eklenen.append((g["dosya"], len(ham), g["sayfa"], "yeni"))
        elif eski != kayit:
            d["dosyalar"][d["dosyalar"].index(eski)] = kayit
            eklenen.append((g["dosya"], len(ham), g["sayfa"], "güncellendi"))
        else:
            atlanan.append(f"{g['dosya']} — kayıt zaten doğru")

d["dosyalar"].sort(key=lambda x: x["yol"])
d["dosya_sayisi"] = len(d["dosyalar"])
d["toplam_bayt"] = sum(x["bayt"] for x in d["dosyalar"])
# ALANIN ESKİ ANLAMI KORUNUYOR. Adı "adresi olmayan" dese de bu alan
# kaynak NESNESİ hiç bulunmayan kalemleri sayıyordu (78). İlk yazımda
# adres alanı boş olanları da saydım ve değer sessizce 119'a çıktı —
# yani alanın anlamını değiştirmiş oldum. Eski kural geri alındı,
# daha dar ölçüm kendi adıyla ayrı alana yazılıyor.
d["kaynak_adresi_olmayan"] = sum(1 for x in d["dosyalar"] if not x.get("kaynak"))
d["kaynak_nesnesi_var_adresi_yok"] = sum(
    1 for x in d["dosyalar"] if x.get("kaynak") and not x["kaynak"].get("adres"))
d["_tarih"] = "2026-11-23"
# GİRİNTİ 1 BOŞLUK. Dosya böyle yazılmış; indent=2 ile yazınca beş kalem
# eklemek 5.000 satırlık fark üretti ve gerçek değişiklik görünmez oldu.
KAYIT.write_text(json.dumps(d, ensure_ascii=False, indent=1), encoding="utf-8")

for g, b, a, durum in eklenen:
    print(f"  {'+' if durum == 'yeni' else '~'} {g:<42} {b/1e6:>6.1f} MB"
          f"  {'✓ adres' if a else '⚠ adres yok'}  {durum}")
for s in atlanan:
    print(f"  · {s}")
if adressiz:
    print(f"\n  ⚠ erisim.json'da adresi bulunamayan: {', '.join(adressiz)}")
print(f"\n  kayıt: {d['dosya_sayisi']} dosya · {d['toplam_bayt']/1e9:.2f} GB"
      f" · kaynaksız {d['kaynak_adresi_olmayan']}"
      f" · kaynak var adres yok {d['kaynak_nesnesi_var_adresi_yok']}")
