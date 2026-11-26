#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""video_metni.md'yi üretir.

NEDEN BETİKLE. Künyeler elle yazıldığında kaynakla ayrışıyor. Burada çekim
listesinin künye sütunu galeri.json / altyazilar.json / kunye.json'dan
OKUNUYOR; metinde yalnız kare kimliği ve hareket yazılı. Kimlik tutmazsa
betik düşüyor, yani listede var olmayan bir kareye plan yazılamıyor.

Seslendirme metni burada elle duruyor — o bir yazı işi. Ama her cümlenin
dayanağı DAYANAK çizelgesinde kaynağına bağlı ve bu betik dayanağı olmayan
cümle bırakılmadığını sınamıyor; onu dogrula_video.py yapıyor.

    python3 _raw/kur_video_metni.py
"""
import json
import pathlib
import sys

KOK = pathlib.Path(__file__).resolve().parent.parent
RAW = KOK / "_raw"

G = {k["_kimlik"]: k for k in
     json.loads((RAW / "galeri.json").read_text(encoding="utf-8"))["kareler"]}
A = json.loads((RAW / "altyazilar.json").read_text(encoding="utf-8"))
KUN = json.loads((RAW / "gorseller" / "kunye.json").read_text(encoding="utf-8"))["gorseller"]

# ADAYLAR DA GEREKİYOR. kunye.json yalnız Commons API'sinden geçen 20 bölüm
# görselini tutuyor; hisse senedi gibi başka yolla inenler yalnız
# gorsel_adaylari.json'da duruyor. Künyesiz kare bırakmamak için ikisi de
# taranıyor.
ADAY = {}


def _aday_gez(o):
    if isinstance(o, dict):
        if o.get("kimlik"):
            ADAY[o["kimlik"]] = o
        for v in o.values():
            _aday_gez(v)
    elif isinstance(o, list):
        for v in o:
            _aday_gez(v)


_aday_gez(json.loads((RAW / "gorsel_adaylari.json").read_text(encoding="utf-8")))

# ── KARAR DEFTERİ ────────────────────────────────────────────────────────
# 26 Kasım 2026, dört turluk çoktan seçmeli. Kullanıcının işaretlediği.
KARARLAR = [
    ("Eksen", "Kurumun yolculuğu — kronolojik omurga"),
    ("Ton", "Mesafeli belgesel"),
    ("Kayıplar", "Anılsın, yorumsuz"),
    ("Uzunluk", "2:25 + Azize için 14 sn"),
    ("Azize'nin mektubu", "İki plan (ön yüz + arka yüz)"),
    ("Deprem gecesi", "Alıntı olarak, olduğu gibi"),
    ("Rölyef", "Kapanışta"),
    ("Kişi adları", "Hepsi geçsin"),
    ("Açılış", "Görüntüyle, tarih sonra"),
    ("Kapanış", "Tarlayla bitsin"),
    ("Yüzüncü yıl", "Yalnız uçlarda"),
    ("Rakamlar", "Altı civarı; kuruluş rakamları kalsın"),
    ("Kurum adı", "İki kez; uzun ad bir kez"),
    ("Kapanış kartı", "Dosya adı + adres"),
    ("Rakam gösterimi", "Sade yazı kartları (CapCut)"),
    ("Dil", "Yalnız Türkçe"),
]

# ── ÇEKİM LİSTESİ ────────────────────────────────────────────────────────
# (bölüm, kimlik, saniye, hareket)
PLAN = [
    ("I · Alpullu",      "turkseker_alpullu_1928",        9,  "albüm sayfasına çok yavaş içeri; ilk 3 sn sessiz"),
    ("I · Alpullu",      "galeri_alpullu_gar",            6,  "hafif sola kaydırma"),

    ("II · Uşaklı çiftçi", "turkseker_usak_kurucular",    8,  "yüzlere çok yavaş içeri"),
    ("II · Uşaklı çiftçi", "turkseker_usak_hisse",        7,  "senedin üstünden aşağı yavaş kaydırma"),
    ("II · Uşaklı çiftçi", "turkseker_usak_disaridan",    6,  "sabit, hafif içeri"),

    ("III · Fotokart",   "galeri_salt_hasat",             7,  "hasada çok yavaş içeri"),
    ("III · Fotokart",   "galeri_salt_hasat_mektup",      7,  "el yazısının üstünden aşağı yavaş kaydırma"),

    ("IV · Tek çatı",    "galeri_salt_turhal",            7,  "hafif sağa kaydırma"),
    ("IV · Tek çatı",    "galeri_salt_silo",              7,  "aşağıdan yukarı yavaş kaydırma"),

    ("V · Tarla",        "galeri_tarla_pelet_tohum",      6,  "makro, çok yavaş içeri"),
    ("V · Tarla",        "galeri_ciftci_sozlesme_imza",   7,  "masaya hafif içeri"),
    ("V · Tarla",        "galeri_ciftci_pancarla",        8,  "üreticiye çok yavaş içeri  ★"),
    ("V · Tarla",        "galeri_tarla_hasat_makinesi",   7,  "makineye yavaş içeri"),

    ("VI · Fabrika",     "galeri_kurum_kazan_atesleme",   7,  "aleve yavaş içeri"),
    ("VI · Fabrika",     "turkseker_s14_melas",           6,  "makro, hafif içeri"),
    ("VI · Fabrika",     "galeri_urun_cuvallama",         6,  "çuvallara hafif içeri"),

    ("VII · Deprem",     "galeri_fab_malatya",            7,  "panoramik, sağa çok yavaş kaydırma"),
    ("VII · Deprem",     "galeri_kurum_malatya_bosaltma", 8,  "sabit, hafif içeri; alıntı bu planda okunur"),

    ("VIII · Bugün",     "turkseker_gm_binasi",           7,  "panoramik, sağa yavaş kaydırma"),
    ("VIII · Bugün",     "galeri_fab_usak",               6,  "sabit, hafif içeri"),

    ("IX · Rölyef",      "turkseker_s25_rolyef_teslim",  10,  "tabloya çok yavaş içeri"),

    ("X · Kapanış",      "turkseker_s14_haymana",        12,  "tarlaya çok yavaş içeri, sonra kararma"),
]
KART_SN = 3

# ── SESLENDİRME ──────────────────────────────────────────────────────────
METIN = [
    ("I · Alpullu", """
