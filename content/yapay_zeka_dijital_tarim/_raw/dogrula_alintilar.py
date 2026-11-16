#!/usr/bin/env python3
"""
Yapay Zeka ve Dijital Tarım — kaynak kayıtlarının doğrulayıcısı (karar 25/48).

Kayıtlardaki her alıntıyı ve her sayıyı PDF'in KENDİSİNDEN yeniden türetir.
Bir alıntı kaynakta yoksa, bir sayı tutmuyorsa, bir sayfa numarası yanlışsa
ya da bir madde konusuyla ilgisi olmayan bir başlığa bağlanmışsa DURUR.

    python3 dogrula_alintilar.py

Neden: bu bölümün Tur 2'sinde üç kayıt hatası elle yakalandı — "Sorumlu Kurum"
büyük harfle arandığı için yanlış "yok" yazıldı; sulama tedbirleri §7 yerine
§6'ya bağlandı; noktalı i bozulması kelimeleri görünmez yaptı. Üçü de bu
betiğin kurallarından biri olsaydı kendiliğinden yakalanırdı.

Sınanan dosyalar: strateji_karsilastirma.json, yillik_program_2027.json.
Kaynak PDF'ler git'e girmiyor (.gitignore: content/**/_raw/**/*.pdf);
SHA-256'ları content/dossiers/_ortak/ham_kaynaklar.json'da.
"""
from __future__ import annotations

import hashlib
import json
import re
import sys
import unicodedata
from pathlib import Path

try:
    from pypdf import PdfReader
except ImportError:  # python3 -I altında kullanıcı paketleri kapalı
    import site
    sys.path.append(site.getusersitepackages())
    from pypdf import PdfReader

BURASI = Path(__file__).resolve().parent
BOLUM = BURASI.parent
DEPO = BOLUM.parent.parent
KAYIT = DEPO / "content" / "dossiers" / "_ortak" / "ham_kaynaklar.json"

HARF = r"\wçğıöşüâîûÇĞİÖŞÜÂÎÛ"
hatalar: list[str] = []
sayac = {"alinti": 0, "sayi": 0, "sayfa": 0, "bag": 0, "ozet": 0}


def hata(mesaj: str) -> None:
    hatalar.append(mesaj)
    print(f"  ✗ {mesaj}")


# ── metin ────────────────────────────────────────────────────────────────

def onar(metin: str) -> str:
    """PDF çıkarma kusurlarını giderir. Anlamı değiştirmez."""
    metin = unicodedata.normalize("NFKC", metin)       # ﬁ → fi
    metin = metin.replace("/i.dot", "i")                # noktalı i glifi
    metin = re.sub(r"\s+", " ", metin)
    return metin


def sade(metin: str) -> str:
    """Karşılaştırma biçimi: yalnız harf ve rakam, küçük, şapkasız.
    Satır sonu tirelemesi ('yürütü- len'), harf aralığı ('B -R e ç et e')
    ve tırnak/kesme farkları eşleşmeyi bozmasın diye."""
    metin = onar(metin).casefold()
    metin = metin.replace("â", "a").replace("î", "i").replace("û", "u")
    return "".join(c for c in metin if c.isalnum())


_onbellek: dict[Path, list[str]] = {}


def sayfalar(pdf: Path) -> list[str]:
    if pdf not in _onbellek:
        _onbellek[pdf] = [(s.extract_text() or "") for s in PdfReader(str(pdf)).pages]
    return _onbellek[pdf]


def kelime_basi(kok: str) -> re.Pattern:
    return re.compile(rf"(?<![{HARF}]){kok}")


# ── 1. kaynak dosyaların bütünlüğü ──────────────────────────────────────

def butunluk(dosyalar: list[Path]) -> None:
    print("\n1 · Kaynak dosyalar kayıttaki SHA-256 ile aynı mı")
    kayit = {d["yol"]: d for d in json.loads(KAYIT.read_text(encoding="utf-8"))["dosyalar"]}
    for pdf in dosyalar:
        yol = str(pdf.relative_to(DEPO))
        if not pdf.exists():
            hata(f"{yol} diskte yok — kaynak indirilmeden doğrulama yapılamaz")
            continue
        if yol not in kayit:
            hata(f"{yol} ham_kaynaklar.json'da kayıtlı değil")
            continue
        ozet = hashlib.sha256(pdf.read_bytes()).hexdigest()
        if ozet != kayit[yol]["sha256"]:
            hata(f"{yol} SHA-256 değişmiş: {ozet[:12]}… ≠ {kayit[yol]['sha256'][:12]}…")
        else:
            sayac["ozet"] += 1
            print(f"  ✓ {pdf.name}  {ozet[:12]}…")


