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
#   ./deploy.sh --fn=ogRenderer  → hosting + YALNIZCA o fonksiyon
#
# `--fn=` neden var:
#   Canlıda, bu depoda KARŞILIĞI OLMAYAN fonksiyonlar duruyor. 3 Kasım 2026
#   ölçümü:
#
#     columnistAudio · homeRenderer · indexNowPing · publishScheduled
#
#   Tam `functions` dağıtımı bunları "yerel kaynakta yok" sayıp SİLMEYE
#   çalışıyor. Firebase etkileşimsiz kipte kendiliğinden duruyor — yani bugün
#   bizi CLI kurtardı, bekçi değil. `--fn=` ile yalnızca adı verilen fonksiyon
#   güncelleniyor ve ötekilere dokunulmuyor.
#
#   Bu bir ÇÖZÜM DEĞİL, geçici bir yol. Kalıcı çözüm dört fonksiyonu canlıdan
#   okuyup depoya geri yazmak (CLAUDE.md §19.4'teki ogRenderer işiyle aynı
#   iş). O yapılana kadar çıplak `./deploy.sh` fonksiyon tarafında kullanılmaz.

set -euo pipefail

cd "$(dirname "$0")"

DO_BUILD=1
# HAZIRLIK: derleme SONRASI adımlar (service worker, functions/shell.html,
# anasayfa link listesi, açılış mozaiği, dosya kabukları). Bunlar `DO_BUILD`
# kapısının DIŞINDA, çünkü mevcut `build/web` üzerinde çalışıyorlar ve
# `--no-build` ile de koşmaları gerekiyor. Ama hepsi Supabase'e gidiyor:
# yalnız fonksiyon dağıtacakken koşmaları, kapalı bir Supabase'de anasayfa
# link listesini BOŞALTIYOR ve dosya kabuğu adımında dağıtımı düşürüyor
# (10 Kasım 2026'da tam böyle oldu). `--sadece-fn` bu bayrağı kapatıyor.
HAZIRLIK=1
TARGETS="hosting,functions"

