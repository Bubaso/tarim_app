#!/usr/bin/env python3
"""
Yapay Zeka ve Dijital Tarım — §30 Kaynakça üreticisi (karar 15).

    python3 kaynakca_uret.py            # yazar
    python3 kaynakca_uret.py --denetle  # yazmaz; dosyalar güncel değilse çıkış 1

Kaynakça elle yazılmaz: bütün başlıkların kilitli kayıtlarından
(`_raw/bNN_kaynaklar.json`, §30 hariç) kendiliğinden çıkar. Karar 15: "sade
liste" — kaynağın niteliği (hakemli, kurumsal, satıcı beyanı) rakamın
yanında duruyor, burada yok.

KURALLAR
  1. TEKİLLEŞTİRME. Aynı kaynak birden çok başlığın kaydında geçebilir
     (2027 Yıllık Programı on beş kayıtta). DOI, kayıtlı dosya ya da adres
     ortaksa girdiler tek kaynakta birleşir; kaynağın yanına geçtiği
     başlıklar yazılır.
  2. KÜNYE. Birleşen girdilerin en uzun künyesi seçilir: kayıtlar arasında
     en dolu olanı odur (ör. "2027 Yılı ... Programı" yerine Resmî Gazete
     tarih ve sayısıyla).
  3. BAĞLANTI. DOI varsa https://doi.org/…, yoksa kaydın adresi, o da yoksa
     kaynak deposunun (`_ortak/ham_kaynaklar.json`) indirme adresi.
  4. DAYANAKSIZ GİRDİ GİRMEZ. DOI'si, dosyası ve adresi olmayan girdi (ör.
     henüz yayımlanmamış bir belgenin kaydı) kaynak değildir.
  5. İKİ DİL. Künye özgün dilinde kalır; İngilizce sayfada yalnız sık geçen
     açıklama sözcükleri ve ay adları çevrilir. Rakamlar iki sayfada aynı.
"""
from __future__ import annotations

import json
import re
import sys
import unicodedata
from pathlib import Path

RAW = Path(__file__).resolve().parent
BOLUMLER = RAW.parent / "bolumler"
KAYIT_DEPOSU = RAW.parents[1] / "dossiers" / "_ortak" / "ham_kaynaklar.json"
DEPO_KOKU = RAW.parents[2]

# Türk alfabesi + İngilizce adlar için q, w, x (yerleri Latin sırasında)
ALFABE = "abcçdefgğhıijklmnoöpqrsştuüvwxyz"

AYLAR = {"Ocak": "January", "Şubat": "February", "Mart": "March", "Nisan": "April",
         "Mayıs": "May", "Haziran": "June", "Temmuz": "July", "Ağustos": "August",
         "Eylül": "September", "Ekim": "October", "Kasım": "November", "Aralık": "December"}