[İlk üç saniye sessiz.]

Trakya'da, Babaeski yakınlarındaki Alpullu. 26 Kasım 1926'da ilk Türk şekeri
burada üretildi. Bu kasımda o günün üzerinden yüz yıl geçiyor.
"""),
    ("II · Uşaklı çiftçi", """
Türkiye'nin şeker sanayiini bir bakanlık kararı başlatmadı. Uşaklı bir çiftçi
başlattı: Molla Ömeroğlu Nuri. Soyadı kanunundan sonra aldığı soyadı Şeker'di.

19 Nisan 1923'te, Cumhuriyet ilan edilmeden altı ay önce, hemşehrilerinin
biriktirdiği altı yüz bin lirayla bir şirket kurdular. Fabrikanın temeli iki
yıl sonra atıldı.
"""),
    ("III · Fotokart", """
İlk yılların fotokartlarından biri. Ön yüzünde "Fabrika için pancar
toplanırken" yazıyor.

Arka yüzünde bir mektup var: Azize, kardeşi Betül'e yazmış. Fotokart Salt
Araştırma'nın arşivinde.
"""),
    ("IV · Tek çatı", """
6 Temmuz 1935'te Alpullu, Uşak, Eskişehir ve Turhal tek şirkete devredildi:
Türkiye Şeker Fabrikaları.

Şeker 1950'ye kadar bu dört bacadan çıktı. 1990'lara gelindiğinde fabrika
sayısı otuzdu.
"""),
    ("V · Tarla", """
