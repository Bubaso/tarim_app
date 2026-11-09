#!/usr/bin/env python3
"""Ana sayfanın SSR gövdesini derleme anında `build/web/index.html`e gömer.

NEDEN VAR (§19.2). CanvasKit her şeyi tuvale PİKSEL olarak çiziyor; DOM'da tek
bir metin düğümü bile oluşmuyor. Ölçüldü: ana sayfa tam yüklendiğinde
`document.body.innerText.length` = 0 ve `<a>` = 0. Yani arama motoru siteye
girip hiçbir yere GİDEMİYORDU — gövde metni bir yana, bağlantı bile yoktu.

NEDEN FONKSİYON DEĞİL, DERLEME ANI. `homeRenderer` yazıldı ve yayında ama
KULLANILMIYOR: Firebase Hosting statik dosyaları yönlendirmelerden ÖNCE
sunuyor, kökte bir index.html durduğu sürece `"source": "/"` rewrite'ı hiç
devreye girmiyor (aynı davranış §2.5'te dosya sayfaları için de yazılı).

Derleme anında gömmenin fonksiyonla elde edilemeyecek bir yan faydası var:
`**` yakalayıcısı TÜM rotaları aynı index.html ile sunduğu için bu liste
/piyasalar, /yazarlar ve kategori sayfalarında da bulunuyor.

KULLANICI BUNU GÖRMÜYOR: üstünde tam ekran #splash var ve Flutter ilk kareyi
çizer çizmez index.html'deki `hide()` bloğu #ssr-content düğümünü DOM'dan
siliyor. Gizleme (cloaking) değil — sunulan metin ile uygulamanın gösterdiği
metin aynı, yalnızca biri ötekinin üstünü örtüyor.

Bu dosya 6 Eylül 2026'da yazıldı, 4 Ekim 2026'daki iCloud kaybında gitti
(commit edilmemişti) ve 5 Ekim 2026'da CANLI ÇIKTIDAN birebir geri yazıldı.

Kullanım:  python3 scripts/ana_sayfa_linkleri.py
"""
import html
import json
import pathlib
import sys
import urllib.request

KOK = pathlib.Path(__file__).resolve().parent.parent
ADRES = "https://tarimportali.net"
BAS, SON = "<!-- SSR_CONTENT_START -->", "<!-- SSR_CONTENT_END -->"
M_BAS, M_SON = "<!-- MOZAIK_START -->", "<!-- MOZAIK_END -->"
ADET = 60

# Açılış mozaiğindeki benzersiz görsel sayısı. 28'den 35'e çıkarıldı:
# tekrar eden kare arası mesafe artıyor, desen kendini daha az
# tekrarlıyor. Gömülü LQIP yükü ~19 KB — hepsi satır içi, ek istek yok.
MOZAIK_ADET = 35


def env():
    d = {}
    for satir in (KOK / ".env").read_text(encoding="utf-8").splitlines():
        if "=" in satir and not satir.lstrip().startswith("#"):
            k, _, v = satir.partition("=")
            d[k.strip()] = v.strip()
    return d


def haberler(url, anahtar):
    istek = urllib.request.Request(
        f"{url}/rest/v1/articles?select=id,title&status=eq.published"
        f"&order=published_at.desc&limit={ADET}",
        headers={"apikey": anahtar, "Authorization": f"Bearer {anahtar}"})
    with urllib.request.urlopen(istek, timeout=60) as y:
        return json.load(y)