for arg in "$@"; do
  case "$arg" in
    --hosting)  TARGETS="hosting" ;;
    --no-build) DO_BUILD=0 ;;
    --fn=*)     TARGETS="hosting,functions:${arg#--fn=}" ;;
    # Yalnız fonksiyon — HOSTING'E HİÇ DOKUNMAZ, derleme de yapmaz.
    #
    # `--fn=` hosting'i de dağıtıyor ve hosting dağıtımı yeniden derleme
    # gerektiriyor. Derlemenin içindeki `mozaik_uret.py` ve ülke/kurum kabuk
    # üreticileri Supabase'den veri çekiyor; Supabase erişilemezse (10 Kasım
    # 2026: kota aşımından proje kısıtlandı, her uç 402) bu adımlar sessizce
    # atlanıyor ve açılış ekranı boş, dosya sayfaları eksik yayına gidiyor.
    # Fonksiyon düzeltmesini o riske atmadan dağıtmak için bu seçenek var.
    #
    # Virgülle birden çok ad alır:  --sadece-fn=ogRenderer,rss,sitemap
    --sadece-fn=*)
      TARGETS=""
      IFS="," read -r -a _adlar <<< "${arg#--sadece-fn=}"
      for _ad in "${_adlar[@]}"; do
        [[ -z "$_ad" ]] && continue
        [[ -n "$TARGETS" ]] && TARGETS="$TARGETS,"
        TARGETS="${TARGETS}functions:${_ad}"
      done
      if [[ -z "$TARGETS" ]]; then
        echo "✗ --sadece-fn= en az bir fonksiyon adı istiyor." >&2
        exit 2
      fi
      DO_BUILD=0
      HAZIRLIK=0
      ;;
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
  # KAPSAM 2 KASIM 2026'DA GENİŞLETİLDİ. Burada yalnızca `web/` çekiliyordu
  # ve dağıtım tam bu yüzden düştü:
  #
  #   Target web_release_bundle failed: FileSystemException: readInto failed,
  #   path = 'assets/images/logo_full.png' (OS Error: Operation timed out,
  #   errno = 60)
  #
  # Flutter derlemesi `web/` dışında `assets/`, `lib/` ve `fonts/` altından da
  # okuyor; biri bulutta duruyorsa derleme düşüyor. Korumanın kapsamı
  # derlemenin okuduğu her yer olmalıydı.
  KLASORLER=(); for d in web assets lib fonts; do [[ -d "$d" ]] && KLASORLER+=("$d"); done
  echo "▸ Varlıklar yerele çekiliyor (iCloud): ${KLASORLER[*]}…"
  cek() { find "${KLASORLER[@]}" -type f -exec cat {} + > /dev/null 2>/tmp/tarim_icloud.log; }
  if ! cek; then
    echo "  ! bazı dosyalar okunamadı; iCloud indirmesi bekleniyor, tekrar deneniyor"
    sleep 20
    cek || {
      echo "  ✗ Dosyalar okunamıyor. iCloud senkronizasyonu takılmış olabilir;" >&2
      echo "    Finder'da klasörü açıp indirmenin bitmesini bekleyin." >&2
      echo "    Okunamayanlar: /tmp/tarim_icloud.log" >&2
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
  # --no-tree-shake-icons KALDIRILDI (6 Kasım 2026 anasayfa denetimi, A1).
  #
  # Bayrak gerekçesiz duruyordu: genel bir "projeyi temizle ve güncelle"
  # commit'iyle gelmiş, hiçbir yerde açıklanmamış. Kaldırıp denedik,
  # derleme sorunsuz geçti. Ölçülen kazanç:
  #
  #   MaterialIcons-Regular.otf   1.645.184 → 31.804 bayt  (%98,1)
  #   CupertinoIcons.ttf            257.628 →  1.472 bayt  (%99,4)
  #   Font-Awesome-Brands.otf       215.132 →  2.288 bayt  (%98,9)
  #                               ─────────────────────────────────
  #                               2.117.944 → 35.564 bayt
  #
  # Yani her ilk ziyarette ~630 KB (sıkıştırılmış) boşuna iniyordu.
  #
  # BAYRAK GERİ KONULACAKSA: tek sebebi `IconData`nın çalışma anında
  # ÜRETİLMESİ olabilir (sabit olmayan codePoint). Öyle bir yer eklenirse
  # derleme zaten açık bir hatayla durur; bayrağı geri koymadan önce o
  # hatayı okuyun — çözüm genellikle ikonu sabit bir sabite bağlamaktır.
  flutter build web --release --pwa-strategy=none
fi

if [[ ! -f build/web/index.html ]]; then
  echo "✗ build/web/index.html yok. Önce --no-build olmadan çalıştırın." >&2
  exit 1
fi

# ══════════════════════════════════════════════════════════════════════════
#  Ağırlık bekçisi (6 Kasım 2026 anasayfa denetimi)
# ──────────────────────────────────────────────────────────────────────────
#  Bu turda ilk yük 945 KB hafifledi: ikon tree-shaking geri geldi (643 KB →
#  38 KB) ve Noto yedekleri 441 KB'dan 101 KB'a indi. Kazanç tek bir
#  bayrakla kayboldu; geri gelmesi de tek bir pubspec satırıyla mümkün.
#
#  Ölçülen şey TOPLAM build/web değil (74 MB — içinde dört canvaskit
#  türevi ve tüm görseller var, ziyaretçi hiçbirini topluca indirmiyor).
#  Ölçülen şey, HER ilk ziyarette inen iki kalem:
#
#    main.dart.js (gzip)   — Firebase Hosting sıkıştırarak servis ediyor
#    FontManifest fontları — Flutter web bunları AÇILIŞTA indiriyor
#
#  Tavan, ölçülen değerin ~%8 üstü. Amaç kılı kırk yarmak değil; bir
#  bayrağın ya da gömülü bir fontun 100 KB'ları sessizce geri getirmesini
#  yakalamak.
#
#  TAVAN YÜKSELTİLECEKSE: sebebini buraya yazın. "Derleme durdu, sayıyı
#  büyüttüm" diye yükseltilen bir tavan bekçi olmaktan çıkıyor.
# ══════════════════════════════════════════════════════════════════════════
JS_TAVAN=1800000      # bayt, gzip — 6 Kas 2026 ölçümü: 1.664.255
FONT_TAVAN=70000      # bayt, ham  — 6 Kas 2026 ölçümü: 49.180

js_boyut=$(gzip -c build/web/main.dart.js | wc -c | tr -d " ")
font_boyut=$(find build/web/assets \( -name "*.ttf" -o -name "*.otf" \) -exec stat -f%z {} + | awk "{s+=\$1} END {print s+0}")

printf "▸ Ağırlık: main.dart.js %s bayt (gzip, tavan %s) · fontlar %s bayt (tavan %s)\n" \
  "$js_boyut" "$JS_TAVAN" "$font_boyut" "$FONT_TAVAN"

if (( js_boyut > JS_TAVAN )); then
  echo "✗ main.dart.js tavanı aştı: $js_boyut > $JS_TAVAN bayt." >&2
  echo "  Yeni bir paket mi girdi, yoksa tree-shaking mi kapandı? Önce ona bakın." >&2
  exit 1
fi

if (( font_boyut > FONT_TAVAN )); then
  echo "✗ Gömülü font yükü tavanı aştı: $font_boyut > $FONT_TAVAN bayt." >&2
  echo "  pubspec.yaml'a font eklendiyse: Flutter web manifest'teki HER fontu" >&2
  echo "  açılışta indiriyor — ekrana girmese bile." >&2
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
if [[ $HAZIRLIK -eq 1 ]]; then
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

# Açılış mozaiğinin sprite'ı. `flutter build web`den SONRA çalışmak
# zorunda: çıktıyı build/web içine yazıyor ve index.html'i düzenliyor.
#
# Başarısız olursa dağıtım DURMUYOR — mozaik LQIP'siz kalır ve açılış
# ekranı düz krem olur; sayfa çalışmaya devam eder. Yine de uyarı
# basılıyor, sessizce boş bir ekrana düşülmesin.
echo "▸ Açılış mozaiği üretiliyor…"
python3 scripts/mozaik_uret.py || echo "  ⚠ mozaik üretilemedi — açılış ekranı boş kalacak"
fi

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
if [[ $HAZIRLIK -eq 1 ]]; then
# Durum bekçisi — kabuklardan ÖNCE.
#
# Sıra önemli: aşağıdaki döngü yalnızca published/archived için kabuk üretiyor,
# bu dağıtım ise genel dizini DEĞİŞTİRİYOR. Yani yayin.json'ı yanlışlıkla
# 'draft' kalmış CANLI bir dosya, kabuğunu bu döngüde kaybeder ve kimse
# görmez (12 Kasım 2026'da Irak'ta on gün boyunca tam olarak böyle oldu).
# Bekçinin döngüden sonra koşmasının anlamı olmazdı: zarar çoktan yazılmış
# olurdu.
echo "▸ Dosya durumları (depo ↔ veritabanı)…"
node content/dossiers/_ortak/durum_bekcisi.mjs

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
fi

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
  #
  # İKİ AYRI KAÇIŞ VAR. dart2js yalnızca \uXXXX kullanmıyor: Latin-1
  # aralığındaki harfleri (â ç î ö û ü ve büyükleri) \xXX ile yazıyor,
  # ötekileri (ı ğ ş İ Ğ Ş) olduğu gibi bırakıyor. Yalnızca \u çözülürken
  # "Önizle" belirteci derlemede "\xd6nizle" olarak durduğu için HİÇBİR
  # ZAMAN eşleşmiyordu — yani içinde ö/ü/ç geçen bir belirteç bekçiye
  # konulamıyordu. 5 Kasım 2026'da fark edildi.
  cozulmus=$(mktemp)
  python3 - "build/web/main.dart.js" "$cozulmus" <<'PYEOF'
import io, re, sys
s = io.open(sys.argv[1], encoding='utf-8', errors='replace').read()
s = re.sub(r'\\u([0-9a-fA-F]{4})', lambda m: chr(int(m.group(1), 16)), s)
s = re.sub(r'\\x([0-9a-fA-F]{2})', lambda m: chr(int(m.group(1), 16)), s)
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
  # Klasörün YOK olması, boş olmasından daha sinsi: `[[ -d ]]` false döndüğü
  # için eski koşul bekçiyi sessizce ATLIYORDU ve dağıtım canlıdaki bütün
  # görselleri silerdi. Boş klasör hiç olmazsa hata veriyordu; silinmiş
  # klasör hiçbir şey vermiyordu.
  #
  # Görseller bir gün Supabase'den Firebase'e taşınırken "klasörü boşaltmak
  # yerine silelim" kolaycılığı tam buraya çarpacaktı.
  if [[ ! -d "$klasor" ]]; then
    echo "✗ $klasor YOK — dağıtım oradaki dosyaları canlıdan silerdi." >&2
    echo "  Klasör silinmiş olabilir; canlıdaki kopyaları depoya indirin." >&2
    exit 1
  fi
  if [[ -z "$(find "$klasor" -type f -print -quit)" ]]; then
    echo "✗ $klasor BOŞ — dağıtım oradaki dosyaları canlıdan silerdi." >&2
    echo "  Canlıdaki kopyaları önce depoya indirin." >&2
    exit 1
  fi
done

# ╔══════════════════════════════════════════════════════════════════════════╗
# ║  FONKSİYON BEKÇİSİ — depodaki functions/ canlının GERİSİNDE              ║
# ╚══════════════════════════════════════════════════════════════════════════╝
# Yukarıdaki sürüm bekçisi DERLENMİŞ WEB PAKETİNİ sınıyor; `functions/` onun
# kapsamı dışında ve bu delik 2 Kasım 2026 denetiminde ölçüldü:
#
#   SSR_CONTENT · sanitizeHtml · articleBody  →  canlıda ÇALIŞIYOR, depoda YOK
#
# Yani çıplak `./deploy.sh` canlı `ogRenderer`'ı depodaki eski sürümle ezer ve
# haber gövdesi arama motorlarına görünmez olur — §19.1'deki duruma dönüş,
# üstelik HİÇBİR HATA VERMEDEN. §19.5 "bu kontrol olmazsa sessizce kırılır"
# diye yazılmıştı; 4 Ekim'de web tarafında tam olarak öyle oldu.
#
# Belirteç eksik derse yapılacak şey belirteci SİLMEK DEĞİL: `ogRenderer`'ı
# §19.2/§19.4'e göre depoya geri yazmak. Geri yazıldığı an bu blok susar.
#
# Dizi değil dize kullanılıyor: bu Mac'te /bin/bash 3.2 ve orada `set -u`
# altında boş dizinin uzunluğunu okumak "unbound variable" veriyor.
if [[ "$TARGETS" == *functions* ]]; then
  eksik_fn=""
  # categoryRenderer AYRI bir sebeple burada: `firebase.json` /kategori/**
  # adresini ona yönlendiriyor. Fonksiyon pakette yoksa yönlendirme boşa
  # düşer ve kategori sayfaları 404 verir — §2.5'te `dossierRenderer` ile
  # bir kez yaşandı ve dağıtım yalnızca uyarı vermişti.
  for imza in SSR_CONTENT sanitizeHtml articleBody categoryRenderer grafikBloku; do
    grep -qF -- "$imza" functions/index.js || eksik_fn="$eksik_fn $imza"
  done
  if [[ -n "$eksik_fn" ]]; then
    echo "" >&2
    echo "✗ FONKSİYON DAĞITIMI DURDURULDU — depo canlının GERİSİNDE." >&2
    echo "" >&2
    echo "  Canlıda çalışan ama depoda bulunmayan:" >&2
    for e in $eksik_fn; do echo "      • $e" >&2; done
    echo "" >&2
    echo "  Bu dağıtım canlıdaki SEO gövdesini (ogRenderer) SİLERDİ." >&2
    echo "  Yalnızca siteyi dağıtmak için:   ./deploy.sh --hosting" >&2
    echo "  Kalıcı çözüm: ogRenderer'ı depoya geri yaz (CLAUDE.md §19.2, §19.4)." >&2
    exit 1
  fi
  echo "  ✓ functions/ canlıdaki özellikleri taşıyor"
fi

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
