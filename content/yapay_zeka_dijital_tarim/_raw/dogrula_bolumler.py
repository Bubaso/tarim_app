#!/usr/bin/env python3
"""
Yapay Zeka ve Dijital Tarım — bölüm metinlerinin doğrulayıcısı (karar 25/48).

    python3 dogrula_bolumler.py
    python3 dogrula_bolumler.py --makbuz     # + kural 19'un ağır sınaması (PDF, Swift)

Her `bolumler/NN-*.{tr,en}.md` dosyası kendi kilitli kaydına
(`_raw/bNN_kaynaklar.json`) karşı sınanır. Kayıt yoksa bölüm yazılmış
sayılmaz — DURUR.

KURALLAR
  1. SAYI İZİ. Metindeki her sayı, YAZILDIĞI BASAMAKTA kayıttaki bir
     değerden türetilebilmeli: "%99" ← 99,35 ✓; "%31" ← 31,40 ✓.
     Kayıtta olmayan sayı metne giremez ("kaynağı olmayan bilgi yayına
     çıkmaz").
  2. REDDEDİLEN SAYI. Kaydın `_reddedilen` bölümündeki sayılar (doğrulanamayan
     satıcı rakamları, birincil kaynaktan teyit edilemeyen tutarlar) metinde
     geçemez — Tur 1'de reddedilen rakamlar metne yazılmış, elle yakalanmıştı.
  3. SATICI ETİKETİ (karar 34). Niteliği SATICI olan bir kaydın sayısını
     taşıyan satır, satıcı beyanı olduğunu söylemeli.
  4. İKİ DİL. TR ve EN sürümlerin sayı kümeleri aynı olmalı: bir dilde olup
     ötekinde olmayan sayı, çeviride düşen ya da eklenen bilgi demek.
  5. BİÇİM. Başlık satırı "# NN · …" ile başlamalı ve dosya adındaki
     numarayla tutmalı (dosya biçimi; okura görünmüyor).
  6. ÜRETİLMİŞ BAŞLIK. §30 Kaynakça elle yazılmıyor, bütün kayıtlardan
     üretiliyor (`kaynakca_uret.py`). Künyelerdeki DOI, tarih ve sayfa
     numaraları iki dilin sayı ayrıştırıcısında farklı okunduğu için §30 sayı
     izine değil, üreticinin o anki çıktısına karşı sınanır: kayıtlar
     değişip kaynakça eski kalırsa DURUR. §29 Sözlük de üretiliyor
     (`sozluk_uret.py`, `sozluk.json`dan); tanımları elle yazıldığı için hem
     sayı izine hem üreticinin çıktısına karşı sınanır.
  7. KOPYA. Bir kayıttaki kaynak başka bir başlığın kaydından kopyalanmışsa
     (`_kopya`: "bNN_kaynaklar.json · anahtar[ · not]") kopyanın her alanı
     (künye, dosya, sayısal alanlar) asıldakiyle aynı olmalı. Asıl değişip
     kopya eski kalırsa DURUR: §1'in özeti ve §25'in dizini öbür başlıkların
     kayıtlarından kopyalanıyor; bir başlıkta ölçüm değişince onlar da
     yeniden okunmalı. Alıntılar burada sınanmıyor: her alıntı belgenin
     kendisine karşı `dogrula_alintilar.py`de sınanıyor ve kopya aynı
     belgeden ek alıntı taşıyabilir.
  8. ÜSLUP (karar 56). Metin başlık satırından sonra doğrudan düz yazıyla
     başlar (alt başlık, tablo ya da alıntı bloğu ile değil); hiçbir yerde
     özet/alıntı bloğu (">"), "§" göndermesi, "Bu sayfa nasıl güncelleniyor"
     bölümü ya da "Eksik olan ise …" kalıbı yok. §29 ve §30 üretilmiş: ilk
     satır kuralı onlara uygulanmaz, ötekiler uygulanır.
  9. TEKNOLOJİ SAYFASI (karar 57). `teknolojiler/<kod>.{tr,en}.md` başlıklar
     gibi sınanır: sayılar `tek_<kod>_kaynaklar.json`'dan (başlık
     kayıtlarından kopya; kural 7), iki dil aynı, üslup kuralı geçerli;
     ilk satır "# <teknolojinin adı>".
 11. GRAFİK (karar 58). `grafikler.json`'daki her değer bir kaydın sayısal
     alanına birebir eşit (ya da kaynağın kendi alıntısında geçiyor);
     metinlerdeki `[[grafik:…]]` yönergeleri tanımlı grafiğe gidiyor, iki dilde
     aynı sırada; kullanılmayan grafik yok.
 12. GÖRSEL (karar 58). `gorseller.json`'daki her görselin dosyası
     `web/yz/gorsel/` altında, sha256'sı tutuyor; künye ve kaynak iki dilde;
     adres ve indirme günü yazılı; yapay zekâ üretimi fotoğraf yok. Türkçeye
     uyarlanmış kopyası (`dosya_tr`, karar 60) varsa o da yerinde ve kaynak
     satırı "Türkçeye uyarlandı" diyor. `yer` görselin anlattığı paragraf,
     `konum` ("önce"/"sonra", madde 5) görselin o paragrafın önünde mi
     ardında mı durduğu: Türkçe metinde paragraf yönergenin o yanında ve
     aynı alt başlık bölümünde.
 13. KISALTMA (karar 60). Başlık ve teknoloji metinlerinde büyük harfli bir
     kısaltma bir sayfada ilk geçtiği yerde açılmıyorsa ("Uzun Ad (KISA)" ya
     da "KISA (uzun ad)") `kisaltmalar.json`da olmalı: balonla açılan
     (`kisaltmalar`), herkesin bildiği (`bilinen`) ya da kısaltma olmayan ad
     (`ad`). Okur her başlığa doğrudan gelebiliyor.
 14. LİSTE (karar 60). Madde listesi ("- " ile başlayan satırlar) bir boş
     satırla başlar ve biter; iç içe liste yok; TR ve EN'de listeler aynı
     sırada, aynı madde sayısıyla.
 15. TERİM BİRLİĞİ (karar 60). Türkçe metinde aynı kavram tek adla:
     "makine öğrenmesi" ("makine öğrenimi" değil), "dron" ("drone" değil).
     Tırnak ve italik içi (özgün ad, alıntı) sayılmaz.
 16. ÖNE ÇIKAN CÜMLE (madde 6). `_raw/cekmeler.json`daki her cümle
     ({kimlik, sayfa, sinif, tr, en}) kendi sayfasında bir gövde
     paragrafının içinde tam bir kez ve harfi harfine geçer; başı ve sonu
     cümle sınırı; 60-170 görünen harf (EN 190); gönderme ya da bağlaçla
     başlamaz, iki nokta ya da soru işareti yok; satıcı beyanı paragrafından
     ve bir grafiğin `yer` paragrafından değil, aynı bölümdeki grafiğin
     rakamını tekrarlamıyor; A sınıfında kaynaklı kalın rakam var; TR ve EN
     rakam kümeleri aynı, EN cümlesi aynı sıradaki paragrafta. Yönerge
     `[[cekme:kimlik]]` iki dilde aynı yerde; yeri: iki paragraf arasında,
     telefonda 1,0 ekranı aşan bir paragraf koşusunun ortasına en yakın
     uygun aralık (ilk ekran, giriş paragrafının ardı ve kaynak paragrafın
     bitişiği değil), aynı alt başlıkta; alt başlık başına en çok 1, sayfa
     başına en çok max(1, round(kelime/600)). Tanınmayan yönerge yok.
 17. KAYNAK KARNESİ. `lib/features/yapay_zeka/data/yz_kaynak_karnesi.g.dart`
     her sayfa için kayıtlardan yeniden hesaplanan karneyle aynı: sayfanın
     mavi rakamlarını (TR ve EN birlikte) destekleyen FARKLI kaynakların
     türe göre sayısı — hakemli (HAKEMLI), kurumsal (KURUMSAL + PROJE),
     resmî (RESMI), satıcı (SATICI) — ve dil başına kaynaklı rakam sayısı.
     Rakam eşlemesindeki her sayfanın karnesi var, fazlası yok; sayılar
     ≥ 0; toplamı ≥ 1 olan sayfa var. Niteliği olmayan ya da tanınmayan
     kaynak sayılmaz ve UYARI verir (durdurmaz).
 10. KESİŞİM NOTU (karar 57). Bir başlık bir teknolojiyle etiketliyse
     `kesisim_<kod>.json`'da o başlığın tek cümlelik notu var, değilse yok.
     Notun sayıları başlığın kendi kaydından, iki dilde aynı.
 17. ATLAS (Türkiye Dijital Tarım Atlası). `atlas_uret.py`'nin kayıtları:
     ızgarada 81 plaka, 81 ayrı hücre; her "Dosyada" kaydının cümlesi
     (TR ve varsa EN) kendi .md dosyasında harfi harfine geçiyor ve o ilin
     adını taşıyor; her "Türkiye dizininde" kaydının ili eşleme dosyasında
     (`atlas_kurum_ili.json`, geçerli dayanakla) ya da girişimde Kuruluş
     hücresinde, gösterilen hücreler §25'in tablosunda harfi harfine; §25
     tablosunda eşleme dosyasında olmayan kurum yok; üretilmiş
     `yz_atlas.g.dart` güncel (dart_uret.py koşmuş).
 19. RAKAMIN MAKBUZU. `makbuz.json` (makbuz_uret.py) rakam eşlemesiyle
     birebir: PDF kopyalı her [kaynak, parça] çiftinin tam alıntısı için
     tek kayıt, fazlası yok; kaydın PDF'i ham_kaynaklar.json'daki SHA-256'yla
     üretilmiş; sayfa 1..sayfa sayısı ya da bulunamama nedeni yazılı;
     niteliği güncel ve kesit yalnız dosyayı anan BÜTÜN kayıtlar RESMI,
     KURUMSAL, SATICI ya da PROJE iken (bir kayıt HAKEMLI ise kesit yok);
     her kesit `web/yz/makbuz/` altında, adı `<kök>-s<sayfa>-<özet>.webp`
     ve özet dosyanın sha256'sıyla tutuyor (site webp'yi bir yıl değişmez
     önbelleğe alıyor: çizim değişip ad değişmezse eski kesit görünür),
     piksel boyu kayıttakiyle aynı; klasörde artık dosya yok; toplam 12 MB'ı
     aşmıyor; `yz_makbuz.g.dart` güncel. `--makbuz` ile AĞIR sınama: yerel
     PDF'lerin SHA-256'sı ve her alıntının sayfası Swift aramasıyla
     (makbuz.swift, kesit çizilmeden) yeniden bulunup karşılaştırılıyor.
 20. CANLI PENCERE. `[[canli:<kimlik>]]` (ör. §19'daki "Uzaydan bugün" NDVI
     haritası) yalnız başlık sayfalarında; kimlik `CANLI_PENCERELER`de
     (Dart eşi `kYzCanliPencereler`); TR ve EN'de aynı yerde (önündeki
     canli'siz blok sayısı aynı); bir sayfada aynı pencere en çok bir kez;
     tanımlı her pencere bir metinde kullanılıyor. Basılı sürüme, aramaya
     ve okuma süresine girmez.
 21. SAHADAN. `sahadan.json`daki her karenin dosyası `web/yz/gorsel/`
     altında, sha256'sı ve piksel boyu kayıttakiyle aynı; künye ve kaynak
     satırı iki dilde dolu, kaynak "Fotoğraf: …" / "Photo: …"; kaynak sayfası
     ve görsel adresi https; ajans izi "hayır"; il boş ya da ızgaradaki 81
     ilden biri; başlık ve alt başlığı (`bolum`) metinde iki dilde var; harf
     ve kimlik tekil. Başlık içinde de duran kare (gorseller.json'da aynı
     kimlik) ortak alanlarda (dosya, boy, sha256, künye, kaynak, adresler,
     indirme günü) gorseller.json'la birebir, sayfası `baslik` ve yönergesi
     iki dilde o alt başlıkta. Aynı görsel adresi gorseller.json'da başka
     bir dosyayla yok (çift dosya yok; aynı dosyayı başka kimlikle yeniden
     kullanmak serbest); `sahadan-*.webp` artık dosya yok; `yz_sahadan.g.dart`
     güncel.
"""
from __future__ import annotations

import hashlib
import importlib.util
import json
import math
import re
import sys
from pathlib import Path

BURASI = Path(__file__).resolve().parent
BOLUMLER = BURASI.parent / "bolumler"

hatalar: list[str] = []
uyarilar: list[str] = []


def hata(m: str) -> None:
    hatalar.append(m)
    print(f"  ✗ {m}")


def uyari(m: str) -> None:
    """Durdurmayan bulgu (kural 18: niteliği olmayan kaynak)."""
    uyarilar.append(m)
    print(f"  ⚠ {m}")


