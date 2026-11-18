#!/usr/bin/env python3
"""
Yapay Zeka ve Dijital Tarım — İngilizce etiketli şekillerin Türkçe kopyaları.

    python3 -I gorsel_turkce.py               # bütün kopyaları yeniden üretir
    python3 -I gorsel_turkce.py <kimlik> ...  # yalnız verilen kimlikleri
    python3 -I gorsel_turkce.py --tablo       # İngilizce → Türkçe etiket tablosu

gorsel_turkce.json'daki her kimlik için web/yz/gorsel/<kimlik>.webp'yi okur,
İngilizce etiketleri yerel zeminle örter, Türkçe karşılıklarını aynı yere,
özgündekine yakın yazı tipi, boyut ve renkte yazar; sonucu
web/yz/gorsel/<kimlik>.tr.webp olarak kaydeder (aynı piksel boyutu, WebP
kalite 90). Özgün dosyaya dokunulmaz; görseller yalnız veri olarak okunur.
Veri işaretleri (çizgi, çubuk, nokta), fotoğraflar, logolar, sayılar ve
eksen değerleri değiştirilmez.

Tanım dosyasının yapısı (gorsel_turkce.json):

  "yazi_tipleri": ad → dosya yolu ya da {"dosya": yol, "indeks": n} (.ttc;
                  değişken yazı tipinde "eksenler": eksen değerleri listesi)
  "gorseller": kimlik → {
      "varsayilan": etiketlerin ortak alanları (yazı tipi, renk, zemin…),
      "ortuler":    yalnız örtülecek (yeniden yazılmayacak) bölgeler,
      "tasimalar":  [{"kutu": […], "hedef": [x, y], "zemin": …}] özgün
                    pikselleri taşır (ör. kalın "z500" Türkçe başlık uzayınca
                    sağa, lejant kutucuğu ya da gösterge ucu yeni yazıya göre);
                    eski yer "zemin"le örtülür,
      "etiketler":  [etiket, …]
  }

Bölge: "kutu": [x0, y0, x1, y1] (x1, y1 hariç) ya da eğik yazı için
"dortgen": [[sol üst], [sağ üst], [sol alt]] (paralelkenar). Bölgenin
"zemin"i:
  "auto"               dört kenardan alınan örneklerle Coons yaması; düz
                       zemini de geçişli (gökyüzü, piramit) zemini de taşır
  "auto-yatay"         yalnız sol ve sağ kenardan doğrusal geçiş
  "auto-dikey"         yalnız üst ve alt kenardan doğrusal geçiş
  "duz"                kenar örneklerinin ortancası, düz renk
  "#rrggbb"            verilen düz renk (ör. yazının üstünde durduğu şeklin rengi)
  {"kopya": [dx, dy]}  özgün görselin kaydırılmış bölgesinden kopya
                       (yazının altında kalan yinelenen çizim ya da çizgi için)
  {"onar": {"renk", "tolerans", "genislet", ["kaynak": [dx, dy]]}}
                       yalnız yazı renginde olan pikselleri siler (çizimin
                       üstündeki yazılar): silinenler çevreden içe doğru
                       doldurulur ya da "kaynak" verilirse aynı çizimin yazısız
                       kaydırılmış yerinden alınır (yaprak, perde çizgisi)
Kenar örnekleri her noktada 1-3 piksel dışarıdan ortancayla alınır; kenar
boyunca geniş ortancadan "tolerans"tan (varsayılan 40) çok sapan örnekler
(kenarı kesen komşu yazı, çizgi) atılır, sonra "pencere" genişliğinde ortanca
süzgeç uygulanır; ince bir çizgi ya da komşu harf yamaya iz bırakmaz.

Etiket: "en" özgün metin (kayıt için), "tr" Türkçe metin ("\\n" satır böler)
ya da satır listesi (her satır metin ya da {"metin", "yazi_tipi", "boyut",
"renk"} parçaları listesi); "kutu"/"dortgen" + "zemin" ya da birden çok
bölge için "ortu": [bölge, …]; "yazi_tipi", "boyut" (px, yazı tipinin em
boyu), "renk"; "nokta": [x, y] ilk satırın taban çizgisindeki çapa (hizaya
göre satırın solu, ortası ya da sağı); "hiza": "sol" | "orta" | "sag";
"satir": satır aralığı (taban → taban, px); "aci": saat yönünün tersine
derece (90 = aşağıdan yukarı okunan eksen başlığı), döndürme çapanın
çevresinde; "en_fazla": en uzun satırın sığması gereken genişlik (aşarsa
boyut küçültülür ve bildirilir); "sikistir": yatay ölçek (<1 daraltır);
"kalin": ek çizgi kalınlığı (px, kesirli olabilir; "ss" katına göre);
"ss": yüksek çözünürlükte çizip küçültme katı (genişlik ve hiza da o
boyutta ölçülür); "bulaniklik": yazı katmanına Gauss bulanıklığı (bulanık
özgünle uyum için).

Sıra: önce bütün örtüler (etiketlerin, "ortuler", taşınacak parçaların eski
yeri), sonra taşınan parçalar, en son Türkçe yazılar çizilir.

Türkçe büyük harfler tanımda doğrudan yazılır (Python'un upper()'ı i'yi I
yapar; Türkçede İ olmalı).
"""
from __future__ import annotations

