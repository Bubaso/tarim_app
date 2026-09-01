#!/usr/bin/env python3
"""Ziraat Bankası — data.json denetimi.

build_data.py'nin kendi çıktısına GÜVENMEZ: data.json'u okur ve her kalemi
ham kaynağa karşı yeniden sınar. Betik doğru çalışıp yanlış veri üretmiş
olabilir; bu dosya o ihtimali kapatır.

    python3 content/dossiers/ziraat-bankasi/dogrula_veri.py

Çıkış kodu 0 = temiz, 1 = en az bir denetim düştü.
"""
import json, re, sys
from pathlib import Path

KOK = Path(__file__).parent
HAM = KOK / "_raw"
duz = lambda s: re.sub(r"\s+", " ", s).strip()

oku = lambda p: json.loads((KOK / p).read_text(encoding="utf-8"))
data = oku("data.json")
tarihce = oku("_raw/tarihce.json")
bddk = oku("_raw/bddk_sektorel_kredi.json")
# Bölünmeyen boşluk ve satır sonu tuzağı: samanlık da iğne de normalleştirilir.
rapor = {y: duz((HAM / f"faaliyet_{y}.txt").read_text(encoding="utf-8"))
         for y in ("2025", "2023", "2021")}
# Sayı 01'in ham kaynağı: buğday masası olayının TEK kaynağı, Ziraat'te yok.
tmo_ham = duz((KOK.parent / "tmo" / "_raw" / "kurum_hakkinda.txt")
              .read_text(encoding="utf-8"))

gecen, kalan = [], []
def sina(ad, kosul, ayrinti=""):
    (gecen if kosul else kalan).append((ad, ayrinti))

# ── 1. Her alıntı ham metinde geçiyor mu ───────────────────────────────────
# data.json'u gezip 'alinti' + 'kaynak' ikilisi taşıyan her düğümü bulur.
def gez(d, yol=""):
    if isinstance(d, dict):
        if "alinti" in d and "kaynak" in d:
            yield yol, d
        for k, v in d.items():
            yield from gez(v, f"{yol}.{k}")
    elif isinstance(d, list):
        for i, v in enumerate(d):
            yield from gez(v, f"{yol}[{i}]")

alinti_sayisi = 0
for yol, dugum in gez(data):
    alinti_sayisi += 1
    kaynak = dugum["kaynak"]
    if "tmo/_raw/kurum_hakkinda.pdf" in kaynak:
        sina(f"alıntı TMO belgesinde: {yol}",
             duz(dugum["alinti"]) in tmo_ham,
             f"{dugum['alinti'][:60]}… ← tmo/kurum_hakkinda")
        continue
    m = re.search(r"faaliyet_(\d{4})\.pdf", kaynak)
    if not m:
        sina(f"{yol} · kaynak tanınmadı", False, kaynak)
        continue
    yil = m.group(1)
    sina(f"alıntı ham metinde: {yol}",
         duz(dugum["alinti"]) in rapor[yil],
         f"{dugum['alinti'][:60]}… ← faaliyet_{yil}")

sina("en az 15 alıntı denetlendi", alinti_sayisi >= 15, f"{alinti_sayisi} alıntı")

# Kırılım tablosunun ham alıntıları ayrı taşınıyor (tablo satırı, alinti/kaynak
# ikilisi değil) — onlar da sınanmalı.
kir = data["tarim_kredisi_2025"]["kirilim"]
for anahtar in ("_alinti_bitkisel", "_alinti_hayvansal"):
    sina(f"kırılım tablosu · {anahtar}", duz(kir[anahtar]) in rapor["2025"],
         kir[anahtar][:60])

# ── 2. Sektör payı aritmetiği BDDK'dan yeniden hesaplanıyor ────────────────
for satir in data["sektor_payi"]["seri"]:
    y = str(satir["yil"])
    payda = round(bddk["yillar"][y]["satirlar"]["Tarım"]["Toplam Nakdi Krediler"] / 1e6, 1)
    sina(f"{y} · payda BDDK ile tutuyor", payda == satir["turkiye_milyar_tl"],
         f"BDDK {payda} ↔ data {satir['turkiye_milyar_tl']}")
    beklenen = round(100 * satir["ziraat_milyar_tl"] / payda)
    sina(f"{y} · oran yeniden hesaplandı", beklenen == satir["ziraat_payi_yuzde"],
         f"%{beklenen} ↔ %{satir['ziraat_payi_yuzde']}")

# Ölçü cümlesi "üçte iki" diyor; üç yılın hiçbiri %60-80 dışına çıkmamalı,
# yoksa cümle veriyi anlatmıyor demektir.
paylar = [s["ziraat_payi_yuzde"] for s in data["sektor_payi"]["seri"]]
sina("ölçü cümlesi seriyle tutarlı", all(60 <= p <= 80 for p in paylar), str(paylar))

