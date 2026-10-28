#!/usr/bin/env bash
#
# Tarım Portalı — Firebase Hosting + Cloud Functions dağıtımı.
#
# Neden ayrı bir script:
#   `ogRenderer` fonksiyonu, `functions/shell.html`e og: etiketlerini
#   enjekte ederek çalışıyor. Bu kabuk, Flutter'ın ürettiği gerçek
#   `build/web/index.html` olmak ZORUNDA — içindeki `flutter_bootstrap.js`
#   sürüm damgası her derlemede değişiyor. Elle kopyalamaya bırakılırsa bir
#   gün unutulur ve haber sayfaları eski bir paketi yüklemeye çalışır.
#   Burada kopyalama derlemenin hemen ardında, tek komutun içinde.
#
# Kullanım:
#   ./deploy.sh              → derle + hosting & functions dağıt
#   ./deploy.sh --hosting    → yalnızca hosting (fonksiyon değişmediyse hızlı)
#   ./deploy.sh --no-build   → mevcut build/web ile dağıt

set -euo pipefail

cd "$(dirname "$0")"

DO_BUILD=1
TARGETS="hosting,functions"

for arg in "$@"; do
  case "$arg" in
    --hosting)  TARGETS="hosting" ;;
    --no-build) DO_BUILD=0 ;;
    *) echo "Bilinmeyen argüman: $arg" >&2; exit 2 ;;
  esac
done

if [[ $DO_BUILD -eq 1 ]]; then
  # iCloud buluta attığı dosyaları yerelde "veri yok" yer tutucusu olarak
  # bırakıyor; derleme okumaya çalışınca `errno 60 — Operation timed out`
  # alıp düşüyor. Depo ~/Desktop altında ve orası senkronizasyona dahil
  # (bkz. CLAUDE.md §1). Dosyaları okumak iCloud'a indirmeyi tetikliyor.
  #
  # `web/` için .nosync YÖNTEMİ KULLANILAMAZ: klasör git tarafından izleniyor
  # (113 dosya) ve taşınıp yerine sembolik bağ konsaydı git hepsini silinmiş
  # görürdü. node_modules'de sorun yoktu, orası zaten gitignore'da.
  echo "▸ Varlıklar yerele çekiliyor (iCloud)…"
  if ! find web -type f -exec cat {} + > /dev/null 2>/tmp/tarim_icloud.log; then
    echo "  ! bazı dosyalar okunamadı; iCloud indirmesi bekleniyor, tekrar deneniyor"
    sleep 20
    find web -type f -exec cat {} + > /dev/null 2>/tmp/tarim_icloud.log || {
      echo "  ✗ web/ altındaki dosyalar okunamıyor. iCloud senkronizasyonu takılmış" >&2
      echo "    olabilir; Finder'da klasörü açıp indirmenin bitmesini bekleyin." >&2
      exit 1
    }
  fi

  echo "▸ Flutter web derleniyor…"
  # --pwa-strategy=none: Flutter'ın service worker'ı kullanımdan kaldırıldı;
  # ürettiği sürüm kendini silip sayfayı yeniden yüklüyor, bootstrap ise onu her
  # açılışta yeniden kaydediyor. Sonuç her ziyarette tekrarlanan yenileme
  # döngüsüydü (ayrıntı: web/flutter_service_worker.js). Bu bayrak
  # `serviceWorkerSettings` bloğunu bootstrap'tan çıkarır; elle yazdığımız
  # temizleyici worker ise `web/` altından olduğu gibi kopyalanır.
  flutter build web --release --pwa-strategy=none --no-tree-shake-icons
fi

if [[ ! -f build/web/index.html ]]; then
  echo "✗ build/web/index.html yok. Önce --no-build olmadan çalıştırın." >&2
  exit 1
fi

# Bootstrap'ta kayıt satırı kalmışsa döngü geri gelmiş demektir. (`serviceWorker`
# sözcüğü küçültülmüş flutter.js içinde parametre adı olarak zaten geçtiği için
# aranan şey gerçek ayar satırı.)
if grep -q 'serviceWorkerVersion: "' build/web/flutter_bootstrap.js; then
  echo "✗ build/web/flutter_bootstrap.js hâlâ service worker kaydediyor." >&2
  echo "  --pwa-strategy=none uygulanmamış." >&2
  exit 1
fi

# Flutter `--pwa-strategy=none` ile bu adrese BOŞ bir dosya yazıyor ve `web/`
# altındaki sürümümüzü eziyor. Daha önce kayıt yaptırmış tarayıcılar adresi
# periyodik olarak yeniden istiyor; temizleyici sürümü alabilmeleri için
# derlemeden sonra dosyayı geri koyuyoruz.
echo "▸ Özel service worker yerine konuyor…"
cp web/flutter_service_worker.js build/web/flutter_service_worker.js

