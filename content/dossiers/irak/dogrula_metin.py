#!/usr/bin/env python3
"""Irak — `metin_tr.md` ve `metin_en.md`'yi veri katmanına karşı sınar.

DOKUZ AVCI:
  1. SAYI İZİ — metindeki her rakam veri katmanında karşılık bulmalı. TR ve EN
     kendi biçimleriyle ayrı taranıyor (§8.10/4).
  2. ALINTI İZİ — tırnak içindeki her uzun ibare, veri katmanındaki BAĞLI
     alıntılardan birinin içinde geçmeli. Belge metni ezberden yazılamaz.
  3. META CÜMLE — dosyanın nasıl hazırlandığı metne girmez (§8.11).
  4. REKLAM DİLİ ve ÖLÇÜLMEMİŞ ÜSTÜNLÜK — "en büyük pazar" bu dosyada
     ÖLÇÜLMEDİ (Comtrade ABD ve Fransa için boş dizi dönüyor) ve yazılamaz.
  5. ÇİZİCİNİN TANIMADIĞI BİÇİM — `dossier_prose.dart` yalnızca paragraf,
     `**kalın**`, `*italik*` ve boru işaretli tablo tanıyor. Gövdeye `###`,
     madde işareti ya da bağlantı yazılırsa EKRANA OLDUĞU GİBİ basılır.
  6. ÖLÇEK ÇARPIŞMASI — BU DOSYAYA ÖZGÜ VE EN ÖNEMLİSİ. BM raporu mandayı
     BATAKLIK ölçeğinde sayıyor (80.000 → ~5.000), FAOSTAT ÜLKE ölçeğinde
     (aynı yıl 302.000). İki ölçek AYNI CÜMLEDE geçerse okur manda sayısının
     altmış kat yanlış olduğunu sanır. Cümle cümle taranıyor.
  7. AYNA İSTATİSTİĞİ — ticaretten söz eden bölümler rakamların TÜRKİYE'NİN
     BEYANINDAN olduğunu söylemek zorunda. Irak muhabir olarak rapor vermiyor.
  8. YAPI — on sekiz bölüm, TR ve EN'de aynı numaralar, ardışık.
  9. ALINTI PARİTESİ — İngilizce alıntı çeviri olduğu için kaynak metninde
     bulunmayabilir ve bu DÜŞÜRMEZ, kayda geçer. O muafiyet uydurma alıntıya
     kapı açmasın diye bölüm başına alıntı SAYISI iki dilde aynı olmalı.

NEYİ KANITLAMAZ (§2.2.2): metnin VERİ KATMANINDAN sapmadığını kanıtlar. Veri
katmanı yanlışsa metin ona sadık kalır ve bu denetim yeşil yanar. Kaynak ile
veri arasındaki halkayı `_raw/cikar.py`'nin `bagla()` çağrıları tutuyor.

Çalıştırma: python3 dogrula_metin.py
"""
from __future__ import annotations

import json
import pathlib
import re
import sys
import unicodedata

KOK = pathlib.Path(__file__).parent
veri = json.loads((KOK / 'data.json').read_text(encoding='utf-8'))
hata: list[str] = []
uyari: list[str] = []

# ── Havuz ─────────────────────────────────────────────────────────────────
sayilar: set[float] = set()
metinler: list[str] = []


def topla(o) -> None:
    if isinstance(o, dict):
        for k, v in o.items():
            topla(k); topla(v)
    elif isinstance(o, list):
        for v in o:
            topla(v)
    elif isinstance(o, bool):
        pass
    elif isinstance(o, (int, float)):
        sayilar.add(float(o))
    elif isinstance(o, str):
        metinler.append(o)
        for parca in re.findall(r'\d+(?:[.,]\d{1,3})*(?:[.,]\d+)?', o):
            for aday in (parca.replace(',', ''), parca.replace('.', ''),
                         parca.replace(',', '.')):
                try:
                    sayilar.add(float(aday))
                except ValueError:
                    pass
        for y in re.findall(r'(?:18|19|20)\d{2}', o):
            sayilar.add(float(y))


