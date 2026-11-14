#!/usr/bin/env python3
"""NASA/TM-20250001897 → ekinler.json — ekin hazırlık düzeyi (CRL) tabloları.

KAYNAK: "Space Crop Considerations for Human Exploration", Temmuz 2024,
Kennedy Uzay Merkezi. 82 sayfa. Ek E'de on üç tablo var.

══ AYRIŞTIRMANIN SINIRI — ÖNCE BU OKUNSUN ══════════════════════════════════
Tablolar dokuz sütunlu (CRL 1-9) ve BOŞ hücreler var. PDF metne
çevrildiğinde boşluklar KONUMUNU KAYBEDİYOR:

    "1 Rosette Red P P P \n \nP \n \nF \n  \nSolanaceae"

Buradan "üç geçti, sonra bir boşluk, sonra geçti, sonra boşluk, sonra kaldı"
okunuyor ama hangi boşluğun hangi DÜZEYE denk geldiği metinden çıkmıyor.
Ekinler sırayla da sınanmıyor — bir ürün CRL 5'i geçip CRL 4'ü atlayabiliyor.

Bu yüzden betik KONUM İDDİA ETMİYOR. Güvenle okunabilen iki şey var:
  1. kültivar adı ve botanik familya
  2. P/F dizisi ve kaç işaret taşıdığı

"DOKUZ İŞARET = CRL 9'U GEÇTİ" ÖLÇÜTÜ DENENDİ VE GEÇERSİZ ÇIKTI. Belgenin
kendi Tablo A-3'ü CRL 9'u geçen dokuz ekini ayrıca sayıyor; çapraz sınama
ikisini tutturamadı:

  · "Waldmann's Green Lettuce" satırında SEKİZ işaret var (CRL 5 hücresi
    boş) ama ekin A-3'te CRL 9 listesinde. Yani bir ürün ara düzeyi boş
    bırakıp dokuzu geçmiş sayılabiliyor.
  · "Cherry Belle Radish" E-7'de ve o tablonun biçimi ötekilerden farklı.

Dolayısıyla CRL 9 listesi ÇIKARIMLA değil, DOĞRUDAN Tablo A-3'ten okunuyor.
E tabloları yalnız ENVANTER veriyor: hangi kültivar denendi, hangi familya,
kaç işaret aldı. Hangi düzeyde kaldığı metinden okunamaz.
═══════════════════════════════════════════════════════════════════════════
"""
from __future__ import annotations
import json, pathlib, re, collections, datetime

KOK = pathlib.Path(__file__).parent
PDF = KOK / "kaynak_dosyalari" / "nasa_space_crops.pdf"

try:
    from pypdf import PdfReader
except ImportError:
    raise SystemExit("pypdf gerekiyor: python3 -m pip install --user pypdf")

metin = "\n".join((s.extract_text() or "") for s in PdfReader(str(PDF)).pages)

TABLO = re.compile(r"Table (E-\d+)\.\s*([^\n]*)")
baslar = [(m.group(1), m.group(2).strip(), m.start()) for m in TABLO.finditer(metin)]
if not baslar:
    raise SystemExit("✗ Ek E tabloları bulunamadı — PDF sürümü değişmiş olabilir")

# ── SATIR AYRIŞTIRMA ─────────────────────────────────────────────────────
# İLK YAZIM YANLIŞTI VE SESSİZCE AZ SAYDI. Kültivar adını `[^\n]{0,60}?`
# ile arıyordu; oysa uzun adlar satır sonuna taşıyor:
#     "5 'Outredgeous' \nLettuce \nP P P P P P P P P Asteraceae"
# Kalıp satır sonunda kopuyor ve o satır HİÇ sayılmıyordu. Sonuç: 297
# kültivar bulundu ama dokuzu tam geçen 1 göründü — oysa belgenin kendi
# Tablo A-3'ü DOKUZ ekin sayıyor. Hata ancak o çapraz sayı sayesinde
# görüldü; betik kendi başına "başardım" diyordu.
#
# Yeni yöntem: tablo gövdesi SIRA NUMARALARINDAN bölünüyor, her dilimin
# sonundaki familya ve P/F işaretleri ayrılıyor, kalan ad sayılıyor.
# ── FAMİLYA SÖZLÜĞÜ, BELGENİN KENDİSİNDEN ───────────────────────────────
# Ek E'nin tamamı önce taranıp belgenin KULLANDIĞI tam familya adları
# toplanıyor. Kırpılmış bir ad ancak bu sözlüğün bir üyesinin ön eki ise
# onarılıyor; sözlük dışarıdan gelmiyor, kaynağın kendi kelime dağarcığı.
TAM_FAMILYA = re.compile(r"\b([A-Z][a-z]+aceae)\b")
# Kırpılmışı da yakalayan gevşek kalıp: "Fabacea", "Asteracea",
# "Chenopodiacea" — PDF metin katmanı son harfi düşürüyor.
FAMILYA_ADAY = re.compile(r"\b([A-Z][a-z]+ace(?:ae|a)|[A-Z][a-z]+acaea)\b")