echo "▸ Fonksiyon kabuğu güncelleniyor (functions/shell.html)…"
# `flutter build web` $FLUTTER_BASE_HREF'i zaten "/" ile değiştiriyor; yine de
# bir kalıntı varsa temizle — kabuk fonksiyondan servis edildiğinde çözümlenmemiş
# bir placeholder tüm göreli yolları kırardı.
sed 's|\$FLUTTER_BASE_HREF|/|g' build/web/index.html > functions/shell.html

# Kabukta işaretler yoksa fonksiyon sessizce zenginleştirmeyi atlar; bunu
# dağıtımdan önce yakalamak, canlıda jenerik kartla karşılaşmaktan iyi.
if ! grep -q 'SOCIAL_META_START' functions/shell.html; then
  echo "✗ functions/shell.html içinde SOCIAL_META_START yok." >&2
  echo "  web/index.html'deki işaret blokları silinmiş olabilir." >&2
  exit 1
fi

# Aynı gerekçe gövde işaretleri için: bunlar olmadan `ogRenderer` ve
# `homeRenderer` haber metnini sayfaya yazamaz ve site arama motorlarına
# yeniden görünmez olur — üstelik sessizce, hiçbir hata vermeden.
if ! grep -q 'SSR_CONTENT_START' functions/shell.html; then
  echo "✗ functions/shell.html içinde SSR_CONTENT_START yok." >&2
  echo "  Gövde metni arama motorlarına sunulamaz (bkz. SEO denetimi)." >&2
  exit 1
fi

# Ana sayfa link listesi — KABUK KOPYALANDIKTAN SONRA.
#
# Sıra önemli: `functions/shell.html` işaretleri BOŞ haliyle alıyor, çünkü
# `ogRenderer` oraya haberin kendi gövdesini yazacak. Liste yalnızca statik
# sunulan `build/web/index.html`e giriyor — yani ana sayfaya ve `**`
# yakalayıcısının sunduğu diğer tüm rotalara.
echo "▸ Ana sayfa link listesi gömülüyor…"
python3 scripts/ana_sayfa_linkleri.py

echo "▸ Fonksiyon sözdizimi denetimi…"
node --check functions/index.js
node --check functions/config.js