# ── 2. sağlama: sıfırlar çıkarma kusurundan gelmesin ─────────────────────

def saglama(ad: str, metin: str, en_az_harf: int) -> bool:
    ı_sayisi = metin.count("ı")
    if len(metin) < 10_000 or ı_sayisi < en_az_harf:
        hata(f"{ad}: metin çıkarması şüpheli ({len(metin)} karakter, {ı_sayisi} 'ı') — "
             "SIFIR sonuçlar güvenilmez, gözle oku")
        return False
    print(f"  · sağlama {ad}: {len(metin):,} karakter, {ı_sayisi:,} 'ı' — sayımlar güvenilir")
    return True


# ── 3. ulusal planlar ────────────────────────────────────────────────────

def strateji() -> None:
    print("\n2 · strateji_karsilastirma.json — sayılar planlardan yeniden türetiliyor")
    k = json.loads((BURASI / "strateji_karsilastirma.json").read_text(encoding="utf-8"))

    # 2024-2025
    eski = onar(" ".join(sayfalar(BURASI / k["onceki"]["kaynak_dosyasi"])))
    if saglama("2024-2025 planı", eski, 500):
        for alan, kok in (("tarim_gecis", "[Tt]ar[ıi]m"), ("tarim_ve_orman_gecis", r"Tarım\s+ve\s+Orman")):
            n = len(kelime_basi(kok).findall(eski))
            sayac["sayi"] += 1
            if n != k["onceki"][alan]:
                hata(f"2024-2025 · {alan}: kayıt {k['onceki'][alan]}, kaynak {n}")
            else:
                print(f"  ✓ 2024-2025 · {alan} = {n}")

    # 2026-2030
    y = k["yeni"]
    yeni = onar(" ".join(sayfalar(BURASI / y["kaynak_dosyasi"])))
    if not saglama("2026-2030 planı", yeni, 2_000):
        return
    tarim = list(kelime_basi("[Tt]ar[ıi]m").finditer(yeni))
    baglam = {yeni[max(0, m.start() - 60):m.end() + 60] for m in tarim}
    for ad, kayit, kaynak in (
        ("tarim_gecis_toplam", y["tarim_gecis_toplam"], len(tarim)),
        ("tarim_gecis_benzersiz", y["tarim_gecis_benzersiz"], len(baglam)),
        ("tarim_ve_orman_gecis", y["tarim_ve_orman_gecis"], len(re.findall(r"Tarım\s+ve\s+Orman", yeni))),
        ("ana_sorumlu_alani", y["ana_sorumlu_alani"], len(re.findall(r"Ana\s+sorumlu\s*:", yeni))),
    ):
        sayac["sayi"] += 1
        if kayit != kaynak:
            hata(f"2026-2030 · {ad}: kayıt {kayit}, kaynak {kaynak}")
        else:
            print(f"  ✓ 2026-2030 · {ad} = {kaynak}")

    kokler = {"çiftçi": "[Çç]iftçi|ÇİFTÇİ", "kırsal": "[Kk]ırsal|KIRSAL", "hayvancılık": "[Hh]ayvancılı",
              "ziraat": "[Zz]iraat", "tarla": "[Tt]arla", "sulama": "[Ss]ulama", "hasat": "[Hh]asat",
              "köy": "[Kk]öy"}
    for kelime in y["sifir_kalanlar"]:
        n = len(kelime_basi(f"(?:{kokler[kelime]})").findall(yeni))
        sayac["sayi"] += 1
        if n:
            hata(f"2026-2030 · '{kelime}' sıfır diye kayıtlı ama {n} kez geçiyor")
    print(f"  ✓ 2026-2030 · {len(y['sifir_kalanlar'])} kelime gerçekten sıfır")

    # sorumlu alanlarındaki bakanlıklar — birleşik satır sonu tirelerini kapat
    birlesik = re.sub(rf"([{HARF}])- ([{HARF}])", r"\1\2", yeni)
    # "Başkanlığı," zincire girerse "Savunma Sanayii Başkanlığı, Ticaret" diye tek ad çıkıyor
    kelime = rf"(?!Bakanlığı|Başkanlığı)[A-ZÇĞİÖŞÜ][{HARF}]+"
    bakanlik = re.compile(rf"((?:{kelime},?\s+(?:ve\s+)?){{1,6}})Bakanlığı")
    bulunan: set[str] = set()
    for m in re.finditer(r"Ana\s+sorumlu\s*:", birlesik):
        alan = birlesik[m.end():m.end() + 400]
        ac = alan.find("(")
        alan = alan[:alan.find(")") + 1] if 0 <= ac < 120 else alan[:120]
        bulunan |= {b.group(1).strip().rstrip(",") for b in bakanlik.finditer(alan)}
    beklenen = set(y["sorumlu_alanlarindaki_bakanliklar"])
    sayac["sayi"] += 1
    if bulunan != beklenen:
        hata(f"2026-2030 · sorumlu alanlarındaki bakanlıklar tutmuyor — "
             f"kayıtta olup kaynakta olmayan {sorted(beklenen - bulunan)}, "
             f"kaynakta olup kayıtta olmayan {sorted(bulunan - beklenen)}")
    else:
        print(f"  ✓ 2026-2030 · sorumlu/iş birliği alanlarında {len(bulunan)} bakanlık, Tarım ve Orman yok")

    for yer in y["tarimin_gectigi_yerler"]:
        sayac["alinti"] += 1
        if sade(yer["alinti"]) not in sade(yeni):
            hata(f"2026-2030 · alıntı kaynakta yok: «{yer['alinti'][:70]}…»")
    print(f"  ✓ 2026-2030 · {len(y['tarimin_gectigi_yerler'])} alıntının hepsi kaynakta birebir")


