#!/usr/bin/env python3
"""Mısır tasarim.json — kontrast sayıları _raw/kontrast.py'den ALINARAK.

Çalıştırma: python3 content/dossiers/misir/_raw/kur_tasarim.py
Sonra MUTLAKA: python3 content/dossiers/misir/dogrula_tasarim.py

NEDEN BETİK: Avustralya'nın tasarım künyesindeki ayrışma sayıları elle
konmuştu ve hiçbir betikte hesaplanmıyordu. Burada künye kontrast.py'nin
ÇIKTISINDAN üretiliyor; betik kusur bulursa künye hiç yazılmıyor.
"""
import json, pathlib, subprocess, sys

KOK = pathlib.Path(__file__).parent.parent

# Ölçüleri betikten AL, elle yazma. Betik kusur bulursa burada da durur.
r = subprocess.run([sys.executable, "_raw/kontrast.py"], cwd=KOK,
                   capture_output=True, text=True)
if r.returncode != 0:
    print(r.stdout[-2000:]); raise SystemExit("kontrast.py kusurlu — künye yazılmadı")
ham = r.stdout[r.stdout.index("{"):r.stdout.rindex("}") + 1]
olcum = json.loads(ham)

src = (KOK / "_raw/kontrast.py").read_text(encoding="utf-8")
ns = {}; exec(src[:src.index("# ── Koyu gövde")], ns)
cr, oran = ns["cr"], ns["oran"]

ZEMIN, YUZEY = "#0F1311", "#19201D"
MUREKKEP, SESSIZ = "#E8E4DA", "#9BA39C"
VURGU, IKINCIL = "#7CC9C2", "#CC7A30"
CIZGI, CIZGIVURGU = "#222B27", "#717D77"
KREM, S_MUREKKEP = "#F6F1E7", "#161917"
S_VURGU, S_IKINCIL = "#0B403C", "#8A3410"
ANASAYFA = {"darkGreen_#2F4B2E": "#2F4B2E", "primaryGreen_#5C8A4A": "#5C8A4A",
            "wheat_#C9A15A": "#C9A15A", "marketDown_#9C4A3C": "#9C4A3C",
            "alertRed_#D32F2F": "#D32F2F"}
y2 = lambda v: round(v, 2)