# Künye ve tarih alanlarından YALNIZ YIL alınır; tanıtıcı alanlardan hiçbir
# şey alınmaz. Aksi hâlde DOI'deki, cilt ve sayfa numarasındaki rakamlar
# havuzu doldurur ve uydurma bir sayı tesadüfen "izlenir" görünür.
YALNIZ_YIL = {"kunye", "yayim_tarihi", "tarih"}
# `guncellendi` sayfanın künyesi, metnin dayanağı değil: tarihindeki 16 ve
# 11 havuza girerse metindeki her "16" kendiliğinden "izlenir" görünürdü.
TANITICI = {"doi", "on_baski", "adres", "dogrulandigi_yer", "lisans_adresi",
            "guncellendi", "dosya"}


def kayit_sayilari(dugum, anahtar: str = "") -> list[float]:
    """Kayıttaki sayılar: sayısal alanlar, metin alanlarındaki rakamlar
    ('3-6 gün' gibi aralıklar) ve künyedeki yıl."""
    cikti: list[float] = []
    if isinstance(dugum, bool) or anahtar in TANITICI:
        return cikti
    if isinstance(dugum, (int, float)):
        cikti.append(float(dugum))
    elif isinstance(dugum, str):
        if anahtar in YALNIZ_YIL:
            return [float(y) for y in re.findall(r"(?<!\d)(?:19|20)\d{2}(?!\d)", dugum)]
        for s in re.findall(r"\d+(?:[.,]\d+)?", dugum):
            try:
                cikti.append(float(s.replace(",", ".")))
            except ValueError:
                pass
            if re.fullmatch(r"\d{1,3}[.,]\d{3}", s):        # binlik ayraçlı
                cikti.append(float(s.replace(".", "").replace(",", "")))
    elif isinstance(dugum, dict):
        for a, v in dugum.items():
            if not a.startswith("_"):
                cikti += kayit_sayilari(v, a)
    elif isinstance(dugum, list):
        for v in dugum:
            cikti += kayit_sayilari(v, anahtar)
    return cikti


def metin_sayilari(metin: str, dil: str) -> list[tuple[float, int, str]]:
    """(değer, ondalık basamak, satır) üçlüleri. TR: binlik '.', ondalık ','.
    EN: binlik ',', ondalık '.'."""
    binlik, ondalik = (r"\.", ",") if dil == "tr" else (",", r"\.")
    desen = re.compile(rf"(?<![\w.,])(\d{{1,3}}(?:{binlik}\d{{3}})+|\d+(?:{ondalik}\d+)?)(?![\d])")
    cikti = []
    for satir in metin.splitlines():
        if satir.startswith("# "):
            continue                        # başlık satırı: bölüm numarası
        if re.fullmatch(r"\s*\[\[[a-z]+:[a-z0-9-]+\]\]\s*", satir):
            continue                        # yönerge satırı: grafik, görsel (karar 58), öne çıkan cümle
        # "§8" bir veri değil, bölümün iç göndermesi; ayrıca sınanıyor
        # (gönderilen başlık iskelette var mı — `gondermeler`).
        satir = re.sub(r"§\d+", "§", satir)
        for m in desen.finditer(satir):
            ham = m.group(1)
            if re.fullmatch(rf"\d{{1,3}}(?:{binlik}\d{{3}})+", ham):
                deger, bas = float(re.sub(binlik, "", ham)), 0
            else:
                ayrac = "," if dil == "tr" else "."
                deger = float(ham.replace(ayrac, "."))
                bas = len(ham.split(ayrac)[1]) if ayrac in ham else 0
            cikti.append((deger, bas, satir.strip()))
    return cikti


def izlenir(deger: float, bas: int, havuz: list[float]) -> bool:
    return any(abs(round(v, bas) - deger) < 1e-9 or abs(v - deger) < 1e-9 for v in havuz)


GECERLI_BASLIKLAR = {b["no"] for b in json.loads(
    (BURASI.parent / "iskelet.json").read_text(encoding="utf-8"))["basliklar"]}

# PROJE: teknolojiyi geliştiren firmanın da yazdığı proje broşürü (§7,
# AquaTag). Satıcı beyanı gibi etiketlenir — karar 34.
SATICI_ETIKETI = {"tr": re.compile(r"[Şş]irket(in)? (kendi )?(beyan|rakam)|[Ss]atıcı|proje beyan"),
                  "en": re.compile(r"[Vv]endor|[Cc]ompany('s)? (own )?(statement|figure)|project statement")}


def sina(no: str, dosyalar: dict[str, Path], kayit_yolu: Path | None = None,
         ilk_satir: str | None = None, ad: str | None = None) -> None:
    """Metnin sayıları kendi kaydına karşı (kural 1-5). Başlık için kayıt
    bNN_kaynaklar.json; teknoloji sayfası için tek_<kod>_kaynaklar.json."""
    kayit_yolu = kayit_yolu or BURASI / f"b{no}_kaynaklar.json"
    ad = ad or f"§{int(no)}"
    if not kayit_yolu.exists():
        hata(f"{ad}: kilitli kayıt yok ({kayit_yolu.name}) — yazılmış sayılmaz")
        return
    kayit = json.loads(kayit_yolu.read_text(encoding="utf-8"))
    havuz = kayit_sayilari({k: v for k, v in kayit.items() if not k.startswith("_")})
    red = {float(x) for x in re.findall(r"\d+", json.dumps(kayit.get("_reddedilen", {}), ensure_ascii=False))} - set(havuz)
    saticilar = [v for v in kayit.get("kaynaklar", {}).values() if v.get("nitelik") in ("SATICI", "PROJE")]
    satici_sayilari = {v for s in saticilar for v in kayit_sayilari(
                           {a: x for a, x in s.items() if a not in ("alinti", "kunye")})
                       if v not in (0, 1)}
    # Satıcı rakamı başka bir kaynakta da geçiyorsa (aynı sayı, başka ölçüm)
    # etiket zorunluluğu o satırda anlamsız olur: yalnız satıcıya ÖZGÜ sayılar.
    oteki = {v for k, s in kayit.get("kaynaklar", {}).items()
             if isinstance(s, dict) and s.get("nitelik") not in ("SATICI", "PROJE")
             for v in kayit_sayilari({a: x for a, x in s.items() if a != "kunye"})}
    satici_sayilari -= oteki

    kume = {}
    for dil, yol in dosyalar.items():
        metin = yol.read_text(encoding="utf-8")
        ilk = metin.splitlines()[0] if metin else ""
        if not re.match(ilk_satir or rf"# {int(no)} · \S", ilk):
            hata(f"{yol.name}: başlık satırı beklenen biçimde değil: {ilk[:50]!r}")
        sayilar = metin_sayilari(metin, dil)
        for deger, bas, satir in sayilar:
            if not izlenir(deger, bas, havuz):
                hata(f"{yol.name}: {deger:g} kayıtta yok — «{satir[:90]}»")
            if any(abs(deger - r) < 1e-9 for r in red):
                hata(f"{yol.name}: REDDEDİLMİŞ sayı {deger:g} metinde — «{satir[:90]}»")
            if deger in satici_sayilari and not SATICI_ETIKETI[dil].search(satir):
                hata(f"{yol.name}: satıcı rakamı {deger:g} etiketsiz — «{satir[:90]}»")
        kume[dil] = sorted({round(d, 4) for d, _, _ in sayilar})
        print(f"  · {yol.name}: {len(sayilar)} sayı, hepsi kayda karşı sınandı")
    if set(kume) == {"tr", "en"} and kume["tr"] != kume["en"]:
        yalniz_tr = sorted(set(kume["tr"]) - set(kume["en"]))
        yalniz_en = sorted(set(kume["en"]) - set(kume["tr"]))
        hata(f"{ad}: iki dilin sayıları farklı — yalnız TR {yalniz_tr}, yalnız EN {yalniz_en}")


URETICI = {"29": "sozluk_uret.py", "30": "kaynakca_uret.py"}
SAYI_IZI_YOK = {"30"}


def sina_uretilmis(no: str, dosyalar: dict[str, Path]) -> None:
    """Üretilmiş başlık: dosyalar (ve üretici kayıt da yazıyorsa kayıt),
    üreticinin şimdiki çıktısıyla birebir mi."""
    import importlib.util
    spec = importlib.util.spec_from_file_location(f"uretici_{no}", BURASI / URETICI[no])
    uretici = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(uretici)
    try:
        tr, en, kayit = uretici.uret()
    except SystemExit as e:                 # üretici kendi denetiminde durdu
        hata(f"{URETICI[no]}: {e}")
        return
    for dil, beklenen in (("tr", tr), ("en", en)):
        yol = dosyalar.get(dil)
        if yol is None:
            continue
        ilk = yol.read_text(encoding="utf-8").splitlines()[0]
        if not re.match(rf"# {int(no)} · \S", ilk):
            hata(f"{yol.name}: başlık satırı '# {int(no)} · …' değil")
        if yol.read_text(encoding="utf-8") != beklenen:
            hata(f"{yol.name}: üreticinin çıktısıyla aynı değil — {URETICI[no]} koşturulmalı")
        else:
            print(f"  · {yol.name}: üreticinin çıktısıyla birebir")
    if kayit is not None:
        kayit_yolu = BURASI / f"b{no}_kaynaklar.json"
        if not kayit_yolu.exists() or kayit_yolu.read_text(encoding="utf-8") != kayit:
            hata(f"b{no}_kaynaklar.json üreticinin çıktısıyla aynı değil — {URETICI[no]} koşturulmalı")


USLUP_YASAK = [
    (re.compile(r"^> ", re.M), "özet ya da alıntı bloğu ('> ')"),
    (re.compile(r"§\d"), "'§' göndermesi"),
    (re.compile(r"^## (Bu sayfa nasıl güncelleniyor|How this page is kept up to date)", re.M),
     "'Bu sayfa nasıl güncelleniyor' bölümü"),
    (re.compile(r"Eksik olan ise|What is missing is"), "'Eksik olan ise' kalıbı"),
]


def sina_uslup(no: str, dosyalar: dict[str, Path]) -> None:
    """Kural 8 (karar 56): metin doğrudan başlar; tekrar eden kalıp yok."""
    for yol in dosyalar.values():
        satirlar = yol.read_text(encoding="utf-8").splitlines()
        govde = "\n".join(satirlar[1:])
        for desen, ad in USLUP_YASAK:
            m = desen.search(govde)
            if m:
                satir = govde[:m.start()].count("\n") + 2
                hata(f"{yol.name}:{satir}: {ad} var (karar 56)")
        if no in URETICI:
            continue
        ilk = next((s for s in satirlar[1:] if s.strip()), "")
        if ilk.startswith(("#", "|", ">")):
            hata(f"{yol.name}: metin doğrudan başlamıyor — ilk satır {ilk[:40]!r} (karar 56)")


TEKNOLOJILER = BURASI.parent / "teknolojiler"
NOT_EN_UZUN = 220


def _iskelet() -> dict:
    return json.loads((BURASI.parent / "iskelet.json").read_text(encoding="utf-8"))


def sina_teknoloji_sayfalari() -> None:
    """Kural 9 (karar 57): her teknolojinin alanlar arası durum sayfası
    (`teknolojiler/<kod>.{tr,en}.md`) kendi kaydına (`tek_<kod>_kaynaklar.json`,
    başlık kayıtlarından kopya) karşı başlıklar gibi sınanır; üslup kuralı da."""
    print("\nTeknoloji sayfaları")
    for kod, t in _iskelet()["teknoloji"].items():
        dosyalar = {dil: TEKNOLOJILER / f"{kod}.{dil}.md" for dil in ("tr", "en")}
        eksik = [y.name for y in dosyalar.values() if not y.exists()]
        if eksik:
            hata(f"teknoloji {kod}: sayfa yok ({', '.join(eksik)})")
            continue
        ilk = rf"# ({re.escape(t['tr'])}|{re.escape(t['en'])})$"
        sina(kod, dosyalar, kayit_yolu=BURASI / f"tek_{kod}_kaynaklar.json",
             ilk_satir=ilk, ad=f"teknoloji {kod}")
        sina_uslup("tek", dosyalar)