# KAYNAĞIN KENDİ DİZGİ HATASI. E-12 satır 1'de familya "Fabacaea" yazıyor.
# Bu bir kırpılma değil, harf hatası; ön ek kuralıyla çözülmüyor. Genel bir
# kural uydurmak yerine TEK TEK yazılıyor ki ne onarıldığı görünsün.
KAYNAK_YAZIM_HATASI = {"Fabacaea": "Fabaceae"}

# İŞARETİN BAŞLADIĞI YER. Eski kalıp işaretleri satırın SONUNDAN alıyordu ve
# en çok dokuz tane sayıyordu. Belge Tokyo Bekana satırını kendi eliyle
# kısaltmış — "33 Tokyo Bekana P P P P P P … F P Brassicaceae" — orada
# sondan dokuz işaret alınınca adın içinde "P P P P" kalıyordu; sayfada
# "Tokyo Bekana P P P P P P …" diye göründü. Yeni kural: ad, İLK bağımsız
# P/F damgasında biter.
ISARET_BASI = re.compile(r"(?:(?<=\s)|^)[PF](?=\s|$)")


# TIRNAK TEMİZLİĞİ — İYELİK KESMESİ KORUNUYOR.
# Kaynak kültivar adını eğri tırnakla sarıyor: ‘Outredgeous' lettuce.
# Kalıbın karakter sınıfı AÇILIŞ tırnağını yutuyor ve geriye
# "Outredgeous' lettuce" kalıyordu — sayfada görüldü. İlk düzeltme bütün
# tırnakları sildi ve bu kez "Waldmann's" → "Waldmanns" oldu, yani MEŞRU
# kesme de gitti. Ayrım şu: KAPANIŞ tırnağı boşluktan önce ya da dizge
# sonunda gelir, İYELİK kesmesinin ardından HARF gelir.
def tirnak_temizle(ad: str) -> str:
    ad = re.sub(r"\s+", " ", ad).strip()
    ad = ad.replace("\u2018", "'").replace("\u2019", "'")
    # AÇILIŞ TIRNAĞI YALNIZ DİZGE BAŞINDA ARANIYORDU VE YETMEDİ. Kaynak
    # adı ters çeviriyor: "Mustard, ‘Wasabi’". Burada açılış tırnağı
    # virgülden sonra, dizgenin ORTASINDA; eski kural onu görmüyor,
    # kapanış kuralı da son tırnağı alıyordu. Sayfada "Mustard, 'Wasabi"
    # diye göründü — yirmi iki adda. Ayrım konumda değil KOMŞULUKTA:
    # açılış tırnağının SOLUNDA boşluk ya da dizge başı, SAĞINDA harf var;
    # iyelik kesmesinin SOLUNDA harf var.
    ad = re.sub(r"(?:(?<=\s)|^)'(?=\w)", "", ad)   # açılış tırnağı
    ad = re.sub(r"'(?=\s|$)", "", ad)              # kapanış tırnağı
    return ad.strip()