import hashlib
import json
import math
import sys
from pathlib import Path

sys.path.append('/Users/BURHAN/Library/Python/3.9/lib/python/site-packages')
from PIL import Image, ImageDraw, ImageFilter, ImageFont  # noqa: E402

BURASI = Path(__file__).resolve().parent
DEPO = BURASI.parents[2]
GORSEL = DEPO / 'web' / 'yz' / 'gorsel'
TANIM = BURASI / 'gorsel_turkce.json'
KALITE = 90


def renk(s: str) -> tuple:
    s = s.lstrip('#')
    return tuple(int(s[i:i + 2], 16) for i in (0, 2, 4))


def ortanca(degerler: list):
    d = sorted(degerler)
    return d[len(d) // 2]


# --------------------------------------------------------------------------
# Bölgeler ve örtme
# --------------------------------------------------------------------------

class Bolge:
    """Kutu ya da paralelkenar; (s, t) ∈ [0,1]² ile içini dolaşır."""

    def __init__(self, tanim: dict):
        if 'dortgen' in tanim:
            A, B, C = [tuple(float(v) for v in p) for p in tanim['dortgen']]
        else:
            x0, y0, x1, y1 = tanim['kutu']
            A, B, C = (x0, y0), (x1, y0), (x0, y1)
        self.A = A
        self.u = (B[0] - A[0], B[1] - A[1])
        self.v = (C[0] - A[0], C[1] - A[1])
        det = self.u[0] * self.v[1] - self.u[1] * self.v[0]
        if abs(det) < 1e-9:
            raise ValueError(f'bölge alanı sıfır: {tanim}')
        self.ters = (self.v[1] / det, -self.v[0] / det, -self.u[1] / det, self.u[0] / det)
        D = (B[0] + C[0] - A[0], B[1] + C[1] - A[1])
        xs, ys = (A[0], B[0], C[0], D[0]), (A[1], B[1], C[1], D[1])
        self.sinir = (math.floor(min(xs)), math.floor(min(ys)), math.ceil(max(xs)), math.ceil(max(ys)))
        self.lu = math.hypot(*self.u)
        self.lv = math.hypot(*self.v)

    def st(self, x: float, y: float) -> tuple:
        dx, dy = x - self.A[0], y - self.A[1]
        a, b, c, d = self.ters
        return a * dx + b * dy, c * dx + d * dy

    def xy(self, s: float, t: float) -> tuple:
        return (self.A[0] + s * self.u[0] + t * self.v[0], self.A[1] + s * self.u[1] + t * self.v[1])

    def pikseller(self, W: int, H: int):
        x0, y0, x1, y1 = self.sinir
        for y in range(max(0, y0), min(H, y1)):
            for x in range(max(0, x0), min(W, x1)):
                s, t = self.st(x + 0.5, y + 0.5)
                if -1e-9 <= s <= 1 + 1e-9 and -1e-9 <= t <= 1 + 1e-9:
                    yield x, y, min(1.0, max(0.0, s)), min(1.0, max(0.0, t))


def ornek(px, W: int, H: int, x: float, y: float) -> tuple:
    xi = min(W - 1, max(0, int(math.floor(x))))
    yi = min(H - 1, max(0, int(math.floor(y))))
    return px[xi, yi]


def suz(dizi: list, pencere: int) -> list:
    """Kenar boyunca ortanca süzgeç (her kanal ayrı)."""
    if pencere <= 1 or len(dizi) < 3:
        return dizi
    y = pencere // 2
    cikis = []
    for i in range(len(dizi)):
        parca = dizi[max(0, i - y): i + y + 1]
        cikis.append(tuple(ortanca([p[c] for p in parca]) for c in range(3)))
    return cikis


def aykirilari_ayikla(dizi: list, tolerans: float, genis: int = 15) -> list:
    """Kenarı kesen komşu yazı ya da çizgi örneklerini atar: geniş ortanca
    eğilimden `tolerans`tan çok sapan örnekler, iki yanındaki uygun örneklerin
    doğrusal ara değeriyle değiştirilir (geçişli zemin korunur)."""
    if len(dizi) < 3 or tolerans <= 0:
        return dizi
    egilim = suz(dizi, genis)
    uygun = [max(abs(p[c] - e[c]) for c in range(3)) <= tolerans for p, e in zip(dizi, egilim)]
    if not any(uygun):
        return egilim
    cikis = list(dizi)
    for i, iyi in enumerate(uygun):
        if iyi:
            continue
        a = next((j for j in range(i - 1, -1, -1) if uygun[j]), None)
        b = next((j for j in range(i + 1, len(dizi)) if uygun[j]), None)
        if a is None:
            cikis[i] = dizi[b]
        elif b is None:
            cikis[i] = dizi[a]
        else:
            k = (i - a) / (b - a)
            cikis[i] = tuple(dizi[a][c] + (dizi[b][c] - dizi[a][c]) * k for c in range(3))
    return cikis


def kenarlar(px, W: int, H: int, b: Bolge, pencere: int, tolerans: float) -> tuple:
    nu = max(2, round(b.lu))
    nv = max(2, round(b.lv))
    ds = [d / b.lu for d in (1.0, 2.0, 3.0)]
    dt = [d / b.lv for d in (1.0, 2.0, 3.0)]

    def bant(noktalar):
        return tuple(ortanca([ornek(px, W, H, *b.xy(s, t))[c] for s, t in noktalar]) for c in range(3))

    ust, alt, sol, sag = [], [], [], []
    for i in range(nu):
        s = (i + 0.5) / nu
        ust.append(bant([(s, -d) for d in dt]))
        alt.append(bant([(s, 1 + d) for d in dt]))
    for j in range(nv):
        t = (j + 0.5) / nv
        sol.append(bant([(-d, t) for d in ds]))
        sag.append(bant([(1 + d, t) for d in ds]))
    return tuple(suz(aykirilari_ayikla(k, tolerans), pencere) for k in (ust, alt, sol, sag))


def ara(dizi: list, s: float) -> tuple:
    n = len(dizi)
    f = s * n - 0.5
    i = int(math.floor(f))
    if i < 0:
        return dizi[0]
    if i >= n - 1:
        return dizi[-1]
    a = f - i
    p, q = dizi[i], dizi[i + 1]
    return tuple(p[c] + (q[c] - p[c]) * a for c in range(3))


def onar(px, W: int, H: int, b: Bolge, o: dict) -> None:
    """Yalnız yazı piksellerini siler: bölgede yazı rengine `tolerans` kadar
    yakın pikseller (kenar yumuşatması için `genislet` piksel büyütülerek)
    çevredeki yazı olmayan piksellerden içe doğru yayılarak doldurulur.
    Altındaki çizim (yaprak, çizgi, saksı) yerinde kalır; harflerin örttüğü
    ince şeritler komşularından tamamlanır."""
    hedef = renk(o.get('renk', '#000000'))
    tol = float(o.get('tolerans', 60))
    bolge = {(x, y) for x, y, _, _ in b.pikseller(W, H)}
    maske = {q for q in bolge if max(abs(px[q][c] - hedef[c]) for c in range(3)) <= tol}
    for _ in range(int(o.get('genislet', 1))):
        maske |= {(x + dx, y + dy) for x, y in maske for dx in (-1, 0, 1) for dy in (-1, 0, 1)} & bolge
    if 'kaynak' in o:
        # Yazı pikselleri, aynı çizimin yazısız benzer bir yerinden (dx, dy) alınır.
        dx, dy = o['kaynak']
        kaynak = o['_ozgun']
        for x, y in maske:
            px[x, y] = kaynak[min(W - 1, max(0, x + dx)), min(H - 1, max(0, y + dy))]
        return
    komsu = ((1, 0, 1.0), (-1, 0, 1.0), (0, 1, 1.0), (0, -1, 1.0),
             (1, 1, 0.7), (1, -1, 0.7), (-1, 1, 0.7), (-1, -1, 0.7))
    esik = 1.7
    while maske:
        sinir = []
        for x, y in maske:
            acc, ag = [0.0, 0.0, 0.0], 0.0
            for dx, dy, w in komsu:
                q = (x + dx, y + dy)
                if q in maske or not (0 <= q[0] < W and 0 <= q[1] < H):
                    continue
                p = px[q]
                acc[0] += w * p[0]; acc[1] += w * p[1]; acc[2] += w * p[2]
                ag += w
            if ag >= esik:
                sinir.append(((x, y), tuple(int(round(a / ag)) for a in acc)))
        if not sinir:
            if esik <= 0.5:
                break
            esik = max(0.5, esik - 0.6)
            continue
        esik = 1.7
        for q, v in sinir:
            px[q] = v
            maske.discard(q)


def ort(im: Image.Image, ozgun: Image.Image, tanim: dict, varsayilan_zemin='auto') -> None:
    b = Bolge(tanim)
    zemin = tanim.get('zemin', varsayilan_zemin)
    pencere = int(tanim.get('pencere', 5))
    W, H = im.size
    px = im.load()
    if isinstance(zemin, dict) and 'kopya' in zemin:
        dx, dy = zemin['kopya']
        kaynak = ozgun.load()
        for x, y, _, _ in b.pikseller(W, H):
            px[x, y] = kaynak[min(W - 1, max(0, x + dx)), min(H - 1, max(0, y + dy))]
        return
    if isinstance(zemin, dict) and 'onar' in zemin:
        onar(px, W, H, b, dict(zemin['onar'], _ozgun=ozgun.load()))
        return
    if isinstance(zemin, str) and zemin.startswith('#'):
        r = renk(zemin)
        for x, y, _, _ in b.pikseller(W, H):
            px[x, y] = r
        return
    ust, alt, sol, sag = kenarlar(px, W, H, b, pencere, float(tanim.get('tolerans', 40)))
    if zemin == 'duz':
        r = tuple(ortanca([p[c] for p in ust + alt + sol + sag]) for c in range(3))
        for x, y, _, _ in b.pikseller(W, H):
            px[x, y] = r
        return
    kose = {
        'ss': tuple((ust[0][c] + sol[0][c]) / 2 for c in range(3)),
        'sg': tuple((ust[-1][c] + sag[0][c]) / 2 for c in range(3)),
        'as': tuple((alt[0][c] + sol[-1][c]) / 2 for c in range(3)),
        'ag': tuple((alt[-1][c] + sag[-1][c]) / 2 for c in range(3)),
    }
    yeni = []
    for x, y, s, t in b.pikseller(W, H):
        if zemin == 'auto-yatay':
            L, R = ara(sol, t), ara(sag, t)
            p = tuple((1 - s) * L[c] + s * R[c] for c in range(3))
        elif zemin == 'auto-dikey':
            T, B = ara(ust, s), ara(alt, s)
            p = tuple((1 - t) * T[c] + t * B[c] for c in range(3))
        elif zemin == 'auto':
            T, B, L, R = ara(ust, s), ara(alt, s), ara(sol, t), ara(sag, t)
            p = tuple(
                (1 - t) * T[c] + t * B[c] + (1 - s) * L[c] + s * R[c]
                - ((1 - s) * (1 - t) * kose['ss'][c] + s * (1 - t) * kose['sg'][c]
                   + (1 - s) * t * kose['as'][c] + s * t * kose['ag'][c])
                for c in range(3))
        else:
            raise ValueError(f'bilinmeyen zemin: {zemin}')
        yeni.append((x, y, tuple(min(255, max(0, int(round(v)))) for v in p)))
    for x, y, p in yeni:
        px[x, y] = p


# --------------------------------------------------------------------------
# Yazı
# --------------------------------------------------------------------------

_yazi_onbellek: dict = {}


def yazi_tipi(ad: str, boyut: float, tablo: dict) -> ImageFont.FreeTypeFont:
    t = tablo[ad]
    yol, indeks = (t, 0) if isinstance(t, str) else (t['dosya'], t.get('indeks', 0))
    eksenler = None if isinstance(t, str) else t.get('eksenler')
    anahtar = (yol, indeks, round(boyut, 3), tuple(eksenler or ()))
    if anahtar not in _yazi_onbellek:
        if not Path(yol).exists():
            raise FileNotFoundError(f'yazı tipi yok: {ad} → {yol}')
        f = ImageFont.truetype(yol, boyut, index=indeks)
        if eksenler:
            # Değişken yazı tipi (SF Pro): eksen değerleri dosyadaki sırayla.
            f.set_variation_by_axes(eksenler)
        _yazi_onbellek[anahtar] = f
    return _yazi_onbellek[anahtar]


def satirlar(e: dict) -> list:
    """"tr"yi satır → parça listesine çevirir; parça: (metin, yazı tipi, boyut çarpanı, renk)."""
    tr = e['tr']
    ham = tr.split('\n') if isinstance(tr, str) else tr
    cikis = []
    for satir in ham:
        if isinstance(satir, str):
            satir = [{'metin': satir}]
        cikis.append([(p['metin'], p.get('yazi_tipi', e['yazi_tipi']), p.get('boyut_carpani', 1.0),
                       p.get('renk', e['renk'])) for p in satir])
    return cikis


def satir_genisligi(satir: list, boyut: float, tablo: dict, ss: int = 1) -> float:
    """Satırın ilerleme genişliği; yazı `ss` katında çizildiği için genişlik de
    o boyutta ölçülür (küçük boyuttaki ipuçlu yuvarlama hizayı kaydırmasın)."""
    return sum(yazi_tipi(ad, boyut * k * ss, tablo).getlength(metin) / ss for metin, ad, k, _ in satir)


def yaz(im: Image.Image, e: dict, tablo: dict, kayit: list) -> None:
    boyut = float(e['boyut'])
    sat = satirlar(e)
    hiza = e.get('hiza', 'sol')
    ss = int(e.get('ss', 1))
    if 'en_fazla' in e:
        for _ in range(8):
            gen = max(satir_genisligi(s, boyut, tablo, ss) for s in sat)
            if gen <= e['en_fazla'] + 0.01:
                break
            boyut *= e['en_fazla'] / gen
        if boyut < float(e['boyut']) - 1e-6:
            kayit.append(f"  boyut {e['boyut']} → {boyut:.2f} (sığdırma): {e['tr']!r}")
    aralik = float(e.get('satir', boyut * 1.2))
    aci = float(e.get('aci', 0))
    kalin = float(e.get('kalin', 0))
    sikistir = float(e.get('sikistir', 1.0))
    bulanik = float(e.get('bulaniklik', 0))
    px_, py_ = e['nokta']
    genislikler = [satir_genisligi(s, boyut, tablo, ss) for s in sat]
    enbuyuk = max(genislikler)
    R = int(math.ceil(enbuyuk + aralik * len(sat) + boyut * 2)) + 4
    # Kesirli çapa yalnız döndürülmeyen yazıda korunur.
    if aci == 0:
        fx, fy = px_ - math.floor(px_), py_ - math.floor(py_)
        ox, oy = math.floor(px_) - R, math.floor(py_) - R
    else:
        fx = fy = 0.0
        ox, oy = round(px_) - R, round(py_) - R
    # Her renk ayrı maske: (renk → maske)
    maskeler: dict = {}
    for i, satir in enumerate(sat):
        g = genislikler[i]
        x = {'sol': 0.0, 'orta': -g / 2, 'sag': -g}[hiza]
        y = i * aralik
        for metin, ad, k, rk in satir:
            f = yazi_tipi(ad, boyut * k * ss, tablo)
            if rk not in maskeler:
                maskeler[rk] = Image.new('L', (2 * R * ss, 2 * R * ss), 0)
            d = ImageDraw.Draw(maskeler[rk])
            d.text(((R + fx + x) * ss, (R + fy + y) * ss), metin, font=f, fill=255, anchor='ls',
                   stroke_width=int(round(kalin * ss)), stroke_fill=255)
            x += yazi_tipi(ad, boyut * k * ss, tablo).getlength(metin) / ss
    for rk, m in maskeler.items():
        if ss > 1:
            m = m.resize((2 * R, 2 * R), Image.BOX)
        if sikistir != 1.0:
            # Çapanın çevresinde yatay ölçek (çapa = katman merkezi + kesir).
            yeni = Image.new('L', m.size, 0)
            gw = max(1, round(m.width * sikistir))
            dar = m.resize((gw, m.height), Image.LANCZOS)
            yeni.paste(dar, (round((R + fx) - (R + fx) * sikistir), 0))
            m = yeni
        if bulanik > 0:
            m = m.filter(ImageFilter.GaussianBlur(bulanik))
        if aci:
            if aci in (90, -90, 180, 270, -270):
                m = m.transpose({90: Image.ROTATE_90, -270: Image.ROTATE_90, -90: Image.ROTATE_270,
                                 270: Image.ROTATE_270, 180: Image.ROTATE_180}[int(aci)])
            else:
                m = m.rotate(aci, resample=Image.BICUBIC, center=(R, R))
        im.paste(Image.new('RGB', m.size, renk(rk)), (ox, oy), m)


# --------------------------------------------------------------------------

def bolgeler(e: dict) -> list:
    if 'ortu' in e:
        return [dict(b, zemin=b.get('zemin', e.get('zemin', 'auto'))) for b in e['ortu']]
    if 'kutu' in e or 'dortgen' in e:
        b = {k: e[k] for k in ('kutu', 'dortgen', 'zemin', 'pencere', 'tolerans') if k in e}
        return [b]
    return []


def uret(kimlik: str, tanim: dict, tablo: dict) -> str:
    kaynak = GORSEL / f'{kimlik}.webp'
    hedef = GORSEL / f'{kimlik}.tr.webp'
    ozgun = Image.open(kaynak).convert('RGB')
    im = ozgun.copy()
    vars_ = tanim.get('varsayilan', {})
    etiketler = [dict(vars_, **e) for e in tanim.get('etiketler', [])]
    kayit: list = []
    # 1) Taşınacak özgün pikseller (örtmeden önce alınır).
    parcalar = []
    for t in tanim.get('tasimalar', []):
        x0, y0, x1, y1 = t['kutu']
        parcalar.append((ozgun.crop((x0, y0, x1, y1)), tuple(t['hedef'])))
    # 2) Örtme: etiketler, ek örtüler, taşınan bölgelerin eski yeri (sırayla).
    for e in etiketler:
        for b in bolgeler(e):
            ort(im, ozgun, b)
    for b in tanim.get('ortuler', []):
        ort(im, ozgun, b)
    for t in tanim.get('tasimalar', []):
        ort(im, ozgun, {'kutu': t['kutu'], 'zemin': t.get('zemin', 'auto')})
    # 3) Taşınan parçaları yeni yerine koy.
    for parca, (x, y) in parcalar:
        im.paste(parca, (x, y))
    # 4) Türkçe yazılar.
    for e in etiketler:
        if e.get('tr') is None:
            continue
        yaz(im, e, tablo, kayit)
    assert im.size == ozgun.size
    im.save(hedef, 'WEBP', quality=KALITE, method=6)
    ozet = hashlib.sha256(hedef.read_bytes()).hexdigest()
    print(f'{hedef.relative_to(DEPO)}  {im.width}×{im.height}  sha256 {ozet}')
    for k in kayit:
        print(k)
    return ozet


def tablo_yaz(veri: dict, kimlikler: list) -> None:
    for kimlik in kimlikler:
        print(f'## {kimlik}')
        for e in veri['gorseller'][kimlik].get('etiketler', []):
            tr = e.get('tr')
            if tr is None:
                continue
            if not isinstance(tr, str):
                tr = '\n'.join(s if isinstance(s, str) else ''.join(p['metin'] for p in s) for s in tr)
            print(f"  {e.get('en', '')!r:60} → {tr!r}")


def main(argv: list) -> int:
    veri = json.loads(TANIM.read_text(encoding='utf-8'))
    tablo = veri['yazi_tipleri']
    tum = list(veri['gorseller'])
    if argv and argv[0] == '--tablo':
        tablo_yaz(veri, argv[1:] or tum)
        return 0
    secilen = argv or tum
    bilinmeyen = [k for k in secilen if k not in veri['gorseller']]
    if bilinmeyen:
        print('tanımda yok:', ', '.join(bilinmeyen), file=sys.stderr)
        return 2
    for kimlik in secilen:
        uret(kimlik, veri['gorseller'][kimlik], tablo)
    return 0


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