# İngilizce sayfada çevrilen açıklama kalıpları (künyenin başlık kısmına
# dokunulmaz; bunlar kayıtlarda parantez içinde ya da sonda duran notlar).
EN_KALIPLAR = [
    # Kurum ve yer adları (Türkçe yazılmış yabancı adlar özgün adlarına döner)
    (r"\bAvrupa Parlamentosu ve Konsey\b", "European Parliament and Council"),
    (r"\bAvrupa Komisyonu\b", "European Commission"),
    (r"\bAvrupa Parlamentosu\b", "European Parliament"),
    (r"\(Avrupa tarım makineleri sanayi birliği\)", "(European agricultural machinery industry association)"),
    (r"\(Durum belgesi\.\)", "(Position paper.)"),
    (r"\(ABD Siber Güvenlik ve Altyapı Güvenliği Ajansı\)", "(US Cybersecurity and Infrastructure Security Agency)"),
    (r"\(ABD Federal Soruşturma Bürosu\)", "(US Federal Bureau of Investigation)"),
    (r"\(ABD Jeoloji Araştırmaları Kurumu\)", "(US Geological Survey)"),
    (r"ABD İflas Mahkemesi, Teksas Güney Bölgesi", "US Bankruptcy Court for the Southern District of Texas"),
    (r"\bDava No\.", "Case No."),
    (r"^Çin Devlet İnternet Bilgi Ofisi", "Cyberspace Administration of China"),
    (r"\) ve Tarım ve Köy İşleri Bakanlığı \(", ") and Ministry of Agriculture and Rural Affairs ("),
    (r"\[Çin Dijital Köy Gelişim Raporu 2019–2025\]", "[China Digital Village Development Report 2019–2025]"),
    (r"^Çin Tarım ve Köy İşleri Bakanlığı \(农业农村部\) Pazar ve Bilişim Dairesi",
     "Ministry of Agriculture and Rural Affairs of China (农业农村部), Department of Market and Information Technology"),
    (r"\bMARA Basın Ofisi\b", "MARA Press Office"),
    (r"Tarım ve Çiftçi Refahı Bakanlığı", "Ministry of Agriculture and Farmers Welfare"),
    (r"\(Rajya Sabha yazılı yanıtı\)", "(Rajya Sabha written reply)"),
    (r"Paris: Uluslararası Enerji Ajansı", "Paris: International Energy Agency"),
    (r"FAO Yüksek Düzeyli Uzmanlar Forumu \(Roma, (12-13 [A-Za-z]+ 2009)\) için arka plan belgesi",
     r"Background paper for the FAO High-Level Experts Forum (Rome, \1)"),
    (r"\(AU Yürütme Konseyi 45\. olağan oturumu, Akra, (18–19 [A-Za-z]+ 2024)'te kabul\)",
     r"(adopted at the 45th ordinary session of the AU Executive Council, Accra, \1)"),
    (r"\bRoma\b", "Rome"),
    (r"\bPekin\b", "Beijing"),
    (r"\bBrüksel\b", "Brussels"),
    (r"\bYeni Delhi\b", "New Delhi"),
    (r"\bFAO ve ITU\b", "FAO and ITU"),
    (r"\) ve GFRAS \(", ") and GFRAS ("),
    (r"\) ve Dalberg Advisors", ") and Dalberg Advisors"),
    (r"\bStart-Up Nation Central ve GrowingIL\b", "Start-Up Nation Central and GrowingIL"),
    (r"\bve ark\.", "et al."),
    # Belge türü ve künye notları
    (r"^6698 sayılı Kişisel Verilerin Korunması Kanunu\. Kabul (\S+); Resmî Gazete (\S+)\.",
     r"Law No. 6698 on the Protection of Personal Data (Kişisel Verilerin Korunması Kanunu). Adopted \1; Resmî Gazete (Official Gazette) \2."),
    (r"\(Yürürlük: (\d{4}/\d+) sayılı Cumhurbaşkanlığı Genelgesi\.\)", r"(In force under Presidential Circular No. \1.)"),
    (r"\bBakanlar Kurulu Kararı\b", "Council of Ministers Decision"),
    (r"Yönetmelik \(Konya Gıda ve Tarım Üniversitesinden\)", "Regulation (from Konya Food and Agriculture University)"),
    (r"\(AB Makine Tüzüğü\), Ek III tanımları", "(EU Machinery Regulation), Annex III definitions"),
    (r"\(IBRD Kredisi (\S+)\): (\S+) dönemi bağımsız denetim raporu\. Tarım ve Orman Bakanlığı sitesinde yayımlandı\.",
     r"(IBRD Loan \1): independent audit report for \2. Published on the Ministry of Agriculture and Forestry website."),
    (r"\(TÜBİTAK sitesinde\)", "(on TÜBİTAK's website)"),
    (r"— teknik ister dokümanı", "— technical requirements document"),
    (r"\(2021-2025 stratejisinin eylem planı\)", "(action plan of the 2021-2025 strategy)"),
    (r"\(Bakanlığın 'Stratejik Plan' sayfasındaki bağlantı\)", "(link on the ministry's 'Stratejik Plan' page)"),
    (r"\(Grup Başkanı: ", "(Group chair: "),
    (r"İlk kabul (\d+ \S+ \d{4}); 'AI system' tanımı (\d+ \S+ \d{4})'te, Tavsiye (\d+ \S+ \d{4})'te revize edildi\.",
     r"First adopted \1; the 'AI system' definition was revised on \2 and the Recommendation on \3."),
    (r"\(basılı sürüm © OECD (\d{4})\)", r"(print version © OECD \1)"),
    (r"\(([A-Za-z]+ \d{4})'te revize edildi\)", r"(revised \1)"),
    (r"makalesinin kurumsal özeti\]", "— institutional summary of the article]"),
    (r"Kitap bölümü (\d+) \(s\. (\d+) vd\.\)", r"Book chapter \1 (pp. \2 ff.)"),
    (r"\byayın no\.", "publication no."),
    (r"Ülke Bazında Öne Çıkan Yatırımlar", "Country Investment Highlights"),
    (r"\(FAO Yatırım Merkezi ve EBRD ortak çalışması\)", "(joint work of the FAO Investment Centre and EBRD)"),
    (r"Sözlük \(Glossary\) s\. ", "Glossary, pp. "),
    (r"Wageningen UR proje broşürü", "Wageningen UR project brochure"),
    (r"\(görev sayfası; LACIE bölümü\)", "(mission page; LACIE section)"),
    (r"\(görev sayfası\)", "(mission page)"),
    (r"\(Sık sorulan sorular\)", "(Frequently asked questions)"),
    (r"\bresmî sitesi\b", "official website"),
    (r"' sayfası \((\d{4}–\d{4}) dereceler\)", r"' page (\1 rankings)"),
    (r"— ürün sayfası", "— product page"),
    (r"\byetkinlik merkezi sayfası\b", "competence centre page"),
    (r"\bprogram sayfası\b", "programme page"),
    (r"— metaveri\b", "— metadata"),
    (r"\((?:haber|news); AI Tomorrow Summit (\d{4}) konuşması\)", r"(news; AI Tomorrow Summit \1 speech)"),
    (r"\(Türkçe\)", "(Turkish)"),
    (r"\b1\. baskı\b", "1st edition"),
    (r"\bBülten No\b", "Bulletin No"),
    (r"\bHaber, (?=\d)", "News, "),
    (r"\(yönlendirme: ", "(redirects to: "),
    (r"\(sayfa: ", "(page: "),
    (r"\(liste sayfası: ", "(list page: "),
    (r"(\d{1,2}\.\d{1,2}\.\d{4})'(?:da|de|ta|te) indirildi", r"downloaded \1"),
    (r"\biçerik tarihsiz\b", "content undated"),
    (r"\bdeğişikliklerle konsolide metin\b", "consolidated text with amendments"),
    (r"\bÖzel Sayı\b", "Special Issue"),
    (r"— bölüm (\d)", r"— section \1"),
    (r"\bbölüm (\d)", r"section \1"),
    (r"\(TARBİL bölümü\)", "(TARBİL section)"),
    (r"\(özet\)", "(abstract)"),
    (r", s\. (\d+[-–]\d+)\.", r", pp. \1."),
    (r", s\. (\d+)\.", r", p. \1."),
    (r"\(haber\)", "(news)"),
    (r"\(duyuru\)", "(announcement)"),
    (r"\(haber; ", "(news; "),
    (r"\bBakanlık haberi\b", "Ministry news"),
    (r"\bÜniversite haber sayfası\b", "University news page"),
    (r"\bhaber sayfası\b", "news page"),
    (r"\bhaber bülteni\b", "press release"),
    (r"\bliste sayfası\b", "list page"),
    (r"\bhaberi,", "news,"),
    (r"\bErişim\b", "Accessed"),
    (r"\(Avrupa Orta Vadeli Hava Tahminleri Merkezi\)", "(European Centre for Medium-Range Weather Forecasts)"),
    (r"\bşirket basın bülteni\b", "company press release"),
    (r"\bşirket duyurusu\b", "company announcement"),
    (r"\bşirket blog yazısı\b", "company blog post"),
    (r"\bşirketin talep ve bildirim ajanı\b", "the company's claims and noticing agent"),
    (r"\btalep ajanı\b", "claims agent"),
    (r"\bİnternet Arşivi kopyası\b", "Internet Archive copy"),
    (r"\bUNT Kütüphaneleri web arşivi kopyası\b", "UNT Libraries web archive copy"),
    (r"\bFarms\.com'da yeniden yayımlandı\b", "republished by Farms.com"),
    (r"\bana sayfa\b", "home page"),
    (r"\berişim\b", "accessed"),
    (r"\bdava bilgi sayfası\b", "case information page"),
    (r"\biflas \(insolvency\) sayfası\b", "insolvency page"),
    (r"\bBirleşik Krallık şirketler sicili\b", "UK companies register"),
    (r"\bkonsolide metin\b", "consolidated text"),
    (r"\bdeğişikliklerle\b", "with amendments"),
    (r"\bson değişiklik\b", "last amended"),
    (r"\bson güncelleme\b", "last updated"),
    (r"\bsayfa güncellemesi\b", "page update"),
    (r"\bbilgi notu\b", "information note"),
    (r"\barka plan notu\b", "background note"),
    (r"\bYayın duyurusu\b", "Release notice"),
    (r"\btarihsiz\b", "undated"),
    (r"\bindirildi\b", "downloaded"),
    (r"\bYayın No\b", "Publication No"),
    (r"\bSayı(?=\s*:?\s*\d)", "Issue"),
    (r"\bsayı(?=\s*:?\s*\d)", "issue"),
    (r"\bMükerrer\b", "repeat issue"),
]


