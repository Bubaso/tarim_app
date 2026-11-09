#!/usr/bin/env python3
"""Açılış mozaiğinin görsellerini TEK bir sprite'a toplar ve gömer.

NEDEN SPRITE. İlk hâlinde 35 kare, Supabase'den 320x320 olarak ayrı ayrı
iniyordu: toplam 894 KB ve 35 istek. İlk açılışta kareler tek tek
netleşiyordu — ölçüldü ve kullanıcı gördü. Üstelik bu yük `canvaskit.wasm`
(2.227 KB) ve `main.dart.js` (1.219 KB) ile aynı anda bant genişliği
yarışına giriyordu.

Üç şey birden değişti:

  1. ÖLÇÜ. Kareler ekranda 124 px (telefon) / 200 px (masaüstü)
     görünüyor; 320 px gereğinden büyüktü. 200 px yeterli.
  2. TEK DOSYA. 35 ayrı istek yerine bir sprite: 264 KB. Ortak
     niceleme tablosu sayesinde toplam da küçülüyor.
  3. AYNI ANDA NETLEŞME. Tek parça indiğinde bütün kareler birden
     netleşiyor. Tek tek inen kareler "yavaş yavaş yükleniyor" hissi
     veriyordu; sprite ya hep ya hiç.

LQIP yine satır içinde: sprite inene kadar ekran bulanık ama DOLU
açılıyor, boş değil.

Kullanım (deploy.sh çağırıyor, `flutter build web`den SONRA):
    python3 scripts/mozaik_uret.py
"""
import io
import json
import math
import pathlib
import sys
import urllib.request

KOK = pathlib.Path(__file__).resolve().parent.parent
KABUK = KOK / "build" / "web" / "index.html"
SPRITE = KOK / "build" / "web" / "mozaik.jpg"

BAS, SON = "<!-- MOZAIK_START -->", "<!-- MOZAIK_END -->"
P_BAS, P_SON = "<!-- MOZAIK_PRELOAD_START -->", "<!-- MOZAIK_PRELOAD_END -->"

ADET = 35
KARE = 200        # sprite içindeki tek kare kenarı (px)
KALITE = 74
SUTUN = 6         # 6x6 = 36 yuva, 35 kare sığıyor


def env():
    d = {}
    for satir in (KOK / ".env").read_text(encoding="utf-8").splitlines():
        if "=" in satir and not satir.lstrip().startswith("#"):
            k, _, v = satir.partition("=")
            d[k.strip()] = v.strip()
    return d


def kayitlar(url, anahtar):
    istek = urllib.request.Request(
        f"{url}/rest/v1/articles?select=thumb_image_url,image_lqip"
        "&status=eq.published&thumb_image_url=not.is.null"
        f"&image_lqip=not.is.null&order=created_at.desc&limit={ADET}",
        headers={"apikey": anahtar, "Authorization": f"Bearer {anahtar}"})
    with urllib.request.urlopen(istek, timeout=60) as y:
        return json.load(y)


def main():
    if not KABUK.exists():
        sys.exit("✗ build/web/index.html yok. Önce flutter build web.")
    metin = KABUK.read_text(encoding="utf-8")
    i, j = metin.find(BAS), metin.find(SON)
    if i < 0 or j < 0:
        sys.exit("✗ index.html içinde MOZAIK işaretleri yok.")

    try:
        from PIL import Image
    except ImportError:
        # Pillow yoksa sprite üretilemiyor. Mozaik LQIP'lerle çalışmaya
        # devam etsin diye işaretler BOŞ bırakılmıyor — sayfa kırılmasın
        # diye sessizce geçiliyor ve uyarı basılıyor.
        print("  ⚠ Pillow yok — mozaik sprite'ı üretilemedi, ekran düz krem kalacak")
        return

    e = env()
    try:
        kayit = kayitlar(e["SUPABASE_URL"], e["SUPABASE_ANON_KEY"])
    except Exception as hata:                        # noqa: BLE001
        print(f"  ⚠ mozaik verisi alınamadı ({hata}) — atlandı")
        return

    satir_sayisi = math.ceil(len(kayit) / SUTUN)
    sayfa = Image.new("RGB", (SUTUN * KARE, satir_sayisi * KARE), (246, 241, 231))
    kareler = []
    yer = 0
    for k in kayit:
        try:
            ham = urllib.request.urlopen(k["thumb_image_url"], timeout=40).read()
            im = Image.open(io.BytesIO(ham)).convert("RGB")
        except Exception as hata:                    # noqa: BLE001
            print(f"  ⚠ indirilemedi, atlandı: {hata}")
            continue
        sayfa.paste(im.resize((KARE, KARE), Image.LANCZOS),
                    ((yer % SUTUN) * KARE, (yer // SUTUN) * KARE))
        # Yüzde adımı sütun sayısının BİR EKSİĞİNE bölünüyor: CSS
        # background-position yüzdesi "kalan boşluğun oranı" demek,
        # "genişliğin oranı" değil. 6 sütunda adım %20.
        kareler.append({
            "l": k["image_lqip"],
            "x": round((yer % SUTUN) * 100 / (SUTUN - 1), 3),
            "y": round((yer // SUTUN) * 100 / max(1, satir_sayisi - 1), 3),
        })
        yer += 1

    if len(kareler) < 12:
        print(f"  ⚠ yalnız {len(kareler)} kare toplandı — mozaik atlandı")
        return

    sayfa.save(SPRITE, "JPEG", quality=KALITE, optimize=True, progressive=True)
    boyut = SPRITE.stat().st_size

    veri = json.dumps({
        "sutun": SUTUN, "satir": satir_sayisi, "kareler": kareler,
    }, ensure_ascii=False).replace("</", "<\\/")
    blok = f"<script>window.__MOZAIK={veri}</script>"
    metin = metin[:i + len(BAS)] + blok + metin[j:]

    # Sprite'ı <head>'den ÖNCEDEN istiyoruz: betik çalışana kadar
    # beklemek yarım saniye kaybettiriyor ve o yarım saniye tam olarak
    # kullanıcının "bulanık geliyor" dediği aralık.
    pi, pj = metin.find(P_BAS), metin.find(P_SON)
    if pi >= 0 and pj >= 0:
        on = ('<link rel="preload" as="image" href="mozaik.jpg" '
              'fetchpriority="high">')
        metin = metin[:pi + len(P_BAS)] + on + metin[pj:]

    KABUK.write_text(metin, encoding="utf-8")
    print(f"✓ mozaik sprite'ı: {len(kareler)} kare · {sayfa.width}x{sayfa.height} px "
          f"· {boyut / 1024:.0f} KB (önceki hâli 35 istek / 894 KB)")


if __name__ == "__main__":
    main()