# ── 4. yıllık program ───────────────────────────────────────────────────

# Bir maddeyi bir başlığa bağlayan, maddenin metninde o başlığın konusunu
# taşıyan bir kelime bulunmalı. §6'ya bağlanmış sulama tedbirleri bu kural
# olmadığı için geçmişti. Genel başlıklar (1, 23, 24, 25) her maddeyi alır.
KONU = {
    4: ["toprak", "arazi", "erozyon"],
    7: ["sulama", "suyun", "suyu"],
    8: ["ilaç", "bitki koruma", "reçete"],
    9: ["izleme", "tahmin", "verim"],
    12: ["hayvan", "küpe", "sığır", "büyükbaş", "küçükbaş"],
    15: ["orman", "yangın", "ağaç", "arazi örtüsü"],
    17: ["iklim", "kuraklık", "sigorta", "risk", "erozyon"],
    19: ["uydu", "uzaktan algılama", "harita", "arazi örtüsü"],
    21: ["veri", "kayıt", "bilgi sistem", "istatistik"],
}
GENEL = {1, 23, 24, 25}


def yillik() -> None:
    print("\n3 · yillik_program_2027.json — alıntılar, sayfalar, başlık bağları")
    k = json.loads((BURASI / "yillik_program_2027.json").read_text(encoding="utf-8"))
    pdf = BURASI / k["kunye"]["kaynak_dosyasi"]
    tum = sayfalar(pdf)
    if not saglama("2027 Yıllık Programı", onar(" ".join(tum[160:190])), 2_000):
        return
    baslik_sayisi = len(json.loads((BOLUM / "iskelet.json").read_text(encoding="utf-8"))["basliklar"])

    def bolge(pdf_sayfa: list[int]) -> str:
        sec = sorted({i for p in pdf_sayfa for i in (p - 1, p, p + 1) if 1 <= i <= len(tum)})
        return "\n".join(tum[i - 1] for i in sec)

    def sina(etiket: str, madde: dict, metinler: list[str], basili: int | None, pdf_sayfa: list[int]) -> None:
        alan = bolge(pdf_sayfa)
        alan_sade = sade(alan)
        for m in metinler:
            sayac["alinti"] += 1
            if sade(m) not in alan_sade:
                hata(f"{etiket}: alıntı s.{pdf_sayfa} çevresinde yok: «{m[:70]}…»")
        if basili is not None:
            sayac["sayfa"] += 1
            if not re.search(rf"(?:^|\n)\s*{basili}\s*\n", alan):
                hata(f"{etiket}: basılı sayfa {basili} PDF s.{pdf_sayfa} çevresinde görünmüyor")
        govde = sade(" ".join([madde.get("ad", ""), *metinler]))
        for b in madde.get("basliklar", []):
            sayac["bag"] += 1
            if not 1 <= b <= baslik_sayisi:
                hata(f"{etiket}: §{b} iskelette yok")
            elif b not in GENEL and not any(sade(a) in govde for a in KONU.get(b, [])):
                hata(f"{etiket}: §{b}'ye bağlanmış ama metninde o başlığın konusu yok "
                     f"({', '.join(KONU.get(b, ['tanımsız']))})")

    for m in k["mevcut_durum"]:
        sina(m["kimlik"], m, m["alinti"], m["basili_sayfa"], m["pdf_sayfa"])
    for p in k["politika_ve_tedbirler"]:
        if "politika" in p:
            sina(f"politika {p['kalkinma_plani_politikasi']}", p, [p["politika"]], p["basili_sayfa"], p["pdf_sayfa"])
        for t in p["tedbirler"]:
            metinler = [x for x in (t.get("tedbir"), t.get("sorumlu")) if x] + t["faaliyet"]
            sina(f"tedbir {t['no']}", t, metinler, None, p["pdf_sayfa"])
            if not re.search(rf"Tedbir\s+{re.escape(t['no'])}\.", onar(bolge(p["pdf_sayfa"]))):
                hata(f"tedbir {t['no']}: numara kaynakta yok")
    h = k["hedefler"]
    sina("hedefler", {}, h["gostergeler"], h["basili_sayfa"], h["pdf_sayfa"])
    sayac["sayi"] += 1
    if len(h["gostergeler"]) != 15:
        hata(f"hedefler: 15 gösterge bekleniyordu, kayıtta {len(h['gostergeler'])}")
    for m in k["bolum_disi"]:
        sina(m["kimlik"], m, m["alinti"], m["basili_sayfa"], m["pdf_sayfa"])

    # künye: karar sayısı ve tarih
    sayac["alinti"] += 1
    if sade("Karar Sayısı: 11934") not in sade(" ".join(tum[:30])):
        hata("künye: Cumhurbaşkanı Kararı 11934 ilk 30 sayfada yok")
    print(f"  · {sum(1 for _ in k['mevcut_durum'])} mevcut durum maddesi, "
          f"{sum(len(p['tedbirler']) for p in k['politika_ve_tedbirler'])} tedbir, "
          f"{len(h['gostergeler'])} gösterge, {len(k['bolum_disi'])} bölüm dışı madde sınandı")


