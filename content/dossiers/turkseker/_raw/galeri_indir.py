#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Galeri karelerini indirir ve galeri_kunye.json'u yazar.

gorsel_indir.py'den İKİ FARKI var, ikisi de o betikte yaşanan hatalardan:

1. ADRES ELLE YAZILMIYOR, API'den isteniyor. gorsel_indir.py'de on dört
   adres elle kurulmuştu ve sekizi HTML döndü: thumb.wikimedia.org'u
   upload.wikimedia.org'a "düzelttim", 1920 kovasını 1440'a çektim; Commons
   yalnız standart kovaları sunuyor. Burada `iiurlwidth=1920` ile adresi
   Commons'un KENDİSİ veriyor — aslı 1920'den darsa aslının adresini
   veriyor, büyütme yapmıyor.

2. KÜNYE DE AYNI ÇAĞRIDAN geliyor. Atıf, lisans ve açıklama elle
   yazılmıyor; §2.4 gereği atıfsız görsel yayımlanmıyor ve "elle yazılmış
   atıf", yazanın hatasına açık.

İÇERİK SINANIYOR, ÇIKIŞ KODU DEĞİL: yanlış adres HTML hata sayfası
döndürüyor ve curl buna 0 diyor.
"""
import html, json, pathlib, re, subprocess, sys, time, urllib.parse, urllib.request

from PIL import Image

KOK = pathlib.Path(__file__).parent
HEDEF = KOK / "gorseller"
HEDEF.mkdir(exist_ok=True)
API = "https://commons.wikimedia.org/w/api.php"
# Kullanıcıya ya da projeye ait hiçbir bilgi taşımıyor.
UA = "research-client/1.0"
GENISLIK = 1920
TAVAN = 1600      # galeri karesinin en büyük kenarı
ARALIK = 1.0

SECIM = json.loads((KOK / "galeri_secim.json").read_text(encoding="utf-8"))["kareler"]
COMMONS = [k for k in SECIM if k["kaynak"] == "commons"]
KURUM = [k for k in SECIM if k["kaynak"] == "kurum"]

_son = [0.0]


def api(**p):
    p.setdefault("format", "json")
    p.setdefault("formatversion", "2")
    url = API + "?" + urllib.parse.urlencode(p)
    istek = urllib.request.Request(url, headers={"User-Agent": UA})
    for deneme in range(5):
        bekle = ARALIK - (time.time() - _son[0])
        if bekle > 0:
            time.sleep(bekle)
        _son[0] = time.time()
        try:
            with urllib.request.urlopen(istek, timeout=45) as y:
                return json.loads(y.read().decode("utf-8"))
        except Exception as e:
            if getattr(e, "code", None) == 429:
                time.sleep(15 * (deneme + 1))
                continue
            if deneme == 4:
                raise
            time.sleep(4)
    return {}


def _tam_mi(yol):
    """Dosya eksiksiz mi. Pillow'un load()'u kesik JPEG'de patlıyor;
    open() patlamıyor — fark bu."""
    try:
        with Image.open(yol) as im:
            im.load()
        return True
    except Exception:
        return False


def duz(v):
    """extmetadata HTML gelebiliyor; künyeye düz metin yazılıyor.

    ETİKET SİLMEK YETMİYOR. İlk sürüm yalnız <...> çıkarıyordu ve atıf
    satırı önizlemede "OSU Special Collections &amp; Archives" olarak
    çıktı: Commons'un Credit alanı HTML VARLIĞI da taşıyor. Önce
    varlıklar çözülüyor, sonra etiketler siliniyor — ters sıra
    "&lt;b&gt;" gibi kaçırılmış etiketleri geri getirirdi."""
    if not v:
        return None
    s = html.unescape(v)
    s = re.sub(r"<[^>]+>", " ", s)
    s = re.sub(r"\s+", " ", s).strip()
    return s or None


# ── 1. KÜNYE VE ADRES, TOPLU ÇAĞRIYLA ──────────────────────────────────────
basliklar = [k["dosya"] for k in COMMONS]
ham = {}
for i in range(0, len(basliklar), 40):
    d = api(action="query", prop="imageinfo", titles="|".join(basliklar[i:i + 40]),
            iiprop="url|size|mime|extmetadata", iiurlwidth=str(GENISLIK),
            iiextmetadatafilter="ImageDescription|ObjectName|DateTimeOriginal|"
                                "Artist|LicenseShortName|Credit|LicenseUrl")
    for p in d.get("query", {}).get("pages", []):
        if p.get("missing"):
            continue
        ii = (p.get("imageinfo") or [{}])[0]
        em = ii.get("extmetadata", {}) or {}
        ham[p["title"]] = {
            "adres": ii.get("thumburl") or ii.get("url"),
            "asil": ii.get("url"),
            "sayfa": ii.get("descriptionurl"),
            "mime": ii.get("mime"),
            "nesne_adi": duz(em.get("ObjectName", {}).get("value")),
            "aciklama": duz(em.get("ImageDescription", {}).get("value")),
            "tarih": duz(em.get("DateTimeOriginal", {}).get("value")),
            "atif": duz(em.get("Artist", {}).get("value")),
            "kredi": duz(em.get("Credit", {}).get("value")),
            "lisans": duz(em.get("LicenseShortName", {}).get("value")),
            "lisans_adresi": duz(em.get("LicenseUrl", {}).get("value")),
        }

# Kurum kareleri Commons'ta değil: künye kurumun kendisi.
# LİSANS UYDURULMUYOR. Bu kareler CC değil; alan kurumun kendi yayını
# olduğunu yazıyor. Kullanıcı 23 Kasım 2026'da açıkça yetkilendirdi.
KURUM_ATIF = "Türkiye Şeker Fabrikaları A.Ş."
KURUM_LISANS = "Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını"
for k in KURUM:
    ham[k["dosya"]] = {
        "adres": k["adres"], "asil": k["adres"],
        "sayfa": "https://www.turkseker.gov.tr/?ModulID=11&MenuID=57",
        "mime": "image/jpeg", "nesne_adi": k["dosya"].rsplit(".", 1)[0].replace("_", " "),
        "aciklama": None, "tarih": None,
        "atif": KURUM_ATIF, "kredi": "turkseker.gov.tr — Şeker Fabrikaları detay sayfası",
        "lisans": KURUM_LISANS, "lisans_adresi": None,
    }

# ── 2. İNDİR VE İÇERİĞİ SINA ───────────────────────────────────────────────
kunye, hata = {}, []
for k in SECIM:
    kimlik, baslik = k["kimlik"], k["dosya"]
    h = ham.get(baslik)
    if not h or not h["adres"]:
        hata.append(f"{kimlik}: kaynakta bulunamadı ({baslik})")
        continue
    if not h["atif"]:
        hata.append(f"{kimlik}: ATIF YOK — §2.4, atıfsız görsel yayımlanmaz")
        continue
    uzanti = ".png" if (h["mime"] or "").endswith("png") else ".jpg"
    yol = HEDEF / f"{kimlik}{uzanti}"
    # TAM İNDİ Mİ, sınanıyor. İlk denemede kurum karelerinin üçü 10 MB'ın
    # ortasında zaman aşımına uğradı; dosya DİSKTE VARDI ve Pillow onu
    # açabiliyordu (JPEG çözücü kesik veriyi hoş görüyor). "Dosya var"
    # kontrolü bu yüzden yetmiyor.
    tam = yol.exists() and yol.stat().st_size >= 4096 and _tam_mi(yol)
    if not tam:
        r = subprocess.run(["curl", "-sS", "--max-time", "120", "-L",
                            "-A", UA, "-o", str(yol), h["adres"]],
                           capture_output=True, text=True)
        if r.returncode != 0:
            hata.append(f"{kimlik}: curl {r.returncode} {r.stderr[:70]}")
            continue
        time.sleep(0.4)
    bayt = yol.stat().st_size if yol.exists() else 0
    bas = yol.read_bytes()[:4] if bayt else b""
    webp = bayt > 12 and yol.read_bytes()[:4] == b"RIFF" and yol.read_bytes()[8:12] == b"WEBP"
    if webp:
        # Hat JPEG/PNG bekliyor; tek webp kare (Eskişehir 1934) burada
        # çevriliyor ki aşağıdaki sihirli-bayt sınaması ortak kalsın.
        with Image.open(yol) as im:
            im.convert("RGB").save(yol, "JPEG", quality=92)
        bayt = yol.stat().st_size
        bas = yol.read_bytes()[:4]
    if bayt < 4096 or not (bas.startswith(b"\xff\xd8") or bas.startswith(b"\x89PNG")):
        hata.append(f"{kimlik}: resim değil ({bayt} bayt, baş {bas!r})")
        continue
    if not _tam_mi(yol):
        hata.append(f"{kimlik}: dosya KESİK ({bayt} bayt)")
        continue
    # ÖLÇÜ NORMALİZASYONU. Kurumun kendi kareleri 6720×4480 ve 10 MB
    # geliyor; galeri ızgarasında göz başına en çok 260 px düşüyor ve
    # tam ekranda bile 1600 px yetiyor. Otuz yedi karenin ham hâli
    # ~70 MB'lık bir dosya dizini demekti. Küçültme TEK YÖNLÜ: zaten
    # küçük olana dokunulmuyor, büyütme yok.
    with Image.open(yol) as im:
        g, y_ = im.size
        if g > TAVAN:
            im = im.convert("RGB")
            im.thumbnail((TAVAN, TAVAN * 10))
            im.save(yol, "JPEG", quality=85, optimize=True)
    bayt = yol.stat().st_size
    # Kurum karesinin adında "File:" öneki yok; bölmeyi koşulsuz yapmak
    # IndexError veriyordu.
    kunye[kimlik] = {**h, "ad": baslik.split(":", 1)[-1], "dosya": yol.name,
                     "bayt": bayt, "kaynak_turu": k["kaynak"],
                     "obek": k.get("obek")}

(HEDEF / "galeri_kunye.json").write_text(
    json.dumps({"_kural": "Atıf, lisans ve adres Commons API'sinden geldi; "
                          "elle yazılmadı. iiurlwidth=1920 — kova Commons'un "
                          "kendi verdiği kova.",
                "_genislik": GENISLIK, "kareler": kunye},
               ensure_ascii=False, indent=2), encoding="utf-8")

for kimlik, v in kunye.items():
    print(f"  ✓ {kimlik:<34} {v['bayt'] / 1024:>7.0f} KB  {v['lisans']}")
if hata:
    print("\n  ✗ " + "\n  ✗ ".join(hata))
    sys.exit(1)
print(f"\n  {len(kunye)} kare · galeri_kunye.json yazıldı")