def sina_kesisimler() -> None:
    """Kural 10 (karar 57): her teknoloji–başlık kesişiminin (başlık o
    teknolojiyle etiketliyse) kısa bir notu var; fazlası yok. Not tek cümle,
    kalın ve § yok; sayıları başlığın kendi kaydından, iki dilde aynı."""
    print("\nKesişim notları")
    isk = _iskelet()
    etiketli = {kod: {b["no"] for b in isk["basliklar"] if kod in b["teknoloji"]}
                for kod in isk["teknoloji"]}
    sayac = 0
    for kod, nolar in etiketli.items():
        yol = BURASI / f"kesisim_{kod}.json"
        if not yol.exists():
            hata(f"{yol.name} yok")
            continue
        notlar = {int(k): v for k, v in json.loads(yol.read_text(encoding="utf-8")).get("notlar", {}).items()}
        for no in sorted(nolar - set(notlar)):
            hata(f"{yol.name}: §{no} etiketli ama notu yok")
        for no in sorted(set(notlar) - nolar):
            hata(f"{yol.name}: §{no} bu teknolojiyle etiketli değil, notu olmamalı")
        for no, n in sorted(notlar.items()):
            kayit_yolu = BURASI / f"b{no:02d}_kaynaklar.json"
            havuz = kayit_sayilari({k: v for k, v in json.loads(kayit_yolu.read_text(encoding="utf-8")).items()
                                    if not k.startswith("_")}) if kayit_yolu.exists() else []
            kume = {}
            for dil in ("tr", "en"):
                metin = (n or {}).get(dil, "")
                if not metin.strip():
                    hata(f"{yol.name} §{no}: {dil} notu boş")
                    continue
                if len(metin) > NOT_EN_UZUN:
                    hata(f"{yol.name} §{no} {dil}: {len(metin)} karakter (en çok {NOT_EN_UZUN})")
                if "§" in metin or "**" in metin or "\n" in metin:
                    hata(f"{yol.name} §{no} {dil}: §, kalın ya da satır sonu var")
                sayilar = metin_sayilari(metin, dil)
                for deger, bas, _ in sayilar:
                    if not izlenir(deger, bas, havuz):
                        hata(f"{yol.name} §{no} {dil}: {deger:g} b{no:02d} kaydında yok")
                kume[dil] = sorted({round(d, 4) for d, _, _ in sayilar})
                sayac += 1
            if set(kume) == {"tr", "en"} and kume["tr"] != kume["en"]:
                hata(f"{yol.name} §{no}: iki dilin sayıları farklı {kume['tr']} / {kume['en']}")
    print(f"  · {sayac} not sınandı")


GRAFIK_TURLERI = {"yatay_cubuk", "dikey_cubuk", "cizgi", "alan", "dumbbell", "aralik", "pay",
                  "waffle", "egim", "kpi", "isi", "zaman", "kucuk"}
DIZI_ROLLERI = {"", "ongoru", "referans", "toplam", "alt"}
YONERGE_DESENI = re.compile(r"^\[\[(grafik|gorsel|cekme):([a-z0-9-]+)\]\]$", re.M)
# Her yönerge satırı (tanınmayanlar dahil): ayrıştırıcılarda blok sayılmaz.
YONERGE_SATIRI = re.compile(r"^\[\[([a-z]+):([a-z0-9-]+)\]\]$")
BILINEN_YONERGE = {"grafik", "gorsel", "cekme", "canli"}


def _alan_degerleri(deger) -> list[float]:
    """Kayıt alanının sayıları: 12.5 → [12.5]; "24-37" → [24, 37]."""
    if isinstance(deger, (int, float)) and not isinstance(deger, bool):
        return [float(deger)]
    if isinstance(deger, str):
        return [float(x.replace(",", ".")) for x in re.findall(r"\d+(?:[.,]\d+)?", deger)]
    return []


def _alan_degeri(kaynak: dict, yol: str):
    """Kaynağın alanı; sözlük alanlarda alt anahtar noktayla (kayip_yuzde.2015)."""
    if yol in kaynak:
        return kaynak[yol]
    dugum = kaynak
    for parca in yol.split("."):
        if not isinstance(dugum, dict) or parca not in dugum:
            return None
        dugum = dugum[parca]
    return dugum


# Alıntıda yazıyla geçen sayılar ("four-fold", "dört kat"): grafik değeri
# yazıyla verilmiş bir oransa alıntıyla böyle eşleşiyor.
YAZIYLA = {"two": 2, "three": 3, "four": 4, "five": 5, "six": 6, "seven": 7, "eight": 8, "nine": 9,
           "ten": 10, "twenty": 20, "iki": 2, "üç": 3, "dört": 4, "beş": 5, "altı": 6, "yedi": 7,
           "sekiz": 8, "dokuz": 9, "on": 10, "yirmi": 20}


def _yaziyla_sayilar(alinti: str) -> list[float]:
    return [float(v) for s_, v in YAZIYLA.items()
            if re.search(rf"(?<![\w-]){s_}(?:-?fold| kat)\b", alinti, re.I)]


def sina_grafikler() -> None:
    """Kural 11 (karar 58): her grafik değeri bir kaydın sayısal alanına
    birebir eşit (ya da kaydın kendi alıntısında geçiyor); zaman
    çizelgesinde olayın yılı kaydın tarih alanında geçiyor; grafiğin başlığı
    ve açıklamasındaki her rakam bağlandığı kayıtlardan türetilebiliyor;
    metinlerdeki her [[grafik:…]] yönergesi tanımlı bir grafiğe gidiyor; iki
    dilin yönergeleri aynı sırada; tanımlanıp hiçbir yerde kullanılmayan
    grafik yok."""
    print("\nGrafikler")
    yol = BURASI / "grafikler.json"
    grafikler = json.loads(yol.read_text(encoding="utf-8")).get("grafikler", {}) if yol.exists() else {}
    kayitlar: dict[str, dict] = {}

    def kayit(ad: str) -> dict:
        if ad not in kayitlar:
            ky = BURASI / ad
            kayitlar[ad] = json.loads(ky.read_text(encoding="utf-8")) if ky.exists() else {}
        return kayitlar[ad]

    for kimlik, g in grafikler.items():
        if g.get("tur") not in GRAFIK_TURLERI:
            hata(f"grafik {kimlik}: bilinmeyen tür {g.get('tur')!r}")
        for a in ("baslik", "aciklama", "kaynak"):
            if not all((g.get(a) or {}).get(d, "").strip() for d in ("tr", "en")):
                hata(f"grafik {kimlik}: {a} iki dilde de dolu değil")
        for a in ("birim", "eksen"):
            if g.get(a) and bool((g[a].get("tr") or "").strip()) != bool((g[a].get("en") or "").strip()):
                hata(f"grafik {kimlik}: {a} iki dilde aynı doluluğta değil")
        if not g.get("noktalar"):
            hata(f"grafik {kimlik}: nokta yok")
        diziler = {d["kod"]: d for d in g.get("diziler", [])}
        for d in diziler.values():
            if d.get("rol", "") not in DIZI_ROLLERI:
                hata(f"grafik {kimlik}: dizi {d['kod']!r} rolü bilinmiyor ({d.get('rol')!r})")
            if not (d.get("tr") or "").strip() or not (d.get("en") or "").strip():
                hata(f"grafik {kimlik}: dizi {d['kod']!r} adı iki dilde de dolu değil")
        kullanilan_kayitlar: set[str] = set()
        for n in g.get("noktalar", []):
            if diziler and n.get("dizi") not in diziler:
                hata(f"grafik {kimlik}: nokta dizisi {n.get('dizi')!r} tanımlı değil")
            for a in ("kategori", "ek", "panel", "birim"):
                if a in n and not all(isinstance((n[a] or {}).get(d), str) for d in ("tr", "en")):
                    hata(f"grafik {kimlik}: noktanın {a} alanı iki dilde değil")
            if g.get("tur") == "kucuk" and not (n.get("panel") or {}).get("tr"):
                hata(f"grafik {kimlik}: küçük çoklu grafikte noktanın paneli yok")
            k = kayit(n.get("kayit", ""))
            kullanilan_kayitlar.add(n.get("kayit", ""))
            kaynak = (k.get("kaynaklar") or {}).get(n.get("kaynak", ""))
            if kaynak is None:
                hata(f"grafik {kimlik}: {n.get('kayit')} · {n.get('kaynak')} kaynağı yok")
                continue
            v = float(n["deger"])
            # Zaman çizelgesinde değer olayın yılı (kesirli: ay ve gün);
            # kayıtta sınanan yılın kendisi.
            aranan = float(math.floor(v)) if g.get("tur") == "zaman" else v
            if n.get("alan"):
                ham = _alan_degeri(kaynak, n["alan"])
                if ham is None:
                    hata(f"grafik {kimlik}: {n['kayit']} · {n['kaynak']} kaynağında {n['alan']!r} alanı yok")
                    continue
                adaylar = _alan_degerleri(ham if not isinstance(ham, (list, dict)) else json.dumps(ham, ensure_ascii=False))
                if not any(abs(aranan - x) < 1e-9 for x in adaylar):
                    hata(f"grafik {kimlik}: {aranan:g} ≠ {n['kayit']} · {n['kaynak']} · {n['alan']} ({ham!r})")
            elif n.get("alinti"):
                if n["alinti"] not in json.dumps(kaynak.get("alinti", []), ensure_ascii=False):
                    hata(f"grafik {kimlik}: alıntı kaynağın alıntılarında yok — {n['alinti'][:60]!r}")
                elif not any(abs(aranan - x) < 1e-9 for x in _alan_degerleri(n["alinti"].replace(",", ""))
                             + _alan_degerleri(n["alinti"]) + _yaziyla_sayilar(n["alinti"])):
                    hata(f"grafik {kimlik}: {aranan:g} alıntıda geçmiyor — {n['alinti'][:60]!r}")
            else:
                hata(f"grafik {kimlik}: değerin alanı da alıntısı da yok")
        # Başlık, açıklama, eksen, kategori ve not metinlerindeki rakamlar:
        # bağlanan kayıtların bütününden türetilebilmeli (metin kuralı 1 gibi).
        havuz: list[float] = []
        for ad in kullanilan_kayitlar | set(g.get("ek_kayitlar", [])):
            kk = kayit(ad)
            havuz += kayit_sayilari({x: y for x, y in kk.items() if not x.startswith("_")})
        for dil in ("tr", "en"):
            parcalar = [(g.get(a) or {}).get(dil, "") for a in ("baslik", "aciklama", "eksen")]
            for n in g.get("noktalar", []):
                parcalar += [(n.get(a) or {}).get(dil, "") for a in ("kategori", "ek", "panel")]
            for d in diziler.values():
                parcalar.append(d.get(dil, ""))
            for deger, bas, satir in metin_sayilari("\n".join(p for p in parcalar if p), dil):
                if not izlenir(deger, bas, havuz):
                    hata(f"grafik {kimlik} ({dil}): {deger:g} kayıtlardan türetilemiyor — {satir[:90]!r}")

    kullanilan: set[str] = set()
    sayfalar = [*sorted(BOLUMLER.glob("[0-2][0-9]-*.tr.md")), *sorted(TEKNOLOJILER.glob("*.tr.md"))]
    for tr in sayfalar:
        en = tr.with_name(tr.name.replace(".tr.md", ".en.md"))
        y_tr = YONERGE_DESENI.findall(tr.read_text(encoding="utf-8"))
        y_en = YONERGE_DESENI.findall(en.read_text(encoding="utf-8")) if en.exists() else []
        if y_tr != y_en:
            hata(f"{tr.name}: TR ve EN'deki grafik/görsel/öne çıkan cümle yönergeleri aynı sırada değil")
        for tur, kimlik in y_tr:
            if tur == "grafik":
                if kimlik not in grafikler:
                    hata(f"{tr.name}: [[grafik:{kimlik}]] tanımlı değil")
                kullanilan.add(kimlik)
    for kimlik in sorted(set(grafikler) - kullanilan):
        hata(f"grafik {kimlik}: hiçbir metinde kullanılmıyor")
    print(f"  · {len(grafikler)} grafik, {len(kullanilan)} yönerge sınandı")


# ── Blok ayrıştırıcı (yzAyristir'in eşi; kural 12 ve 16) ──────────────────

def sayfa_bloklari(md: str) -> list[dict]:
    """Sayfanın blokları sırayla: {tur, metin, ogeler}. Tür: paragraf,
    altBaslik, liste, tablo, ozet, grafik, gorsel, cekme, canli (yönergede
    metin kimliktir). Başlık satırı ve tanınmayan yönerge blok sayılmaz."""
    bloklar: list[dict] = []
    par: list[str] = []
    satirlar = md.replace("\r\n", "\n").split("\n")

    def kapat():
        if par:
            bloklar.append({"tur": "paragraf", "metin": " ".join(par), "ogeler": []})
            par.clear()

    i = 0
    while i < len(satirlar):
        t = satirlar[i].strip()
        m = YONERGE_SATIRI.fullmatch(t)
        if not t or t.startswith("# "):
            kapat(); i += 1
        elif m:
            kapat(); i += 1
            if m.group(1) in BILINEN_YONERGE:
                bloklar.append({"tur": m.group(1), "metin": m.group(2), "ogeler": []})
        elif t.startswith("## "):
            kapat(); bloklar.append({"tur": "altBaslik", "metin": t[3:].strip(), "ogeler": []}); i += 1
        elif t.startswith("- "):
            kapat()
            ogeler = []
            while i < len(satirlar) and satirlar[i].strip().startswith("- "):
                ogeler.append(satirlar[i].strip()[2:].strip()); i += 1
            bloklar.append({"tur": "liste", "metin": "", "ogeler": ogeler})
        elif t.startswith(">"):
            kapat()
            while i < len(satirlar) and satirlar[i].strip().startswith(">"):
                i += 1
            bloklar.append({"tur": "ozet", "metin": "", "ogeler": []})
        elif t.startswith("|"):
            kapat()
            n = 0
            while i < len(satirlar) and satirlar[i].strip().startswith("|"):
                i += 1; n += 1
            bloklar.append({"tur": "tablo", "metin": "", "ogeler": [""] * n})
        else:
            par.append(t); i += 1
    kapat()
    return bloklar