def capraz_b23() -> None:
    """§23'ün kilitli kaydındaki her sayı, PDF'ten sınanmış iki kayıtla
    (strateji_karsilastirma.json, yillik_program_2027.json) tutmalı.
    Zincir: PDF → sınanmış kayıt → b23_kaynaklar.json → metin
    (son halkayı dogrula_bolumler.py sınıyor)."""
    yol = BURASI / "b23_kaynaklar.json"
    if not yol.exists():
        return
    print("\n4 · b23_kaynaklar.json — sınanmış kayıtlarla çapraz bağ")
    b = json.loads(yol.read_text(encoding="utf-8"))["kaynaklar"]
    s = json.loads((BURASI / "strateji_karsilastirma.json").read_text(encoding="utf-8"))
    y = json.loads((BURASI / "yillik_program_2027.json").read_text(encoding="utf-8"))
    tedbir = {t["no"]: t for p in y["politika_ve_tedbirler"] for t in p["tedbirler"]}
    durum = {m["kimlik"]: m for m in y["mevcut_durum"]}
    politika = {p["kalkinma_plani_politikasi"] for p in y["politika_ve_tedbirler"]}

    def metinde(parca: str, *metinler: str) -> bool:
        return sade(parca) in sade(" ".join(metinler))

    takis = " ".join(durum["takis"]["alinti"])
    kkydp = " ".join(durum["kkydp_yz_onceligi"]["alinti"])
    denetimler = [
        ("2024-2025 eylem 71", b["uyzs_2024_2025"]["eylem_sayisi"] == 71 and "71 eylem" in s["onceki"]["yapi"]),
        ("2024-2025 bakanlık 11", b["uyzs_2024_2025"]["sorumlu_ve_ilgili_bakanlik_sayisi"] == s["onceki"]["sorumlu_ve_ilgili_bakanlik_sayisi"]),
        ("2024-2025 tarım 0", b["uyzs_2024_2025"]["tarim_gecis"] == s["onceki"]["tarim_gecis"]),
        ("2026-2030 eylem 16", b["yzep_2026_2030"]["eylem_sayisi"] == s["yeni"]["ana_sorumlu_alani"]),
        ("2026-2030 somut bağlam 11", b["yzep_2026_2030"]["tarim_somut_baglam"] == len(s["yeni"]["tarimin_gectigi_yerler"])),
        ("2026-2030 tarım 19", b["yzep_2026_2030"]["tarim_gecis_toplam"] == s["yeni"]["tarim_gecis_toplam"]),
        ("2026-2030 bakanlık 9", b["yzep_2026_2030"]["sorumlu_alanlarindaki_bakanlik_sayisi"] == len(s["yeni"]["sorumlu_alanlarindaki_bakanliklar"])),
        ("2026-2030 Tarım ve Orman 0", b["yzep_2026_2030"]["tarim_ve_orman_gecis"] == s["yeni"]["tarim_ve_orman_gecis"]),
        ("2026-2030 çiftçi/kırsal 0", {"çiftçi", "kırsal"} <= set(s["yeni"]["sifir_kalanlar"])),
        # Parça parça: iki kayıt aynı bilgiyi farklı sırayla yazıyor.
        ("Genelge ve Resmî Gazete", all(metinde(p, s["yeni"]["yururluk"]) and metinde(p, b["yzep_2026_2030"]["yururluk"])
                                        for p in ("2026/9", "18 Ağustos 2026", "33344"))),
        ("program karar 11934", sade(str(b["yillik_program_2027"]["karar_sayisi"])) in sade(y["kunye"]["karar"])),
        ("program Resmî Gazete", metinde(b["yillik_program_2027"]["resmi_gazete"], y["kunye"]["resmi_gazete"])),
        ("politika 489", str(b["yillik_program_2027"]["yz_politikasi_paragraf"]) in politika),
        ("politika 505", str(b["yillik_program_2027"]["sulama_bit_politikasi_paragraf"]) in politika),
        ("makine parkı 14", metinde(f"{b['yillik_program_2027']['makine_parki_orgut_sayisi']} tarımsal üretici örgütü", *tedbir["489.1"]["faaliyet"])),
        ("TAKİS 7 gün", metinde(f"yedi günlük", takis) and b["yillik_program_2027"]["takis_izleme_periyodu_gun"] == 7),
        ("TAKİS 2027", metinde(f"{b['yillik_program_2027']['takis_tahmin_yili']} yılında yapay zekâ", takis)),
        ("TAKİS 1-4 hafta", metinde(b["yillik_program_2027"]["takis_tahmin_ufku"], takis)),
        ("KKYDP %50-70", metinde(f"yüzde {b['yillik_program_2027']['kkydp_hibe_orani_yuzde']}", kkydp)),
        ("KKYDP %20", metinde(f"en az yüzde {b['yillik_program_2027']['kkydp_kadin_genc_payi_en_az_yuzde']}", kkydp)),
        ("KKYDP %30", metinde(f"yüzde {b['yillik_program_2027']['kkydp_aile_isletmesi_payi_yuzde']}", kkydp)),
        ("gösterge 15", b["yillik_program_2027"]["gosterge_sayisi"] == len(y["hedefler"]["gostergeler"])),
        ("B-Reçete 81 il", metinde(f"{b['yillik_program_2027']['b_recete_baslangic']} itibarıyla {b['yillik_program_2027']['b_recete_il']} ilde", *durum["b_recete"]["alinti"])),
        ("toprak etüdü 15 il 3,5 milyon ha", metinde(f"{b['yillik_program_2027']['toprak_etudu_il']} ilde 3,5 milyon hektar", *tedbir["490.1"]["faaliyet"])
                                              and b["yillik_program_2027"]["toprak_etudu_milyon_ha"] == 3.5),
        ("elektronik ölçüm 100 tesis", metinde(f"{b['yillik_program_2027']['elektronik_olcum_tesis']} tesise", *tedbir["504.3"]["faaliyet"])),
    ]
    for ad, tamam in denetimler:
        sayac["sayi"] += 1
        if not tamam:
            hata(f"b23 · {ad}: sınanmış kayıtla tutmuyor")
    print(f"  ✓ {sum(1 for _, t in denetimler if t)}/{len(denetimler)} bağ tutuyor")


