#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""tasarim.json denetimi — her kontrast sayısı YENİDEN ÖLÇÜLÜYOR.

Dizide bir kez dört şerit kontrastı tahmin edilmiş ve dosyaya yazılmıştı;
o yüzden kural şu: yazılan her sayı burada bir kez daha ölçülür.
"""
import contextlib, importlib.util, io, json, pathlib, sys

KOK = pathlib.Path(__file__).parent
T = json.loads((KOK / "tasarim.json").read_text(encoding="utf-8"))
G = json.loads((KOK / "grafikler.json").read_text(encoding="utf-8"))["grafikler"]

_spec = importlib.util.spec_from_file_location(
    "ortak_kontrast", KOK.parent / "_ortak" / "kontrast.py")
_mod = importlib.util.module_from_spec(_spec)
with contextlib.redirect_stdout(io.StringIO()):
    _spec.loader.exec_module(_mod)
cr = _mod.cr

hata, olculen = [], 0
sayfa, kapak, serit = T["palet"]["sayfa"], T["palet"]["kapak"], T["palet"]["serit"]
KAGIT, YUZEY = sayfa["zemin"]["hex"], sayfa["yuzey"]["hex"]
KZEMIN, KREM = kapak["zemin"]["hex"], "#F6F1E7"


def olc(ad, a, b, yazili, tolerans=0.015):
    global olculen
    olculen += 1
    gercek = cr(a, b)
    if abs(gercek - yazili) > tolerans:
        hata.append(f"{ad}: yazılı {yazili}, ölçülen {gercek:.2f}")


# 1 · kağıt gövdesindeki her kontrast
for ad, v in sayfa.items():
    if "kontrast_zemin" in v:
        olc(f"sayfa.{ad}.kontrast_zemin", v["hex"], KAGIT, v["kontrast_zemin"])
    if "kontrast_yuzey" in v:
        olc(f"sayfa.{ad}.kontrast_yuzey", v["hex"], YUZEY, v["kontrast_yuzey"])
    if "kontrast_app_krem" in v:
        olc(f"sayfa.{ad}.kontrast_app_krem", v["hex"], KREM, v["kontrast_app_krem"], 0.005)

# 2 · kapak
for ad, v in kapak.items():
    if "kontrast_zemin" in v:
        olc(f"kapak.{ad}", v["hex"], KZEMIN, v["kontrast_zemin"])

# 3 · şerit
for ad, v in serit.items():
    if isinstance(v, dict) and "kontrast_krem" in v:
        olc(f"serit.{ad}", v["hex"], KREM, v["kontrast_krem"])
ay = serit["_ayrisma"]
olc("serit._ayrisma.oran", sayfa["vurgu"]["hex"], ay["uygulamanin_yapisal_yesili"], ay["oran"])

# 4 · gövde metni WCAG AA (4.5) ve meta AA (4.5) eşiğini geçiyor
for ad, esik in (("murekkep", 4.5), ("sessiz", 4.5), ("vurgu", 4.5)):
    g = cr(sayfa[ad]["hex"], KAGIT)
    if g < esik:
        hata.append(f"sayfa.{ad} kağıt üzerinde {g:.2f} — AA eşiği {esik}")

# 5 · vurgu ile ikincil AYRI renk değilse, rol biçimle ayrışmak ZORUNDA
if sayfa["vurgu"]["hex"] == sayfa["ikincil"]["hex"]:
    hata.append("vurgu ve ikincil aynı renk — bu dosyada öyle olmamalı")

# 6 · ikincil nötr tutulduysa gerekçesi yazılı olmalı
if sayfa["ikincil"]["hex"] == sayfa["sessiz"]["hex"] and not sayfa["ikincil"].get("_not"):
    hata.append("ikincil, sessiz ile aynı renk ama gerekçesi yazılmamış")

# 7 · küme devralındıysa kaynağı yazılı olmalı
if not T["kume"].get("_devralindi"):
    hata.append("küme devralma notu yok — yeni küme açıldıysa gerekçesi gerekir")

# 8 · YASAK LİSTESİ BOŞ GEÇİLEMEZ ve klişeleri saymalı
if len(T.get("_yasak", [])) < 5:
    hata.append("_yasak listesi beşten az madde taşıyor")

# 9 · grafiklerde kullanılan her rol palette tanımlı mı
roller = set()
def gez(o):
    if isinstance(o, dict):
        if isinstance(o.get("rol"), str):
            roller.add(o["rol"])
        for v in o.values():
            gez(v)
    elif isinstance(o, list):
        for v in o:
            gez(v)
gez(G)
tanimli = set(sayfa) | {"sessiz"}
for r in roller - tanimli:
    hata.append(f"grafikte tanımsız rol: {r}")

# 10 · kapak başlığı Türkçe büyük harf tuzağına düşmemiş
bas = T["kapak"]["tipografi_katmani"]["baslik"]
if "TURK" in bas or "TURKIYE" in bas or ("TURKİYE" in bas):
    hata.append(f"kapak başlığında Türkçe büyük harf hatası: {bas}")
if bas != bas.upper() and "İ" not in bas:
    hata.append("kapak başlığı büyük harf değil")

print(f"  {olculen} kontrast yeniden ölçüldü · {len(roller)} rol · 10 kural")
if hata:
    print("\n  ✗ " + "\n  ✗ ".join(hata))
    sys.exit(1)
print(f"  roller: {', '.join(sorted(roller))}")
print("\n  ✓ denetim temiz")