def ad_temizle(ham: str) -> str:
    """Satır numarasını, sarkan kültivar kodunu ve dipnot işaretini atar."""
    # SIRA NUMARASI. Eski hâli `^\d{1,3}\s*` idi ve HİÇ ÇALIŞMIYORDU: dilim
    # "\n" ile başladığı için çapa rakama değil satır sonuna bakıyordu.
    # Sonuç 395 kültivarın HEPSİNDE adın başında numara kalmasıydı —
    # "1 'Vit Mache" — ve numara öndeyken açılış tırnağı da temizlenmiyordu.
    ad = re.sub(r"^\s*\d{1,3}\s*", "", ham)
    ad = re.sub(r"\s+", " ", ad).strip()
    # SARKAN KÜLTİVAR KODU. Uzun adlar satır sonuna taşıyor ve kod ortadan
    # bölünüyor: "Snap Pea/351-6-\n1" → "351-6- 1". Tire ile rakam arasına
    # giren boşluk kapatılıyor.
    ad = re.sub(r"-\s+(?=\d)", "-", ad)
    ad = tirnak_temizle(ad)
    # DİPNOT İŞARETİ. "'Cherry Belle' Radish1" — sondaki 1 üst simge dipnot
    # numarası. Meşru rakamlar ya ayrı sözcük ("4921", "H-10"), ya tireden
    # ya da parantezden sonra geliyor; küçük harfe YAPIŞIK tek rakam bu
    # derlemede yalnız dipnot işareti.
    ad = re.sub(r"(?<=[a-z])\d$", "", ad).strip()
    return ad


def familya_coz(ham: str, bilinen: list[str]) -> tuple[str | None, str | None]:
    """Kırpılmış familya adını onarır; onaramazsa None döner, uydurmaz."""
    if ham in bilinen:
        return ham, None
    if ham in KAYNAK_YAZIM_HATASI:
        return KAYNAK_YAZIM_HATASI[ham], f"{ham} → {KAYNAK_YAZIM_HATASI[ham]} (kaynakta dizgi hatası)"
    onek = [b for b in bilinen if b.startswith(ham)]
    if len(onek) == 1:
        return onek[0], f"{ham} → {onek[0]} (PDF son harfi düşürmüş)"
    # Belgenin başka yerde tam yazmadığı ad: düşen harf yalnız sondaki "e"
    # ise geri konuyor. "Chenopodiacea" → "Chenopodiaceae". Bu, belgenin
    # KENDİ tutarsızlığı: aynı ürün ailesine başka satırlarda
    # "Amaranthaceae" diyor. Ad DEĞİŞTİRİLMİYOR, yalnız harfi tamamlanıyor.
    if ham.endswith("acea"):
        return ham + "e", f"{ham} → {ham}e (belgede tam hâli hiç geçmiyor)"
    return None, f"{ham} çözülemedi"


def satirlari_ayir(govde: str, bilinen: list[str],
                   gunluk: dict) -> list[dict]:
    # SIRA BEKLENTİSİ. Eski hâli her "\n<rakam> " dizisini yeni satır
    # sanıyordu ve sarkan kültivar kodunu ("…/351-6-\n1 ") satır başı
    # okuyup önceki satırı ORTADAN BÖLÜYORDU; bölünen satırda familya
    # kalmadığı için satır sessizce DÜŞÜYORDU. Ölçüldü: 22 gerçek kültivar
    # böyle kayboldu, E-4'ün 25 baklagilinden yalnız 21'i geliyordu.
    # Tablo numaraları 1'den başlayıp birer artıyor; beklenen sayıyı
    # tutmayan aday artık satır başı sayılmıyor. Ek E'nin sonundaki kaynakça
    # dipnotları da (1'den yeniden başlar) bu kuralla eleniyor.
    adaylar = [(m.start(), int(m.group(1)))
               for m in re.finditer(r"\n\s*(\d{1,3})\s", govde)]
    kabul, bekle = [], 1
    for yer, no in adaylar:
        if no == bekle or no == bekle + 1:
            kabul.append((yer, no))
            bekle = no + 1

    out = []
    for i, (bas, no) in enumerate(kabul):
        son = kabul[i + 1][0] if i + 1 < len(kabul) else len(govde)
        dilim = govde[bas:son]
        # FAMİLYA DİLİMİN SONUNDA DEĞİL, İÇİNDE ARANIYOR. Eski kalıp `$`
        # ile bağlıydı; satırın ardından sayfa altlığı ya da sonraki
        # tablonun başlığı geldiğinde tutmuyor, satır düşüyordu.
        fm = FAMILYA_ADAY.search(dilim)
        kalan = dilim[:fm.start()].rstrip() if fm else dilim.rstrip()
        im = ISARET_BASI.search(kalan)
        if not im:
            gunluk["isaretsiz"].append((no, dilim[:90]))
            continue
        ad = ad_temizle(kalan[:im.start()])
        if not ad:
            gunluk["adsiz"].append((no, dilim[:90]))
            continue
        isaret = re.findall(r"(?:(?<=\s)|^)([PF])(?=\s|$)", kalan[im.start():])
        if fm:
            familya, notu = familya_coz(fm.group(1), bilinen)
            if notu:
                gunluk["familya_onarimi"].append(
                    {"tablo_satiri": no, "kultivar": ad, "not": notu})
            if familya is None:
                gunluk["familyasiz"].append({"tablo_satiri": no, "kultivar": ad})
        else:
            familya = None
            gunluk["familyasiz"].append({"tablo_satiri": no, "kultivar": ad})
        # BELGENİN KENDİ KISALTMASI. Tokyo Bekana satırında "…" var; o
        # satırda kaç işaret olduğu kaynaktan okunamıyor.
        kisaltilmis = "…" in dilim or "..." in dilim
        if kisaltilmis:
            gunluk["kaynakta_kisaltilmis"].append({"tablo_satiri": no, "kultivar": ad})
        out.append({
            "sira": no, "kultivar": ad, "familya": familya,
            "isaretler": "".join(isaret), "isaret_sayisi": len(isaret),
            "isaret_sayisi_guvenilir": not kisaltilmis,
            "kalmis": "F" in isaret,
        })
    return out