_metin_onbellegi: dict[Path, str] = {}


def dosya_metni(yol: Path) -> str:
    """PDF ya da (X)HTML kaynağın düz metni."""
    if yol not in _metin_onbellegi:
        if yol.suffix.lower() == ".pdf":
            _metin_onbellegi[yol] = onar(" ".join(sayfalar(yol)))
        elif yol.suffix.lower() in (".txt", ".json"):
            # API cevabı (Europe PMC, Crossref, OpenAlex) ya da düz metin:
            # JSON'daki kaçışlar çözülsün diye metin olarak değil, değer
            # olarak okunuyor.
            ham = yol.read_text(encoding="utf-8", errors="replace")
            if yol.suffix.lower() == ".json":
                try:
                    ham = " ".join(_json_metinleri(json.loads(ham)))
                except ValueError:
                    pass
            _metin_onbellegi[yol] = onar(html_coz(re.sub(r"<[^>]+>", " ", ham)))
        else:
            ham = yol.read_text(encoding="utf-8", errors="replace")
            ham = re.sub(r"<(script|style)[^>]*>.*?</\1>", " ", ham, flags=re.S)
            _metin_onbellegi[yol] = onar(html_coz(re.sub(r"<[^>]+>", " ", ham)))
    return _metin_onbellegi[yol]