topla(veri)
for v in list(sayilar):
    for k in (1e3, 1e6, 1e9):
        sayilar.add(v / k); sayilar.add(v * k)
    sayilar.add(abs(v)); sayilar.add(v * 100); sayilar.add(v / 100)
sayilar |= {float(n) for n in range(0, 32)}
havuz = sorted(sayilar)


def sade(s: str) -> str:
    """Türkçe güvenli küçültme (§39.5): lower() 'İ' için iki kod noktası üretir."""
    s = s.replace('İ', 'I').replace('ı', 'i')
    s = s.replace('’', "'").replace('‘', "'")
    s = unicodedata.normalize('NFD', s.lower())
    s = ''.join(c for c in s if not unicodedata.combining(c))
    return re.sub(r'\s+', ' ', s)


KAYNAK_METNI = ' ¶ '.join(sade(m) for m in metinler)

META = {
    'tr': ['hazırlanırken', 'bu dosyayı yazarken', 'doğrulanamadı', 'erişilemedi',
           'bulamadık', 'bulunamadı', 'veri katmanı', 'kaynağa ulaşılamadı',
           'teyit edilemedi', 'araştırma sırasında', 'bu araştırmada', 'betik',
           'data.json', 'doğrulayıcı'],
    'en': ['while preparing', 'could not be verified', 'we could not find',
           'was not accessible', 'data layer', 'during our research',
           'we were unable', 'in this research', 'script', 'validator'],
}
# ÖLÇÜLMEMİŞ ÜSTÜNLÜK — bu dosyanın açık maddesi
REKLAM = {
    'tr': ['en büyük pazar', 'en büyük tarım pazarı', 'lider', 'lokomotif',
           'başarıyla', 'gururla', 'dünyanın en'],
    'en': ['largest market', 'biggest agricultural market', 'leading role',
           'flagship', 'successfully', 'proudly'],
}

# ── Gövde ─────────────────────────────────────────────────────────────────
def govde(yol: pathlib.Path) -> list[tuple[str, str]]:
    """Yalnızca NUMARALI bölümleri döndürür.

    Yazım kuralları bloğu metnin kendisi değil; oradaki 'yazılmaz', 'yoktur'
    gibi ifadeler avcıları boşa tetikler."""
    ham = yol.read_text(encoding='utf-8')
    parcalar = re.split(r'^## (\d+)\.\s*(.*)$', ham, flags=re.M)
    return [(parcalar[i], parcalar[i + 2]) for i in range(1, len(parcalar), 3)]


SAYI = {
    'tr': re.compile(r'(?<![\w.,])(\d{1,3}(?:\.\d{3})+|\d+)(?:,(\d+))?(?![\w])'),
    'en': re.compile(r'(?<![\w.,])(\d{1,3}(?:,\d{3})+|\d+)(?:\.(\d+))?(?![\w])'),
}
# Çizicinin tanımadığı biçimler
BICIM = [
    (r'^\s*#{1,6}\s', 'alt başlık (###) — ekrana olduğu gibi basılır'),
    (r'^\s*>', 'alıntı bloğu (>) — tanınmıyor'),
    (r'^\s*[-*+]\s', 'madde işareti — liste tanınmıyor'),
    # NUMARALI LİSTE ARANMIYOR — VE BU BİR EKSİK DEĞİL.
    # `dossier_prose.dart`'ın sözleşmesi numaralı listeyi BİLEREK
    # desteklemiyor ve gerekçesini kendi yazıyor: satır kaydırması yüzünden
    # metinde "1979. Yani bu bir zirve resmi değil…" gibi satır başları
    # oluşuyor ve bunları madde sayan bir ayrıştırıcı cümleyi bozardı. Bu
    # dosyada da iki satır öyle başlıyor ("154." ve "2024.") ve ÇİZİCİ İÇİN
    # SORUN DEĞİL. İlk sürüm bu deseni arıyordu ve ikisini de işaretledi;
    # kural kaldırıldı çünkü yanlış olan metin değil kuraldı.
    (r'\[[^\]]+\]\([^)]+\)', 'bağlantı — tanınmıyor'),
    (r'```', 'kod bloğu — tanınmıyor'),
]