def bolum_numaralari(bloklar: list[dict]) -> list[int]:
    """Her bloğun alt başlık bölümü (0: ilk alt başlıktan önceki giriş)."""
    n, cikti = 0, []
    for b in bloklar:
        if b["tur"] == "altBaslik":
            n += 1
        cikti.append(n)
    return cikti


def sayfa_dosyasi(kod: str) -> Path | None:
    """"bNN" → bolumler/NN-*.tr.md; "tek_<kod>" → teknolojiler/<kod>.tr.md."""
    if kod.startswith("tek_"):
        yol = TEKNOLOJILER / f"{kod[4:]}.tr.md"
        return yol if yol.exists() else None
    return next(BOLUMLER.glob(f"{kod[1:]}-*.tr.md"), None) if re.fullmatch(r"b\d{2}", kod) else None


def sina_gorsel_yerleri(gorseller: dict) -> None:
    """Kural 12, madde 5: `yer` görselin anlattığı paragraf, `konum` görselin
    o paragrafın neresinde durduğu. Türkçe metinde paragraf yönergenin o
    yanında ve aynı alt başlık bölümünde."""
    sayac = 0
    for kimlik, g in gorseller.items():
        if g.get("konum") not in ("önce", "sonra"):
            hata(f"görsel {kimlik}: konum 'önce' ya da 'sonra' değil ({g.get('konum')!r})")
            continue
        yol = sayfa_dosyasi(g.get("sayfa", ""))
        if yol is None:
            hata(f"görsel {kimlik}: sayfası çözülemiyor ({g.get('sayfa')!r})")
            continue
        bl = sayfa_bloklari(yol.read_text(encoding="utf-8"))
        bn = bolum_numaralari(bl)
        gi = [i for i, b in enumerate(bl) if b["tur"] == "gorsel" and b["metin"] == kimlik]
        if not gi:
            continue                                    # kullanılmayan görsel ayrıca hata
        pi = [i for i, b in enumerate(bl) if b["tur"] == "paragraf" and b["metin"].startswith(g.get("yer") or "\0")]
        if len(pi) != 1:
            hata(f"görsel {kimlik}: `yer` paragrafı {yol.name}'de {len(pi)} kez bulundu (tam bir kez olmalı)")
            continue
        gi, pi = gi[0], pi[0]
        if (pi < gi) != (g["konum"] == "sonra") or bn[pi] != bn[gi]:
            hata(f"görsel {kimlik}: {yol.name}'de `yer` paragrafının {'ardında' if g['konum'] == 'sonra' else 'önünde'} "
                 "ve aynı alt başlıkta değil (konum, madde 5)")
        sayac += 1
    print(f"  · {sayac} görselin yeri ve konumu sınandı")


def sina_gorseller() -> None:
    """Kural 12 (karar 58): her görselin dosyası `web/yz/gorsel/` altında ve
    sha256'sı kayıttakiyle aynı; künye ve kaynak satırı iki dilde dolu;
    adresi ve indirme günü yazılı; yapay zekâ üretimi FOTOĞRAF yok (istisna
    kullanıcı onayıyla, `istisna` alanında); metindeki her [[gorsel:…]]
    tanımlı, tanımlı her görsel kullanılıyor."""
    import hashlib
    print("\nGörseller")
    yol = BURASI / "gorseller.json"
    gorseller = json.loads(yol.read_text(encoding="utf-8")).get("gorseller", {}) if yol.exists() else {}
    depo = BURASI.parents[2]
    for kimlik, g in gorseller.items():
        dosya = depo / g.get("dosya", "")
        if not g.get("dosya", "").startswith("web/yz/gorsel/") or not dosya.exists():
            hata(f"görsel {kimlik}: dosya yok ya da yanlış yerde ({g.get('dosya')!r})")
        elif hashlib.sha256(dosya.read_bytes()).hexdigest() != g.get("sha256"):
            hata(f"görsel {kimlik}: sha256 tutmuyor")
        # Türkçeye uyarlanmış kopya (karar 60): dosyası yerinde, sha256'sı
        # tutuyor, kaynak satırı uyarlandığını söylüyor.
        if g.get("dosya_tr"):
            dt = depo / g["dosya_tr"]
            if not g["dosya_tr"].startswith("web/yz/gorsel/") or not dt.exists():
                hata(f"görsel {kimlik}: Türkçe kopya yok ({g['dosya_tr']!r})")
            elif hashlib.sha256(dt.read_bytes()).hexdigest() != g.get("sha256_tr"):
                hata(f"görsel {kimlik}: Türkçe kopyanın sha256'sı tutmuyor")
            if "Türkçeye uyarlandı" not in (g.get("kaynak") or {}).get("tr", ""):
                hata(f"görsel {kimlik}: Türkçe kopyanın kaynak satırı uyarlandığını söylemiyor")
        for a in ("kunye", "kaynak"):
            if not all((g.get(a) or {}).get(d, "").strip() for d in ("tr", "en")):
                hata(f"görsel {kimlik}: {a} iki dilde de dolu değil")
        if not str(g.get("sayfa_adresi") or g.get("gorsel_adresi") or "").startswith("https://") and not g.get("yapay_zeka"):
            hata(f"görsel {kimlik}: kaynak adresi yok")
        if not g.get("indirme_gunu") and not g.get("yapay_zeka"):
            hata(f"görsel {kimlik}: indirme günü yok")
        if g.get("yapay_zeka") and g.get("tur") not in ("sema", "illustrasyon") and not g.get("istisna"):
            hata(f"görsel {kimlik}: yapay zekâ üretimi fotoğraf (karar 58: yalnız şema/illüstrasyon)")
    kullanilan: set[str] = set()
    for md in [*BOLUMLER.glob("[0-2][0-9]-*.md"), *TEKNOLOJILER.glob("*.md")]:
        for tur, kimlik in YONERGE_DESENI.findall(md.read_text(encoding="utf-8")):
            if tur == "gorsel":
                if kimlik not in gorseller:
                    hata(f"{md.name}: [[gorsel:{kimlik}]] tanımlı değil")
                kullanilan.add(kimlik)
    for kimlik in sorted(set(gorseller) - kullanilan):
        hata(f"görsel {kimlik}: hiçbir metinde kullanılmıyor")
    print(f"  · {len(gorseller)} görsel sınandı")
    sina_gorsel_yerleri(gorseller)


def sina_kopyalar() -> None:
    """Kural 7: kopya kaynak asılla aynı mı."""
    kayitlar = {y.name: json.loads(y.read_text(encoding="utf-8"))
                for y in sorted([*BURASI.glob("b[0-9][0-9]_kaynaklar.json"),
                                 *BURASI.glob("tek_*_kaynaklar.json")])}
    sayi = 0
    print("\nKopyalar")
    for ad, kayit in kayitlar.items():
        for anahtar, k in kayit.get("kaynaklar", {}).items():
            iz = k.get("_kopya")
            if not iz:
                continue
            sayi += 1
            m = re.fullmatch(r"(b\d{2}_kaynaklar\.json) · (\S+)(?: · .*)?", iz)
            if not m or m.group(1) not in kayitlar:
                hata(f"{ad} · {anahtar}: _kopya '{iz}' çözülemiyor")
                continue
            asil = kayitlar[m.group(1)].get("kaynaklar", {}).get(m.group(2))
            if asil is None:
                hata(f"{ad} · {anahtar}: asıl kaynak {iz} artık yok")
                continue
            for alan, deger in k.items():
                if alan.startswith("_") or alan == "alinti":
                    continue
                if asil.get(alan) != deger:
                    hata(f"{ad} · {anahtar}: '{alan}' asıldan ({iz}) ayrışmış — kopya yeniden okunmalı")
    print(f"  · {sayi} kopya kaynak asıllarıyla sınandı")


# ── Kural 13-15 (karar 60, okuma deneyimi turu) ───────────────────────────

KISALTMA_DESENI = re.compile(r"(?<![\wÇĞİÖŞÜçğıöşü])([A-ZÇĞİÖŞÜ][A-ZÇĞİÖŞÜ0-9-]*[A-ZÇĞİÖŞÜ0-9])(?![\wÇĞİÖŞÜçğıöşü])")
_SONRA_ACILIM = re.compile(r"^ \((?![^)]*\d)[^)]{6,}\)")
_BICIMLI = re.compile(r"\*\*.+?\*\*|\*[^*]+?\*")


def metin_parcalari(md: str) -> list[str]:
    """Okurun okuduğu parçalar sırayla: paragraflar ve liste maddeleri
    (tablo, alt başlık, yönerge hariç) — yzAyristir'in parcalar'ı."""
    cikti, par = [], []
    for satir in md.split("\n")[1:]:
        t = satir.strip()
        if not t or t.startswith(("#", "|", ">")) or YONERGE_SATIRI.fullmatch(t):
            if par:
                cikti.append(" ".join(par)); par = []
            continue
        if t.startswith("- "):
            if par:
                cikti.append(" ".join(par)); par = []
            cikti.append(t[2:].strip())
            continue
        par.append(t)
    if par:
        cikti.append(" ".join(par))
    return cikti


def kisaltma_acilmis(metin: str, bas: int, son: int) -> bool:
    """yzKisaltmaAcilmis ile aynı: "(KISA)" ya da "KISA (uzun ad)"."""
    once = bas > 0 and metin[bas - 1] == "(" and son < len(metin) and metin[son] in ")-"
    return once or bool(_SONRA_ACILIM.match(metin[son:]))


def _okur_sayfalari() -> list[Path]:
    return [*sorted(p for p in BOLUMLER.glob("[0-2][0-9]-*.md") if p.name[:2] not in ("29", "30")),
            *sorted(TEKNOLOJILER.glob("*.md"))]


def sina_kisaltmalar() -> None:
    """Kural 13: açılmayan her kısaltma kisaltmalar.json'da."""
    print("\nKısaltmalar")
    yol = BURASI / "kisaltmalar.json"
    if not yol.exists():
        hata("kisaltmalar.json yok")
        return
    k = json.loads(yol.read_text(encoding="utf-8"))
    balonlu = k.get("kisaltmalar", {})
    disi = set(k.get("bilinen", [])) | set(k.get("ad", []))
    for ad, x in balonlu.items():
        if not (x.get("tr") or "").strip() or not (x.get("en") or "").strip():
            hata(f"kisaltmalar.json · {ad}: açılım iki dilde de dolu değil")
        if ad in disi:
            hata(f"kisaltmalar.json · {ad}: hem balonlu hem bilinen/ad listesinde")
    sayac = 0
    for md in _okur_sayfalari():
        gorulen: set[str] = set()
        for par in metin_parcalari(md.read_text(encoding="utf-8")):
            bicimli = [(m.start(), m.end()) for m in _BICIMLI.finditer(par)]
            for m in KISALTMA_DESENI.finditer(par):
                kis = m.group(1)
                if len(re.sub(r"[^A-ZÇĞİÖŞÜ]", "", kis)) < 2 or kis in gorulen:
                    continue
                if any(a <= m.start() < b for a, b in bicimli):
                    continue
                gorulen.add(kis)
                sayac += 1
                if kis in balonlu or kis in disi or kisaltma_acilmis(par, m.start(), m.end()):
                    continue
                hata(f"{md.name}: '{kis}' sayfada ilk geçtiği yerde açılmıyor — metinde aç "
                     "ya da kisaltmalar.json'a ekle (kural 13)")
    print(f"  · {sayac} ilk geçiş, {len(balonlu)} balonlu kısaltma sınandı")


def _liste_yapisi(md: str, ad: str) -> list[int]:
    satirlar = md.split("\n")
    yapi: list[int] = []
    for i, satir in enumerate(satirlar):
        t = satir.strip()
        if not t.startswith("- "):
            continue
        if satir != satir.lstrip():
            hata(f"{ad}:{i + 1}: iç içe liste yok — madde satır başında")
        onceki = satirlar[i - 1].strip() if i > 0 else ""
        sonraki = satirlar[i + 1].strip() if i + 1 < len(satirlar) else ""
        if not onceki.startswith("- "):
            if onceki:
                hata(f"{ad}:{i + 1}: listeden önce boş satır yok (kural 14)")
            yapi.append(0)
        yapi[-1] += 1
        if sonraki and not sonraki.startswith("- "):
            hata(f"{ad}:{i + 1}: listeden sonra boş satır yok (kural 14)")
    return yapi