def kucult(s: str) -> str:
    """Türkçe küçültme (I → ı, İ → i); `.lower()` doğrudan çağrılmaz."""
    return s.replace("I", "ı").replace("İ", "i").lower()


def _harf_sirasi(c: str):
    """Alfabedeki sıra; aksanlı Latin harf (é, ł, ñ) temel harfine iner, Türkçe
    harfler (ç, ğ, ı, ö, ş, ü) kendi yerinde kalır. Rakam harften önce,
    alfabe dışı yazı (Çince) en sonda; boşluk her harften önce."""
    if c == " ":
        return 0
    if c in ALFABE:
        return 20 + ALFABE.index(c)
    if c.isdigit():
        return 1 + int(c)
    taban = unicodedata.normalize("NFKD", c)[:1]
    if taban in ALFABE:
        return 20 + ALFABE.index(taban)
    return 1000 + ord(c) if c.isalnum() else None


def siralama_anahtari(kunye: str):
    k = kucult(kunye)
    return [s for s in (_harf_sirasi(c) for c in k[:80]) if s is not None]


def bas_harf(kunye: str) -> str:
    for c in kucult(kunye):
        taban = c if c in ALFABE else unicodedata.normalize("NFKD", c)[:1]
        if taban in ALFABE:
            return {"i": "İ", "ı": "I"}.get(taban, taban.upper())
        if c.isalnum():
            return "#"
    return "#"