# Dosya sayfalarının statik paylaşım kabukları.
#
# Cloud Function DEĞİL: dosya 28 günde bir değişen, elle yazılmış bir metin ve
# künyesi zaten depoda. Sabit bir şeyi her istekte sunucuda üretmenin anlamı
# yok. Firebase statik dosyayı yönlendirmelerden önce sunuyor, yani
# build/web/ulke/<slug>/index.html yazıldığında /ulke/<slug> og etiketleriyle
# birlikte doğrudan geliyor ve Flutter yine normal açılıyor.
echo "▸ Dosya paylaşım kabukları…"
for d in content/dossiers/*/; do
  slug=$(basename "$d")
  [[ "$slug" == _* ]] && continue
  [[ -f "$d/yayin.json" ]] || continue
  node content/dossiers/_ortak/statik_sayfa.mjs "$slug"
done

# Kaynak klasörü OLMAYAN yayımlanmış dosyalar. Üç dosyanın klasörü 4 Ekim
# 2026'daki iCloud kaybında gitti; dosyalar veritabanında ve canlıda duruyor.
# Hosting dağıtımı genel dizini DEĞİŞTİRDİĞİ için kabuğu üretilmeyen dosya
# og etiketlerini kaybeder. Bu adım boşluğu veritabanından kapatıyor.
node content/dossiers/_ortak/statik_sayfa_db.mjs

# ╔══════════════════════════════════════════════════════════════════════╗
# ║  SÜRÜM BEKÇİSİ — geriye dağıtımı durdurur. Ayrıntı: surum_bekcisi.txt ║
# ╚══════════════════════════════════════════════════════════════════════╝
#
# Depo 4 Ekim 2026'da GitHub'dan yeniden klonlandı; GitHub 2 Eylül'de
# kalmıştı. Bu ağaçtaki lib/ canlının GERİSİNDE ve bunu hiçbir şey
# söylemiyor: derleme geçer, testler geçer, dağıtım "başarılı" der ve site
# haftalarca geriye gider. Üç kez oldu.
#
# Bu blok, canlıda çalıştığı BİLİNEN her özelliğin derlemede de bulunduğunu
# sınar. Eksik varsa dağıtım yapılmaz.
if [[ -f surum_bekcisi.txt ]]; then
  echo "▸ Sürüm bekçisi…"

  # Paket Türkçe harfleri KAÇIŞ DİZİSİYLE yazıyor: "doğrulama" derlemede
  # "do\u011frulama" olarak duruyor. Ham dosyada aramak, Türkçe karakter
  # içeren her belirteçte YANLIŞ ALARM verir ve dağıtımı sonsuza kadar
  # bloke ederdi (28 Ekim'de tam olarak böyle oldu). Önce çözüyoruz.
  cozulmus=$(mktemp)
  python3 - "build/web/main.dart.js" "$cozulmus" <<'PYEOF'
import io, re, sys
s = io.open(sys.argv[1], encoding='utf-8', errors='replace').read()
s = re.sub(r'\\u([0-9a-fA-F]{4})', lambda m: chr(int(m.group(1), 16)), s)
# yalnız kalan vekil karakterler yazdırılamıyor; aramada işe de yaramıyorlar
s = ''.join(c for c in s if not (0xD800 <= ord(c) <= 0xDFFF))
io.open(sys.argv[2], 'w', encoding='utf-8').write(s)
PYEOF

  eksik=()
  sizan=()
  while IFS= read -r belirtec; do
    [[ -z "$belirtec" || "$belirtec" == \#* ]] && continue
    if [[ "$belirtec" == '!'* ]]; then
      # YASAK: bulunmaMAlı. Bulunursa gerileme var demektir.
      yasak="${belirtec#!}"
      grep -qF -- "$yasak" "$cozulmus" && sizan+=("$yasak")
    else
      grep -qF -- "$belirtec" "$cozulmus" || eksik+=("$belirtec")
    fi
  done < surum_bekcisi.txt

  if (( ${#sizan[@]} > 0 )); then
    echo "" >&2
    echo "✗ DAĞITIM DURDURULDU — derlemeye YASAKLI içerik sızmış." >&2
    for e in "${sizan[@]}"; do echo "      • $e" >&2; done
    echo "" >&2
    echo "  Bu genellikle veritabanından gelmesi gereken bir listenin" >&2
    echo "  koda gömülü uydurma sürümüne dönmesi demektir." >&2
    exit 1
  fi

  if (( ${#eksik[@]} > 0 )); then
    echo "" >&2
    echo "✗ DAĞITIM DURDURULDU — derleme canlının GERİSİNDE." >&2
    echo "" >&2
    echo "  Canlıda çalışan ama bu derlemede BULUNMAYAN ${#eksik[@]} özellik:" >&2
    for e in "${eksik[@]}"; do echo "      • $e" >&2; done
    echo "" >&2
    echo "  Bu haliyle dağıtmak siteyi geriye alır. Bu üçüncü kez olmasın." >&2
    echo "  Ayrıntı: surum_bekcisi.txt ve CLAUDE.md §40." >&2
    exit 1
  fi
  rm -f "$cozulmus"
  echo "  ✓ $(grep -vE '^#|^$' surum_bekcisi.txt | grep -vc '^!') belirtecin tamamı derlemede var"
fi

# Dağıtım genel dizini DEĞİŞTİRİYOR: yerelde olmayan varlık canlıdan SİLİNİR
# (§40.1'de 33 dosya görseli, 28 Ekim'de 3 yazar görseli böyle gitti).
for klasor in web/yazarlar web/dosya; do
  if [[ -d "$klasor" ]] && [[ -z "$(find "$klasor" -type f -print -quit)" ]]; then
    echo "✗ $klasor BOŞ — dağıtım oradaki dosyaları canlıdan silerdi." >&2
    echo "  Canlıdaki kopyaları önce depoya indirin." >&2
    exit 1
  fi
done

echo "▸ Dağıtılıyor (${TARGETS})…"
# firebase-tools 14.x + Node 24 birleşimi fonksiyon keşfi sırasında varsayılan
# yığınla bellek taşması veriyor. Belirti yanıltıcıdır: CLI önce
#   "User code failed to load. Cannot determine backend specification.
#    Timeout after 10000."
# der; zaman aşımı büyütülünce asıl hata olan V8 OOM ortaya çıkar. Kod tarafında
# bir sorun yok — `node --check` yukarıda geçiyor ve modül tek başına 100 ms'de
# yükleniyor. İki değişken de bu yüzden burada:
#   NODE_OPTIONS ................ CLI'nin yığın sınırını yükseltir (asıl çözüm)
#   FUNCTIONS_DISCOVERY_TIMEOUT . soğuk dosya sisteminde ilk modül okuması
#                                 10 sn'yi aşabiliyor
NODE_OPTIONS="--max-old-space-size=8192" \
FUNCTIONS_DISCOVERY_TIMEOUT=120 \
  firebase deploy --only "$TARGETS"

echo "✓ Bitti — https://tarim-app-2026.web.app"