def sina_listeler() -> None:
    """Kural 14: liste biçimi ve iki dilde aynı liste yapısı."""
    print("\nListeler")
    sayi = 0
    for tr in [*sorted(BOLUMLER.glob("[0-2][0-9]-*.tr.md")), *sorted(TEKNOLOJILER.glob("*.tr.md"))]:
        en = tr.with_name(tr.name.replace(".tr.md", ".en.md"))
        y_tr = _liste_yapisi(tr.read_text(encoding="utf-8"), tr.name)
        y_en = _liste_yapisi(en.read_text(encoding="utf-8"), en.name) if en.exists() else []
        if y_tr != y_en:
            hata(f"{tr.name}: TR ve EN'nin listeleri aynı değil — TR {y_tr}, EN {y_en} (kural 14)")
        sayi += len(y_tr)
    print(f"  · {sayi} liste sınandı")


TERIM_BIRLIGI = [
    (re.compile(r"makine öğrenim", re.I), "“makine öğrenmesi” yazılır"),
    (re.compile(r"(?<![\wçğıöşü])drone(?![\wçğıöşü])", re.I), "“dron” yazılır"),
]
_TIRNAK_ITALIK = re.compile(r'"[^"\n]*"|“[^”\n]*”|(?<!\*)\*[^*\n]+\*(?!\*)')


def sina_terim_birligi() -> None:
    """Kural 15: Türkçe metinde aynı kavram tek adla."""
    print("\nTerim birliği")
    for md in [p for p in _okur_sayfalari() if p.name.endswith(".tr.md")]:
        metin = _TIRNAK_ITALIK.sub(lambda m: " " * len(m.group(0)), md.read_text(encoding="utf-8"))
        for desen, oneri in TERIM_BIRLIGI:
            for m in desen.finditer(metin):
                satir = metin[:m.start()].count("\n") + 1
                hata(f"{md.name}:{satir}: '{m.group(0)}' — {oneri} (kural 15)")
    print("  · tamam")


# ── Kural 16: öne çıkan cümle (madde 6) ───────────────────────────────────

CEKME_KAYDI = BURASI / "cekmeler.json"
CEKME_UZUNLUK = {"tr": (60, 170), "en": (60, 190)}
CEKME_SINIFLARI = {"A", "S"}            # A: kaynaklı rakamlı; S: rakamsız sonuç (ayrı onay)
CEKME_GONDERIM = {
    "tr": set("""Bu Bunlar Bunun Buna Bunu Bunda Bundan Bunlara Şu Şunlar O Onun Ona Onu Onlar Onların
        Aynı Yani Ama Ancak Fakat Oysa Çünkü Ayrıca Dolayısıyla Böylece Yine Üstelik Öte İkisi Birincisi
        İkincisi Üçüncüsü Sonuncusu İlki Sonuç Burada Orada Şimdi Ardından Sonra Hem Ne Asıl Tersine
        Kısacası Öyleyse Bununla Ve Veya Ya""".split()),
    "en": set("""This These That Those It Its They Their Them So But However Yet Because Also Thus
        Therefore Hence Still Moreover Second Third Finally Here There Then Such And Or""".split()),
}
# Telefon ölçüsü (yz_metin_gorunumu.dart, 375 px'lik ekran, 16 px yan pay):
# satırda ~40 harf (17,5 px Newsreader; giriş paragrafı 19,5 px, ~36 harf),
# satır yüksekliği 1,62 (giriş 1,55), paragraf arası 22 (giriş 26); ekran
# 812 - 56 (üst çubuk) = 756 px. Kaba bir ölçü; kuralın amacı yeri metnin
# içinden, ortaya yakın seçmek.
TEL = {"harf": 40, "giris_harf": 36, "satir": 17.5 * 1.62, "giris_satir": 19.5 * 1.55,
       "aralik": 22.0, "giris_aralik": 26.0, "ekran": 756.0}


def gorunen_metin(s: str) -> str:
    """Okurun gördüğü dizgi: ** ve *italik* imleri kalkmış."""
    s = s.replace("**", "")
    return re.sub(r"(?<!\w)\*(?!\s)(.+?)(?<!\s)\*(?!\w)", r"\1", s)


def _satir_sayisi(metin: str, harf: int) -> int:
    n, satir = 0, 0
    for k in gorunen_metin(metin).split():
        if satir == 0 or satir + 1 + len(k) > harf:
            n += 1
            satir = len(k)
        else:
            satir += 1 + len(k)
    return max(1, n)


def tel_yuksekligi(b: dict, giris: bool = False) -> float:
    """Bloğun telefondaki yaklaşık yüksekliği (px)."""
    if b["tur"] == "paragraf":
        if giris:
            return _satir_sayisi(b["metin"], TEL["giris_harf"]) * TEL["giris_satir"] + TEL["giris_aralik"]
        return _satir_sayisi(b["metin"], TEL["harf"]) * TEL["satir"] + TEL["aralik"]
    if b["tur"] == "altBaslik":
        return 44 + 10 + _satir_sayisi(b["metin"], 30) * 21 * 1.14
    if b["tur"] == "liste":
        return 24 + sum(_satir_sayisi(o, TEL["harf"] - 3) * TEL["satir"] + 9 for o in b["ogeler"])
    if b["tur"] == "tablo":
        return 22 + 110 * max(0, len(b["ogeler"]) - 2)
    if b["tur"] in ("gorsel", "grafik"):
        return 360.0
    if b["tur"] == "canli":
        return CANLI_TEL_YUKSEKLIGI
    return 0.0


def kelime_sayisi(s: str) -> int:
    return len(re.findall(r"[^\W_]+", gorunen_metin(s)))


def cumle_siniri_mi(paragraf: str, bas: int, son: int) -> bool:
    """[bas, son) paragrafta tam bir cümle mi: önü paragraf başı ya da bir
    cümle sonu ve boşluk; kendisi cümle sonu imiyle bitiyor, ardı paragraf
    sonu ya da boşluk; parantez ve kalın imleri kendi içinde kapanıyor
    ("(**505.** paragraf)" içindeki sıra noktası cümle sonu değil)."""
    once, cumle = paragraf[:bas], paragraf[bas:son]
    bas_iyi = bas == 0 or bool(re.search(r"[.!?…][\"”’)*]*\s$", once))
    son_iyi = bool(re.search(r"[.!?…][\"”’)*]*$", cumle)) and (son == len(paragraf) or paragraf[son] == " ")
    kapali = cumle.count("(") == cumle.count(")") and cumle.count("**") % 2 == 0
    return bas_iyi and son_iyi and kapali


def _kaynakli_rakamlar(cumle: str, esleme: dict) -> list[str]:
    """Cümlenin kaynağa bağlı (rakamdan kaynağa eşlemesinde olan) kalın rakamları."""
    return [m.group(1) for m in re.finditer(r"\*\*([^*]*\d[^*]*)\*\*", cumle) if m.group(1) in esleme]


def cekme_yerleri(bloklar: list[dict], kaynak: int | None = None) -> list[tuple[int, float, float, int]]:
    """Öne çıkan cümle konabilecek paragraf araları: (j, koşunun ortasına
    uzaklık, koşunun ekranı, koşunun ilk bloğu); j ile j+1 arası. [bloklar] yönergesiz
    (cekme'siz) blok dizisi. Koşu: grafik, görsel, tablo, liste ve alt
    başlıkla kesilen ardışık paragraflar; telefonda 1,0 ekranı aşmalı ve en
    az 2 paragraf. Konmaz: ilk ekran, giriş paragrafının ardı, [kaynak]
    paragrafın bitişiği."""
    giris = 0 if bloklar and bloklar[0]["tur"] == "paragraf" else -1
    yuk = [tel_yuksekligi(b, i == giris) for i, b in enumerate(bloklar)]
    ust = [sum(yuk[:i]) for i in range(len(bloklar) + 1)]
    kosular, bas = [], None
    for i, b in enumerate(bloklar + [{"tur": "son"}]):
        if b["tur"] == "paragraf":
            bas = i if bas is None else bas
        else:
            if bas is not None:
                kosular.append((bas, i - 1))
            bas = None
    cikti = []
    for a, z in kosular:
        boy = ust[z + 1] - ust[a]
        if z == a or boy <= TEL["ekran"]:
            continue
        orta = ust[a] + boy / 2
        for j in range(a, z):
            if ust[j + 1] < TEL["ekran"] or j == giris or kaynak in (j, j + 1):
                continue
            cikti.append((j, abs(ust[j + 1] - orta), boy / TEL["ekran"], a))
    return cikti


def _cekme_konumlari(bloklar: list[dict]) -> list[tuple[str, int]]:
    """(kimlik, önündeki cekme'siz blok sayısı) — iki dilin yer eşitliği için."""
    cikti, n = [], 0
    for b in bloklar:
        if b["tur"] == "cekme":
            cikti.append((b["metin"], n))
        else:
            n += 1
    return cikti


