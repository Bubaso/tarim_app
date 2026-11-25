"""Telefonda uzun paragrafın GÖRÜNÜMDE cümle sonundan bölünmesi — Python ikizi.

Dart eşi: lib/features/yapay_zeka/presentation/yz_telefon_bolme.dart. İkisi
AYNI kuralı uygular; `--fikstur` bütün sayfalarda bölme noktalarını üretip
test/veri/yz_telefon_bolme.json'a yazar, test/yz_telefon_bolme_test.dart Dart
bölücünün aynı noktaları bulduğunu sınar. Kural değişirse ikisi birlikte
değişir ve fikstür yeniden üretilir:

    python3 content/yapay_zeka_dijital_tarim/_raw/telefon_bolme.py --fikstur

.md dosyalarına dokunmaz; metin AYNEN kalır, yalnız telefonda çizim bölünür.

KURAL (madde 2 ve 4):
  * Ölçü GÖRÜNEN harftir: `*` işaretleri sayılmaz, baştaki/sondaki boşluk
    sayılmaz.
  * Etkin ölçek s = sistem yazı büyütmesi × okurun yazı boyu (A−/A+).
    W = metin sütununun genişliği (375 px'lik telefonda 343).
  * Eşik E = 560 × (W/343) / s²; en küçük parça M = max(120, 180/s).
  * E'yi aşan paragraf, ortasına en yakın cümle sonundan ikiye ayrılır
    (|sol − sağ| en küçük; eşitlikte önce gelen); iki yanın her biri en az
    M. Parça hâlâ E'yi aşıyorsa kural ona da uygulanır. Uygun sınır yoksa
    bölünmez.
  * Giriş paragrafı (sayfanın ilk bloğu paragrafsa): G = 220 × (W/343) / s.
    Paragraf G'yi aşıyorsa ilk parça, kalanı en az M olan cümle
    sonlarından G'yi aşmayan EN SONUNCUSUYLA biter; hiçbiri sığmıyorsa
    yalnız ilk cümle. Kalan kısım gövde kuralıyla (E, M) bölünür.
  * Sözlük (§29) ve Kaynakça (§30) sayfalarında bölme yok (çizici ayrıca
    sözlükten açılan terimin bloğunda da bölmüyor).

CÜMLE SONU: . ! ? … (ardışık işaretler tek aday) + isteğe bağlı kapanış
(” " ’ ) **) + boşluk + (atlanan * “ " ' ‘ ( « [ sonrası) büyük harf, rakam
ya da %. Parantez, tırnak ve **…** içinde sınır yok. Noktadan önceki kelime
kısaltma (ör., vb., bkz., Dr., Prof., e.g., U.S. …), tek büyük harf (baş
harf; İngilizcede "I" hariç), Türkçede Roma rakamı (IV.) ya da Türkçede
büyük harften önce 1-4 haneli sayıysa (sıra sayısı: "2. Dünya") sınır yok.
Büyük harf sınıfı açık yazılı (Türkçe harflerle); büyütme/küçültme yok.

KONUMLAR: fikstürdeki konumlar UTF-16 birimiyle (Dart String dizini).
"""
from __future__ import annotations

import json
import re
import sys
from pathlib import Path

KOK = Path(__file__).resolve().parents[1]           # content/yapay_zeka_dijital_tarim
DEPO = KOK.parents[1]
FIKSTUR = DEPO / "test/veri/yz_telefon_bolme.json"

TABAN_GENISLIK = 343.0
TABAN_ESIK = 560.0
TABAN_EN_AZ = 180.0
ALT_SINIR = 120.0
GIRIS_TABAN = 220.0
BOLUMSUZ = {29, 30}

BUYUK = "ABCDEFGHIJKLMNOPQRSTUVWXYZÇĞİÖŞÜÂÎÛ"
NOKTALAMA = ".!?…"
KAPANIS = "”\"’)"
ATLANAN = "*“\"'‘(«["
BAS_TEMIZ = "(“\"*'‘"

KISALTMALAR = {
    "ör", "vb", "vs", "bkz", "Dr", "Prof", "Doç", "yy", "St", "No", "Av", "Yrd",
    "Öğr", "Gör", "Arş", "Ltd", "Şti", "A.Ş", "AŞ", "Bşk", "Md", "Müd", "çev",
    "haz", "yay", "s", "ss", "c", "vd", "Tel", "Mah", "Cad", "Sok", "Inc", "Co",
    "Corp", "Jr", "Sr", "Mr", "Ms", "Mrs", "Fig", "vol", "al", "approx", "e.g",
    "i.e", "etc", "cf", "U.S", "U.K", "U.N", "Mt", "Ave", "Univ", "Dept",
    "est", "ca", "no", "Nos", "pp", "p", "Eq", "Ref", "viz", "Gen", "Col",
    "Gov", "Sen", "Rep",
}

_ONCEKI = re.compile(r"(\S+)$")
_ROMA = re.compile(r"[IVX]{1,5}")
_BAS_HARF = re.compile(r"[A-ZÇĞİÖŞÜ]")
_NOKTALI = re.compile(r"(?:[A-Za-z]\.)+[A-Za-z]")
_SAYI = re.compile(r"\d{1,4}")


