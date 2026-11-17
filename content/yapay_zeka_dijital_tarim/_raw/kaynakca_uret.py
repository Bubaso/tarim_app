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
        if en:
            out.append(f"> **Summary.** The **{n}** sources used across the **{bolum_sayisi}** written headings of this file, in alphabetical order. The standing of each figure — peer-reviewed study, institutional report, official document or vendor claim — is stated in the text next to the figure itself, not here. After each source come the headings that use it.")
        else:
            out.append(f"> **Özet.** Bu dosyanın yazılmış **{bolum_sayisi}** başlığında kullanılan **{n}** kaynak, alfabetik sırayla. Her rakamın niteliği (hakemli çalışma, kurumsal rapor, resmî belge ya da satıcı beyanı) metinde rakamın yanında yazıyor, burada değil. Her kaynağın ardından onu kullanan başlıklar geliyor.")
        out.append("")
        harf = None
        kayit_satirlari = []
        for kunye, bag, bolumler in satirlar:
            h = bas_harf(kunye)
            if h != harf:
                harf = h
                out += [f"## {'Other' if en and h == '#' else ('Diğer' if h == '#' else h)}", ""]
            metin = en_cevir(kunye) if en else kunye
            parca = [metin]
            if bag:
                parca.append(bag)
            parca.append("· " + ", ".join(f"§{b}" for b in bolumler))
            satir = " ".join(parca)
            out += [satir, ""]
            kayit_satirlari.append(satir)
        out.append("## How this page is kept up to date" if en else "## Bu sayfa nasıl güncelleniyor")
        out.append("")
        out.append("This list is not written by hand: it is rebuilt from the source records of every heading each time a heading is written or updated. New sources are added after an editor's approval." if en
                   else "Bu liste elle yazılmıyor: bir başlık her yazıldığında ya da güncellendiğinde bütün başlıkların kaynak kayıtlarından yeniden kuruluyor. Yeni kaynak, editör onayından sonra listeye ekleniyor.")
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