def _json_metinleri(dugum) -> list[str]:
    if isinstance(dugum, str):
        return [dugum]
    if isinstance(dugum, dict):
        return [m for v in dugum.values() for m in _json_metinleri(v)]
    if isinstance(dugum, list):
        return [m for v in dugum for m in _json_metinleri(v)]
    return [str(dugum)] if dugum is not None else []


def html_coz(s: str) -> str:
    import html as _h
    return _h.unescape(s)


def kayit_alintilari() -> None:
    """bNN_kaynaklar.json'larda `dosya` + `alinti` taşıyan her kaynak:
    alıntılar belgenin kendisinde BİREBİR geçmeli; dosya kayıtlı olmalı."""
    kayitlar = sorted(BURASI.glob("b[0-9][0-9]_kaynaklar.json"))
    print("\n5 · bölüm kayıtlarındaki alıntılar — belgenin kendisinden")
    kayit = {d["yol"]: d for d in json.loads(KAYIT.read_text(encoding="utf-8"))["dosyalar"]}
    for k in kayitlar:
        veri = json.loads(k.read_text(encoding="utf-8"))
        for ad, kaynak in (veri.get("kaynaklar") or {}).items():
            if not (isinstance(kaynak, dict) and kaynak.get("dosya") and kaynak.get("alinti")):
                continue
            yol = BURASI / kaynak["dosya"]
            if not yol.exists():
                hata(f"{k.name} · {ad}: kaynak dosyası yok ({kaynak['dosya']})")
                continue
            goreli = str(yol.relative_to(DEPO))
            if goreli not in kayit:
                hata(f"{k.name} · {ad}: {goreli} ham_kaynaklar.json'da kayıtlı değil")
            elif hashlib.sha256(yol.read_bytes()).hexdigest() != kayit[goreli]["sha256"]:
                hata(f"{k.name} · {ad}: {yol.name} SHA-256 kayıttakiyle tutmuyor")
            govde = sade(dosya_metni(yol))
            for a in kaynak["alinti"]:
                sayac["alinti"] += 1
                if sade(a) not in govde:
                    hata(f"{k.name} · {ad}: alıntı belgede yok — «{a[:80]}…»")
            print(f"  ✓ {k.name} · {ad}: {len(kaynak['alinti'])} alıntı belgede birebir")


def main() -> int:
    k1 = json.loads((BURASI / "strateji_karsilastirma.json").read_text(encoding="utf-8"))
    k2 = json.loads((BURASI / "yillik_program_2027.json").read_text(encoding="utf-8"))
    butunluk([
        BURASI / k1["onceki"]["kaynak_dosyasi"],
        BURASI / k1["yeni"]["kaynak_dosyasi"],
        BURASI / k1["yeni"]["genelge_dosyasi"],
        BURASI / k2["kunye"]["kaynak_dosyasi"],
    ])
    strateji()
    yillik()
    capraz_b23()
    kayit_alintilari()
    print(f"\n{sayac['alinti']} alıntı · {sayac['sayi']} sayı · {sayac['sayfa']} sayfa numarası · "
          f"{sayac['bag']} başlık bağı · {sayac['ozet']} dosya özeti")
    if hatalar:
        print(f"\n✗ {len(hatalar)} HATA — kayıt kaynakla tutmuyor")
        return 1
    print("\n✓ Kayıtlar kaynakla birebir tutuyor")
    return 0


if __name__ == "__main__":
    sys.exit(main())