# ── Ölçek çarpışması: bataklık ↔ ülke ─────────────────────────────────────
BATAKLIK_IZ = {'tr': [r'80\.?000', r'5\.000', r'bataklıkta'],
               'en': [r'80,?000', r'5,000', r'in the marshes']}
ULKE_IZ = {'tr': [r'269\.940', r'302\.000', r'ülke genelinde', r'ülke ölçeğinde'],
           'en': [r'269,940', r'302,000', r'country-wide', r'across the country']}

alinti_sayisi: dict[str, dict[str, int]] = {}
TICARET_BOLUMLERI = {'1', '14', '15'}
AYNA = {'tr': ['türkiye\'nin beyanından', 'türkiyenin beyanından', 'muhabir'],
        'en': ["türkiye's reporting", "turkiye's reporting", 'reporter', 'reporting']}


def sin(dil: str, yol: pathlib.Path) -> list[str]:
    if not yol.exists():
        hata.append(f'[{dil}] DOSYA YOK · {yol.name}')
        return []
    bolumler = govde(yol)
    numaralar = [n for n, _ in bolumler]
    if len(bolumler) != 18:
        hata.append(f'[{dil}] BÖLÜM SAYISI {len(bolumler)} — on sekiz olmalı')
    if numaralar != [str(i) for i in range(1, len(bolumler) + 1)]:
        hata.append(f'[{dil}] BÖLÜM NUMARALARI ARDIŞIK DEĞİL: {numaralar}')

    for no, g in bolumler:
        # ── 1. Sayı izi
        for m in SAYI[dil].finditer(g):
            tam = m.group(1).replace('.', '').replace(',', '')
            kesir = m.group(2) or ''
            try:
                deger = float(f'{tam}.{kesir}' if kesir else tam)
            except ValueError:
                continue
            if not any(round(v, len(kesir)) == deger for v in havuz):
                hata.append(f"[{dil}] §{no} · SAYI VERİDE YOK: '{m.group(0)}'")
        # ── 2. Alıntı izi
        # DİZİNİN YAZIM KURALI: kaynak alıntısı *"..."* ile yazılır. Düz
        # tırnak yazarın kendi vurgusudur ("ağır hasarlı" gibi bir terim
        # anma) ve kaynağa bağlanamaz. Ama UZUN bir düz tırnak neredeyse
        # kesinlikle yanlış işaretlenmiş bir kaynak alıntısıdır; eşik 60.
        adaylar = [(m, True) for m in re.findall(r'\*"([^"]{12,})"\*', g)]
        # TIRNAKLAR SIRAYLA EŞLEŞTİRİLİYOR, düzenli ifadeyle değil.
        # r'"([^"]{60,})"' deseni ardışık iki tırnak çiftinde BİRİNİN
        # KAPANIŞIYLA ÖTEKİNİN AÇILIŞINI eşleştiriyor ve aradaki düz metni
        # alıntı sanıyor. split('"')[1::2] doğru çiftleri verir.
        kalan = re.sub(r'\*"[^"]*"\*', ' ', g)
        adaylar += [(m, False) for m in kalan.split('"')[1::2] if len(m) >= 60]
        for ibare, kaynak_isareti in adaylar:
            # Kaynak cümlesi devam edebilir: alıntının sonundaki noktalama
            # kaynakta olmayabilir. Baş ve sondaki noktalama atılıyor.
            sade_ibare = sade(ibare).strip(' .,;:!?')
            if sade_ibare not in KAYNAK_METNI:
                tur = 'ALINTI BAĞLANMADI' if kaynak_isareti else \
                      'UZUN DÜZ TIRNAK BAĞLANMADI (kaynak alıntısı *"..."* yazılır)'
                if dil == 'en':
                    # 1946 protokolü ve TBMM nüshası TÜRKÇE. İngilizce metin
                    # onları çeviriyle veriyor ve çeviri kaynak metninde
                    # harfi harfine bulunmaz. Düşürmüyor, KAYDA GEÇİYOR —
                    # uydurulmuş bir alıntı ise aşağıdaki PARİTE yakalar.
                    uyari.append(f"[en] §{no} · çeviri alıntı (tr karşılığı "
                                 f"sayıldı): '{ibare[:55]}…'")
                else:
                    hata.append(f"[{dil}] §{no} · {tur}: '{ibare[:60]}'")
        alinti_sayisi.setdefault(dil, {})[no] = len(adaylar)
        # ── 3 ve 4. Meta ve reklam — TIRNAK DIŞI metinde
        disari = sade(re.sub(r'\*?"[^"]*"\*?', ' ', g))
        for k in META[dil]:
            if sade(k) in disari:
                hata.append(f"[{dil}] §{no} · META CÜMLE: '{k}'")
        for k in REKLAM[dil]:
            if sade(k) in disari:
                hata.append(f"[{dil}] §{no} · ÖLÇÜLMEMİŞ ÜSTÜNLÜK / REKLAM: '{k}'")
        # ── 5. Çizicinin tanımadığı biçim
        for desen, aciklama in BICIM:
            if re.search(desen, g, re.M):
                hata.append(f'[{dil}] §{no} · BİÇİM: {aciklama}')
        # ── 6. Ölçek çarpışması — CÜMLE CÜMLE
        for cumle in re.split(r'(?<=[.!?])\s+', g):
            b = any(re.search(d, cumle, re.I) for d in BATAKLIK_IZ[dil])
            u = any(re.search(d, cumle, re.I) for d in ULKE_IZ[dil])
            if b and u:
                hata.append(f'[{dil}] §{no} · ÖLÇEK ÇARPIŞMASI — bataklık ve ülke '
                            f'rakamı AYNI CÜMLEDE: "{cumle.strip()[:90]}…"')
        # ── 7. Ayna istatistiği
        if no in TICARET_BOLUMLERI:
            if not any(sade(k) in sade(g) for k in AYNA[dil]):
                hata.append(f'[{dil}] §{no} · AYNA İSTATİSTİĞİ SÖYLENMEMİŞ — '
                            'rakamlar Türkiye\'nin beyanından')
    return numaralar