def en_cevir(s: str) -> str:
    for desen, yerine in EN_KALIPLAR:
        s = re.sub(desen, yerine, s)
    for tr, en in AYLAR.items():
        s = re.sub(rf"(?<=\d )({tr})\b", en, s)
        s = re.sub(rf"\b{tr}(?= \d{{4}})", en, s)
    return s


def adres_normal(a: str) -> str:
    a = a.strip()
    a = re.sub(r"^https?://", "", a)
    return a.rstrip("/").lower()


def girdileri_oku():
    girdiler = []
    for yol in sorted(RAW.glob("b[0-9][0-9]_kaynaklar.json")):
        no = int(yol.name[1:3])
        if no == 30:
            continue
        kayit = json.loads(yol.read_text(encoding="utf-8"))
        for anahtar, k in kayit.get("kaynaklar", {}).items():
            if not isinstance(k, dict):
                continue
            adres = k.get("adres") if str(k.get("adres", "")).startswith("http") else None
            if not (k.get("doi") or k.get("dosya") or adres):
                continue  # kural 4
            girdiler.append({"no": no, "anahtar": anahtar, "kunye": (k.get("kunye") or "").strip(),
                             "doi": (k.get("doi") or "").strip().lower() or None,
                             "dosya": k.get("dosya"), "adres": adres})
    return girdiler


