#!/usr/bin/env python3
"""iOS ana ekran açılış görsellerini üretir (`web/splash/apple-splash-*.png`).

NEDEN VAR. iOS'ta ana ekrandan açılan bir PWA, `apple-touch-startup-image`
verilmezse BEYAZ bir ekranla başlıyor. Verilen görsel, uygulamanın ilk
karesine benzemiyorsa açılışta görünür bir sıçrama oluyor.

NEDEN PUPPETEER DEĞİL. Önceki üretici (`puppeteer_test/generate_ios_splash.js`)
gerçek sayfanın ekran görüntüsünü alıyordu ama puppeteer kurulu değil ve
kurulumu ~150 MB'lık bir Chromium indirmesi demek. Mozaik yeterince basit
bir geometri: aynı kurgu burada doğrudan çiziliyor.

SAPMA UYARISI. Bu görseller `web/index.html`deki mozaiğin AYNI
parametreleriyle üretilmek zorunda. Kare boyu, boşluk, dönüş açısı, zemin
rengi ya da vinyet değişirse bu betik yeniden koşturulmalı; yoksa iOS'ta
ana ekrandan açılışta eski desen çıkar ve uygulama açılınca değişir.
Değerler aşağıda tek yerde ve index.html'dekilerle eşleşiyor.

Kullanım:
    python3 scripts/ios_acilis_gorselleri.py
"""
import io
import json
import math
import pathlib
import sys
import urllib.request

try:
    from PIL import Image
except ImportError:
    sys.exit("✗ Pillow gerekli:  python3 -m pip install --user Pillow")

KOK = pathlib.Path(__file__).resolve().parent.parent
CIKTI = KOK / "web" / "splash"
LOGO = KOK / "web" / "icons" / "splash-mark.png"

# ── index.html ile EŞLEŞMESİ gereken değerler ──────────────────────────────
ZEMIN = (246, 241, 231)      # #F6F1E7
MARKA_ZEMIN = (241, 234, 220)  # #F1EADC
ACI = -45
LOGO_ARALIK = 14
LOGO_SERIT = 3
GORSEL_ADET = 35


def boy_icin(gen_css, yuk_css):
    """index.html'deki `boy()` ile aynı kural."""
    return 124 if min(gen_css, yuk_css) < 600 else 200


DEVICES = [
    (320, 568, 2), (375, 667, 2), (414, 736, 3), (375, 812, 3),
    (414, 896, 2), (414, 896, 3), (360, 780, 3), (390, 844, 3),
    (393, 852, 3), (402, 874, 3), (428, 926, 3), (430, 932, 3),
    (440, 956, 3), (768, 1024, 2), (810, 1080, 2), (820, 1180, 2),
    (834, 1112, 2), (834, 1194, 2), (1024, 1366, 2),
]


def kareleri_al():
    env = {}
    for satir in (KOK / ".env").read_text(encoding="utf-8").splitlines():
        if "=" in satir and not satir.lstrip().startswith("#"):
            k, _, v = satir.partition("=")
            env[k.strip()] = v.strip()
    url, anahtar = env["SUPABASE_URL"], env["SUPABASE_ANON_KEY"]
    istek = urllib.request.Request(
        f"{url}/rest/v1/articles?select=thumb_image_url&status=eq.published"
        f"&thumb_image_url=not.is.null&order=created_at.desc&limit={GORSEL_ADET}",
        headers={"apikey": anahtar, "Authorization": f"Bearer {anahtar}"})
    with urllib.request.urlopen(istek, timeout=60) as y:
        adresler = [k["thumb_image_url"] for k in json.load(y)]

    gorseller = []
    for a in adresler:
        try:
            ham = urllib.request.urlopen(a, timeout=40).read()
            gorseller.append(Image.open(io.BytesIO(ham)).convert("RGB"))
        except Exception as hata:                    # noqa: BLE001
            print(f"  ⚠ indirilemedi: {hata}")
    return gorseller