tr = sin('tr', KOK / 'metin_tr.md')
en = sin('en', KOK / 'metin_en.md')
if tr and en and tr != en:
    hata.append(f'BÖLÜM NUMARALARI TR/EN FARKLI: {tr} / {en}')

# ── 9. ALINTI PARİTESİ — çeviri muafiyetinin bedeli ───────────────────────
# İngilizce alıntı bağlanmadığında düşürmüyoruz; o muafiyet uydurma bir
# alıntıya kapı açardı. Kapıyı parite kapatıyor: bölüm başına alıntı sayısı
# iki dilde AYNI olmak zorunda.
for no in alinti_sayisi.get('tr', {}):
    a = alinti_sayisi['tr'][no]
    b = alinti_sayisi.get('en', {}).get(no, 0)
    if a != b:
        hata.append(f'§{no} · ALINTI SAYISI UYUŞMUYOR · tr {a} / en {b} — '
                    'çeviri muafiyeti ancak parite tutarsa geçerlidir')

if hata:
    print('METİN SINAMASI BAŞARISIZ:\n', file=sys.stderr)
    for h in hata:
        print('  ✗ ' + h, file=sys.stderr)
    sys.exit(1)

for u in uyari:
    print('  ! ' + u)
print('✓ metin · 9 avcı geçti')
print(f'  tr {len(tr)} bölüm · en {len(en)} bölüm')
print('Temiz: veriye dayanmayan sayı, bağlanmamış alıntı, meta cümle, ölçülmemiş '
      'üstünlük, çizicinin tanımadığı biçim, ölçek çarpışması, ayna uyarısı eksiği.')
