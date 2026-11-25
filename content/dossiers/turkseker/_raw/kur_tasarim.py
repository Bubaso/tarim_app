#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""tasarim.json üreteci — Türkşeker, Kurum Dosyası Sayı 07.

PALET ÜRETİLMİYOR, DEVRALINIYOR. §8.4: vurgu kuruma değil KÜMEYE ait.
Türkşeker, TİGEM'in kurduğu dokuzuncu kümeye (Üretim) giriyor ve bunu
TİGEM'in kendi tasarım dosyası bir sayı önceden yazmış:

  "Rotasyonun 7. sırasındaki Türkşeker ve 8. sırasındaki Et ve Süt Kurumu
   da aynı kümeye girer — üçü de devletin kendi tesisinde üretim yapan KİT'i."

Renkler aynı olduğu için kontrast sayıları da aynı çıkacak. Yine de
KOPYALANMIYOR, yeniden ÖLÇÜLÜYOR: kopyalanan sayı kaynağından koptuğu an
sessizce yanlışlanabilir. dogrula_tasarim.py hepsini bir kez daha ölçüyor.
"""
import importlib.util, json, pathlib

KOK = pathlib.Path(__file__).parent.parent
ORTAK = KOK.parent / "_ortak" / "kontrast.py"

# _ortak/kontrast.py bir BETİK (içe aktarılınca ölçümlerini basıyor).
# Yalnız fonksiyonları lazım; çıktısı yutuluyor.
import io, contextlib
_spec = importlib.util.spec_from_file_location("ortak_kontrast", ORTAK)
_mod = importlib.util.module_from_spec(_spec)
with contextlib.redirect_stdout(io.StringIO()):
    _spec.loader.exec_module(_mod)
cr = _mod.cr

# ── Küme · DEVRALINDI ────────────────────────────────────────────────
KUME_AD, KAGIT_VURGU, KAPAK_VURGU = "Üretim", "#1F5626", "#4CC756"
KUME_SIRA = 9

KAGIT, YUZEY = "#E3E7E5", "#F0F2F0"
MUREKKEP, SESSIZ = "#15191A", "#575F61"
RAY, KURAL = "#C0C6C3", "#767E7C"
KZEMIN, KYUZEY, KMUREKKEP, KSESSIZ = "#131718", "#1D2325", "#F0F2F0", "#98A1A2"
APP_KREM = "#F6F1E7"
APP_YAPISAL_YESIL = "#2F4B2E"


def o(x, b=2):
    return round(x, b)


d = {
    "_dosya": "Türkşeker — Kurum Dosyası Sayı 07 · tasarım künyesi",
    "_amac": "Evrak görsel dilinin bu dosyadaki uygulaması. DossierTheme bu dosyadan üretilir.",
    "_kural": ("Buradaki hiçbir kontrast sayısı elle yazılmadı. Hepsi _ortak/kontrast.py'nin "
               "ölçü fonksiyonuyla ÖLÇÜLDÜ ve bu dosya _raw/kur_tasarim.py'den üretildi; "
               "dogrula_tasarim.py her sayıyı yeniden ölçüp karşılaştırıyor."),
    "_uretec": "content/dossiers/turkseker/_raw/kur_tasarim.py",

    "tez_cumlesi": {
        "tr": ("Alpullu'dan bugüne yüz yıl: pancarı şekere çeviren kurum."),
        "en": ("A hundred years from Alpullu: the institution that turns beet into sugar."),
        "_not": ("§8.2 — tez cümlesi İDDİA KURMAZ, tanıtır. Dizinin bir kez durdurulma "
                 "sebebi iddianame tonuydu."),
    },

    "kume": {
        "ad": KUME_AD, "sira": KUME_SIRA,
        "kagit_vurgu": KAGIT_VURGU, "kapak_vurgu": KAPAK_VURGU,
        "_devralindi": ("Küme TİGEM dosyasında (Sayı 06) kuruldu ve Türkşeker orada ADIYLA "
                        "anıldı. Yeni küme açılmadı, yeni renk üretilmedi."),
        "gerekce": ("Devletin BİZZAT ÜRETİCİ olması. TÜRKŞEKER kendi fabrikasında pancarı "
                    "şekere çeviriyor; kota bölüştüren düzenleyici değil, üreten KİT."),
    },

    "palet": {
        "ad": "Evrak — kağıt gövde",
        "kaynak_fikir": ("Kurumun manzarası yok; maddi karşılığı kağıttır. Bu dosyada kağıt "
                         "ayrıca konunun kendisi: şeker rejimi 1925'ten beri özel mevzuatla "
                         "yürüyor ve üretim kotayla planlanıyor. Çiftçinin pancarı da bir "
                         "kağıtla başlıyor — Şeker Pancarı Üretim Sözleşmesi."),
        "mod": "KOYU KAPAK → KAĞIT GÖVDE. Dosya sayfası sistem açık/koyu tercihini izlemez.",
        "mod_gerekcesi": "Fiziksel dosyanın kendisi: dışı mukavva kapak, içi kağıt.",
        "sayfa": {
            "zemin": {"hex": KAGIT, "rol": "Sayfa zemini — arşiv kağıdı",
                      "kontrast_app_krem": o(cr(KAGIT, APP_KREM), 3)},
            "yuzey": {"hex": YUZEY, "rol": "Kart, tablo, kayıt bloğu",
                      "kontrast_zemin": o(cr(YUZEY, KAGIT))},
            "murekkep": {"hex": MUREKKEP, "rol": "Gövde metni",
                         "kontrast_zemin": o(cr(MUREKKEP, KAGIT)),
                         "kontrast_yuzey": o(cr(MUREKKEP, YUZEY))},
            "sessiz": {"hex": SESSIZ, "rol": "Meta, kaynak satırı, altyazı",
                       "kontrast_zemin": o(cr(SESSIZ, KAGIT)),
                       "kontrast_yuzey": o(cr(SESSIZ, YUZEY))},
            "vurgu": {"hex": KAGIT_VURGU,
                      "rol": "Üretim — rakamlar, başlık vurguları, ülke serisi",
                      "kontrast_zemin": o(cr(KAGIT_VURGU, KAGIT)),
                      "kontrast_yuzey": o(cr(KAGIT_VURGU, YUZEY))},
            "ikincil": {"hex": SESSIZ,
                        "rol": "Karşılaştırmanın ikinci ölçüsü — TÜRKŞEKER satırı, şirket sayısı",
                        "kontrast_zemin": o(cr(SESSIZ, KAGIT)),
                        "kontrast_yuzey": o(cr(SESSIZ, YUZEY)),
                        "_not": ("Kasıtlı olarak NÖTR, TİGEM'deki kararın aynısı. Bu dosyada "
                                 "ikinci seri bir kez 'TÜRKŞEKER', bir kez 'şirket sayısı' — "
                                 "ikisi de başka bir KURUM TÜRÜ değil, aynı şeyin başka ölçüsü. "
                                 "Başka kümenin rengi ödünç alınsaydı okur orada bir kurum "
                                 "türü arardı.")},
            "cizgi": {"hex": RAY, "rol": "Marj rayı, tablo kuralı",
                      "kontrast_zemin": o(cr(RAY, KAGIT))},
            "cizgiVurgu": {"hex": KURAL, "rol": "Bölüm ayırıcı, motif",
                           "kontrast_zemin": o(cr(KURAL, KAGIT))},
        },
        "kapak": {
            "zemin": {"hex": KZEMIN, "rol": "Kapak zemini — mukavva"},
            "yuzey": {"hex": KYUZEY, "rol": "Kapak üstü blok",
                      "kontrast_zemin": o(cr(KYUZEY, KZEMIN))},
            "murekkep": {"hex": KMUREKKEP, "rol": "Kapak başlığı",
                         "kontrast_zemin": o(cr(KMUREKKEP, KZEMIN))},
            "sessiz": {"hex": KSESSIZ, "rol": "Seri etiketi, belge satırı",
                       "kontrast_zemin": o(cr(KSESSIZ, KZEMIN))},
            "vurgu": {"hex": KAPAK_VURGU, "rol": "Üretim, kapak karşılığı",
                      "kontrast_zemin": o(cr(KAPAK_VURGU, KZEMIN))},
        },
        "serit": {
            "_amac": "Ana sayfadaki dosya şeridi sayfanın içinde yaşıyor; krem zemin.",
            "murekkep": {"hex": MUREKKEP, "kontrast_krem": o(cr(MUREKKEP, APP_KREM))},
            "vurguKoyu": {"hex": KAGIT_VURGU, "rol": "Üretim'in krem zemindeki karşılığı",
                          "kontrast_krem": o(cr(KAGIT_VURGU, APP_KREM))},
            "ikincilKoyu": {"hex": SESSIZ, "kontrast_krem": o(cr(SESSIZ, APP_KREM))},
            "_ayrisma": {
                "uygulamanin_yapisal_yesili": APP_YAPISAL_YESIL,
                "oran": o(cr(KAGIT_VURGU, APP_YAPISAL_YESIL)),
                "_not": ("Aynı risk TİGEM'de ölçülmüştü ve bu dosyada aynen duruyor: kümenin "
                         "rengi yeşil, uygulamanın yapısal yeşili #2F4B2E. Kart kendi "
                         "zemininden parlaklıkla değil, krem zemin üzerindeki konumuyla "
                         "ayrışıyor. Dizinin en dar aralığı."),
            },
        },
    },

    "motif": {
        "ad": "Cetvel çizgisi",
        "tanim": "Defter ve resmî evrak kağıdının marj rayı: solda dikey ray, aralarda ince yatay kural çizgileri.",
        "gerekce": "Kuruma göre DEĞİŞMEZ, dizi kimliğidir (§8.4). Değişen renktir.",
        "uygulama": {
            "opaklik": "%8",
            "renk": f"cizgiVurgu {KURAL} üzerine opaklık",
            "bicim": "Vektör (CustomPainter) — telif yok, ölçeklenir",
            "yerlesim": "Bölüm ayırıcılarında ve kapak altı geçiş bandında. Gövde metninin ARKASINDA kullanılmaz.",
            "aralik_notu": "Izgara aralığı 24 px'in altına inmeyecek (moiré).",
        },
    },

    "kapak": {
        "yon": "Kuruluş belgesinden kurulan tipografik kapak",
        "gerekce": ("Fotoğraf kapak yine reddedildi (§8.8). Bu dosyada ayrıca bir sebep daha "
                    "var: kurumun kuruluş karesi YOK. Commons'ta Alpullu Şeker Fabrikası'nın "
                    "hiçbir fotoğrafı bulunmuyor."),
        "sinir": ("Kapak bir belgeyi ALINTILAR, TAKLİT ETMEZ. Resmî Gazete anteti, mühür, arma "
                  "veya kurum logosu yeniden üretilmez. Kapakta her zaman seri etiketi ve sayı "
                  "numarası bulunur."),
        "tipografi_katmani": {
            "ust_satir": "KURUM DOSYASI · 07 · ÜRETİM",
            "baslik": "TÜRKİYE ŞEKER FABRİKALARI",
            "_baslik_notu": ("Büyük harfler ELLE yazıldı. Türkçede upper() 'i' harfini 'I' "
                             "yapıyor ve TÜRKIYE çıkıyor; dizide aynı hata iki kez yaşandı "
                             "(§8.5, _Kartlar ve yaka başlığı)."),
            "belge_satiri": ("Türkiye Şeker Fabrikaları A.Ş. · 6 Temmuz 1935 — "
                             "ilk Türk şekeri · Alpullu · 26 Kasım 1926"),
            "_iki_tarih_notu": ("Kurumun iki doğum tarihi var ve ikisi de doğru: tüzel kişilik "
                                "1935'te, şeker 1926'da. Dosyanın ekseni 1926 (kullanıcı kararı), "
                                "kuruluş belgesi 1935. Kapak ikisini de taşıyor."),
        },
    },

    "_yasak": [
        "Kurum logosu, arma, mühür, Resmî Gazete anteti — yeniden üretilmez.",
        "Kapakta fotoğraf (§8.8).",
        "Stok 'mutlu çiftçi' fotoğrafı ve dekoratif ikon seti.",
        ("Şekerlikte küp şeker, fincan yanında şeker, kaşıkta dökülen şeker: 'şeker' kelimesinin "
         "en yıpranmış stok karesi ve dosyanın anlattığı şey sofra değil, SANAYİ."),
        ("Şekerleme, pasta, tatlı — her türlü şekerli mamul. Türkçede 'şeker' hem ürünü hem "
         "şekerlemeyi anlatıyor; dosya pancardan kristal şeker üreten bir KİT'i anlatıyor."),
        ("Toprakta filizlenen fide makrosu: 'büyüme' klişesi. Kurumun ürettiği şey fide değil, "
         "kristal şeker."),
        "Grafikte rengi tek ayırt edici işaret yapmak (bkz. renk_korlugu).",
    ],
}

# ── Renk körlüğü · küme ayrışması ────────────────────────────────────
# Ölçüm TİGEM'de yapıldı ve küme aynı olduğu için sonuç da aynı. Karar
# kopyalanmıyor, SEBEBİYLE birlikte taşınıyor: renk tek başına anlam
# taşımaz, bu dosyada da taşımayacak.
d["renk_korlugu"] = {
    "_olcum": "TİGEM · _raw/kontrast.py · Viénot-Mollon benzetimi + CIE76 ΔE",
    "_ayni_kume": ("Küme TİGEM ile aynı olduğu için ayrışma ölçümü de aynı; yeniden "
                   "ölçülmedi, kararı devralındı."),
    "KARAR": ("RENK TEK BAŞINA HİÇBİR YERDE ANLAM TAŞIMAZ. Üretim kümesinin kağıt vurgusu "
              "deuteranopi altında Kamu gücü'ne ΔE 3,6 mesafede; dizinin mevcut tabanı zaten "
              "2,0. Her grafikte rol BİÇİMLE de ayrışıyor (etiket, tarama, konum)."),
}

(KOK / "tasarim.json").write_text(json.dumps(d, ensure_ascii=False, indent=2), encoding="utf-8")

s = d["palet"]["sayfa"]
print(f"  küme: {KUME_AD} (#{KUME_SIRA}) · kağıt {KAGIT_VURGU} · kapak {KAPAK_VURGU}  [devralındı]")
print("\n  kağıt gövde:")
for ad in ("murekkep", "sessiz", "vurgu", "ikincil", "cizgi", "cizgiVurgu"):
    v = s[ad]
    print(f"    {ad:<11} {v['hex']}  zemin {v['kontrast_zemin']:>5}")
k = d["palet"]["kapak"]
print("\n  koyu kapak:")
for ad in ("murekkep", "sessiz", "vurgu"):
    print(f"    {ad:<11} {k[ad]['hex']}  zemin {k[ad]['kontrast_zemin']:>5}")
print(f"\n  şerit ayrışması (uygulamanın yeşili): "
      f"{d['palet']['serit']['_ayrisma']['oran']}")