def birlestir(girdiler):
    """Ortak DOI, dosya ya da adres taşıyan girdileri tek kaynakta toplar."""
    ebeveyn = list(range(len(girdiler)))

    def kok(i):
        while ebeveyn[i] != i:
            ebeveyn[i] = ebeveyn[ebeveyn[i]]
            i = ebeveyn[i]
        return i

    gorulen = {}
    for i, g in enumerate(girdiler):
        for anahtar in (("doi", g["doi"]), ("dosya", g["dosya"]),
                        ("adres", adres_normal(g["adres"]) if g["adres"] else None)):
            if anahtar[1] is None:
                continue
            if anahtar in gorulen:
                ebeveyn[kok(i)] = kok(gorulen[anahtar])
            else:
                gorulen[anahtar] = i
    gruplar = {}
    for i in range(len(girdiler)):
        gruplar.setdefault(kok(i), []).append(girdiler[i])
    return list(gruplar.values())


def depo_adresleri():
    if not KAYIT_DEPOSU.exists():
        return {}
    reg = json.loads(KAYIT_DEPOSU.read_text(encoding="utf-8"))
    cikti = {}
    for x in reg.get("dosyalar", []):
        a = (x.get("kaynak") or {}).get("adres")
        if a and str(a).startswith("http"):
            cikti[x["yol"]] = a
    return cikti


def kaynak_satiri(grup, depo):
    kunye = max((g["kunye"] for g in grup), key=len)
    kunye = kunye if kunye.endswith((".", "!", "?")) else kunye + "."
    doi = next((g["doi"] for g in grup if g["doi"]), None)
    if doi:
        bag = f"https://doi.org/{doi}"
    else:
        adresler = [g["adres"] for g in grup if g["adres"]]
        canli = [a for a in adresler if "web.archive.org" not in a]
        bag = (canli or adresler or [None])[0]
        if bag is None:
            for g in grup:
                yol = f"content/yapay_zeka_dijital_tarim/_raw/{g['dosya']}" if g["dosya"] else None
                if yol and yol in depo:
                    bag = depo[yol]
                    break
    # Künye bağlantıyı zaten taşıyorsa ikinci kez yazılmaz
    if bag and bag in kunye:
        bag = None
    bolumler = sorted({g["no"] for g in grup})
    return kunye, bag, bolumler


def kisa_adlar() -> dict[str, dict[int, str]]:
    """{dil: {no: kısa ad}} — sozluk_uret.kisa_adlar ile aynı kural: başlığın
    iki noktadan önceki kısmı. Okura numara gösterilmiyor (karar 56)."""
    iskelet = json.loads((BOLUMLER.parent / "iskelet.json").read_text(encoding="utf-8"))
    return {dil: {b["no"]: b["baslik"][dil].split(":")[0].strip() for b in iskelet["basliklar"]}
            for dil in ("tr", "en")}