T = {
  "_dosya": "Mısır — Ülke Dosyası Sayı 06 · tasarım künyesi",
  "_amac": "Görsel kararlar. DossierTheme bu dosyadan üretilir; kodda serbest renk yazılmaz.",
  "_kural": ("Bu dosyadaki hiçbir kontrast sayısı 'yaklaşık' değildir. Hepsi "
             "_raw/kontrast.py'den geliyor ve bu künye o betiğin çıktısından "
             "ÜRETİLDİ, elle yazılmadı. Palet değişirse betik yeniden koşar."),
  "_sureklilik": (
      "Altı dosya, altı geometri: Hollanda dikey şeritler (polder), Rusya yatay "
      "bantlar (toprak profili), İspanya nokta ızgarası (dikilmiş zeytinlik), "
      "Avustralya ortogonal ızgara (kanal ağı), Irak düzensiz poligon ağı (tuz "
      "kabuğu), Mısır EŞİT OLMAYAN BÖLÜNME. İlk dördü insan yapımı DÜZEN, "
      "beşincisi düzen çekildiğinde kalan biçimdi. Altıncısı ikisi de değil: "
      "bir işlemin kendi kendine tekrarı. Aynı tarla bölünüyor, bölünen parça "
      "yine bölünüyor; hücreler küçülüyor ve hiçbiri ötekine eşit değil. "
      "Dosyanın imzası bu — birimi ülke değil bir tarla, ve o tarla feddan."),
  "tez_cumlesi": {
    "tr": ("Mısır toprağının %4,25'ini ekiyor ve ektiği yerin tamamı sulanıyor; "
           "suyunun %96,9'u ülke dışından geliyor. Bir tarım çalışanına 0,72 "
           "hektar — 1,71 feddan — düşüyor, Türkiye'de 7,89 hektar. Dünyanın en "
           "büyük buğday alıcısı aynı ülke, portakalda bizi 2,61 kat geçmiş "
           "durumda."),
    "en": ("Egypt sows 4.25% of its land and every sown hectare is irrigated; "
           "96.9% of its water originates outside the country. One agricultural "
           "worker has 0.72 hectares — 1.71 feddans — against 7.89 hectares in "
           "Türkiye. The world's largest wheat buyer is the same country, and "
           "in oranges it stands 2.61 times ahead of us."),
    "gerekce": (
        "Sıra Irak dosyasından devralındı ve kullanıcı şartının kendisi: dosya "
        "yalnız Türkiye ilişkisi üzerinden kurulmuyor. Bu yüzden ÖNCE Mısır'ın "
        "kendi tarımı — arazi, su, bir çalışanın tarlası — SONRA eksen geliyor. "
        "Türkiye cümlede iki kez var ama cümleyi yönetmiyor; gövdenin konusu "
        "Mısır'ın kendi toprağı."),
    "_dayanak": (
        "Beş sayının beşi de ölçüldü ve data.json'da duruyor: arazi payı "
        "FAOSTAT LandUse 2024'ten hesaplandı (4.229 / 99.545 bin ha); sulama "
        "oranı aynı kaynakta BİREBİR eşitlik olarak duruyor ve sınırı yazılı "
        "(yalnız 2021-2024); su bağımlılığı FAO AQUASTAT'ın kendi ifadesi "
        "(%96,9); çalışan başına arazi arazi ile İSTİHDAM'dan hesaplandı "
        "(nüfustan değil); portakal oranı FAOSTAT QCL'nin ortak son yılından."),
    "_olmayan_iddia": (
        "'Mısır'ın tarımı dışa bağımlı' gibi bir yargı cümleye KONULMADI. "
        "Cümlenin taşıdığı şey ölçülmüş olan: suyun %96,9'u dışarıdan geliyor "
        "ve buğdayda dünyanın en büyük alıcısı. 'Kendine yetmiyor' denmedi, "
        "çünkü pirinçte yetiyor ve dosyanın bir bölümü tam bunu gösteriyor."),
    "_sayi_rakamla": (
        "Dizide tez cümlesinde sayılar YAZIYLA yazılıyordu; kullanıcının 3 "
        "Kasım 2026 kararıyla RAKAMLA yazılıyor. Kesir deyimleri Türkçede "
        "yazıyla yazıldığı için istisna; bu cümlede kesir yok."),
  },
  "palet": {
    "ad": "Mil ve Portakal",
    "kaynak_fikir": (
        "Palet manzaradan değil, dosyanın ÖLÇTÜĞÜ iki şeyden türedi. Mil "
        "(alüvyon ve onu getiren su) ülkenin kendi ürünü DEĞİL: suyun %96,9'u "
        "yukarıdan geliyor ve dosyanın ekseni bu. Portakal ise Mısır'ın kendi "
        "ürünü ve dizide ilk kez bir karşılaştırmada Türkiye'nin GERİDE olduğu "
        "kalem: 1990'da 2,14 kat, 2024'te 2,61 kat ve makas açılıyor. Yani iki "
        "renk 'ülke ve Türkiye' demiyor; 'dışarıdan gelen' ve 'burada yetişen' "
        "diyor. Üçüncü madde — bölünen tarla — renk değil MOTİF oldu."),
    "mod": "KOYU — dosya sayfası her zaman koyu. Uygulamanın açık/koyu tercihini izlemez.",
    "mod_gerekcesi": (
        "Dergi dosyası mantığı: içeri girdiğinizde başka bir yere geldiğinizi "
        "anlamalısınız (İspanya'dan devralınan karar). Ana sayfadaki şerit "
        "bunun istisnasıdır — sayfanın içinde yaşadığı için açık/koyu izler."),
    "koyu": {
      "zemin": {"hex": ZEMIN, "rol": "Sayfa arka planı — ıslak mil, gece"},
      "yuzey": {"hex": YUZEY, "rol": "Kart, tablo, alıntı bloğu",
                "kontrast_zemin": y2(cr(YUZEY, ZEMIN))},
      "murekkep": {"hex": MUREKKEP, "rol": "Gövde metni",
                   "kontrast_zemin": y2(cr(MUREKKEP, ZEMIN)),
                   "kontrast_yuzey": y2(cr(MUREKKEP, YUZEY))},
      "sessiz": {"hex": SESSIZ, "rol": "Meta, kaynak satırı, altyazı ve YALNIZ "
                 "siralama'da bağlam satırı",
                 "kontrast_zemin": y2(cr(SESSIZ, ZEMIN)),
                 "kontrast_yuzey": y2(cr(SESSIZ, YUZEY)),
                 "_rol_siniri": (
                     "Yığılmış türlerde (ikili_cubuk, yigin) seri rengi OLAMAZ. "
                     "Gerekçe ölçülü: `ChartRole.taramali` yalnız ikincil için "
                     "true, yani vurgu ile sessiz aynı çubukta yan yana "
                     "durduğunda ayrımı taşıyan tek şey renk olur — ve bu "
                     "paletin vurgu↔sessiz oranı deuteranopi altında 1,31'e "
                     "düşüyor. dogrula_grafik.py kural 20 bunu durduruyor.")},
      "vurgu": {"hex": VURGU, "rol": "Mil — rakamlar, başlık vurguları ve her "
                "grafiğin ÖNDEKİ serisi",
                "kontrast_zemin": y2(cr(VURGU, ZEMIN)),
                "kontrast_yuzey": y2(cr(VURGU, YUZEY)),
                "kontrast_murekkep": y2(oran(VURGU, MUREKKEP)),
                "_murekkep_notu": (
                    "Vurgu gövde metninin İÇİNDE rakam rengi olarak da "
                    "kullanılıyor, o yüzden mürekkepten de 1,4 ayrışmak "
                    "zorunda. Bu sınama bu dosyada kondu: onsuz arama "
                    "#F5C689'u öneriyordu, mürekkepten oranı 1,25 — bütün "
                    "öteki eşikleri geçiyor ve cümlenin içinde vurgu değil.")},
      "ikincil": {"hex": IKINCIL, "rol": "Portakal — karşılaştırmanın ikinci serisi",
                  "kontrast_zemin": y2(cr(IKINCIL, ZEMIN)),
                  "kontrast_yuzey": y2(cr(IKINCIL, YUZEY)),
                  "_rol_notu": (
                      "Irak dosyasında olduğu gibi ikincil renk 'Türkiye "
                      "serisi' DEMİYOR. Bu dosyanın ikincil rollü serileri: "
                      "ithalat, Mısır'ın sattığı, kentli nüfus, hasat alanı, "
                      "geri kalan yüzey, ekonominin geri kalanı, yenilenebilir "
                      "kaynağın tamamı — ve iki grafikte Türkiye. Yani çoğunda "
                      "Türkiye yok; künyeye 'Türkiye serisi' yazmak sonraki "
                      "turda grafiklerin yanlış okunmasına yol açardı."),
                  "_doygunluk_notu": (
                      "#C9772F ile #D07F33 arasında tarandı. İlki metin "
                      "eşiğinde (4,87) rahat değil, ikincisinin deuteranopi "
                      "altındaki seri ayrımı 1,41 — eşiğe bir yüzde birlik "
                      "payla. #CC7A30 ikisinin ortası: metin 5,05, deuteranopi "
                      "1,51. Eşiği kıl payı geçen renk bir sonraki küçük "
                      "değişiklikte sessizce altına düşer.")},
      "cizgi": {"hex": CIZGI, "rol": "SADECE dekoratif ayırıcı",
                "kontrast_zemin": y2(cr(CIZGI, ZEMIN)),
                "kontrast_yuzey": y2(cr(CIZGI, YUZEY)),
                "_uyari": ("3:1'in altında. Anlam taşıyan hiçbir yerde "
                           "kullanılamaz — grafik ekseni, sınır, odak halkası "
                           "için cizgiVurgu kullanılır.")},
      "cizgiVurgu": {"hex": CIZGIVURGU,
                     "rol": "Grafik ekseni, ızgara çizgisi, odak halkası",
                     "kontrast_zemin": y2(cr(CIZGIVURGU, ZEMIN)),
                     "kontrast_yuzey": y2(cr(CIZGIVURGU, YUZEY))},
    },
    "acik_mod_seridi": {
      "_amac": ("Ana sayfadaki dosya şeridi sayfanın içinde yaşıyor; krem zemin "
                "üstünde koyu gövdenin renkleri okunmuyor."),
      "murekkep": {"hex": S_MUREKKEP, "kontrast_krem": y2(cr(S_MUREKKEP, KREM))},
      "vurguKoyu": {
          "hex": S_VURGU,
          "rol": "Milin krem zemindeki karşılığı — kart kenarı ve açık moddaki "
                 "tüm vurgu metni",
          "kontrast_krem": y2(cr(S_VURGU, KREM)),
          "kontrast_serit_murekkebi": y2(oran(S_VURGU, S_MUREKKEP)),
          "_anasayfadan_ayrisma": {k: y2(oran(S_VURGU, v)) for k, v in ANASAYFA.items()},
      },
      "ikincilKoyu": {
          "hex": S_IKINCIL,
          "rol": "Portakalın krem zemindeki karşılığı — ikinci vurgu",
          "kontrast_krem": y2(cr(S_IKINCIL, KREM)),
          "kontrast_serit_murekkebi": y2(oran(S_IKINCIL, S_MUREKKEP)),
          "_anasayfadan_ayrisma": {k: y2(oran(S_IKINCIL, v)) for k, v in ANASAYFA.items()},
      },
      "_rol_degismedi": (
          "IRAK'TAN AYRILAN NOKTA. Orada hangi rengin önde durduğu ZEMİNE "
          "bağlıydı: koyu sayfada hurma amberi, krem şeritte nehir mavisi. "
          "Burada DEĞİŞMİYOR — mil her iki zeminde de önde. Bu da bir ölçüm: "
          "milin koyu sürümü #0B403C ana sayfanın beş renginin en yakınından "
          "1,44 uzakta, portakalın koyu sürümü #8A3410 ise 1,35. İkisi de "
          "eşiği (1,25) geçiyor, yani rol değiştirmeye gerek yok. İlk deneme "
          "#14544E ana sayfanın yapısal yeşiliyle 1,21 veriyordu ve "
          "koyulaştırıldı."),
    },
    "renk_korlugu_notu": (
        "Bağıl parlaklık oranı VEKİL ölçüdür ve dizide bir kez yanıldı "
        "(Hollanda: oran 1,05, deuteranopi altında ayırt edilemiyordu). O "
        "günden beri kontrast.py üç körlük tipini DOĞRUDAN benzetiyor "
        "(Viénot-Mollon, LMS izdüşümü) ve oranı benzetim sonrasında ölçüyor. "
        "Bu dosyada ikinci bir vekil — CIELAB ΔE76 — denendi ve BIRAKILDI: "
        "kalibrasyon başarısız. Hollanda'da çöken çift deuteranopi benzetimi "
        "sonrası ΔE 52,2 veriyor, yayında ÇALIŞAN Irak paleti 87,9; eşiği "
        "52'nin üstüne koymak çalışan paletleri de keserdi. Vekili vekille "
        "denetlemek yerine kayıtlı ölçü korundu. Ölçülen değerler düzyazıda "
        "değil `_olculen_ayrisma` alanında duruyor."),
    "_uc_yollu_ladder_denendi": (
        "Bu dosyada 'üç rolün üçü de birbirinden 1,4 ayrışsın' kuralı denendi, "
        "çünkü sessiz dört grafikte çubuk rengi. RENK UZAYI TARANDI: 4,5 "
        "eşiğini geçen 2.374 renk, vurgu adayı olarak mürekkepten de ayrışan "
        "1.668 renk. Geçen üçlüler VAR ama hepsinde en çok BİR rol renkli, "
        "ötekiler gri (#928787 / #AAA1A1 / #CFC9C9); doygun bir vurguyla geçen "
        "üçlülerde de ikincil griye düşüyor (#C76B6B / #B6AFAF / #D9CCBF). "
        "Yani İKİ RENKLİ bir palet bu ladder'ı sağlayamıyor — arayış değil, "
        "aritmetik. KARAR: ladder zorunlu kılınmadı; yerine sessiz yığılmış "
        "türlerde seri olarak yasaklandı (dogrula_grafik.py kural 20) ve "
        "sessiz çiftleri burada ÖLÇÜLÜ ama durdurmuyor."),
    "_olculen_ayrisma": {
        "_uretim": ("_raw/kontrast.py — elle yazılmaz; bu künye o betiğin "
                    "çıktısından üretildi, dogrula_tasarim.py bloğu künyenin "
                    "kendi hex'lerinden yeniden hesaplayıp karşılaştırır."),
        "_esik": 1.4,
        "_durduran": ["govde", "serit", "vurgu_murekkep"],
        "_olculen_ama_durdurmayan": ["vurgu_sessiz", "ikincil_sessiz"],
        "govde": olcum["_olculen_ayrisma"]["govde"],
        "serit": olcum["_olculen_ayrisma"]["serit"],
        "vurgu_sessiz": olcum["_olculen_ayrisma"]["vurgu_sessiz"],
        "ikincil_sessiz": olcum["_olculen_ayrisma"]["ikincil_sessiz"],
        "vurgu_murekkep": {"normal": y2(oran(VURGU, MUREKKEP))},
    },
    "denetim_betigi": "_raw/kontrast.py — `python3 content/dossiers/misir/_raw/kontrast.py`",
  },
  "motif": {
    "ad": "Bölünen tarla",
    "tanim": ("Bir dikdörtgenin kendi içinde eşit olmayan parçalara bölünmesi, "
              "sonra parçaların yine bölünmesi: hücreler küçülüyor, hiçbiri "
              "ötekine eşit değil, kenarlar dik ama ritim düzensiz."),
    "gerekce": (
        "Dizideki altıncı geometri ve ilk kez bir DESEN değil bir İŞLEM: "
        "önceki beşi (şerit, bant, nokta, ızgara, poligon) tek seferde "
        "kurulmuş biçimlerdi; bu, aynı hareketin tekrarı. Dosyanın ölçtüğü şey "
        "bu: tarım arazisi 1961'den bu yana %64,7 büyüdü ama bir tarım "
        "çalışanına düşen alan 0,72 hektar — Türkiye'dekinin on birde biri. "
        "Toprak artıyor, pay küçülüyor. Dosyanın imzası da aynı yerden: "
        "feddan (0,42 ha) bir ülkenin değil bir tarlanın birimi."),
    "uygulama": {
      "opaklik": "%4",
      "renk": "cizgiVurgu #717D77 üzerine opaklık",
      "bicim": "Vektör (CustomPainter) — raster değil. Ölçeklenebilir, dosya boyutu sıfır, telif sorunu yok.",
      "yerlesim": "Bölüm ayırıcılarında ve kapak altı geçiş bandında. Gövde metninin ARKASINDA kullanılmaz.",
      "moire_notu": "En küçük hücre kenarı 28 px'in altına inmeyecek; özyineleme derinliği buna göre durur.",
      "_opaklik_notu": ("Tuz poligonundan bir puan düşük (%5 → %4): özyinelemeli "
                        "bölünme kenar sayısını katlıyor ve aynı opaklıkta gözü "
                        "poligondan daha çok meşgul ediyor."),
    },
    "_UYGULANMAMIŞ": (
        "ÖNEMLİ — BU GEOMETRİ ŞU AN ÇİZİLMİYOR. Depodaki tek motif çizici "
        "`polder_motif.dart` ve `DossierTheme` motif bloğundan YALNIZCA "
        "opaklığı okuyor (`motif.uygulama.opaklik`, 0,02-0,10 arasına "
        "kırpılıyor); `motifAralik` bile JSON'dan değil yedekten geliyor. "
        "Avustralya ve Irak künyeleri bunu aynı açıklıkla yazdı ve doğru "
        "yaptı: okunmayan bir alana değer yazmak, sonraki turda 'bölünen tarla "
        "bölüm ayırıcılarında görünüyor' diye yanlış bir cümle yazdırır. "
        "Bölünen tarla bir ŞARTNAMEDİR; çizici yazılana kadar sayfada polder "
        "motifi görünür ve bu dosyada aksini iddia eden cümle yazılmayacak."),
  },
  "kapak": {
    "yon": ("Nil vadisinin çöl sınırı — yüksekten, ekili yeşil ile kumun "
            "kesiştiği çizgi kadrajın içinden geçecek kadar yakın"),
    "gerekce": (
        "Kapak dosyanın ilk sayısını gösteriyor: %4,25. Dünyada ekili alan ile "
        "ekilmeyen arasındaki en keskin sınır burada ve sınırın kendisi bir "
        "fotoğrafta görünüyor — başka hiçbir ülke dosyasında böyle bir çizgi "
        "yoktu. Hollanda ve Rusya yörüngeden, İspanya yerden, Avustralya "
        "yüksekten, Irak alçak eğik açıdan baktı; burası yüksekten ama tek bir "
        "çizgiye odaklı."),
    "gorsel_kaynagi": {
      "tercih_1": "NASA Earth Observatory / ISS astronot fotoğrafı — kamu malı; Nil vadisi ve deltası için arşivi geniş.",
      "tercih_2": "Wikimedia Commons, açık lisanslı havadan çekim.",
      "tercih_3": "FAO / BM fotoğraf kütüphaneleri — LİSANS TEK TEK OKUNACAK, 'BM yayını' açık lisans demek değildir.",
      "_karar": "Görsel BULUNANA KADAR kapak tipografik iskeletle çalışır — sayfa görselsiz de tam çalışmak zorunda (§3.5).",
      "_yasak": "Telifi belirsiz hiçbir görsel kullanılmayacak. Google görsel araması kaynak değildir.",
      "_altyazi_kurali": ("Altyazı KÜNYEDİR: konu + yer + tarih, kaynağın kendi "
                          "künyesinden yazılır. Karede ne görüldüğü anlatılmaz. "
                          "Kullanıcı bu düzeltmeyi iki kez verdi (8 ve 12 Kasım "
                          "2026) ve TİGEM dosyasında bu yoldan dört maddi hata "
                          "girmişti."),
      "_erisim_uyarisi": ("Kaynak turlarında ölçüldü: Dünya Bankası API'si "
                          "sekiz göstergenin yedisinde hata verdi, biri açıldı; "
                          "FAO AQUASTAT'ın HTML sayfası JavaScript kabuğu, "
                          "rakamlar yalnız PDF'te. Yumuşak 404'e karşı durum "
                          "koduna değil İÇERİK TÜRÜNE ve gövde uzunluğuna "
                          "bakılacak (§2.12.1)."),
    },
    "tipografi_katmani": {
      "ust_satir": "ÜLKE DOSYASI · 06",
      "baslik": "MISIR",
      "alt_satir": "tez_cumlesi.tr",
      "veri_rozeti": "Tarım çalışanı başına 1,71 feddan",
    },
    "_rozet_notu": (
        "Rozet %96,9'u ya da dünya birinciliğini DEĞİL, feddanı söylüyor. "
        "Dosyanın imzası o birim ve rozetin işi dosyanın ölçeğini bir bakışta "
        "vermek: 1,71 feddan bir tarla, 'suyun %96,9'u' bir ülke. Dosya "
        "tarlanın hikâyesi."),
    "_baslik_notu": (
        "Başlık 'MISIR' — 5 harf, dizinin en kısalarından (IRAK 4, İSPANYA 7, "
        "AVUSTRALYA 10, KOOPERATİFLERİ 14). `kapakAdiOlcegi` puntoyu EN GENİŞ "
        "kelimeye bakarak küçültüyor (TİGEM turunda düzeltildi: önce harf "
        "sayısına bakıyordu ve kelimeyi ortadan bölüyordu). Taşma riski yok; "
        "ters yönde kontrol edilecek, punto ÜST sınıra dayanabilir. "
        "BÜYÜTMEDE TUZAK: 'Mısır' kelimesini büyütürken Türkçe kuralı şart — "
        "'mısır'.upper() noktasız I vermiyor, projenin `buyult` yardımcısı "
        "kullanılacak."),
    "okunurluk": "Görsel üzerine zemin renginden %0 → %85 dikey gradyan; metin yalnızca %60+ bölgede durur.",
  },
  "_zorunluluklar": [
    "Grafiklerde iki seri renkle BİRLİKTE biçimle de ayrılacak; bu dosyada parlaklık farkı da var ve üç körlük tipinde benzetilerek ölçüldü (gövdede en kötü 1,51, şeritte en kötü 1,54).",
    "Yığılmış türlerde (ikili_cubuk, yigin) seri rolü vurgu + ikincil olacak; sessiz seri olarak kullanılmayacak (ölçüm: vurgu↔sessiz deuteranopi altında 1,31).",
    "Bölünen tarla motifi CustomPainter ile çizilecek — ama çizici YAZILANA KADAR sayfada polder motifi görünür; bu dosyada aksini iddia eden cümle yazılmayacak.",
    "Kapak görseli bulunamazsa sayfa yine de tam çalışacak.",
    "Koyu sayfa sistem açık/koyu tercihini izlemeyecek; ana sayfa şeridi izleyecek.",
    "Tüm renkler bu dosyadan türetilen DossierTheme üzerinden gelecek, kodda serbest hex yazılmayacak.",
    "Palet değişirse _raw/kontrast.py yeniden çalıştırılacak ve bu künye onun çıktısından YENİDEN ÜRETİLECEK.",
    "Ticaret rakamlarını gösteren her görsel öğe rakamın HANGİ TARAFIN beyanından olduğunu söyleyecek — iki taraf da kendi gidenini fazla sayıyor (%58,8 ve %53,1).",
    "Sulama oranının (%100) yanında eşitliğin yalnız 2021-2024 için geçerli olduğu yazılacak.",
  ],
  "_yasak": [
    "Mısır bayrağı, arması ya da herhangi bir devlet amblemi",
    "Piramit, Sfenks, tapınak, hiyeroglif, mumya, firavun ikonografisi — dosya tarımı anlatıyor ve bu imgeler ülkeyi müzeye çeviriyor",
    "Nil'de feluka silueti, gün batımı, deve, palmiye — ülke kartpostalı",
    "Dinî imge, cami silueti, hat sanatı süslemesi",
    "Süveyş Kanalı, konteyner gemisi, liman — dosya ticareti ölçüyor ama konusu tarla",
    "Tahrir Meydanı, kalabalık, protesto, asker — dosyada siyasi olay anlatılmıyor",
    "Yoksulluk tasviri: yalınayak çocuk, yıkık ev, dilenen el. Dosya kırsalda yaşayan 63,7 milyon kişiyi SAYIYLA anlatıyor, görsel dil sefalet turizmine kaymayacak",
    "Stok 'çatlamış kurak toprak' fotoğrafı — Mısır'ın tarım arazisinin tamamı sulanıyor; kuraklık bu dosyanın konusu değil",
    "Resmî kurum logosu ya da Resmî Gazete yazı tıpkıbasımı",
  ],
}

yol = KOK / "tasarim.json"
yol.write_text(json.dumps(T, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
print(f"✓ {yol}")
print(f"  palet {T['palet']['ad']} · gövde {VURGU} ↔ {IKINCIL} · şerit {S_VURGU} ↔ {S_IKINCIL}")