def gorunen_uzunluk(metin: str) -> int:
    """Okurun gördüğü harf sayısı: `*` sayılmaz, uçtaki boşluk sayılmaz."""
    return sum(1 for c in metin.strip() if c != "*")


def _buyuk_mu(c: str) -> bool:
    return c != "" and c in BUYUK


def _rakam_mi(c: str) -> bool:
    return c != "" and "0" <= c <= "9"


def cumle_sinirlari(metin: str, en: bool = False) -> list[int]:
    """Cümle sınırları: bir sonraki cümlenin ilk karakterinin konumu."""
    sinirlar: list[int] = []
    par = 0
    tirnak = False
    kalin = False
    n = len(metin)
    i = 0
    while i < n:
        if metin.startswith("**", i):
            kalin = not kalin
            i += 2
            continue
        c = metin[i]
        if c == "(":
            par += 1
        elif c == ")":
            par = max(0, par - 1)
        elif c == "“":
            tirnak = True
        elif c == "”":
            tirnak = False
        elif c == '"':
            tirnak = not tirnak
        if c in NOKTALAMA and par == 0 and not tirnak and not kalin:
            son = i + 1
            while son < n and metin[son] in NOKTALAMA:
                son += 1
            j = son
            while j < n and (metin[j] in KAPANIS or metin.startswith("**", j)):
                j += 2 if metin.startswith("**", j) else 1
            if j < n and metin[j] == " ":
                k = j
                while k < n and metin[k] == " ":
                    k += 1
                a = k
                while a < n and metin[a] in ATLANAN:
                    a += 1
                ilk = metin[a] if a < n else ""
                if _buyuk_mu(ilk) or _rakam_mi(ilk) or ilk == "%":
                    m = _ONCEKI.search(metin[:i])
                    onceki = (m.group(1) if m else "").lstrip(BAS_TEMIZ)
                    kisaltma = False
                    if c == ".":
                        if onceki in KISALTMALAR or onceki.rstrip(".") in KISALTMALAR:
                            kisaltma = True
                        elif not en and _ROMA.fullmatch(onceki):
                            kisaltma = True
                        elif _BAS_HARF.fullmatch(onceki) and not (en and onceki == "I"):
                            kisaltma = True
                        elif _NOKTALI.fullmatch(onceki):
                            kisaltma = True
                        elif not en and _SAYI.fullmatch(onceki) and _buyuk_mu(ilk):
                            kisaltma = True
                    if not kisaltma:
                        sinirlar.append(k)
            # Kapanışlar ana döngüde işlensin (** durumunu doğru çevirsin).
            i = son
            continue
        i += 1
    return sinirlar


def esik(genislik: float, s: float) -> float:
    return TABAN_ESIK * (genislik / TABAN_GENISLIK) / (s * s)


def en_az(s: float) -> float:
    return max(ALT_SINIR, TABAN_EN_AZ / s)


def giris_siniri(genislik: float, s: float) -> float:
    return GIRIS_TABAN * (genislik / TABAN_GENISLIK) / s


def bolme_noktalari(metin: str, e: float, m: float, en: bool = False,
                    bas: int = 0, son: int | None = None) -> list[int]:
    """[bas, son) aralığının gövde kuralıyla bölme noktaları (mutlak)."""
    if son is None:
        son = len(metin)
    parca = metin[bas:son]
    if gorunen_uzunluk(parca) <= e:
        return []
    en_iyi = None
    en_iyi_fark = None
    for k in cumle_sinirlari(parca, en):
        sol = gorunen_uzunluk(parca[:k])
        sag = gorunen_uzunluk(parca[k:])
        if sol < m or sag < m:
            continue
        fark = abs(sol - sag)
        if en_iyi_fark is None or fark < en_iyi_fark:
            en_iyi, en_iyi_fark = k, fark
    if en_iyi is None:
        return []
    mutlak = bas + en_iyi
    return (bolme_noktalari(metin, e, m, en, bas, mutlak) + [mutlak]
            + bolme_noktalari(metin, e, m, en, mutlak, son))


def giris_noktasi(metin: str, g: float, m: float, en: bool = False) -> int | None:
    """Giriş paragrafının ilk parçasının bittiği yer (yoksa None)."""
    if gorunen_uzunluk(metin) <= g:
        return None
    adaylar = [k for k in cumle_sinirlari(metin, en) if gorunen_uzunluk(metin[k:]) >= m]
    if not adaylar:
        return None
    sigan = [k for k in adaylar if gorunen_uzunluk(metin[:k]) <= g]
    return sigan[-1] if sigan else adaylar[0]


def telefon_noktalari(metin: str, genislik: float, s: float, giris: bool = False,
                      en: bool = False) -> list[int]:
    """Çizicinin kullandığı bütün bölme noktaları (artan sırada)."""
    e, m = esik(genislik, s), en_az(s)
    if giris:
        k = giris_noktasi(metin, giris_siniri(genislik, s), m, en)
        if k is not None:
            return [k] + bolme_noktalari(metin, e, m, en, k, len(metin))
        return []
    return bolme_noktalari(metin, e, m, en)