Şeker tarlada başlıyor. Kurum tohumunu kendi üretiyor; çiftçi pancarını
ekimden önce imzaladığı bir sözleşmeyle satıyor ve bedelinin bir bölümünü
teslimden önce alıyor.

Hektardan alınan pancar 1961'de yirmi iki tondu, bugün yetmiş bir ton.

Pancar üreticisi sayısı ise 2017'den bu yana üçte bir azaldı. Üretim aynı
kaldı; aynı hasadı daha az çiftçi kaldırıyor.
"""),
    ("VI · Fabrika", """
Fabrikaya gelen pancar suyla taşınıyor, kıyılıyor, şekeri alınıyor. Geriye
kalan atılmıyor: posa yemliğe, melas maya ve alkole gidiyor.
"""),
    ("VII · Deprem", """
Fabrikaların bir bölümü kendi elektriğini üretiyor. Bunun ne anlama geldiği
6 Şubat 2023 depremlerinde görüldü.

Genel müdür o geceyi şöyle anlatıyor: "Deprem oldu, Malatya kapkaranlık.
Şeker fabrikası ışıl ışıl. Aynı gece binlerce insanı içeri alıp bir
ekosistemi besledi."
"""),
    ("VIII · Bugün", """
Bugün TÜRKŞEKER on dört fabrikayla çalışıyor. Yirmi yılı aşkın süre
özelleştirme programında kaldı; 2018'de on fabrikası satıldı — ilk Türk
şekerinin üretildiği Alpullu da onların arasında.

Türkiye'de kamış şekeri üretilmiyor; tüketilen kristal şekerin tamamı
pancardan geliyor.
"""),
    ("IX · Rölyef", """
1934'te Turhal Şeker Fabrikası'nın açılışı için ahşap bir rölyef yapıldı.
Yıllar sonra demirbaş kaydından çıktı.

Eseri Amasya Tren İstasyonu şefi Mehmet Canyurt korudu; sonra iş insanı Taner
Canyurt'un koleksiyonunda kaldı. 31 Mart 2026'da kuruma iade edildi.
"""),
    ("X · Kapanış", """
Yüz yıl sonra sayaç işliyor. Uşak'ta yüz birinci kampanya 22 Eylül'de
başladı; Alpullu'da üretimi artık başka bir şirket sürdürüyor.

Pancar hâlâ tarlada başlıyor.