# Ek E'nin tamamından belgenin kendi familya dağarcığı çıkarılıyor.
BILINEN_FAMILYA = sorted(set(TAM_FAMILYA.findall(metin[baslar[0][2]:])))

gunluk = {"isaretsiz": [], "adsiz": [], "familya_onarimi": [],
          "familyasiz": [], "kaynakta_kisaltilmis": []}

tablolar, tum = [], []
for i, (kod, baslik, bas) in enumerate(baslar):
    son = baslar[i + 1][2] if i + 1 < len(baslar) else len(metin)
    satirlar = satirlari_ayir(metin[bas:son], BILINEN_FAMILYA, gunluk)
    tablolar.append({"kod": kod, "baslik": baslik,
                     "kultivar_sayisi": len(satirlar), "satirlar": satirlar})
    tum.extend(satirlar)

# ── BELGENİN KENDİ TÜR TÜR SAYIMIYLA ÇAPRAZ SINAMA ──────────────────────
# Belge düzyazıda tablo tablo sayı veriyor: "37 leafy crops, 10 tomato
# plant cultivars, 41 pepper plant cultivars, 16 types of herbs, 25 legume
# cultivars, 67 types of microgreens, 3 strawberry cultivars, 2 cucumber
# cultivars, and 2 melon cultivars". Ayrıştırma bu sayılarla sınanıyor;
# tutmayan tablo SUSTURULMUYOR, çıktıya yazılıyor.
BELGENIN_SAYISI = {"E-1": 37, "E-2": 41, "E-3": 10, "E-4": 25,
                   "E-5": 67, "E-6": 16, "E-7": 7}
capraz = []
for t in tablolar:
    bekleniyor = BELGENIN_SAYISI.get(t["kod"])
    if bekleniyor is None:
        continue
    capraz.append({"tablo": t["kod"], "belgenin_duzyazisi": bekleniyor,
                   "ayristirma": t["kultivar_sayisi"],
                   "tutuyor": bekleniyor == t["kultivar_sayisi"]})

# ── CRL 9 LİSTESİ — Tablo A-3'ten DOĞRUDAN okunuyor ──────────────────────
# Çıkarım denendi ve geçersiz çıktı (bkz. başlıktaki sınır notu). Belge
# listeyi kendisi veriyor; metinden o alınıyor.
#
a3_bas = metin.find("Crops which have passed CRL 9")
if a3_bas < 0:
    raise SystemExit("✗ Tablo A-3 bulunamadı — PDF sürümü değişmiş olabilir")
a3 = metin[a3_bas:a3_bas + 1000]
crl9 = []
for m in re.finditer(r"([A-Z‘'][^\n]{3,46}?)\s+([A-Z][a-z]+(?:aceae|ceae))", a3):
    # SIRA ÖNEMLİ: kategori öneki ÖNCE siliniyor. Ters sırada
    # "Root Zone Crops ‘Cherry Belle’ Radish" adında tırnak temizliği başa
    # bakıyor, baş "Root" olduğu için açılış tırnağı kurtuluyor ve önek
    # silindikten sonra "'Cherry Belle Radish" kalıyordu — sayfada görüldü.
    ad = re.sub(r"^(Leafy Greens|Small Fruit Crops|Root Zone Crops)\s*", "",
                re.sub(r"\s+", " ", m.group(1)).strip())
    ad = tirnak_temizle(ad)
    if ad and ad.lower() not in ("type crop plant family",):
        crl9.append({"kultivar": ad, "familya": m.group(2)})
