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
ADET = 60


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

    kabuk.write_text(metin[:i + len(BAS)] + govde + metin[j:], encoding="utf-8")
    print(f"✓ {len(kayitlar)} haber bağlantısı gömüldü ({len(govde):,} bayt)")


if __name__ == "__main__":
    main()
