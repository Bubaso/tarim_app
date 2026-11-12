#!/usr/bin/env python3
"""Mısır — grafik tariflerini data.json'a karşı sınar. Tohumlamadan ÖNCE koşar.

ON SEKİZ KURAL. İlk on biri TİGEM dosyasından devralındı; 12-18 bu dosyada
doğdu ve her biri bu turda yaşanmış ya da yaşanmaya bir adım kalmış bir
tuzağı bekliyor.

 1. Her @yol çözülüyor
 2. Yol SAYI döndürüyor — küme yalnızca 'harita'/'liste' altında serbest
 3. Grafik kimlikleri benzersiz, türler çizici bulunan türlerden
 4. ikili_cubuk: en az iki seri, her satırın değer sayısı seri sayısına eşit
 5. cizgi: x ekseni SAYISAL ve noktalar `noktalar` altında. Dizge yıl
    CizgiSeri._coz'dan geçmiyor ve seri SESSİZCE boş kalıyor
 6. Her grafikte başlık ve kaynak var
 7. ikili_cubuk satırları KOMPOZİSYON: her satır ~100 etmeli. Bu tür satır
    satır oranlıyor; büyüklük karşılaştırması için kullanılırsa küçük değer
    büyük değerle AYNI uzunlukta çizilir (Irak dosyası tur 9'un hatası)
 8. kartlar çizicisi `rol`/`vurgu` okumuyor — kart tanımında rol varsa
    sessizce düşer, o yüzden yazılmaz
 9. siralama aralığı 40 katı aşmıyor — bu tür bütün grafiği birden oranlar,
    aşarsa en küçük çubuk görünmez olur
10. zaman_cizelgesi yılları artan
11. islem_akisi adımlarının başlığı var (bu dosyada kullanılmıyor; kural
    kaldırılmadı, tür bir gün geri gelirse sessiz kalmasın)
12. SIRALI LİSTEDEN İNDEKSLE OKUMA SINANIYOR. `_kimlik` alanı [yol, beklenen]
    diyor; kaynak verinin sıralaması değişirse çubuk sessizce başka
    ülkeyi/faslı gösterir ve etiket elle yazıldığı için kimse görmez
13. yigin: her çubuk KENDİ bütününe oranlanıyor ve notu bunu söylüyor
14. cizgi `harita` biçimi: anahtarlar sayısal yıl, değerler sayı, artan
15. YÜZDE İŞARETİ Türkçede başa, İngilizcede sona — onek {tr:'%', en:''} ve
    sonek {tr:'', en:'%'}. Tersi yazılırsa Türkçe '4,25%' diye çizilir
16. NOTTAKİ ONDALIK SAYI data.json'da VAR. Elle yazılan bir oran, paydanın
    ya da kaynağın bir sonraki güncellemesinde sessizce yanlışa döner
17. ikili_cubuk'ta sayı biçimi HER SATIRDA — grafik düzeyindeki biçimi
    çizici okumuyor (TİGEM tur 9: %90,93 '91' diye çiziliyordu)
18. kunye/kartlar rakamlarının etiketi var — etiketsiz rakam künye değil
19. YIGIN ÇUBUKLARI AYNI DİLİM ADLARINI TAŞIYOR. Çizici göstergeyi YALNIZ
    İLK ÇUBUKTAN kuruyor (dossier_chart_view.dart, _Yigin: `final ilk =
    c.cubuklar.first`). Çubuklar ayrı dilim adları taşırsa gösterge ikinci
    çubuk için YANLIŞ ad gösterir. Bu turda kod okunarak bulundu; ilk
    yazımdaki su grafiği tam bu hataya düşmüştü (bir çubuk kaynak, öteki
    çekim) ve grafik `siralama`ya çevrildi. Yayındaki Rusya dosyasının
    `tez_yigin` grafiği de bu durumda — orası kullanıcı kararı.
20. YIĞILMIŞ TÜRLERDE SERİ ROLÜ vurgu + ikincil. `sessiz` seri olamaz:
    `ChartRole.taramali` YALNIZ ikincil için true (dossier_chart.dart), yani
    vurgu ile sessiz aynı çubukta yan yana durduğunda ayrımı taşıyan tek şey
    renk olur. Bu paletin vurgu↔sessiz parlaklık oranı deuteranopi altında
    1,31 (ölçüm: _raw/kontrast.py) — eşik 1,4. Vurgu ile ikincil yan yana
    durduğunda renk VE tarama birlikte taşıyor. `sessiz` yalnız siralama'da
    bağlam satırı; orada etiket ve uzunluk taşıyor.
"""
from __future__ import annotations