def sina_cekmeler() -> None:
    """Kural 16 (madde 6): öne çıkan cümle."""
    print("\nÖne çıkan cümleler")
    kayit = json.loads(CEKME_KAYDI.read_text(encoding="utf-8")) if CEKME_KAYDI.exists() else {}
    cekmeler = kayit.get("cekmeler", [])
    grafikler = json.loads((BURASI / "grafikler.json").read_text(encoding="utf-8")).get("grafikler", {})
    grafik_yerleri = [g["yer"] for g in grafikler.values() if g.get("yer")]
    import importlib.util
    spec = importlib.util.spec_from_file_location("rakam_kaynaklari_16", BURASI / "rakam_kaynaklari.py")
    rk = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(rk)
    esleme = rk.esle()[0]

    # Tanınmayan yönerge (her sayfa) ve yönergesi olmayan ya da kaydı olmayan cümle.
    kayitli = {c.get("kimlik"): c for c in cekmeler}
    if len(kayitli) != len(cekmeler):
        hata("cekmeler.json: aynı kimlik birden çok")
    kullanilan: dict[str, list[str]] = {}
    for md in [*sorted(BOLUMLER.glob("[0-2][0-9]-*.md")), *sorted(TEKNOLOJILER.glob("*.md"))]:
        for n, satir in enumerate(md.read_text(encoding="utf-8").split("\n"), 1):
            m = YONERGE_SATIRI.fullmatch(satir.strip())
            if m and m.group(1) not in BILINEN_YONERGE:
                hata(f"{md.name}:{n}: tanınmayan yönerge [[{m.group(1)}:…]] (kural 16)")
            if m and m.group(1) == "cekme":
                kullanilan.setdefault(m.group(2), []).append(md.name)
    for k, dosyalar in sorted(kullanilan.items()):
        if k not in kayitli:
            hata(f"[[cekme:{k}]] cekmeler.json'da yok ({', '.join(dosyalar)})")
    sayfa_basina: dict[str, list[dict]] = {}
    for c in cekmeler:
        k = c.get("kimlik", "")
        if not re.fullmatch(r"[a-z0-9-]+", k or ""):
            hata(f"cekmeler.json: kimlik geçersiz {k!r}")
            continue
        if c.get("sinif") not in CEKME_SINIFLARI:
            hata(f"öne çıkan {k}: sınıf {c.get('sinif')!r} (A ya da S)")
        if not all((c.get(d) or "").strip() for d in ("tr", "en")):
            hata(f"öne çıkan {k}: tr ve en cümlesi dolu değil")
            continue
        sayfa_basina.setdefault(c.get("sayfa", ""), []).append(c)

    sayac = 0
    for kod, liste in sorted(sayfa_basina.items()):
        tr = sayfa_dosyasi(kod)
        if tr is None:
            hata(f"cekmeler.json: sayfa çözülemiyor ({kod!r})")
            continue
        en = tr.with_name(tr.name.replace(".tr.md", ".en.md"))
        bl = {"tr": sayfa_bloklari(tr.read_text(encoding="utf-8")),
              "en": sayfa_bloklari(en.read_text(encoding="utf-8"))}
        if _cekme_konumlari(bl["tr"]) != _cekme_konumlari(bl["en"]):
            hata(f"{tr.name}: öne çıkan cümle yönergeleri iki dilde aynı yerde değil")
        yalin = {d: [b for b in bl[d] if b["tur"] != "cekme"] for d in bl}
        bn = bolum_numaralari(yalin["tr"])
        giris = 0 if yalin["tr"] and yalin["tr"][0]["tur"] == "paragraf" else -1
        kelime = sum(kelime_sayisi(b["metin"]) for b in yalin["tr"] if b["tur"] == "paragraf") + \
            sum(kelime_sayisi(o) for b in yalin["tr"] if b["tur"] == "liste" for o in b["ogeler"])
        butce = max(1, round(kelime / 600))
        konumlar = dict(_cekme_konumlari(bl["tr"]))
        if len(konumlar) > butce:
            hata(f"{tr.name}: {len(konumlar)} öne çıkan cümle, en çok {butce} (sayfa {kelime} kelime)")
        dolu_bolum: set[int] = set()
        for c in liste:
            k = c["kimlik"]
            ad = f"öne çıkan {k}"
            sayac += 1
            if k not in konumlar:
                hata(f"{ad}: {tr.name}'de [[cekme:{k}]] yönergesi yok")
                continue
            # Cümle: tam bir kez, bir gövde paragrafının içinde, cümle sınırında.
            kaynak: dict[str, int] = {}
            for d, yol in (("tr", tr), ("en", en)):
                cumle = c[d]
                if yol.read_text(encoding="utf-8").count(cumle) != 1:
                    hata(f"{ad} ({d}): cümle {yol.name}'de tam bir kez geçmiyor")
                    continue
                yer = [(i, b["metin"].index(cumle)) for i, b in enumerate(yalin[d])
                       if b["tur"] == "paragraf" and cumle in b["metin"]]
                if len(yer) != 1:
                    hata(f"{ad} ({d}): cümle bir gövde paragrafının içinde değil")
                    continue
                i, bas = yer[0]
                kaynak[d] = i
                par = yalin[d][i]["metin"]
                if not cumle_siniri_mi(par, bas, bas + len(cumle)):
                    hata(f"{ad} ({d}): başı ya da sonu cümle sınırı değil")
                if i == giris:
                    hata(f"{ad} ({d}): giriş paragrafından alınmış")
                g = gorunen_metin(cumle)
                a, z = CEKME_UZUNLUK[d]
                if not a <= len(g) <= z:
                    hata(f"{ad} ({d}): {len(g)} görünen harf ({a}-{z})")
                ilk = re.split(r"['’\s,;]", re.sub(r"^[*“\"(]+", "", cumle), maxsplit=1)[0]
                if ilk in CEKME_GONDERIM[d]:
                    hata(f"{ad} ({d}): gönderme ya da bağlaçla başlıyor ({ilk!r})")
                if ":" in g or "?" in g:
                    hata(f"{ad} ({d}): iki nokta ya da soru işareti var")
                if SATICI_ETIKETI[d].search(par):
                    hata(f"{ad} ({d}): satıcı/şirket beyanı paragrafından")
                if d == "tr" and any(par.startswith(y) for y in grafik_yerleri):
                    hata(f"{ad}: bir grafiğin `yer` paragrafından (grafik o rakamı gösteriyor)")
                if c.get("sinif") == "A" and not _kaynakli_rakamlar(cumle, esleme.get(kod, {}).get(d, {})):
                    hata(f"{ad} ({d}): A sınıfı ama kaynağa bağlı kalın rakam yok")
            if set(kaynak) != {"tr", "en"}:
                continue
            if kaynak["tr"] != kaynak["en"]:
                hata(f"{ad}: İngilizce cümle aynı sıradaki paragrafta değil")
            rakam = {d: sorted({round(v, 4) for v, _, _ in metin_sayilari(c[d], d)}) for d in ("tr", "en")}
            if rakam["tr"] != rakam["en"]:
                hata(f"{ad}: iki dilin rakamları farklı {rakam['tr']} / {rakam['en']}")
            # Yer: cekme'siz dizide konumlar[k]. ve konumlar[k]-1. bloklar arası.
            j = konumlar[k] - 1
            ks = kaynak["tr"]
            if not (0 <= j and j + 1 < len(yalin["tr"]) and yalin["tr"][j]["tur"] == "paragraf"
                    and yalin["tr"][j + 1]["tur"] == "paragraf"):
                hata(f"{ad}: yönerge iki paragrafın arasında değil")
                continue
            if bn[j] != bn[ks]:
                hata(f"{ad}: yönerge cümlenin alt başlık bölümünde değil")
            if bn[j] in dolu_bolum:
                hata(f"{ad}: aynı alt başlıkta ikinci öne çıkan cümle")
            dolu_bolum.add(bn[j])
            # Bölümdeki grafiklerin rakamı tekrarlanmıyor.
            gosterilen: set[float] = set()
            for i, b in enumerate(yalin["tr"]):
                if b["tur"] == "grafik" and bn[i] == bn[j] and b["metin"] in grafikler:
                    gr = grafikler[b["metin"]]
                    gosterilen |= {round(float(n["deger"]), 4) for n in gr.get("noktalar", [])}
                    gosterilen |= {round(v, 4) for v, _, _ in metin_sayilari(
                        f"{gr['baslik']['tr']}\n{gr['aciklama']['tr']}", "tr")}
            kalin = {round(v, 4) for m in re.finditer(r"\*\*([^*]*\d[^*]*)\*\*", c["tr"])
                     for v, _, _ in metin_sayilari(m.group(1), "tr")}
            if kalin & gosterilen:
                hata(f"{ad}: yanındaki grafiğin rakamını tekrarlıyor ({sorted(kalin & gosterilen)})")
            uygun = cekme_yerleri(yalin["tr"], kaynak=ks)
            bu = [u for u in uygun if u[0] == j]
            if not bu:
                hata(f"{ad}: yer kurala uymuyor (telefonda 1,0 ekranı aşan koşu, ilk ekran, giriş ya da kaynak bitişiği)")
            elif (en_iyi := min((u for u in uygun if u[3] == bu[0][3]), key=lambda u: (u[1], u[0]))[0]) != j:
                hata(f"{ad}: koşunun ortasına en yakın uygun ara değil — "
                     f"«{gorunen_metin(yalin['tr'][en_iyi + 1]['metin'])[:50]}…» paragrafının önü olmalı")
    for k in sorted(set(kayitli) - set(kullanilan)):
        hata(f"öne çıkan {k}: hiçbir metinde yönergesi yok")
    print(f"  · {sayac} öne çıkan cümle sınandı")


# ── Kural 17: Türkiye Dijital Tarım Atlası ────────────────────────────────

def sina_atlas() -> None:
    """Kural 17: atlasın kayıtları metinle ve eşleme dosyasıyla birebir;
    üretilmiş Dart dosyası güncel."""
    print("\nAtlas")
    sp = importlib.util.spec_from_file_location("atlas_uret_k17", BURASI / "atlas_uret.py")
    atlas = importlib.util.module_from_spec(sp)
    try:
        sp.loader.exec_module(atlas)
        k = atlas.kayitlar()            # ızgara: 81 plaka, 81 ayrı hücre (SystemExit)
    except SystemExit as e:
        hata(f"atlas: {e}")
        return
    il = k["iller"]
    metin: dict[str, str] = {}

    def md(ad: str) -> str:
        if ad not in metin:
            metin[ad] = (BOLUMLER / ad).read_text(encoding="utf-8")
        return metin[ad]

    for r in k["dosya"]:
        ad = il[r["il"]]["ad"]
        for dil, cumle, dosya in (("tr", r["tr"], r["dosya_tr"]), ("en", r["en"], r["dosya_en"])):
            if cumle is None:
                continue
            if cumle not in md(dosya):
                hata(f"atlas {dosya}: cümle metinde harfi harfine geçmiyor — {cumle[:60]!r}")
            if r["il"] not in {p for p, _, _ in atlas.il_bul(cumle, en=dil == "en")}:
                hata(f"atlas {dosya}: cümlede {ad} yok — {cumle[:60]!r}")
    esleme = atlas.kurum_dosyasi()
    tr25 = next(BOLUMLER.glob(f"{atlas.DIZIN_NO}-*.tr.md")).name
    en25 = tr25.replace(".tr.md", ".en.md")
    for r in k["dizin"]:
        ad = il[r["il"]]["ad"]
        for kurum, dayanak in zip(r["kurum"], r["dayanak"]):
            if dayanak == "Kuruluş sütunu":
                if [p for p, _, _ in atlas.il_bul(r["il_hucresi_tr"])] != [r["il"]]:
                    hata(f"atlas §25 '{kurum}': {ad} Kuruluş hücresinden okunmuyor")
                continue
            e = esleme["kurumlar"].get(kurum)
            if e is None or e.get("il") != ad or e.get("dayanak") not in esleme["dayanaklar"]:
                hata(f"atlas §25 '{r['ad_tr']}': {kurum} → {ad} eşleme dosyasında (geçerli dayanakla) yok")
        for dil, dosya in (("tr", tr25), ("en", en25)):
            for alan in ("ad", "ek", "aciklama"):
                x = r[f"{alan}_{dil}"]
                if x is not None and f"| {x} |" not in md(dosya):
                    hata(f"atlas {dosya}: '{x[:50]}' bir tablo hücresi değil")
            if f"| {r[f'aciklama_basligi_{dil}']} |" not in md(dosya):
                hata(f"atlas {dosya}: sütun başlığı '{r[f'aciklama_basligi_{dil}']}' tabloda yok")
    for p, v in esleme["kurumlar"].items():
        if v.get("il") not in {x["ad"] for x in il.values()} or v.get("dayanak") not in esleme["dayanaklar"]:
            hata(f"atlas_kurum_ili.json '{p}': il ya da dayanak geçersiz")
    for h in k["dizin_ist"]["hatalar"]:
        hata(f"atlas: {h}")
    if not atlas.CIKIS.exists() or atlas.CIKIS.read_text(encoding="utf-8") != atlas.dart_kaynagi(k):
        hata(f"atlas: {atlas.CIKIS.name} eski — dart_uret.py'yi koştur")
    di = k["dosya_ist"]
    print(f"  · {len(k['dosya'])} dosya, {len(k['dizin'])} dizin kaydı, "
          f"{len({r['il'] for r in k['dosya'] + k['dizin']})} il · İngilizce hizalama "
          f"{di['hizalanan']}/{di['toplam']} · eşlenemeyen kurum {len(k['dizin_ist']['eslenmeyen'])}")


# ── Kural 20: canlı pencere ───────────────────────────────────────────────

# Dart eşi: lib/features/yapay_zeka/presentation/yz_uzaydan_bugun.dart ›
# kYzCanliPencereler (test/yz_uzaydan_bugun_test.dart ikisini karşılaştırıyor).
CANLI_PENCERELER = {"uzaydan-bugun"}
# Canlı pencerenin 375 px'lik telefondaki boyu: harita kenardan kenara (168),
# lejant, tarih, kaydırıcı, künye ve Worldview bağlantısı. Gömülü yazı
# tipleriyle ölçüldü: 461 px (25 Kasım 2026).
CANLI_TEL_YUKSEKLIGI = 460.0


def _canli_konumlari(bloklar: list[dict]) -> list[tuple[str, int]]:
    """(kimlik, önündeki canli'siz blok sayısı) — iki dilin yer eşitliği için."""
    cikti, n = [], 0
    for b in bloklar:
        if b["tur"] == "canli":
            cikti.append((b["metin"], n))
        else:
            n += 1
    return cikti


def sina_canli_pencereler() -> None:
    """Kural 20: canlı pencere yalnız başlık sayfasında, tanınan kimlikle,
    iki dilde aynı yerde, sayfada en çok bir kez; tanımlı her pencere
    kullanılıyor."""
    print("\nCanlı pencereler")
    for md in sorted(TEKNOLOJILER.glob("*.md")):
        for n, satir in enumerate(md.read_text(encoding="utf-8").split("\n"), 1):
            m = YONERGE_SATIRI.fullmatch(satir.strip())
            if m and m.group(1) == "canli":
                hata(f"{md.name}:{n}: canlı pencere teknoloji sayfasında — yalnız başlık sayfası (kural 20)")
    kullanilan: set[str] = set()
    sayac = 0
    for tr in sorted(BOLUMLER.glob("*.tr.md")):
        en = tr.with_name(tr.name.replace(".tr.md", ".en.md"))
        konum = {"tr": _canli_konumlari(sayfa_bloklari(tr.read_text(encoding="utf-8"))),
                 "en": _canli_konumlari(sayfa_bloklari(en.read_text(encoding="utf-8"))) if en.exists() else []}
        if konum["tr"] != konum["en"]:
            hata(f"{tr.name}: canlı pencere yönergeleri iki dilde aynı yerde değil — "
                 f"TR {konum['tr']}, EN {konum['en']} (kural 20)")
        for d, yol in (("tr", tr), ("en", en)):
            kimlikler = [k for k, _ in konum[d]]
            for k in sorted(set(kimlikler)):
                if k not in CANLI_PENCERELER:
                    hata(f"{yol.name}: [[canli:{k}]] tanınmıyor — CANLI_PENCERELER'de yok (kural 20)")
                if kimlikler.count(k) > 1:
                    hata(f"{yol.name}: [[canli:{k}]] sayfada {kimlikler.count(k)} kez — en çok bir (kural 20)")
            kullanilan.update(kimlikler)
        sayac += len(konum["tr"])
    for k in sorted(CANLI_PENCERELER - kullanilan):
        hata(f"canlı pencere {k}: hiçbir metinde yönergesi yok (kural 20)")
    print(f"  · {sayac} canlı pencere sınandı")