[Kapanış kartı, 3 sn]
TÜRKŞEKER · Kurum Dosyası Sayı 07
tarimportali.net
"""),
]

# ── EKRAN YAZISI (CapCut'ta binecek rakamlar) ───────────────────────────
EKRAN = [
    ("I",    "26 KASIM 1926 · ALPULLU"),
    ("II",   "19 Nisan 1923 · 600.000 lira"),
    ("IV",   "6 Temmuz 1935 · dört fabrika, tek şirket"),
    ("IV",   "1990 · 30 fabrika"),
    ("V",    "1961: 22 ton/ha   →   2024: 71 ton/ha"),
    ("V",    "Pancar üreticisi · 2017: 110.131   →   2025: 76.767"),
    ("VI",   "posa → yem · melas → maya, alkol"),
    ("VIII", "2026 · 14 fabrika · pancar şekerinin %36,08'i"),
    ("IX",   "1934 → 2026 · 92 yıl"),
    ("X",    "101. kampanya"),
]

# ── DAYANAKLAR ───────────────────────────────────────────────────────────
DAYANAK = [
    ("Babaeski yakınlarındaki Alpullu", "metin_tr.md §1 ilk paragraf"),
    ("26 Kasım 1926 · ilk Türk şekeri", "`data.json/kimlik.ilk_seker_tarihi`, `.ilk_seker_yeri`"),
    ("Molla Ömeroğlu Nuri · soyadı Şeker", "§2 ilk paragraf"),
    ("19 Nisan 1923 · 600.000 lira · Cumhuriyet'ten altı ay önce", "§2"),
    ("hemşehrilerinin biriktirdiği sermaye", "§2 üçüncü paragraf"),
    ("temel 6 Kasım 1925 (iki yıl sonra)", "§2"),
    ("fotokartın ön yüzündeki yazı", "galeri karesi `galeri_salt_hasat` altyazısı"),
    ("Azize'den kardeşi Betül'e mektup", "karenin altyazısı · imza: \"ablan Azize\""),
    ("Salt Araştırma · AFDIVH215", "aynı karenin künyesi"),
    ("6 Temmuz 1935 · Alpullu, Uşak, Eskişehir, Turhal", "§3 ilk paragraf · `data.json/kimlik.sirket_kurulus`"),
    ("1950'ye kadar dört fabrika", "§3 ikinci paragraf"),
    ("1990'larda 30 fabrika", "`data.json/kimlik.fabrika_1990_oncesi`"),
    ("tohumu kendi üretiyor · sözleşme ekimden önce · teslimden önce avans",
     "§20 \"Değişmeyen üç şey\" paragrafı"),
    ("1961'de 22 ton → 2024'te 71 ton", "`data.json/pancar.verim_ilk`, `.verim_son`"),
    ("üretici 2017'den beri üçte bir azaldı, üretim aynı",
     "`data.json/ciftci` 110.131 → 76.767 · §20"),
    ("posa yemliğe · melas maya ve alkole", "§14 \"Şekerden sonra kalanlar\""),
    ("fabrikaların bir bölümü kendi elektriğini üretiyor", "§15 kojenerasyon paragrafı"),
    ("deprem gecesi alıntısı", "§15, genel müdürün sözü — birebir"),
    ("bugün 14 fabrika", "`data.json/kimlik.fabrika_bugun`"),
    ("yirmi yılı aşkın özelleştirme programı · 2018'de on fabrika satıldı",
     "§17 · satılanların listesi aynı yerde"),
    ("Alpullu bugün Binbirgıda'ya ait", "§17 · `_raw/kota.json` 2025/26 kota listesi %0,94"),
    ("kamış şekeri üretilmiyor", "`data.json/seker.kamis_sekeri_bin_ton` = 0"),
    ("1934 Turhal rölyefi · demirbaştan düşmesi", "§19 ilk iki paragraf"),
    ("Mehmet Canyurt · Taner Canyurt · 31 Mart 2026 iadesi",
     "§19 · `turkseker_s25_rolyef_teslim` altyazısı"),
    ("Uşak'ta 101. kampanya 22 Eylül'de başladı",
     "`_raw/kaynak_dosyalari/turkseker_haberler.json` — TÜRKŞEKER haberi, 22 Eylül 2026 törenleri"),
    ("Alpullu'da üretimi başka bir şirket sürdürüyor", "§17 · kota listesi"),
    ("%36,08 pay", "`_raw/kota.json` pancar_sekeri_2025_26"),
]


def _birlestir(*parcalar):
    """Boş olmayanları ' · ' ile birleştirir, tekrarı atar."""
    cikti = []
    for p in parcalar:
        p = (p or "").strip()
        if not p or p.lower() in ("none", "own work"):
            continue
        # İÇİNDE GEÇENİ ATLA. Kurumun görsellerinde atıf
        # "Türkiye Şeker Fabrikaları A.Ş.", lisans ise aynı ad + " — kurumun
        # kendi yayını". Tam eşitlik sınaması bunu yakalamıyor; kapsama
        # sınaması yakalıyor. Uzun olan kalıyor.
        cikti = [c for c in cikti if c not in p]
        if not any(p in c for c in cikti):
            cikti.append(p)
    return " · ".join(cikti)


def kunye(kimlik):
    """Künyeyi dört kaynaktan sırayla arar. Bulamazsa düşer.

    TAM KÜNYE: atıf + kredi (bağış/yayın notu) + lisans. Yalnız `atif`
    alanını yazmak eksik künye demek — Commons'ta o alanda çoğu zaman
    'Unknown author' ya da yükleyicinin rumuzu duruyor.
    """
    if kimlik in G:
        k = G[kimlik]
        return k["atif"], k["en_boy"], (k.get("alt_tr") or "")
    alt = A.get(kimlik, {}).get("tr", "") if not kimlik.startswith("_") else ""
    kay = KUN.get(kimlik) or ADAY.get(kimlik)
    if kay:
        return (_birlestir(kay.get("atif"), kay.get("kredi"), kay.get("lisans")),
                None, alt or kay.get("aciklama", ""))
    sys.exit("✗ künyesi bulunamayan kare: %s" % kimlik)


def main():
    satirlar = []
    toplam = 0
    dikeyler = []
    for n, (bolum, kimlik, sn, hareket) in enumerate(PLAN, 1):
        atif, en_boy, alt = kunye(kimlik)
        toplam += sn
        isaret = ""
        if en_boy is not None and en_boy < 1:
            isaret = " ▲"
            dikeyler.append((kimlik, en_boy))
        satirlar.append((n, bolum, kimlik + isaret, sn, hareket, alt, atif))

    # Bölüm görselleri galeri.json'da olmadığı için en_boy'u yok; dikey
    # olanları dosyadan ölçüyoruz.
    import struct
    for _, kimlik, _, _ in PLAN:
        if kimlik in G:
            continue
        p = RAW / "gorseller" / (kimlik + ".jpg")
        if not p.exists():
            continue
        b = p.read_bytes()
        i = 2
        w = h = None
        while i < len(b) - 9:
            if b[i] != 0xFF:
                i += 1
                continue
            m = b[i + 1]
            if m in (0xC0, 0xC1, 0xC2, 0xC3):
                h, w = struct.unpack(">HH", b[i + 5:i + 9])
                break
            if m in (0xD8, 0xD9) or 0xD0 <= m <= 0xD7:
                i += 2
                continue
            i += 2 + struct.unpack(">H", b[i + 2:i + 4])[0]
        if w and h and w < h:
            dikeyler.append((kimlik, w / h))

    toplam_kart = toplam + KART_SN
    y = []
    y.append("# TÜRKŞEKER — dosya videosu · metin ve çekim listesi")
    y.append("")
    y.append("**Biçim:** 16:9 · %d plan + kapanış kartı · %d sn (%d:%02d)"
             % (len(PLAN), toplam_kart, toplam_kart // 60, toplam_kart % 60))
    y.append("**Ses:** Flow'da YOK. Seslendirme ve altyazı CapCut'ta, aşağıdaki metinden.")
    y.append("**Görüntü:** hepsi dosyanın gerçek arşiv karesi. Üretilmiş plan yok.")
    y.append("")
    y.append("Flow burada görüntü üreteci olarak değil **hareket vereci** olarak")
    y.append("kullanılıyor: her planın başlangıç karesi gerçek bir fotoğraf, Flow ona")
    y.append("yavaş bir kamera hareketi veriyor. 139 galeri karesi ve 20 bölüm görseli")
    y.append("anlatının her durağını karşıladığı için üretilmiş kareye gerek kalmadı.")
    y.append("")
    y.append("## Karar defteri")
    y.append("")
    y.append("26 Kasım 2026, dört turluk çoktan seçmeli. İşaretlenen:")
    y.append("")
    y.append("| soru | karar |")
    y.append("|---|---|")
    for s, k in KARARLAR:
        y.append("| %s | %s |" % (s, k))
    y.append("")
    y.append("## Seslendirme metni")
    y.append("")
    kelime = sum(len(t.split()) for _, t in METIN)
    y.append("> ~%d kelime. Belgesel temposunda ~%d sn; planlar nefes payıyla"
             % (kelime, round(kelime / 2.2)))
    y.append("> %d saniyeye yayılıyor." % toplam_kart)
    y.append("")
    for bolum, t in METIN:
        y.append("### " + bolum)
        y.append(t.strip())
        y.append("")
    y.append("## Ekrana binecek yazılar")
    y.append("")
    y.append("Rakamlar seslendirmede değil ekranda. CapCut işi; Flow'da kredi")
    y.append("harcamıyor ve biçim denetimi bizde kalıyor.")
    y.append("")
    y.append("| bölüm | yazı |")
    y.append("|---|---|")
    for b, t in EKRAN:
        y.append("| %s | %s |" % (b, t))
    y.append("")
    y.append("## Çekim listesi")
    y.append("")
    y.append("Hareketler yavaş: arşiv fotoğrafına hızlı kamera, belgeyi oyuncağa çevirir.")
    y.append("")
    y.append("| # | bölüm | sn | kaynak kare | hareket |")
    y.append("|---|---|---:|---|---|")
    for n, bolum, kimlik, sn, hareket, _, _ in satirlar:
        y.append("| %d | %s | %d | `%s` | %s |" % (n, bolum, sn, kimlik, hareket))
    y.append("| — | X · Kapanış | %d | kapanış kartı (CapCut) | sabit |" % KART_SN)
    y.append("")
    y.append("▲ dikey kaynak — Flow'a verilmeden önce 1920×1080 koyu tuvale ortalanacak")
    y.append("★ anlatının insan merkezi")
    y.append("")
    y.append("**Toplam: %d saniye (%d:%02d).**"
             % (toplam_kart, toplam_kart // 60, toplam_kart % 60))
    y.append("")
    y.append("## Dikey kareler")
    y.append("")
    y.append("16:9 kadraja kırpmak bunları mahveder. Dosyanın kendi zemin rengiyle")
    y.append("1920×1080 koyu tuvale ortalanacak — belge sunar gibi. İş yerelde")
    y.append("yapılıyor, kredi harcamıyor, kadrajın denetimi bizde kalıyor.")
    y.append("")
    y.append("| kare | en/boy |")
    y.append("|---|---:|")
    for kimlik, eb in dikeyler:
        y.append("| `%s` | %.2f |" % (kimlik, eb))
    y.append("")
    y.append("## Künyeler")
    y.append("")
    y.append("| # | kare | altyazı | künye |")
    y.append("|---|---|---|---|")
    for n, _, kimlik, _, _, alt, atif in satirlar:
        y.append("| %d | `%s` | %s | %s |"
                 % (n, kimlik.replace(" ▲", ""), alt or "—", atif))
    y.append("")
    y.append("## Kredi")
    y.append("")
    final = (toplam) * 3
    taslak = 60
    y.append("| | |")
    y.append("|---|---|")
    y.append("| 360p taslak (1 kredi/sn) · hareketi sınanacak planlar | ~%d |" % taslak)
    y.append("| 720p final (3 kredi/sn) · %d sn | %d |" % (toplam, final))
    y.append("| **Toplam** | **~%d** · 1050 kredinin yarısı |" % (taslak + final))
    y.append("")
    y.append("Kapanış kartı CapCut'ta yapılıyor, Flow'da kredi harcamıyor.")
    y.append("x2 kullanılmıyor: aynı istemden ikinci rastgele çekiliş yerine,")
    y.append("düzeltilmiş istemden tek çekiliş hem daha ucuz hem daha isabetli.")
    y.append("")
    y.append("## Dayanaklar")
    y.append("")
    y.append("Hiçbir rakam ve hiçbir ad hafızadan yazılmadı.")
    y.append("")
    y.append("| metindeki ifade | kaynak |")
    y.append("|---|---|")
    for i, k in DAYANAK:
        y.append("| %s | %s |" % (i, k))
    y.append("")

    cikti = RAW / "video_metni.md"
    cikti.write_text("\n".join(y) + "\n", encoding="utf-8")
    print("✓ %s" % cikti)
    print("  %d plan + kart · %d sn (%d:%02d) · %d kelime · %d dikey kare"
          % (len(PLAN), toplam_kart, toplam_kart // 60, toplam_kart % 60,
             kelime, len(dikeyler)))
    print("  kredi: ~%d" % (taslak + final))
    return 0


sys.exit(main())
