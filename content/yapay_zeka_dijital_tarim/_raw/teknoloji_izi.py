#!/usr/bin/env python3
"""
Yapay Zeka ve Dijital Tarım — teknolojilerin metinlerdeki izi.

    python3 -I teknoloji_izi.py            # başlık × teknoloji tablosu
    python3 -I teknoloji_izi.py goruntu    # o teknolojinin geçtiği paragraflar

Merkez sayfadaki teknoloji seçimi (karar 13, çapraz eksen) eskiden elle
konmuş etiketlere bakıyordu: bir başlık teknolojiyi tek cümlede anıp etiket
alabiliyor, tersi de olabiliyordu. Artık etiket metnin kendisinden çıkıyor:
bir teknolojinin desenleri bir başlığın paragraflarında (ve tablo
satırlarında) aranıyor; iki dilde de geçtiği paragraf sayısı eşiği
geçerse başlık o teknolojiyle etiketleniyor. Aynı desenler başlık
sayfasında, seçili teknolojinin geçtiği paragrafları işaretlemek için
Dart'ta da kullanılıyor (`yz_teknoloji_izi.dart`; eşlik testi
`yz_bolum_test.dart`).

DESEN KURALLARI (sözlük eşleştiricisiyle aynı aile, daha basit):
  · küçük harfli desen: kelime başında, büyük-küçük harfe duyarsız (Türkçe
    küçültme: I → ı, İ → i); kelimenin devamı serbest ("robot" →
    "robotun", "robotik").
  · "=" önekli desen: büyük-küçük harfe duyarlı, kelime başında
    ("=IoT", "=Sentinel").
  · `haric`: bu desenlerin içine düşen geçiş sayılmaz ("sohbet robotu"
    robotik değil, dil modeli).
  · kalın parça (**…**) sayılmaz: rakam ve ad vurgusu.
"""
from __future__ import annotations

import json
import re
import sys
from pathlib import Path

BURASI = Path(__file__).resolve().parent
BOLUMLER = BURASI.parent / "bolumler"
ISKELET = BURASI.parent / "iskelet.json"

# Eşik: teknolojinin geçtiği paragraf sayısı (iki dilin küçüğü) bu sayıya
# ulaşırsa başlık o teknolojiyle etiketlenir. Tek bir yan cümle etiket
# vermesin diye 2.
ESIK = 2
IZSIZ = {29, 30}          # sözlük ve kaynakça: her terimi anıyorlar, etiket almıyorlar
YONERGE = re.compile(r"\[\[[a-z]+:[a-z0-9-]+\]\]")   # karar 58, madde 6: yönerge satırı metin değil


def kucult(s: str) -> str:
    return s.replace("I", "ı").replace("İ", "i").lower()


# Desenler burada (tek kaynak); iskelet_uret.py iskelete yazıyor, Dart oradan
# okuyor. Kurallar dosyanın başında.
IZ = {
    "goruntu": {
        "desen_tr": ["görüntü işleme", "görüntü tanıma", "görüntüden", "görüntüde", "görüntülerde",
                     "görüntülerden", "görüntü veri", "yaprak görüntü", "bilgisayarlı görü",
                     "kamera", "fotoğraf", "multispektral görüntüleme", "görüntüyle",
                     "görüntülük", "optik", "yapraktaki belirti"],
        "desen_en": ["image processing", "image recognition", "from images", "in images",
                     "on images", "from an image", "image dataset", "image data set", "leaf images",
                     "computer vision", "camera", "photo", "multispectral imaging",
                     "using images", "image set", "optical", "leaf symptom"],
        "haric_tr": ["uydu görüntü", "optik uydu"],
        "haric_en": ["satellite image", "optical satellite"],
    },
    "tahmin": {
        "desen_tr": ["tahmin", "öngörü model", "erken uyarı"],
        "desen_en": ["forecast", "predict", "early warning"],
        "haric_tr": ["tahminen", "=Hava Tahminleri Merkezi"],
        "haric_en": ["=Medium-Range Weather Forecasts"],
    },
    "uzaktan": {
        "desen_tr": ["uzaktan algılama", "uydu", "=Sentinel", "=Landsat", "=İMECE", "radar"],
        "desen_en": ["remote sensing", "satellite", "=Sentinel", "=Landsat", "=İMECE", "radar"],
        "haric_tr": ["uydu konum"], "haric_en": ["satellite positioning"],
    },
    "robotik": {
        "desen_tr": ["robot", "otonom", "otomatik dümen", "otomatik yönlendirme"],
        "desen_en": ["robot", "autonomous", "autonomy", "auto-steer", "automated guidance"],
        "haric_tr": ["sohbet robot"],
    },
    "sensor": {
        "desen_tr": ["sensör", "nesnelerin interneti", "=IoT", "=LoRaWAN"],
        "desen_en": ["sensor", "internet of things", "=IoT", "=LoRaWAN"],
    },
    "dil": {
        "desen_tr": ["dil model", "sohbet robot", "büyük dil", "=LLM", "yapay zekâ asistan"],
        "desen_en": ["language model", "chatbot", "=LLM", "AI assistant"],
    },
    "karar": {
        "desen_tr": ["karar destek", "tavsiye"],
        "desen_en": ["decision support", "decision-support", "recommendation", "advice engine"],
        "haric_en": ["=Recommendation of the Council"],
    },
    "veri": {
        "desen_tr": ["veri platform", "açık veri", "veri paylaş", "veri alanı", "veri alanları",
                     "veri sahipliğ", "veri tabanı", "verisine erişim", "veriye erişim",
                     "kayıt sistem", "=Veri Tüzüğü"],
        "desen_en": ["data platform", "open data", "data sharing", "data space", "data ownership",
                     "database", "access to the data", "access to data", "registration system",
                     "register", "=Data Act"],
    },
    "genomik": {
        "desen_tr": ["genomik", "ıslah", "genetik"],
        "desen_en": ["genomic", "breeding", "genetic"],
    },
}