# ── 3. Tarih zinciri, tarihçenin KENDİ cümleleri mi ────────────────────────
tarihce_eslem = {k["yil"]: k["maddeler"] for k in tarihce}
for kayit in data["tarih_zinciri"]["yillar"]:
    y = kayit["yil"]
    sina(f"{y} · tarihçede var", y in tarihce_eslem)
    if y in tarihce_eslem:
        sina(f"{y} · cümleler değiştirilmemiş",
             kayit["maddeler"] == tarihce_eslem[y],
             "banka metni yeniden yazılmış")

# ── 4. Kırılım toplamı, genel bakiyeyi AŞMAMALI ───────────────────────────
# Alt kalemler birbirini içerebiliyor (basınçlı sulama bitkiselin içinde —
# raporun kendi dipnotu). Bu yüzden eşitlik değil, üst sınır sınanıyor.
alt = sum(kir[k]["bakiye"] for k in
          ("bitkisel", "hayvansal", "mekanizasyon"))
toplam = data["tarim_kredisi_2025"]["bakiye_milyar_tl"]["deger"]
sina("kırılım toplamı bakiyeyi aşmıyor", alt <= toplam,
     f"{alt} ≤ {toplam} milyar TL")
# Basınçlı sulama bitkiselin İÇİNDE — raporun kendi dipnotu. Toplama iki kez
# girmemesi için üstteki toplamda yok; dipnotun kaydı da burada aranıyor.
sina("basınçlı sulama ayrı toplanmamış",
     "basincli_sulama" in kir and "basıncl" not in str(alt))

# ── 5. Şüpheli rakam metne SIZMAMALI ──────────────────────────────────────
# 172,3 milyar TL aynı raporda iki farklı kalem için geçiyor (genç çiftçi
# kredisi / ihtiyaç kredisi). _raw/README.md'de şüpheli işaretli.
ham_json = (KOK / "data.json").read_text(encoding="utf-8")
sina("şüpheli 172,3 rakamı data.json'a girmemiş", "172,3" not in ham_json)

# ── 6. Uydurulmamış künye ─────────────────────────────────────────────────
# mevzuat.gov.tr ve resmigazete.gov.tr bu ağdan açılmıyor. Resmî Gazete künyesi
# YALNIZCA birincil bir belgeden alıntılanmışsa durabilir — tek örneği TMO'nun
# kurum_hakkinda.pdf'inden gelen 1932 künyesi. Başka hiçbir blokta olamaz.
for blok, icerik in data.items():
    if blok in ("tmo_baglantisi", "_kural", "_uretim", "_dosya"):
        continue
    sina(f"{blok} · doğrulanmamış RG künyesi yok",
         not re.search(r"Resmî Gazete", json.dumps(icerik, ensure_ascii=False)))
sina("1932 RG künyesi TMO belgesinden alıntı",
     "2146 sayılı Resmî Gazete" in tmo_ham)

# ── 7. Veri Notları paneli KAPALI (CLAUDE.md §2.2, mutlak kural) ──────────
sina("bosluklar bloğu boş", data.get("bosluklar") == [])

# ── 8. Zorunlu bloklar ────────────────────────────────────────────────────
for blok in ("olcu", "kunye", "tarih_zinciri", "sektor_payi",
             "tarim_kredisi_2025", "kredili_musteri_serisi",
             "portfoy_bilesimi", "subvansiyon", "kucuk_krediler",
             "banka_geneli_2025", "credit_agricole", "tmo_baglantisi"):
    sina(f"blok var: {blok}", blok in data)

# ── 9. Müşteri serisi düz artan DEĞİL — metin öyle anlatmasın diye işaretli ─
seri = data["kredili_musteri_serisi"]["seri"]
sayi = lambda s: float(re.sub(r"[^\d,]", "", s).replace(",", "."))
artan = all(sayi(seri[i]["musteri"]) <= sayi(seri[i+1]["musteri"])
            for i in range(len(seri) - 1))
sina("müşteri serisinin düz artmadığı kayıtlı",
     (not artan) and "_uyari" in data["kredili_musteri_serisi"],
     "2023 tepe yapıp iniyor; uyarı bloğu şart")

# ── Rapor ─────────────────────────────────────────────────────────────────
# Ayrıntı yalnızca DÜŞEN denetimde basılıyor: geçen satırda "neyin yanlış
# olacağını" anlatan not, ekranda hatalı sonuç varmış gibi okunuyordu.
for ad, _ in gecen:
    print(f"  ✓ {ad}")
for ad, ayrinti in kalan:
    print(f"  ✗ {ad}" + (f"  ({ayrinti})" if ayrinti else ""))
print(f"\n{len(gecen)} geçti, {len(kalan)} düştü.")
sys.exit(1 if kalan else 0)