import json
import pathlib
import re
import sys

KOK = pathlib.Path(__file__).parent
VERI = json.loads((KOK / "data.json").read_text(encoding="utf-8"))
TANIM = json.loads((KOK / "grafikler.json").read_text(encoding="utf-8"))
CIZICI = {"ikili_cubuk", "siralama", "cizgi", "yigin", "kunye",
          "zaman_cizelgesi", "kartlar", "islem_akisi", "ticaret_akisi"}
KUME = {"harita", "liste"}

hata: list[str] = []
yol_sayisi = 0


def coz(yol: str):
    d = VERI
    for p in yol.split("."):
        if isinstance(d, list):
            try:
                d = d[int(p)]
            except (ValueError, IndexError):
                return None
        elif isinstance(d, dict):
            if p not in d:
                return None
            d = d[p]
        else:
            return None
    return d


def gez(dugum, anahtar: str, iz: str):
    global yol_sayisi
    if isinstance(dugum, str) and dugum.startswith("@"):
        yol_sayisi += 1
        v = coz(dugum[1:])
        if v is None:
            hata.append(f"{iz}: '{dugum}' data.json'da yok")
        elif isinstance(v, (dict, list)):
            if anahtar not in KUME:
                hata.append(f"{iz}: '{dugum}' küme döndürdü ama '{anahtar}' sayı bekliyor")
        elif not isinstance(v, (int, float)) or isinstance(v, bool):
            hata.append(f"{iz}: '{dugum}' sayı değil ({v!r})")
    elif isinstance(dugum, list):
        for i, x in enumerate(dugum):
            gez(x, anahtar, f"{iz}[{i}]")
    elif isinstance(dugum, dict):
        for k, v in dugum.items():
            if not k.startswith("_"):
                gez(v, k, f"{iz}.{k}")


def sayi(x):
    """@yol ise çöz, değilse olduğu gibi."""
    return coz(x[1:]) if isinstance(x, str) and x.startswith("@") else x


# ── 16'nın hazırlığı: data.json'daki BÜTÜN sayılar ───────────────────────
VERI_SAYILARI: list[float] = []


def _topla(x):
    if isinstance(x, bool):
        return
    if isinstance(x, (int, float)):
        VERI_SAYILARI.append(float(x))
    elif isinstance(x, dict):
        for k, v in x.items():
            _topla(v)
            # Yıl→değer sözlüklerinde ANAHTAR da bir sayı (1961, 1990...).
            if isinstance(k, str) and k.isdigit():
                VERI_SAYILARI.append(float(k))
    elif isinstance(x, list):
        for v in x:
            _topla(v)


_topla(VERI)

# Ölçek kümesi: not "bin ton", "milyon dolar", "m²" diye konuşuyor, data.json
# ise kendi biriminde duruyor. Onluk kuvvetler denenerek eşleştiriliyor.
OLCEKLER = [10.0 ** k for k in range(-9, 10)]


def veride_var(deger: float, basamak: int) -> bool:
    for x in VERI_SAYILARI:
        for s in OLCEKLER:
            if round(x * s, basamak) == deger:
                return True
    return False


# Türkçe ve İngilizce ayrı ayrıştırılıyor: "12.467" Türkçede on iki bin,
# İngilizcede on iki tam dört yüz altmış yedi. Aynı kalıpla okunamazlar.
KALIP = {
    "tr": [(re.compile(r"\d{1,3}(?:\.\d{3})+(?:,\d+)?"), ".", ","),
           (re.compile(r"\d+,\d+"), None, ",")],
    "en": [(re.compile(r"\d{1,3}(?:,\d{3})+(?:\.\d+)?"), ",", "."),
           (re.compile(r"\d+\.\d+"), None, ".")],
}


def sayilari_ayikla(metin: str, dil: str) -> list[tuple[str, float, int]]:
    bulunan: list[tuple[str, float, int]] = []
    yerler: list[tuple[int, int]] = []
    for kalip, binlik, ondalik in KALIP[dil]:
        for m in kalip.finditer(metin):
            if any(a <= m.start() < b for a, b in yerler):
                continue        # daha geniş kalıp bu parçayı zaten aldı
            yerler.append((m.start(), m.end()))
            ham = m.group()
            if binlik:
                ham = ham.replace(binlik, "")
            ham = ham.replace(ondalik, ".")
            basamak = len(ham.split(".")[1]) if "." in ham else 0
            bulunan.append((m.group(), float(ham), basamak))
    return bulunan