def mozaik_kareleri(url, anahtar):
    """Açılış mozaiğinin yedek seti.

    Bu set yalnızca İLK ziyarette ve `localStorage` boşken kullanılıyor;
    normalde uygulama bir önceki açılışta o günün haberlerini oraya
    yazıyor. Yani buradaki görseller dağıtımdan dağıtıma yaşlanabilir ve
    bu sorun değil — tek işleri ilk kareyi doldurmak.

    `image_lqip` ZORUNLU: mozaiğin anında dolu açılmasını sağlayan şey o.
    LQIP'i olmayan haber karede gri bir kutu bırakırdı.
    """
    istek = urllib.request.Request(
        f"{url}/rest/v1/articles?select=thumb_image_url,image_lqip"
        "&status=eq.published&thumb_image_url=not.is.null"
        f"&image_lqip=not.is.null&order=created_at.desc&limit={MOZAIK_ADET}",
        headers={"apikey": anahtar, "Authorization": f"Bearer {anahtar}"})
    with urllib.request.urlopen(istek, timeout=60) as y:
        return [{"t": k["thumb_image_url"], "l": k["image_lqip"]}
                for k in json.load(y)]


def main():
    kabuk = KOK / "build" / "web" / "index.html"
    if not kabuk.exists():
        sys.exit("✗ build/web/index.html yok. Önce flutter build web.")

    metin = kabuk.read_text(encoding="utf-8")
    i, j = metin.find(BAS), metin.find(SON)
    # deploy.sh ayrıca denetliyor ama burada da duruyor: işaretler kaybolursa
    # site arama motorlarına SESSİZCE görünmez olur, hiçbir hata vermeden.
    if i < 0 or j < 0:
        sys.exit("✗ index.html içinde SSR_CONTENT işaretleri yok.")

    e = env()
    try:
        kayitlar = haberler(e["SUPABASE_URL"], e["SUPABASE_ANON_KEY"])
    except Exception as hata:                       # noqa: BLE001
        # Liste üretilemezse işaretler BOŞ kalır ve sayfa eskisi gibi çalışır.
        # Zenginleştirme başarısız olabilir; sayfa kırılmaz.
        print(f"  ⚠ haber listesi alınamadı ({hata}) — işaretler boş bırakıldı")
        kayitlar = []

    satirlar = "".join(
        f'<li><a href="{ADRES}/haber/{k["id"]}">{html.escape(k["title"] or "")}</a></li>'
        for k in kayitlar)
    govde = (
        '<div id="ssr-content">'
        "<h1>Tarım Portalı</h1>"
        "<p>Türkiye tarım, hayvancılık ve ekonomi haberleri.</p>"
        "<h2>Son haberler</h2>"
        f"<ul>{satirlar}</ul>"
        "</div>")

    metin = metin[:i + len(BAS)] + govde + metin[j:]

    # ── Açılış mozaiğinin yedek seti ──
    mi, mj = metin.find(M_BAS), metin.find(M_SON)
    if mi < 0 or mj < 0:
        # İşaret yoksa mozaik veri bulamaz ve açılış ekranı düz krem kalır.
        # Sayfa kırılmaz ama ekran boşalır; o yüzden uyarı basılıyor.
        print("  ⚠ index.html içinde MOZAIK işaretleri yok — mozaik boş kalacak")
    else:
        try:
            kareler = mozaik_kareleri(e["SUPABASE_URL"], e["SUPABASE_ANON_KEY"])
        except Exception as hata:                   # noqa: BLE001
            print(f"  ⚠ mozaik görselleri alınamadı ({hata}) — boş bırakıldı")
            kareler = []
        if kareler:
            # `</script>` dizisi JSON içinde geçerse betik bloğu ERKEN
            # kapanır; tek güvenli yol onu kırmak.
            veri = json.dumps(kareler, ensure_ascii=False).replace("</", "<\\/")
            blok = f"<script>window.__MOZAIK={veri}</script>"
        else:
            blok = ""
        metin = metin[:mi + len(M_BAS)] + blok + metin[mj:]
        print(f"✓ {len(kareler)} mozaik karesi gömüldü ({len(blok):,} bayt)")

    kabuk.write_text(metin, encoding="utf-8")
    print(f"✓ {len(kayitlar)} haber bağlantısı gömüldü ({len(govde):,} bayt)")


if __name__ == "__main__":
    main()