def uret():
    girdiler = girdileri_oku()
    gruplar = birlestir(girdiler)
    depo = depo_adresleri()
    satirlar = [kaynak_satiri(g, depo) for g in gruplar]
    satirlar.sort(key=lambda s: siralama_anahtari(s[0]))
    n = len(satirlar)
    bolum_sayisi = len({no for _, _, b in satirlar for no in b})

    def sayfa(dil):
        en = dil == "en"
        out = ["# 30 · Sources" if en else "# 30 · Kaynakça", ""]
        adlar = kisa_adlar()[dil]
        harf = None
        # Satır metni dile göre; İngilizce sayfa İngilizce metnin kendi
        # sırasıyla dizilir (çevrilen kurum adı başa gelebilir). Kayıttaki
        # satır_tr/satır_en eşleşmesi kaynak numarasına göre kalır.
        metinler = [(en_cevir(k) if en else k) for k, _, _ in satirlar]
        sira = sorted(range(len(satirlar)), key=lambda i: siralama_anahtari(metinler[i])) if en \
            else list(range(len(satirlar)))
        kayit_satirlari = [None] * len(satirlar)
        for i in sira:
            _, bag, bolumler = satirlar[i]
            metin = metinler[i]
            h = bas_harf(metin)
            if h != harf:
                harf = h
                out += [f"## {'Other' if en and h == '#' else ('Diğer' if h == '#' else h)}", ""]
            parca = [metin]
            if bag:
                parca.append(en_cevir(bag) if en else bag)
            parca.append("· " + "; ".join(adlar[b] for b in bolumler))
            satir = " ".join(parca)
            out += [satir, ""]
            kayit_satirlari[i] = satir
        while out and out[-1] == "":
            out.pop()
        return "\n".join(out) + "\n", kayit_satirlari

    tr, tr_satir = sayfa("tr")
    en, en_satir = sayfa("en")
    guncel = max(json.loads(p.read_text(encoding="utf-8")).get("guncellendi", "")
                 for p in RAW.glob("b[0-9][0-9]_kaynaklar.json") if not p.name.startswith("b30"))
    kayit = {
        "_ne": "§30 Kaynakça — ÜRETİLMİŞ kayıt (kaynakca_uret.py). Elle düzenlenmez.",
        "guncellendi": guncel,
        "_kural": "Bütün başlıkların kilitli kayıtlarından tekilleştirilerek üretilir; dogrula_bolumler.py §30'u sayı izine değil, bu üreticinin çıktısına karşı sınar.",
        "kaynak_sayisi": n,
        "bolum_sayisi": bolum_sayisi,
        "kaynaklar": {f"k{i:03d}": {"kunye": s[0], "baglanti": s[1], "bolumler": s[2],
                                     "satir_tr": tr_satir[i], "satir_en": en_satir[i]}
                      for i, s in enumerate(satirlar)},
        "turkiye": {"durum": "yok", "_not": "Kaynakça; Türkiye'ye özgü bir içerik taşımıyor."},
        "_reddedilen": {},
    }
    return tr, en, json.dumps(kayit, ensure_ascii=False, indent=2) + "\n"


HEDEFLER = {"tr": BOLUMLER / "30-kaynakca.tr.md", "en": BOLUMLER / "30-kaynakca.en.md",
            "kayit": RAW / "b30_kaynaklar.json"}


def main() -> int:
    tr, en, kayit = uret()
    yeni = {"tr": tr, "en": en, "kayit": kayit}
    if "--denetle" in sys.argv:
        eski = {k: (p.read_text(encoding="utf-8") if p.exists() else None) for k, p in HEDEFLER.items()}
        farkli = [k for k in yeni if yeni[k] != eski[k]]
        if farkli:
            print(f"✗ §30 güncel değil ({', '.join(farkli)}) — kaynakca_uret.py koşturulmalı")
            return 1
        print("✓ §30 kaynakça kayıtlarla güncel")
        return 0
    for k, p in HEDEFLER.items():
        p.write_text(yeni[k], encoding="utf-8")
    sayi = json.loads(kayit)["kaynak_sayisi"]
    print(f"✓ §30 kaynakça · {sayi} kaynak · {json.loads(kayit)['bolum_sayisi']} başlık")
    return 0


if __name__ == "__main__":
    sys.exit(main())