# Teknolojinin asıl konu olduğu başlık(lar): merkez sayfada seçilince bu
# karolar dolu, öbür eşleşenler çerçeveli çiziliyor. Elle seçiliyor ama
# sınanıyor: ana başlık eşiği geçmiş, yani metinde gerçekten geçiyor olmalı.
ANA = {
    "goruntu": [8], "tahmin": [9, 17], "uzaktan": [19], "robotik": [10],
    "sensor": [20], "dil": [18], "karar": [], "veri": [21], "genomik": [5],
}


def desenler() -> dict[str, dict]:
    return IZ


def bloklar(md: str) -> list[str]:
    """Paragraflar ve tablo satırları (başlık satırları ve alt başlıklar hariç)."""
    cikti, paragraf = [], []
    for satir in md.splitlines()[1:]:
        t = satir.strip()
        if YONERGE.fullmatch(t):          # [[grafik:…]] / [[gorsel:…]] / [[cekme:…]] / [[canli:…]] ve tanınmayan
            if paragraf:
                cikti.append(" ".join(paragraf))
                paragraf = []
            continue
        if not t or t.startswith("#"):
            if paragraf:
                cikti.append(" ".join(paragraf))
                paragraf = []
            continue
        if t.startswith("|"):
            if paragraf:
                cikti.append(" ".join(paragraf))
                paragraf = []
            if not re.fullmatch(r"\|[\s:|-]+\|?", t):
                cikti.append(t)
            continue
        # Madde listesi (karar 60) tek blok: Dart'taki yzAyristir gibi liste
        # paragraftan ayrı başlıyor ve ilk liste dışı satırda bitiyor.
        liste = t.startswith("- ")
        if paragraf and paragraf[0].startswith("- ") != liste:
            cikti.append(" ".join(paragraf))
            paragraf = []
        paragraf.append(t)
    if paragraf:
        cikti.append(" ".join(paragraf))
    return cikti


def _kalinsiz(metin: str) -> str:
    return re.sub(r"\*\*.+?\*\*", lambda m: " " * len(m.group(0)), metin)


def _kucult(s: str, en: bool) -> str:
    """Uzunluğu koruyan küçültme (Dart'taki _kucult ile aynı): İngilizce
    metinde de "İMECE" gibi adlar var; İ önce i'ye iner."""
    return s.replace("İ", "i").lower() if en else kucult(s)


def _gecisler(metin: str, liste: list[str], en: bool) -> list[tuple[int, int]]:
    kucuk = _kucult(metin, en)
    cikti = []
    for d in liste:
        if d.startswith("="):
            hedef, kaynak = d[1:], metin
        else:
            hedef, kaynak = _kucult(d, en), kucuk
        for m in re.finditer(re.escape(hedef), kaynak):
            if m.start() > 0 and (kaynak[m.start() - 1].isalnum()):
                continue
            cikti.append((m.start(), m.end()))
    return cikti


def geciyor_mu(metin: str, tek: dict, en: bool) -> bool:
    """Blokta teknolojinin sayılan bir geçişi var mı."""
    dil = "en" if en else "tr"
    metin = _kalinsiz(metin)
    haric = _gecisler(metin, tek.get(f"haric_{dil}", []), en)
    for a, b in _gecisler(metin, tek.get(f"desen_{dil}", []), en):
        if not any(ha <= a and b <= hb for ha, hb in haric):
            return True
    return False


def iz() -> dict[int, dict[str, dict[str, int]]]:
    """{no: {teknoloji: {"tr": paragraf sayısı, "en": …}}}"""
    tek = desenler()
    cikti: dict[int, dict[str, dict[str, int]]] = {}
    for yol in sorted(BOLUMLER.glob("[0-3][0-9]-*.md")):
        m = re.match(r"(\d{2})-.*\.(tr|en)\.md$", yol.name)
        no, dil = int(m.group(1)), m.group(2)
        if no in IZSIZ:
            continue
        bl = bloklar(yol.read_text(encoding="utf-8"))
        for kod, t in tek.items():
            n = sum(geciyor_mu(b, t, dil == "en") for b in bl)
            cikti.setdefault(no, {}).setdefault(kod, {})[dil] = n
    return cikti


def etiketler(izler: dict | None = None) -> dict[int, list[str]]:
    """Eşiği geçen teknolojiler, her başlık için (iskeletteki sırayla)."""
    izler = izler if izler is not None else iz()
    sira = list(desenler())
    return {no: [k for k in sira if min(v[k].get("tr", 0), v[k].get("en", 0)) >= ESIK]
            for no, v in izler.items()}


def main() -> int:
    izler = iz()
    tek = desenler()
    if len(sys.argv) > 1:
        kod = sys.argv[1]
        for yol in sorted(BOLUMLER.glob("[0-2][0-9]-*.tr.md")):
            for b in bloklar(yol.read_text(encoding="utf-8")):
                if geciyor_mu(b, tek[kod], False):
                    print(f"§{yol.name[:2]} · {b[:160]}")
        return 0
    kodlar = list(tek)
    print("    " + " ".join(f"{k[:7]:>7}" for k in kodlar))
    for no, v in sorted(izler.items()):
        print(f"§{no:<2} " + " ".join(f"{v[k]['tr']:>3}/{v[k]['en']:<3}" for k in kodlar))
    et = etiketler(izler)
    print("\netiket (eşik %d):" % ESIK)
    for no in sorted(et):
        print(f"  §{no}: {', '.join(et[no]) or '—'}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