# ── Kural 21: Sahadan galerisi ────────────────────────────────────────────

# Galerideki kare başlık içinde de duruyorsa (gorseller.json'da aynı kimlik)
# bu alanlar iki kayıtta AYNI: tek dosya, tek künye.
_DIL_ADI = {"tr": "TR", "en": "EN"}
SAHADAN_ORTAK = ("dosya", "genislik", "yukseklik", "sha256", "kunye", "kaynak",
                 "sayfa_adresi", "gorsel_adresi", "indirme_gunu")


def _gorsel_adres_koku(adres: str) -> str:
    """Görsel adresinin sorgusuz, yüzde kodu çözülmüş hâli: SharePoint'in
    `?RenditionID=` sürümleri aynı dosyadır. Küçültme yok (Türkçe İ tuzağı;
    yüzde kodunun harf büyüklüğünü çözme zaten eşitliyor)."""
    from urllib.parse import unquote
    return unquote(adres.split("?")[0])


def sina_sahadan(su=None) -> None:
    """Kural 21: Sahadan galerisinin kayıtları dosyalarla, gorseller.json'la ve
    metinle tutarlı; üretilmiş Dart dosyası güncel. [su]: sahadan_uret
    modülü (sahadan_test.py yollarını geçici kopyalara çeviriyor)."""
    print("\nSahadan")
    if su is None:
        sp = importlib.util.spec_from_file_location("sahadan_uret_k21", BURASI / "sahadan_uret.py")
        su = importlib.util.module_from_spec(sp)
        sp.loader.exec_module(su)
    if not su.KAYIT.exists():
        hata("sahadan.json yok (kural 21)")
        return
    kareler = su.kareler()
    if not kareler:
        hata("sahadan: kayıt yok (kural 21)")
    gorseller = json.loads(su.GORSELLER.read_text(encoding="utf-8")).get("gorseller", {})
    plaka = su.plakalar()
    depo = su.DEPO
    basliklar = {b["no"] for b in json.loads((BURASI.parent / "iskelet.json").read_text(encoding="utf-8"))["basliklar"]}
    for alan in ("harf", "kimlik", "dosya"):
        degerler = [r.get(alan) for r in kareler]
        for x in sorted({d for d in degerler if degerler.count(d) > 1}, key=str):
            hata(f"sahadan: {alan} '{x}' iki kez (kural 21)")
    merkez = sum(1 for r in kareler if r.get("merkez"))
    if kareler and not 2 <= merkez <= 3:
        hata(f"sahadan: merkez kartı için {merkez} kare işaretli — 2 ya da 3 olmalı (kural 21)")
    for r in kareler:
        kimlik = str(r.get("kimlik") or "")
        ad = f"sahadan {r.get('harf')} {kimlik}"
        g = gorseller.get(kimlik)
        dosya = str(r.get("dosya") or "")
        yol = depo / dosya
        if dosya != f"web/yz/gorsel/{kimlik}.webp" or not yol.exists():
            hata(f"{ad}: dosya yok ya da kimlikle adlanmamış ({dosya!r}) (kural 21)")
        else:
            veri = yol.read_bytes()
            if hashlib.sha256(veri).hexdigest() != r.get("sha256"):
                hata(f"{ad}: sha256 tutmuyor (kural 21)")
            if webp_boyu(veri) != (r.get("genislik"), r.get("yukseklik")):
                hata(f"{ad}: piksel boyu kayıttakiyle aynı değil — dosyada {webp_boyu(veri)} (kural 21)")
        if g is None and not kimlik.startswith("sahadan-"):
            hata(f"{ad}: yalnız galerideki karenin kimliği 'sahadan-' ile başlamalı (kural 21)")
        for a in ("kunye", "kaynak"):
            if not all(str((r.get(a) or {}).get(d) or "").strip() for d in ("tr", "en")):
                hata(f"{ad}: {a} iki dilde de dolu değil (kural 21)")
        kaynak = r.get("kaynak") or {}
        if not str(kaynak.get("tr") or "").startswith("Fotoğraf: ") or \
                not str(kaynak.get("en") or "").startswith("Photo: "):
            hata(f"{ad}: kaynak satırı 'Fotoğraf: <kurum>' / 'Photo: <institution>' değil (kural 21)")
        for a in ("sayfa_adresi", "gorsel_adresi"):
            if not str(r.get(a) or "").startswith("https://"):
                hata(f"{ad}: {a} yok ya da https değil (kural 21)")
        for a in ("indirme_gunu", "tarih"):
            if not re.fullmatch(r"\d{4}-\d{2}-\d{2}", str(r.get(a) or "")):
                hata(f"{ad}: {a} YYYY-AA-GG değil (kural 21)")
        if not str(r.get("ajans_izi") or "").startswith("hayır"):
            hata(f"{ad}: ajans izi 'hayır' değil — ajans fotoğrafı galeriye girmez (kural 21)")
        if r.get("il") is not None and r["il"] not in plaka:
            hata(f"{ad}: il {r['il']!r} ızgaradaki 81 ilden biri değil (kural 21)")
        # Çift dosya yok: aynı görsel gorseller.json'da başka bir DOSYAYLA
        # duruyorsa o kayıt kullanılır. Aynı dosyayı başka kimlikle yeniden
        # kullanmak (teknoloji sayfası) serbest.
        kok = _gorsel_adres_koku(str(r.get("gorsel_adresi") or ""))
        for k, x in gorseller.items():
            if k != kimlik and x.get("dosya") != dosya and \
                    _gorsel_adres_koku(str(x.get("gorsel_adresi") or "")) == kok:
                hata(f"{ad}: aynı görsel gorseller.json'da '{k}' kimliğiyle başka dosyada — "
                     f"çift dosya, o kaydı kullan (kural 21)")
        # Başlık bağlantısı: başlık ve alt başlığı iki dilde metinde.
        no = r.get("baslik")
        if no not in basliklar or no in (29, 30):
            hata(f"{ad}: başlık {no!r} yok ya da başvuru sayfası (kural 21)")
            continue
        bolum = r.get("bolum") or {}
        bloklar: dict[str, list[dict]] = {}
        for d in ("tr", "en"):
            md = next(BOLUMLER.glob(f"{no:02d}-*.{d}.md"), None)
            bloklar[d] = sayfa_bloklari(md.read_text(encoding="utf-8")) if md else []
            if bolum.get(d) and not any(x["tur"] == "altBaslik" and x["metin"] == bolum[d] for x in bloklar[d]):
                hata(f"{ad}: alt başlık {bolum[d]!r} §{no} {_DIL_ADI[d]} metninde yok (kural 21)")
        if g is None:
            continue
        # Başlık içinde de duran kare: gorseller.json'la birebir; yönergesi
        # iki dilde kaydın alt başlığında (bağlantı fotoğrafın yanına açılsın).
        for a in SAHADAN_ORTAK:
            if g.get(a) != r.get(a):
                hata(f"{ad}: '{a}' gorseller.json'daki kayıttan ayrışmış (kural 21)")
        if g.get("sayfa") != f"b{no:02d}":
            hata(f"{ad}: başlık §{no}, gorseller.json'da sayfa {g.get('sayfa')!r} (kural 21)")
        for d in ("tr", "en"):
            bl = bloklar[d]
            bn = bolum_numaralari(bl)
            gi = [i for i, x in enumerate(bl) if x["tur"] == "gorsel" and x["metin"] == kimlik]
            if len(gi) != 1:
                hata(f"{ad}: §{no} {_DIL_ADI[d]} metninde yönergesi {len(gi)} kez — tam bir kez olmalı (kural 21)")
                continue
            alt = next((x["metin"] for x, n in zip(bl, bn) if x["tur"] == "altBaslik" and n == bn[gi[0]]), None)
            if bolum.get(d) != alt:
                hata(f"{ad}: yönerge §{no} {_DIL_ADI[d]} {alt!r} alt başlığında, kayıtta {bolum.get(d)!r} (kural 21)")
    # Artık dosya: hiçbir kayıtta olmayan sahadan-*.webp.
    kayitli = {r.get("dosya") for r in kareler}
    for f in sorted((depo / "web/yz/gorsel").glob("sahadan-*.webp")):
        if f"web/yz/gorsel/{f.name}" not in kayitli:
            hata(f"sahadan: web/yz/gorsel/{f.name} hiçbir kayıtta yok — artık dosya (kural 21)")
    try:
        beklenen = su.dart_kaynagi(kareler)
    except SystemExit:
        beklenen = None                                 # geçersiz il yukarıda yakalandı
    if beklenen is not None and (not su.CIKIS.exists() or su.CIKIS.read_text(encoding="utf-8") != beklenen):
        hata(f"sahadan: {su.CIKIS.name} eski — dart_uret.py'yi koştur (kural 21)")
    print(f"  · {len(kareler)} kare sınandı ({sum(1 for r in kareler if r.get('kimlik') in gorseller)} "
          f"başlık içinde de, {sum(1 for r in kareler if r.get('il'))} ilde, merkez kartında {merkez})")


# ── Kural 18: kaynak karnesi ──────────────────────────────────────────────

KARNE_DART = BURASI.parents[2] / "lib/features/yapay_zeka/data/yz_kaynak_karnesi.g.dart"
# Üretilen satır: `  "b23": YzKarne(0, 4, 3, 0, 0, 20, 20),` — hakemli, kurumsal,
# resmî, satıcı, proje, rakam (TR), rakam (EN). Eksi sayı desene uymaz: o sayfa
# "üretilen dosyada yok" diye yakalanır.
KARNE_SATIRI = re.compile(r'^\s*"([a-z0-9_]+)": YzKarne\((\d+), (\d+), (\d+), (\d+), (\d+), (\d+), (\d+)\),\s*$', re.M)
# Bilerek rakam_kaynaklari.KARNE_NITELIK'ten alınmıyor: karne bağımsız
# yeniden hesaplanıyor.
KARNE_TURU = {"HAKEMLI": 0, "KURUMSAL": 1, "RESMI": 2, "SATICI": 3, "PROJE": 4}


def sina_karne() -> None:
    """Kural 18: üretilen kaynak karnesi kayıtlardan yeniden hesaplanınca aynı."""
    print("\nKaynak karnesi")
    import importlib.util
    spec = importlib.util.spec_from_file_location("rakam_kaynaklari_17", BURASI / "rakam_kaynaklari.py")
    rk = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(rk)
    esleme = rk.esle()[0]
    beklenen: dict[str, tuple[int, ...]] = {}
    for sayfa, diller in esleme.items():
        kayit = json.loads((BURASI / f"{sayfa}_kaynaklar.json").read_text(encoding="utf-8"))
        kaynaklar = kayit.get("kaynaklar", {})
        destek: set[str] = set()
        for kalinlar in diller.values():
            for adaylar in kalinlar.values():
                destek.update(a for a, _ in adaylar)
        say = [0, 0, 0, 0, 0]
        for a in sorted(destek):
            nitelik = (kaynaklar.get(a) or {}).get("nitelik")
            if nitelik not in KARNE_TURU:
                neden = "niteliği yok" if not nitelik else f"niteliği tanınmıyor ({nitelik!r})"
                uyari(f"{sayfa}: «{a}» rakam destekliyor ama {neden} — karnede sayılmadı (kural 18)")
                continue
            say[KARNE_TURU[nitelik]] += 1
        beklenen[sayfa] = (*say, len(diller.get("tr", {})), len(diller.get("en", {})))
    if not KARNE_DART.exists():
        hata(f"{KARNE_DART.name} yok — dart_uret.py koşturulmalı (kural 18)")
        return
    metin = KARNE_DART.read_text(encoding="utf-8")
    uretilen: dict[str, tuple[int, ...]] = {}
    for m in KARNE_SATIRI.finditer(metin):
        if m.group(1) in uretilen:
            hata(f"karne: {m.group(1)} üretilen dosyada iki kez (kural 18)")
        uretilen[m.group(1)] = tuple(int(x) for x in m.groups()[1:])
    girdi = len(re.findall(r'^\s*"[^"]*": YzKarne\(', metin, re.M))
    if girdi != len(uretilen):
        hata(f"karne: {girdi} girdi var, okunabilen {len(uretilen)} — biçim bozuk (kural 18)")
    for sayfa in sorted(set(beklenen) | set(uretilen)):
        if sayfa not in uretilen:
            hata(f"karne: {sayfa} üretilen dosyada yok — dart_uret.py koşturulmalı (kural 18)")
        elif sayfa not in beklenen:
            hata(f"karne: {sayfa} üretilen dosyada var ama rakam eşlemesinde yok (kural 18)")
        elif uretilen[sayfa] != beklenen[sayfa]:
            hata(f"karne: {sayfa} kayıtlardan yeniden hesaplanınca farklı — üretilen {uretilen[sayfa]}, "
                 f"kayıtlar {beklenen[sayfa]}; dart_uret.py koşturulmalı (kural 18)")
    if any(x < 0 for v in uretilen.values() for x in v):
        hata("karne: eksi sayı (kural 18)")
    if not any(sum(v[:5]) >= 1 for v in uretilen.values()):
        hata("karne: hiçbir sayfanın toplamı 1'e ulaşmıyor (kural 18)")
    # Kaynağın türü (mavi rakamın renk noktası): kayıtlardan bağımsız yeniden.
    dort = {0: 0, 1: 1, 2: 2, 3: 3, 4: 3}
    tur_beklenen: dict[str, dict[str, int]] = {}
    for sayfa, diller in esleme.items():
        kaynaklar = json.loads((BURASI / f"{sayfa}_kaynaklar.json").read_text(encoding="utf-8")).get("kaynaklar", {})
        destek = {a for kalinlar in diller.values() for adaylar in kalinlar.values() for a, _ in adaylar}
        tur_beklenen[sayfa] = {
            a: dort[KARNE_TURU[(kaynaklar.get(a) or {}).get("nitelik")]]
            for a in destek if (kaynaklar.get(a) or {}).get("nitelik") in KARNE_TURU
        }
    blok = re.search(r"kYzKaynakTuru = \{\n(.*?)^\};", metin, re.M | re.S)
    if not blok:
        hata(f"{KARNE_DART.name}: kYzKaynakTuru yok — dart_uret.py koşturulmalı (kural 18)")
    else:
        tur_uretilen: dict[str, dict[str, int]] = {}
        sayfa_adi = None
        for satir in blok.group(1).splitlines():
            if m := re.match(r'^  "([a-z0-9_]+)": \{$', satir):
                sayfa_adi = m.group(1)
                tur_uretilen[sayfa_adi] = {}
            elif (m := re.match(r'^    "(.+)": ([0-3]),$', satir)) and sayfa_adi:
                tur_uretilen[sayfa_adi][m.group(1)] = int(m.group(2))
            elif satir.strip() not in ("},", ""):
                hata(f"kaynak türü: okunamayan satır {satir!r} (kural 18)")
        if tur_uretilen != tur_beklenen:
            farkli = sorted(s for s in set(tur_uretilen) | set(tur_beklenen)
                            if tur_uretilen.get(s) != tur_beklenen.get(s))
            hata(f"kaynak türü kayıtlardan yeniden hesaplanınca farklı: {', '.join(farkli[:6])}"
                 f" — dart_uret.py koşturulmalı (kural 18)")
    print(f"  · {len(uretilen)} sayfanın karnesi kayıtlardan yeniden hesaplandı "
          f"({sum(sum(v[:5]) for v in beklenen.values())} sayfa-kaynak çifti); kaynak türleri aynı")


