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
  echo "▸ Flutter web derleniyor…"
  # --pwa-strategy=none: Flutter'ın service worker'ı kullanımdan kaldırıldı;
  # ürettiği sürüm kendini silip sayfayı yeniden yüklüyor, bootstrap ise onu her
  # açılışta yeniden kaydediyor. Sonuç her ziyarette tekrarlanan yenileme
  # döngüsüydü (ayrıntı: web/flutter_service_worker.js). Bu bayrak
  # `serviceWorkerSettings` bloğunu bootstrap'tan çıkarır; elle yazdığımız
  # temizleyici worker ise `web/` altından olduğu gibi kopyalanır.
  flutter build web --release --pwa-strategy=none
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
echo "▸ Temizleyici service worker yerine konuyor…"
cp web/flutter_service_worker.js build/web/flutter_service_worker.js
if ! grep -q 'registration.unregister' build/web/flutter_service_worker.js; then
  echo "✗ web/flutter_service_worker.js temizleyici sürüm değil." >&2
  exit 1
fi

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

echo "▸ Fonksiyon sözdizimi denetimi…"
node --check functions/index.js
node --check functions/config.js

echo "▸ Dağıtılıyor (${TARGETS})…"
firebase deploy --only "$TARGETS"

echo "✓ Bitti — https://tarim-app-2026.web.app"