def vinyet(im):
    """index.html'deki radyal gradyanın karşılığı — kenarlar zemine doğru solsun."""
    g, y = im.size
    maske = Image.new("L", (g, y), 0)
    px = maske.load()
    # Gradyan merkezden kenara: %40'a kadar saydam, %100'de neredeyse opak.
    yari_g, yari_y = g / 2, y / 2
    for j in range(y):
        dy = (j - yari_y) / (yari_y * 0.88)
        for i in range(g):
            dx = (i - yari_g) / (yari_g * 1.18)
            d = math.sqrt(dx * dx + dy * dy)
            if d <= 0.40:
                a = 0
            elif d >= 1.0:
                a = 235
            else:
                a = int(235 * ((d - 0.40) / 0.60) ** 1.4)
            px[i, j] = a
    im.paste(Image.new("RGB", (g, y), ZEMIN), (0, 0), maske)
    return im


def uret(gorseller, logo, gen_css, yuk_css, dpr):
    gen, yuk = gen_css * dpr, yuk_css * dpr
    boy = boy_icin(gen_css, yuk_css) * dpr
    ara = max(8 * dpr, round(boy * 0.07))

    # Döndürülmüş tuval: (genişlik + yükseklik) / √2 kadar kenar yetiyor.
    kenar = int((gen + yuk) * 0.7072) + boy
    tuval = Image.new("RGB", (kenar, kenar), ZEMIN)

    serit_sayisi = math.ceil(kenar / (boy + ara)) + 1
    kare_sayisi = math.ceil(kenar / (boy + ara)) + 2
    ust = (kenar - serit_sayisi * (boy + ara)) // 2

    n = 0
    for i in range(serit_sayisi):
        y = ust + i * (boy + ara)
        marka_seridi = (i == LOGO_SERIT)
        for j in range(kare_sayisi):
            x = j * (boy + ara)
            if marka_seridi and j % LOGO_ARALIK == 2:
                kutu = Image.new("RGB", (boy, boy), MARKA_ZEMIN)
                lg = round(boy * 0.62)
                kutu.paste(logo.resize((lg, lg), Image.LANCZOS),
                           ((boy - lg) // 2, (boy - lg) // 2),
                           logo.resize((lg, lg), Image.LANCZOS))
            else:
                kaynak = gorseller[(i * 5 + j) % len(gorseller)]
                kutu = kaynak.resize((boy, boy), Image.LANCZOS)
            tuval.paste(kutu, (x, y))
            n += 1

    dondurulmus = tuval.rotate(ACI, resample=Image.BICUBIC, expand=False,
                               fillcolor=ZEMIN)
    sol = (kenar - gen) // 2
    ustk = (kenar - yuk) // 2
    return vinyet(dondurulmus.crop((sol, ustk, sol + gen, ustk + yuk)))


def main():
    print("▸ Mozaik görselleri indiriliyor…")
    gorseller = kareleri_al()
    if len(gorseller) < 8:
        sys.exit(f"✗ yalnız {len(gorseller)} görsel indirildi — üretim durduruldu")
    logo = Image.open(LOGO).convert("RGBA")
    print(f"  {len(gorseller)} görsel hazır")

    CIKTI.mkdir(parents=True, exist_ok=True)
    for gen_css, yuk_css, dpr in DEVICES:
        im = uret(gorseller, logo, gen_css, yuk_css, dpr)
        # JPEG, PNG DEĞİL. Mozaik fotoğraftan oluşuyor; PNG'de 19 görsel
        # 69 MB tutuyordu (öncesi 4,5 MB'lık düz logo ekranlarıydı ve PNG
        # onlar için doğru biçimdi). Bu görseller iOS'ta yalnızca ana
        # ekrandan açılışta ve yalnız EŞLEŞEN tek tanesi indiriliyor;
        # kalite 78 o tek indirmede gözle fark edilmiyor.
        yol = CIKTI / f"apple-splash-{gen_css * dpr}x{yuk_css * dpr}.jpg"
        im.save(yol, "JPEG", quality=78, optimize=True, progressive=True)
        print(f"  ✓ {yol.name}  {im.width}x{im.height}  "
              f"{yol.stat().st_size / 1024:.0f} KB")
    print(f"✓ {len(DEVICES)} açılış görseli üretildi")


if __name__ == "__main__":
    main()