# TABLONUN "None" SATIRLARI — belgenin en güçlü ifadesi ve ilk okumada
# atlanmıştı. A-3 yalnız geçenleri saymıyor, GEÇMEYEN KATEGORİLERİ de
# açıkça yazıyor: "Herbs None · Microgreens None · Legumes None".
# Yani eksiklik bir çıkarım değil, kaynağın kendi beyanı.
crl9_bos = [m.group(1) for m in re.finditer(r"\n(Herbs|Microgreens|Legumes)\s+None", a3)]

if len(crl9) != 9:
    raise SystemExit(f"✗ Tablo A-3'ten {len(crl9)} ekin okundu, 9 bekleniyordu. "
                     f"Okunanlar: {[c['kultivar'] for c in crl9]}")

# Envanterde A-3'ün ekinleri GERÇEKTEN var mı — ayrıştırma büsbütün
# kaçırmasın diye. Düzey iddiası yok, yalnız varlık sınaması.
eksik = [c["kultivar"] for c in crl9
         if not any(c["kultivar"].split()[-1].lower() in s["kultivar"].lower()
                    for s in tum)]

kalan = [s for s in tum if s["kalmis"]]
fam = collections.Counter(s["familya"] for s in tum if s["familya"])

cikti = {
    "_kaynak": ("NASA/TM-20250001897 · Space Crop Considerations for Human "
                "Exploration · Temmuz 2024 · Kennedy Uzay Merkezi"),
    "_yazarlar": ("Ralph Fritsche (emekli), Natasha Haveman, Gioia Massa, "
                  "Matthew Mickens, Trent Smith, Raymond Wheeler (emekli), "
                  "Bruce Link, LaShelle Spencer"),
    "_nitelik": "BİRİNCİL — NASA teknik memorandumu",
    "_belge": "kaynak_dosyalari/nasa_space_crops.pdf",
    "_cekim": datetime.date.today().isoformat(),
    "_AYRISTIRMA_SINIRI": (
        "Tablolar dokuz sütunlu (CRL 1-9) ve boş hücreler PDF metninde "
        "KONUMUNU KAYBEDİYOR. Betik KONUM İDDİA ETMİYOR: bir ürünün hangi "
        "basamakta kaldığı metinden okunamaz, yalnız 'bir yerde kaldı' "
        "denebilir. "
        "ESKİ NOT ÇÜRÜTÜLDÜ — 'dokuz işaret taşıyan satırda o ürün CRL 9'u "
        "geçmiştir' denmişti. Yanlış: Waldmann marulunun satırında SEKİZ "
        "işaret var (CRL 5 hücresi boş) ama ekin Tablo A-3'teki CRL 9 "
        "listesinde. İşaret sayısı düzeyi VERMİYOR; CRL 9 listesi bu yüzden "
        "A-3'ten doğrudan okunuyor. Konum gerekirse PDF'e bakılacak."),
    "_belgenin_kendi_tutarsizligi": (
        "Belge bir yerde 'only 9 crops have passed CRL 9', Ek E'de 'there are "
        "10 crops that have passed CRL 9' diyor. Tablo A-3'te DOKUZ satır "
        "var. Metin hangi sayıyı kullanırsa kullansın tutarsızlığı söyleyecek."),
    "_crl9_kaynagi": ("Tablo A-3'ten DOĞRUDAN okundu. E tablolarının P/F "
                      "dizisinden ÇIKARILAMAZ — denendi, Waldmann marulu "
                      "sekiz işaretle A-3'te yer aldığı için ölçüt düştü."),
    "envanterde_bulunamayan_crl9": eksik,
    "_SAYIM_AYRISMASI": (
        "ÜÇ SAYI VAR VE ÜÇÜ DE TUTMUYOR. (1) Belgenin kendi toplamı: "
        "'the Growing Beyond Earth program has tested 191 crops and KSC has "
        "tested 204 crops listed above and in Appendix E (total 376)'. "
        "191+204=395, 376 DEĞİL — toplama hatası KAYNAĞIN KENDİSİNDE. "
        "(2) Belgenin tür tür sayımı: 37 yeşillik + 10 domates + 41 biber + "
        "16 ot + 25 baklagil + 67 mikro yeşillik + 3 çilek + 2 salatalık + "
        "2 kavun = 203; aynı belge iki cümle ötede KSC için 204 diyor. "
        f"(3) Tabloların ayrıştırması: {len(tum)} satır. "
        "Ayrıştırma belgenin tür tür sayımıyla YEDİ TABLODAN BEŞİNDE "
        "BİREBİR tutuyor (domates, biber, ot, baklagil, mikro yeşillik). "
        "Tutmayan ikisi: E-7'de ayrıştırma 8, düzyazı 7 diyor — düzyazı "
        "çilek/salatalık/kavun sayıyor ama aynı tablodaki 'Cherry Belle' "
        "turbunu hiç anmıyor, oysa o turp CRL 9'u geçen dokuz ekinden biri. "
        "E-1'de ayrıştırma 38, düzyazı 37 'yeşillik' diyor — tabloda iki "
        "baklagil satırı var ('Dwarf Grey' Sugar Pea ve Kudzu), düzyazının "
        "hangisini yeşillik saymadığı belli değil. "
        "METİN HANGİ SAYIYI KULLANIRSA KULLANSIN bu ayrışmayı söyleyecek."),
    "_SAYIM_KAYNAKLARI": {
        "belgenin_toplami": 376,
        "belgenin_bilesenleri": {"gbe": 191, "ksc": 204, "aritmetik_toplam": 395},
        "belgenin_tur_tur_sayimi": {"yesillik": 37, "domates": 10, "biber": 41,
                                    "ot": 16, "baklagil": 25,
                                    "mikro_yesillik": 67, "cilek": 3,
                                    "salatalik": 2, "kavun": 2, "toplam": 203},
        "ayristirma": len(tum),
    },
    "_CAPRAZ_SINAMA": capraz,
    "_ONARIM_GUNLUGU": gunluk,
    "_ONARIM_NOTU": (
        "Ayrıştırma sessizce satır düşürüyordu ve bu ancak tablo satır "
        "numaraları sırayla sayılınca görüldü: 22 gerçek kültivar kayıptı. "
        "Sebepler ölçüldü ve giderildi — (a) sarkan kültivar kodu satır "
        "başı sanılıyordu, (b) familya yalnız dilim SONUNDA aranıyordu, "
        "(c) PDF metni bazı familya adlarının son harfini düşürüyor. "
        "Onarılan her familya ve familyası okunamayan her satır bu "
        "günlükte tek tek yazılı."),
    "ksc_kultivar": sum(t["kultivar_sayisi"] for t in tablolar
                        if int(t["kod"].split("-")[1]) <= 7),
    "gbe_kultivar": sum(t["kultivar_sayisi"] for t in tablolar
                        if int(t["kod"].split("-")[1]) >= 8),
    "_belgenin_duzyazi_sayisi": {"ksc": "204 (more than)", "gbe": 191, "toplam": 376},
    "tablo_sayisi": len(tablolar),
    "kultivar_sayisi": len(tum),
    "crl9_gecen_sayisi": len(crl9),
    "bir_yerde_kalan": len(kalan),
    "familya_dagilimi": dict(fam.most_common()),
    "crl9_gecenler": crl9,
    "crl9_bos_kategoriler": crl9_bos,
    "_BOS_KATEGORI_NOTU": ("Tablo A-3 geçmeyen kategorileri de açıkça "
                           "yazıyor: Herbs None, Microgreens None, Legumes "
                           "None. Eksiklik çıkarım değil, kaynağın beyanı."),
    "tablolar": tablolar,
}
(KOK / "ekinler.json").write_text(json.dumps(cikti, ensure_ascii=False, indent=1) + "\n",
                                  encoding="utf-8")
print(f"✓ ekinler.json · {len(tablolar)} tablo · {len(tum)} kültivar")
print(f"  Tablo A-3'ten CRL 9: {len(crl9)} ekin · bir yerde kalan: {len(kalan)}")
if eksik:
    print(f"  ⚠ envanterde bulunamayan CRL 9 ekini: {eksik}")
print(f"  familya: {dict(fam.most_common(6))}")
print(f"  tabloda 'None' yazan kategori: {crl9_bos}")
print("\n  CRL 9'u geçenler (Tablo A-3):")
for c in crl9:
    print(f"    {c['kultivar'][:42]:42s} {c['familya']}")
print("\n  tablo tablo:")
for t in tablolar:
    print(f"    {t['kod']:5s} {t['kultivar_sayisi']:3d} kültivar · {t['baslik'][:62]}")