# ══════════════════════════════════════════════════════════════════════════
G = TANIM["grafikler"]
if len(G) != len({k for k in G if not k.startswith("_")}):
    hata.append("GRAFİK KİMLİĞİ TEKRARLI")

for gid, g in G.items():
    if gid.startswith("_"):
        continue
    gez(g, gid, gid)

    tur = g.get("tur")
    if tur not in CIZICI:
        hata.append(f"{gid}: çizici yok — tür '{tur}'")
    if not g.get("baslik"):
        hata.append(f"{gid}: başlık yok")
    if not g.get("kaynak"):
        hata.append(f"{gid}: kaynak yok")

    # ── 12 — sıralı listeden indeksle okuma ──────────────────────────────
    for alan in ("satirlar", "kartlar", "cubuklar", "kalemler"):
        for i, satir in enumerate(g.get(alan, [])):
            if not isinstance(satir, dict) or "_kimlik" not in satir:
                continue
            yol, beklenen = satir["_kimlik"]
            gercek = coz(yol[1:]) if yol.startswith("@") else None
            if gercek != beklenen:
                hata.append(
                    f"{gid}.{alan}[{i}]: KİMLİK AYRIŞMASI — '{yol}' "
                    f"{gercek!r} döndürdü, etiket {beklenen!r} diyor. "
                    f"Kaynak sıralaması değişmiş; etiketler elden geçmeli")

    # ── 16 — nottaki ondalık sayı data.json'da ───────────────────────────
    disi = {str(k): v for k, v in (g.get("_olcum_disi") or {}).items()}
    # Taranacak metinler: grafik notu ve başlığı, KART GÖVDELERİ ve künye
    # etiketleri. Kart gövdeleri ilk yazımda taranmıyordu ve STA tavizi
    # kartları tam oraya sayı yazıyor — gövde taranmazsa kural boşa düşer.
    metinler: list[tuple[str, dict]] = [("not", g.get("not") or {}),
                                        ("baslik", g.get("baslik") or {})]
    for i, k in enumerate(g.get("kartlar", [])):
        metinler.append((f"kartlar[{i}].govde", k.get("govde") or {}))
        metinler.append((f"kartlar[{i}].baslik", k.get("baslik") or {}))
    for i, k in enumerate(g.get("kalemler", [])):
        metinler.append((f"kalemler[{i}].alt", k.get("alt") or {}))
    for dil in ("tr", "en"):
        for kaynak_alan, sozluk in metinler:
            metin = sozluk.get(dil, "")
            for ham, deger, basamak in sayilari_ayikla(metin, dil):
                if ham.replace(".", "").replace(",", "") in disi:
                    continue
                if not veride_var(deger, basamak):
                    hata.append(
                        f"{gid}.{kaynak_alan}.{dil}: '{ham}' data.json'da yok. "
                        f"Elle yazılmış bir oran, kaynak güncellenince sessizce "
                        f"yanlışa döner. Kasıtlıysa `_olcum_disi` ile gerekçesi "
                        f"yazılır")

    # ── 20 — yığılmış türlerde seri rolü ─────────────────────────────────
    if tur in ("ikili_cubuk", "yigin"):
        roller = set()
        for s_ in g.get("seriler", []):
            roller.add(s_.get("rol"))
        for c in g.get("cubuklar", []):
            for dl in c.get("dilimler", []):
                roller.add(dl.get("rol"))
        if "sessiz" in roller:
            hata.append(
                f"{gid}: yığılmış türde 'sessiz' seri rengi. Yalnız ikincil "
                f"taramalı çiziliyor; vurgu ile sessiz yan yana durduğunda "
                f"ayrımı taşıyan tek şey renk olur ve bu palette o oran "
                f"deuteranopi altında 1,31")

    # ── 4, 7, 17 — ikili_cubuk ───────────────────────────────────────────
    if tur == "ikili_cubuk":
        seriler = g.get("seriler", [])
        if len(seriler) < 2:
            hata.append(f"{gid}: ikili_cubuk en az iki seri ister")
        for i, s in enumerate(g.get("satirlar", [])):
            d = s.get("degerler", [])
            if len(d) != len(seriler):
                hata.append(f"{gid}.satirlar[{i}]: {len(d)} değer, {len(seriler)} seri")
            sayilar = [sayi(x) for x in d]
            if all(isinstance(x, (int, float)) for x in sayilar):
                toplam = sum(sayilar)
                if abs(toplam - 100) > 0.5:
                    hata.append(
                        f"{gid}.satirlar[{i}]: değerler {toplam} ediyor, 100 değil — "
                        f"ikili_cubuk SATIR SATIR oranlar, büyüklük karşılaştırmaz")
            # 17 — biçim satırda mı
            if "ondalik" not in s:
                hata.append(
                    f"{gid}.satirlar[{i}]: 'ondalik' satırda yok. Grafik "
                    f"düzeyindeki biçimi çizici OKUMUYOR (IkiliSatir kendi "
                    f"sözlüğünden kuruyor); TİGEM'de %90,93 '91' çizilmişti")

    # ── 5, 14 — cizgi ────────────────────────────────────────────────────
    if tur == "cizgi":
        for i, s in enumerate(g.get("seriler", [])):
            n = s.get("noktalar")
            if not isinstance(n, dict) or not (KUME & set(n)):
                hata.append(f"{gid}.seriler[{i}]: noktalar 'harita' ya da 'liste' altında değil")
                continue
            if "harita" in n:
                h = coz(n["harita"][1:]) if str(n["harita"]).startswith("@") else n["harita"]
                if not isinstance(h, dict) or not h:
                    hata.append(f"{gid}.seriler[{i}]: '{n['harita']}' sözlük döndürmedi")
                    continue
                kotu = [k for k in h if not str(k).lstrip("-").isdigit()]
                if kotu:
                    hata.append(f"{gid}.seriler[{i}]: harita anahtarı sayısal değil {kotu[:3]}")
                bos = [k for k, v in h.items() if not isinstance(v, (int, float))]
                if bos:
                    hata.append(f"{gid}.seriler[{i}]: harita değeri sayı değil {bos[:3]} — "
                                f"çizici o noktayı sessizce DÜŞÜRÜR")
                yil = [int(k) for k in h if str(k).lstrip("-").isdigit()]
                if yil != sorted(yil):
                    hata.append(f"{gid}.seriler[{i}]: harita yılları artan değil")
            if "liste" in n:
                kayit = coz(n["liste"][1:]) if str(n["liste"]).startswith("@") else None
                if not isinstance(kayit, list) or not kayit:
                    hata.append(f"{gid}.seriler[{i}]: '{n['liste']}' liste döndürmedi")
                    continue
                for k in (n.get("x"), n.get("y")):
                    if k not in kayit[0]:
                        hata.append(f"{gid}.seriler[{i}]: kayıtlarda '{k}' alanı yok")
                        break
                else:
                    xd = [r.get(n["x"]) for r in kayit]
                    yd = [r.get(n["y"]) for r in kayit]
                    if not all(isinstance(x, (int, float)) and not isinstance(x, bool) for x in xd):
                        hata.append(f"{gid}.seriler[{i}]: x ekseni SAYISAL değil — seri sessizce boş kalır")
                    elif xd != sorted(xd):
                        hata.append(f"{gid}.seriler[{i}]: x ekseni artan değil {xd}")
                    bos = [x for a, x in zip(yd, xd) if not isinstance(a, (int, float))]
                    if bos:
                        hata.append(f"{gid}.seriler[{i}]: y değeri boş olan noktalar {bos[:3]} — "
                                    f"çizici onları DÜŞÜRÜR, iki seri ayrı yıllarda biter")

    # ── 13 — yigin ───────────────────────────────────────────────────────
    if tur == "yigin":
        cubuklar = g.get("cubuklar", [])
        if len(cubuklar) < 2:
            hata.append(f"{gid}: yigin en az iki çubuk ister")
        for i, c in enumerate(cubuklar):
            dilim = c.get("dilimler", [])
            if len(dilim) < 2:
                hata.append(f"{gid}.cubuklar[{i}]: en az iki dilim ister")
            for j, dl in enumerate(dilim):
                if not isinstance(sayi(dl.get("deger")), (int, float)):
                    hata.append(f"{gid}.cubuklar[{i}].dilimler[{j}]: değer sayı değil")
                if not dl.get("ad"):
                    hata.append(f"{gid}.cubuklar[{i}].dilimler[{j}]: ad yok")
        # 19 — gösterge yalnız ilk çubuktan kuruluyor
        adlar = [tuple(json.dumps(dl.get("ad"), ensure_ascii=False, sort_keys=True)
                       for dl in c.get("dilimler", [])) for c in cubuklar]
        if len(set(adlar)) > 1:
            hata.append(
                f"{gid}: yigin çubukları AYRI dilim adları taşıyor. Çizici "
                f"göstergeyi yalnız İLK çubuktan kuruyor; ikinci çubuğun "
                f"dilimleri göstergede yanlış adla görünür")
        notu = json.dumps(g.get("not", {}), ensure_ascii=False)
        if "kendi" not in notu.lower() and "its own" not in notu.lower():
            hata.append(
                f"{gid}: yigin notu çubukların KENDİ bütününe oranlandığını "
                f"söylemiyor. Okur çubukları birbiriyle karşılaştırır")

    # ── 8, 18 — kartlar ve kunye ─────────────────────────────────────────
    if tur == "kartlar":
        for i, k in enumerate(g.get("kartlar", [])):
            if "rol" in k or "vurgu" in k:
                hata.append(f"{gid}.kartlar[{i}]: 'rol' kartlar çizicisinde okunmuyor, sessizce düşer")
            if not k.get("baslik") or not k.get("govde"):
                hata.append(f"{gid}.kartlar[{i}]: başlık ya da gövde yok")
            if "rakam" in k and not (k["rakam"] or {}).get("etiket"):
                hata.append(f"{gid}.kartlar[{i}].rakam: etiket yok — etiketsiz rakam künye değil")
    if tur == "kunye":
        for i, k in enumerate(g.get("kalemler", [])):
            if not k.get("etiket"):
                hata.append(f"{gid}.kalemler[{i}]: etiket yok — etiketsiz rakam künye değil")

    # ── 9 — siralama aralığı ─────────────────────────────────────────────
    if tur == "siralama":
        sayilar = [v for v in (sayi(s.get("deger")) for s in g.get("satirlar", []))
                   if isinstance(v, (int, float)) and v > 0]
        if sayilar and max(sayilar) / min(sayilar) > 40:
            hata.append(
                f"{gid}: siralama aralığı {max(sayilar) / min(sayilar):.0f} kat — "
                f"en küçük çubuk görünmez. Küçükleri topla, düşürme")

    # ── 10 — zaman_cizelgesi ─────────────────────────────────────────────
    if tur == "zaman_cizelgesi":
        yillar = [o.get("yil") for o in g.get("olaylar", [])]
        if yillar != sorted(y for y in yillar if isinstance(y, int)):
            hata.append(f"{gid}: zaman çizelgesi yılları artan değil {yillar}")

    # ── 11 — islem_akisi ─────────────────────────────────────────────────
    if tur == "islem_akisi":
        for i, a in enumerate(g.get("adimlar", [])):
            if not a.get("baslik"):
                hata.append(f"{gid}.adimlar[{i}]: başlık yok")

    # ── 15 — yüzde işaretinin yeri ───────────────────────────────────────
    def yuzde_denetle(d: dict, iz: str):
        on = (d.get("onek") or {})
        son = (d.get("sonek") or {})
        if "%" in (on.get("tr", "") + son.get("tr", "") +
                   on.get("en", "") + son.get("en", "")):
            if not (on.get("tr") == "%" and on.get("en", "") == ""
                    and son.get("tr", "") == "" and son.get("en") == "%"):
                hata.append(
                    f"{iz}: yüzde işareti yanlış yerde. Türkçede BAŞA, "
                    f"İngilizcede SONA: onek {{tr:'%',en:''}} + "
                    f"sonek {{tr:'',en:'%'}}. Şimdiki hâli Türkçeyi '4,25%' "
                    f"diye çizdirir")

    for alan in ("satirlar", "kalemler"):
        for i, s in enumerate(g.get(alan, [])):
            yuzde_denetle(s, f"{gid}.{alan}[{i}]")
    for i, k in enumerate(g.get("kartlar", [])):
        if isinstance(k.get("rakam"), dict):
            yuzde_denetle(k["rakam"], f"{gid}.kartlar[{i}].rakam")
    yuzde_denetle(g, gid)

if hata:
    print("GRAFİKLER KİLİTLENMEDİ:", file=sys.stderr)
    for h in hata:
        print("  ✗", h, file=sys.stderr)
    sys.exit(1)

sayac: dict[str, int] = {}
for gid, g in G.items():
    if not gid.startswith("_"):
        sayac[g["tur"]] = sayac.get(g["tur"], 0) + 1
print(f"grafikler kilitlendi · {len([k for k in G if not k.startswith('_')])} grafik · "
      f"{yol_sayisi} @yol çözüldü · {len(VERI_SAYILARI)} veri sayısı taranarak "
      f"20 kuralın 20'si geçti")
for t, n in sorted(sayac.items()):
    print(f"  {t:18s} {n}")