def parcalar(metin: str, noktalar: list[int]) -> list[str]:
    s = [0] + noktalar + [len(metin)]
    return [metin[a:b].strip() for a, b in zip(s, s[1:])]


# ── yzAyristir'in paragraf kesiti ───────────────────────────────────────
# yzAyristir'in blok saydığı yönergeler: grafik, görsel, öne çıkan cümle,
# canlı pencere (kural 20). Hepsi tek blok; paragraf değil.
_YONERGE = re.compile(r"^\[\[(grafik|gorsel|cekme|canli):([a-z0-9-]+)\]\]$")


def bloklar(md: str) -> list[tuple[str, str]]:
    """(tür, metin) — yzAyristir ile aynı blok sırası; yalnız paragraf
    metni dolu (öbürleri yalnız sırayı ve giriş tespitini taşır)."""
    cikti: list[tuple[str, str]] = []
    satirlar = md.replace("\r\n", "\n").split("\n")
    par: list[str] = []

    def kapat():
        if par:
            cikti.append(("paragraf", " ".join(par)))
            par.clear()

    i = 0
    while i < len(satirlar):
        t = satirlar[i].strip()
        if not t:
            kapat(); i += 1
        elif t.startswith("# "):
            kapat(); i += 1
        elif _YONERGE.match(t):
            kapat(); cikti.append(("yonerge", "")); i += 1
        elif t.startswith("## "):
            kapat(); cikti.append(("altBaslik", "")); i += 1
        elif t.startswith("- "):
            kapat()
            while i < len(satirlar) and satirlar[i].strip().startswith("- "):
                i += 1
            cikti.append(("liste", ""))
        elif t.startswith(">"):
            kapat()
            while i < len(satirlar) and satirlar[i].strip().startswith(">"):
                i += 1
            cikti.append(("ozet", ""))
        elif t.startswith("|"):
            kapat()
            while i < len(satirlar) and satirlar[i].strip().startswith("|"):
                i += 1
            cikti.append(("tablo", ""))
        else:
            par.append(t)
            i += 1
    kapat()
    return cikti


def sayfalar() -> list[Path]:
    return sorted((KOK / "bolumler").glob("*.md")) + sorted((KOK / "teknolojiler").glob("*.md"))


def bolum_no(yol: Path) -> int | None:
    if yol.parent.name != "bolumler":
        return None
    return int(yol.name[:2])


def _utf16(metin: str, k: int) -> int:
    return len(metin[:k].encode("utf-16-le")) // 2


# Fikstürün koşulları: (sütun genişliği, etkin ölçek). 320/360/375/414 px
# telefonlar (sütun = genişlik − 32) ve beş yazı boyu.
KOSULLAR = [(343.0, 1.0), (343.0, 0.9), (343.0, 1.4), (288.0, 1.12), (328.0, 1.0), (382.0, 1.82)]


def fikstur() -> dict:
    sonuc: dict = {"kosullar": [{"genislik": w, "s": s} for w, s in KOSULLAR], "sayfalar": {}}
    for yol in sayfalar():
        no = bolum_no(yol)
        en = yol.name.endswith(".en.md")
        bl = bloklar(yol.read_text(encoding="utf-8"))
        ad = f"{yol.parent.name}/{yol.name}"
        kayit: dict = {}
        for i, (tur, metin) in enumerate(bl):
            if tur != "paragraf" or no in BOLUMSUZ:
                continue
            giris = i == 0
            noktalar = []
            for w, s in KOSULLAR:
                nk = telefon_noktalari(metin, w, s, giris=giris, en=en)
                noktalar.append([_utf16(metin, k) for k in nk])
            if any(noktalar):
                kayit[str(i)] = noktalar
        sonuc["sayfalar"][ad] = kayit
    return sonuc


def _ozet():
    """375 px, s=1: kaç paragraf bölünüyor."""
    for dil in ("tr", "en"):
        toplam = bolunen = parca = giris = 0
        for yol in sayfalar():
            if not yol.name.endswith(f".{dil}.md") or bolum_no(yol) in BOLUMSUZ:
                continue
            for i, (tur, metin) in enumerate(bloklar(yol.read_text(encoding="utf-8"))):
                if tur != "paragraf":
                    continue
                toplam += 1
                nk = telefon_noktalari(metin, 343.0, 1.0, giris=i == 0, en=dil == "en")
                if nk:
                    bolunen += 1
                    parca += len(nk) + 1
                    giris += i == 0
        print(f"[{dil}] 375 px, s=1: {bolunen}/{toplam} paragraf bölünüyor "
              f"({giris} giriş), {parca} parça")


if __name__ == "__main__":
    if "--fikstur" in sys.argv:
        FIKSTUR.parent.mkdir(parents=True, exist_ok=True)
        FIKSTUR.write_text(json.dumps(fikstur(), ensure_ascii=False, separators=(",", ":")) + "\n",
                           encoding="utf-8")
        print(f"yazıldı: {FIKSTUR.relative_to(DEPO)}")
    _ozet()