# ── Kural 19: rakamın makbuzu ─────────────────────────────────────────────

def webp_boyu(veri: bytes) -> tuple[int, int] | None:
    """WebP'nin piksel boyu, RIFF başlığından (Pillow'suz)."""
    if len(veri) < 30 or veri[:4] != b"RIFF" or veri[8:12] != b"WEBP":
        return None
    tur = veri[12:16]
    if tur == b"VP8 " and veri[23:26] == b"\x9d\x01\x2a":
        return (int.from_bytes(veri[26:28], "little") & 0x3FFF,
                int.from_bytes(veri[28:30], "little") & 0x3FFF)
    if tur == b"VP8L" and veri[20] == 0x2F:
        b = int.from_bytes(veri[21:25], "little")
        return (b & 0x3FFF) + 1, ((b >> 14) & 0x3FFF) + 1
    if tur == b"VP8X":
        return int.from_bytes(veri[24:27], "little") + 1, int.from_bytes(veri[27:30], "little") + 1
    return None


def sina_makbuz(agir: bool = False, mu=None) -> None:
    """Kural 19: makbuz.json eşlemeyle, kesit dosyalarıyla ve üretilmiş Dart
    dosyasıyla tutarlı; [agir] ise sayfalar PDF'te yeniden bulunuyor. [mu]:
    makbuz_uret modülü (sınama, yolları geçici kopyalara çevrilmiş olarak verir)."""
    print("\nRakamın makbuzu")
    if mu is None:
        sp = importlib.util.spec_from_file_location("makbuz_uret_k19", BURASI / "makbuz_uret.py")
        mu = importlib.util.module_from_spec(sp)
        sp.loader.exec_module(mu)
    if not mu.KAYIT.exists():
        hata("makbuz.json yok — makbuz_uret.py koşturulmalı (kural 19)")
        return
    k = mu.kayitlar()
    kayit = {(r["dosya"], r["alinti"]): r for r in k["kayitlar"]}
    if len(kayit) != len(k["kayitlar"]):
        hata("makbuz: aynı (dosya, alıntı) iki kez (kural 19)")
    cift, eslenemeyen = mu.ciftler()
    for x in eslenemeyen:
        hata(f"makbuz: {x} (kural 19)")

    def ad(c: tuple[str, str]) -> str:
        return f"{Path(c[0]).name} «{c[1][:45]}…»"

    for c in sorted(set(cift) - set(kayit)):
        hata(f"makbuz {ad(c)}: eşlemede var, makbuz.json'da yok — makbuz_uret.py koşturulmalı (kural 19)")
    for c in sorted(set(kayit) - set(cift)):
        hata(f"makbuz {ad(c)}: makbuz.json'da var, eşlemede yok — makbuz_uret.py koşturulmalı (kural 19)")
    nitelik = mu.dosya_nitelikleri()
    ham = mu.ham_ozetler()
    toplam = 0
    adlar: set[str] = set()
    for c, r in kayit.items():
        dosya = c[0]
        if r.get("sha256") != (ham.get(dosya) or {}).get("sha256"):
            hata(f"makbuz {ad(c)}: PDF'in SHA-256'sı ham_kaynaklar.json'dakiyle aynı değil (kural 19)")
        if r.get("nitelik") != sorted(x for x in nitelik.get(dosya, set()) if x):
            hata(f"makbuz {ad(c)}: dosyayı anan kayıtların niteliği değişmiş — makbuz_uret.py (kural 19)")
        s = r.get("sayfa")
        if s is None:
            if not r.get("neden"):
                hata(f"makbuz {ad(c)}: ne sayfa ne bulunamama nedeni var (kural 19)")
            if r.get("kesit"):
                hata(f"makbuz {ad(c)}: sayfa yok ama kesit var (kural 19)")
            continue
        if not isinstance(s, int) or not 1 <= s <= (r.get("sayfa_sayisi") or 0):
            hata(f"makbuz {ad(c)}: sayfa {s!r} belgenin dışında (kural 19)")
        kesitli = mu.kesitli_mi(nitelik.get(dosya))
        if r.get("kesit") and not kesitli:
            hata(f"makbuz {ad(c)}: kesit var ama dosyayı anan bir kayıt {'/'.join(mu.KESITLI)} dışında "
                 f"({', '.join(sorted(str(x) for x in nitelik.get(dosya, set())))}) (kural 19)")
        if kesitli and not r.get("kesit") and not r.get("neden"):
            hata(f"makbuz {ad(c)}: kesitli kaynak ama kesit de neden de yok (kural 19)")
        if not r.get("kesit"):
            continue
        yol = mu.KESITLER / Path(r["kesit"]).name
        m = mu.KESIT_ADI.match(yol.name)
        if r["kesit"] != f"web/yz/makbuz/{yol.name}" or not m or m["kok"] != Path(dosya).stem \
                or int(m["sayfa"]) != s:
            hata(f"makbuz {ad(c)}: kesit adı '{r['kesit']}' <kök>-s<sayfa>-<özet>.webp değil (kural 19)")
            continue
        if not yol.exists():
            hata(f"makbuz {ad(c)}: {r['kesit']} yok — makbuz_uret.py koşturulmalı (kural 19)")
            continue
        veri = yol.read_bytes()
        if hashlib.sha256(veri).hexdigest()[:10] != m["ozet"]:
            hata(f"makbuz {ad(c)}: {yol.name} içeriği adındaki özetle tutmuyor — ad değişmeden çizim "
                 f"değişmiş, önbellek eskisini gösterir (kural 19)")
        if webp_boyu(veri) != (r.get("genislik"), r.get("yukseklik")) or len(veri) != r.get("bayt"):
            hata(f"makbuz {ad(c)}: {yol.name} boyu kayıttakiyle aynı değil (kural 19)")
        toplam += len(veri)
        adlar.add(yol.name)
    if mu.KESITLER.exists():
        for f in sorted(x.name for x in mu.KESITLER.iterdir() if x.name not in adlar):
            hata(f"makbuz: web/yz/makbuz/{f} hiçbir kayıtta yok — artık dosya (kural 19)")
    if toplam > mu.TAVAN_BAYT:
        hata(f"makbuz: kesitler {toplam / 1024 / 1024:.1f} MB, tavan {mu.TAVAN_BAYT / 1024 / 1024:.0f} MB (kural 19)")
    if not mu.CIKIS.exists() or mu.CIKIS.read_text(encoding="utf-8") != mu.dart_kaynagi(k):
        hata(f"makbuz: {mu.CIKIS.name} eski — dart_uret.py'yi koştur (kural 19)")
    o = mu.ozet(k)
    print(f"  · {o['cift']} alıntı · sayfası bulunan {o['sayfa']} · kesitli {o['kesit']} · "
          f"{toplam / 1024 / 1024:.2f} MB")
    if not agir:
        print("  · PDF'te yeniden arama (ağır sınama): --makbuz")
        return
    dosyalar = sorted({d for d, _ in kayit})
    eksik = [d for d in dosyalar if not (BURASI / d).exists()]
    for d in eksik:
        hata(f"makbuz --makbuz: {d} diskte yok — yerel kopya olmadan yeniden aranamaz (kural 19)")
    if eksik:
        return
    for d in dosyalar:
        if mu.sha256(BURASI / d) != (ham.get(d) or {}).get("sha256"):
            hata(f"makbuz --makbuz: {d} SHA-256'sı ham_kaynaklar.json'dakiyle aynı değil (kural 19)")
    yeni = mu.yeniden_bul(k)
    for c, r in kayit.items():
        if yeni.get(c) != r.get("sayfa"):
            hata(f"makbuz --makbuz {ad(c)}: kayıtta s. {r.get('sayfa')}, yeniden aramada s. {yeni.get(c)} (kural 19)")
    print(f"  · ağır sınama: {len(dosyalar)} PDF, {len(kayit)} alıntının sayfası yeniden arandı")


def main() -> int:
    gruplar: dict[str, dict[str, Path]] = {}
    for yol in sorted(BOLUMLER.glob("*.md")):
        m = re.match(r"(\d{2})-[a-z0-9-]+\.(tr|en)\.md$", yol.name)
        if not m:
            hata(f"{yol.name}: ad 'NN-adres.tr.md' biçiminde değil")
            continue
        gruplar.setdefault(m.group(1), {})[m.group(2)] = yol
    # Dosya adındaki adres iskeletteki adresle aynı olmalı: bölüm sayfası
    # dosyayı iskeletten kurduğu adla arıyor; ayrışan ad sessizce boş sayfa.
    iskelet = {b["no"]: b["slug"] for b in json.loads(
        (BURASI.parent / "iskelet.json").read_text(encoding="utf-8"))["basliklar"]}
    for no, dosyalar in gruplar.items():
        for yol in dosyalar.values():
            beklenen = f"{no}-{iskelet.get(int(no), '?')}."
            if not yol.name.startswith(beklenen):
                hata(f"{yol.name}: adres iskeletle tutmuyor — '{beklenen}…' bekleniyordu")
    print(f"{len(gruplar)} bölüm")
    for no, dosyalar in sorted(gruplar.items()):
        if set(dosyalar) != {"tr", "en"}:
            hata(f"§{int(no)}: iki dilden biri eksik ({', '.join(dosyalar)}) — karar 7")
        print(f"\n§{int(no)}")
        if no in URETICI:
            sina_uretilmis(no, dosyalar)
        if no not in SAYI_IZI_YOK:
            sina(no, dosyalar)
        sina_uslup(no, dosyalar)
    sina_teknoloji_sayfalari()
    sina_kesisimler()
    sina_grafikler()
    sina_gorseller()
    sina_kopyalar()
    sina_kisaltmalar()
    sina_listeler()
    sina_terim_birligi()
    sina_cekmeler()
    sina_atlas()
    sina_karne()
    sina_makbuz(agir="--makbuz" in sys.argv[1:])
    sina_canli_pencereler()
    sina_sahadan()
    if uyarilar:
        print(f"\n⚠ {len(uyarilar)} UYARI (durdurmaz)")
    if hatalar:
        print(f"\n✗ {len(hatalar)} HATA")
        return 1
    print("\n✓ Bölüm metinleri kayıtlarıyla birebir")
    return 0


if __name__ == "__main__":
    sys.exit(main())
