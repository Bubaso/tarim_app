#!/usr/bin/env python3
"""Mısır — palet kontrast ve renk körlüğü hesabı.

tasarim.json'daki HİÇBİR kontrast sayısı elle yazılmaz; hepsi buradan gelir.
Palet değişirse bu betik yeniden koşar ve tasarim.json güncellenir.
WCAG 2.1: gövde metni ≥ 4,5 · anlam taşıyan çizgi ≥ 3,0.

DEVRALINAN DÖRT DERS:
  1. Eşik HEM zeminde HEM yüzeyde sınanır (Avustralya: #6A6354 zeminde 3,19
     ile geçiyor, yüzeyde 2,86 ile geçmiyordu).
  2. İki serinin BAĞIL PARLAKLIK oranı ayrıca sınanır (Hollanda: sodyum
     turuncusu ile cam yeşilinin oranı 1,05'ti, deuteranopi altında ayırt
     edilemiyorlardı). Eşik 1,4.
  3. ANA SAYFADAN AYRIŞMA hesaplanır, elle yazılmaz (Irak dosyası: ilk
     denemede nehir koyusu ile ana sayfanın yapısal yeşili 1,24 çıkmıştı).
  4. Parlaklık oranı VEKİL ölçüdür ve yanılır; üç körlük tipi doğrudan
     benzetilir (Viénot-Mollon, LMS düzleminde izdüşüm) ve oran benzetim
     SONRASINDA ölçülür.

BU DOSYADA EKLENEN BİRİNCİ SINAMA — VURGU GÖVDE METNİNDEN AYRIŞIYOR:
  `vurgu` yalnız grafikte değil, gövde metninin İÇİNDE rakam rengi olarak
  da kullanılıyor. Mürekkebe yakın bir vurgu, grafikte eşikleri geçse bile
  cümlenin içinde vurgu olmaktan çıkar. Eşik seri ayrımıyla aynı: 1,4.
  Bu sınama ölçülerek kondu, çünkü onsuz arama sonucu şu paleti öneriyordu:
  vurgu #F5C689 (bağıl parlaklık 0,616), mürekkep #E8E4DA (0,766) — oran
  1,25. Bütün öteki eşikleri geçiyordu ve okurun gözünde vurgu değildi.

BU DOSYADA ÖLÇÜLEN SINIR — ÜÇ YOLLU LADDER MÜMKÜN DEĞİL:
  Bu dosyada `sessiz` dört grafikte çubuk rengi (suyun_defteri'nde üçü
  birden aynı grafikte). O yüzden "üç rolün üçü de birbirinden 1,4 ayrışsın"
  kuralı denendi ve RENK UZAYI TARANDI: 4,5 eşiğini geçen 2.374 renk,
  vurgu adayı olarak mürekkepten de ayrışan 1.668 renk. Sonuç:
    · üç yollu ladder'ı geçen üçlüler VAR — ama hepsinde en çok BİR rol
      renkli, ötekiler gri. Tek örnek: #928787 / #AAA1A1 / #CFC9C9.
    · doygun bir vurguyla (s ≥ 0,40) geçen üçlüler de var ama ikincil her
      defasında griye düşüyor: #C76B6B / #B6AFAF / #D9CCBF.
    · yani İKİ RENKLİ bir palet (iki seri + bir kısık rol) bu ladder'ı
      sağlayamıyor. Arayış değil, aritmetik: üç rolün üçü de koyu zeminde
      metin olarak okunacaksa (bağıl parlaklık ≥ 0,235) ve aralarında 1,4
      basamak olacaksa en parlak rol mürekkebin mahallesine çıkıyor.
  KARAR: ladder zorunlu kılınmadı. Yerine iki şey yapıldı —
    1. Grafik tarafında kural: `ikili_cubuk` ve `yigin` serileri
       vurgu + ikincil olmak zorunda, sessiz olamaz (dogrula_grafik.py
       kural 20). Gerekçe kodda: `ChartRole.taramali` YALNIZ ikincil için
       true, yani vurgu ile sessiz yan yana durduğunda ayrımı taşıyan tek
       şey renk olurdu. Vurgu ile ikincil yan yana durduğunda ise renk VE
       tarama birlikte taşıyor.
    2. Burada: vurgu↔sessiz ve ikincil↔sessiz oranları ÖLÇÜLÜYOR ve
       yazılıyor ama DURDURMUYOR. Sessizin tek işi `siralama`da bağlam
       satırı olmak; orada ayrımı etiket ve çubuk uzunluğu taşıyor.
  ΔE DENENDİ VE BIRAKILDI: CIELAB ΔE76 ikinci bir vekil olarak ölçüldü ama
  kalibrasyon başarısız. Hollanda'da çöken çift (#FF9E5E / #7FC8A9)
  deuteranopi benzetimi sonrası ΔE 52,2 veriyor; yayında ÇALIŞAN Irak
  paleti 87,9. İkisi aynı mahallede değil ama ΔE eşiğini 52'nin üstüne
  koymak çalışan paletleri de keserdi. Vekili vekille denetlemek yerine
  kayıtlı ölçü (benzetim sonrası parlaklık oranı) korundu.

Çalıştırma: python3 content/dossiers/misir/_raw/kontrast.py
"""


def lin(c):
    c = c / 255
    return c / 12.92 if c <= 0.03928 else ((c + 0.055) / 1.055) ** 2.4


def L(hx):
    hx = hx.lstrip('#')
    r, g, b = (int(hx[i:i + 2], 16) for i in (0, 2, 4))
    return 0.2126 * lin(r) + 0.7152 * lin(g) + 0.0722 * lin(b)


def cr(a, b):
    la, lb = L(a), L(b)
    return (max(la, lb) + 0.05) / (min(la, lb) + 0.05)


def oran(a, b):
    return max(L(a), L(b)) / min(L(a), L(b))


# ── Renk körlüğü benzetimi (Viénot-Mollon) ────────────────────────────────
def _rgb(h):
    h = h.lstrip('#')
    return [lin(int(h[i:i + 2], 16)) for i in (0, 2, 4)]


def _hex(v):
    def g(c):
        c = max(0.0, min(1.0, c))
        c = 12.92 * c if c <= 0.0031308 else 1.055 * c ** (1 / 2.4) - 0.055
        return round(c * 255)
    return '#%02X%02X%02X' % tuple(g(c) for c in v)


def _mm(M, v):
    return [sum(M[i][j] * v[j] for j in range(3)) for i in range(3)]


_R2L = [[.31399, .63951, .04649], [.15537, .75789, .08670], [.01775, .10945, .87253]]
_L2R = [[5.47221, -4.6419, .16963], [-1.1252, 2.29317, -.1678], [.02980, -.19318, 1.16364]]
KORLUK = {
    'protanopi': [[0, 1.05118, -.05116], [0, 1, 0], [0, 0, 1]],
    'deuteranopi': [[1, 0, 0], [.9513, 0, .04315], [0, 0, 1]],
    'tritanopi': [[1, 0, 0], [0, 1, 0], [-.86744, 1.86727, 0]],
}


def benzet(hx, tip):
    return _hex(_mm(_L2R, _mm(KORLUK[tip], _mm(_R2L, _rgb(hx)))))


# ── Koyu gövde: PORTAKAL VE MİL ───────────────────────────────────────────
# İki renk de dosyanın ÖLÇTÜĞÜ iki şeyden geliyor, manzaradan değil:
# portakal Mısır'ın Türkiye'yi geçtiği ve makası açmaya devam ettiği ürün
# (1990'da 2,14 kat, 2024'te 2,61 kat); mil ise suyun kendisi — ülkenin
# kendi ürünü DEĞİL, %96,9'u dışarıdan geliyor.
# MİL ÖNDE, PORTAKAL İKİNCİ. Bu sıra ölçülerek seçildi: portakal önde
# olduğunda (vurgu #F2A14A / ikincil #479898) seri ayrımının en kötü
# değeri 1,53'te kalıyordu; mil önde olduğunda 1,51 yerine daha geniş bir
# pay var ve vurgu mürekkepten de 1,56 ile ayrışıyor. Dizide ilk kez SOĞUK
# renk önde (Irak'ta hurma amberi öndeydi, nehir ikinci).
ZEMIN, YUZEY = '#0F1311', '#19201D'
MUREKKEP, SESSIZ = '#E8E4DA', '#9BA39C'
VURGU, IKINCIL = '#7CC9C2', '#CC7A30'
CIZGI, CIZGIVURGU = '#222B27', '#717D77'

# ── Ana sayfa şeridi: krem zemin ──────────────────────────────────────────
KREM, S_MUREKKEP = '#F6F1E7', '#161917'
# ŞERİTTE DE MİL ÖNDE — Irak'ta rol zemine göre DEĞİŞMİŞTİ (koyu sayfada
# hurma, krem şeritte nehir). Burada değişmiyor ve bu da ölçüm: ilk deneme
# #14544E ana sayfanın yapısal yeşiliyle 1,21 veriyordu (eşik 1,25) ve
# koyulaştırıldı. #0B403C ile beş ana sayfa renginin en yakını 1,44.
S_VURGU, S_IKINCIL = '#0B403C', '#8A3410'   # mil koyusu · portakal koyusu

# ── Ana sayfanın kendi renkleri (lib/core/theme/app_colors.dart) ──────────
ANASAYFA = {
    'darkGreen #2F4B2E': '#2F4B2E',
    'primaryGreen #5C8A4A': '#5C8A4A',
    'wheat #C9A15A': '#C9A15A',
    'marketDown #9C4A3C': '#9C4A3C',
    'alertRed #D32F2F': '#D32F2F',
}

kusur = []

print('=== Koyu gövde ===')
for ad, hx, esik in (('murekkep', MUREKKEP, 4.5), ('sessiz', SESSIZ, 4.5),
                     ('vurgu', VURGU, 4.5), ('ikincil', IKINCIL, 4.5),
                     ('cizgiVurgu', CIZGIVURGU, 3.0),
                     ('cizgi', CIZGI, 0), ('yuzey', YUZEY, 0)):
    z, y = cr(hx, ZEMIN), cr(hx, YUZEY)
    if esik and min(z, y) < esik:
        kusur.append(f'{ad} eşik altı ({min(z, y):.2f} < {esik})')
    im = '' if esik == 0 else ('  ✓' if min(z, y) >= esik else '  ✗ EŞİK ALTI')
    print(f'  {ad:11} {hx}  zemin {z:5.2f}  yuzey {y:5.2f}{im}')


print('\n=== Vurgu gövde metninden ayrışıyor mu ===')
vm = oran(VURGU, MUREKKEP)
if vm < 1.4:
    kusur.append(f'vurgu mürekkepten ayrışmıyor ({vm:.2f})')
print(f'  vurgu {VURGU} ↔ mürekkep {MUREKKEP}  parlaklık oranı {vm:.2f}'
      + ('  ✓' if vm >= 1.4 else '  ✗ VURGU DEĞİL'))


def seri_ayrimi(baslik, a, b, ad_a, ad_b, durdur=True):
    print(f'\n=== {baslik} ===')
    o = oran(a, b)
    print(f'  {ad_a:11} {a}  bağıl parlaklık {L(a):.4f}')
    print(f'  {ad_b:11} {b}  bağıl parlaklık {L(b):.4f}')
    print(f'  normal görme    parlaklık oranı {o:.2f}' + ('  ✓' if o >= 1.4 else '  ✗ ZAYIF'))
    if o < 1.4 and durdur:
        kusur.append(f'{baslik}: normal görmede zayıf ({o:.2f})')
    sonuc = {'normal': round(o, 2)}
    for tip in KORLUK:
        sa, sb = benzet(a, tip), benzet(b, tip)
        ob = oran(sa, sb)
        sonuc[tip] = round(ob, 2)
        if ob < 1.4 and durdur:
            kusur.append(f'{baslik}: {tip} altında ayrışmıyor ({ob:.2f})')
        print(f'  {tip:13}  {sa} {sb}  oran {ob:.2f}'
              + ('  ✓' if ob >= 1.4 else '  ✗ AYRIŞMIYOR'))
    return sonuc


olculen = {}
olculen['govde'] = seri_ayrimi('Gövde serileri (portakal ↔ mil)',
                               VURGU, IKINCIL, 'vurgu', 'ikincil')
# ÖLÇÜLÜYOR AMA DURDURMUYOR — gerekçe dosyanın başındaki "üç yollu ladder"
# notunda. Sessizin tek işi siralama'da bağlam satırı olmak; yığılmış
# türlerde seri olarak kullanılması dogrula_grafik.py kural 20 ile yasak.
olculen['vurgu_sessiz'] = seri_ayrimi('Vurgu ↔ sessiz (siralama bağlam satırı)',
                                      VURGU, SESSIZ, 'vurgu', 'sessiz', durdur=False)
olculen['ikincil_sessiz'] = seri_ayrimi('İkincil ↔ sessiz (siralama bağlam satırı)',
                                        IKINCIL, SESSIZ, 'ikincil', 'sessiz', durdur=False)

print('\n=== Şerit (krem zemin) ===')
for ad, hx in (('murekkep', S_MUREKKEP), ('vurguKoyu', S_VURGU),
               ('ikincilKoyu', S_IKINCIL)):
    k = cr(hx, KREM)
    if k < 4.5:
        kusur.append(f'şerit {ad} eşik altı ({k:.2f})')
    print(f'  {ad:12} {hx}  krem {k:5.2f}' + ('  ✓' if k >= 4.5 else '  ✗ EŞİK ALTI'))
for ad, hx in (('vurguKoyu', S_VURGU), ('ikincilKoyu', S_IKINCIL)):
    om = oran(hx, S_MUREKKEP)
    if om < 1.4:
        kusur.append(f'şerit {ad} kendi mürekkebinden ayrışmıyor ({om:.2f})')
    print(f'  {ad:12} ↔ şerit mürekkebi {om:5.2f}' + ('  ✓' if om >= 1.4 else '  ✗ ZAYIF'))

olculen['serit'] = seri_ayrimi('Şerit serileri (mil ↔ portakal)',
                               S_VURGU, S_IKINCIL, 'vurguKoyu', 'ikincilKoyu')

print('\n=== Ana sayfadan ayrışma ===')
print("  Eşik 1,25 — Hollanda'da çöken çiftin oranı 1,05'ti.")
ayrisma = {}
for ad, hx in (('vurguKoyu', S_VURGU), ('ikincilKoyu', S_IKINCIL)):
    print(f'  {ad}:')
    ayrisma[ad] = {}
    for an, ahx in ANASAYFA.items():
        r = oran(hx, ahx)
        ayrisma[ad][an] = round(r, 2)
        if r < 1.25:
            kusur.append(f'şerit {ad} ↔ {an} ayrışmıyor ({r:.2f})')
        print(f'     ↔ {an:22} {r:5.2f}' + ('  ✓' if r >= 1.25 else '  ✗ ÇAKIŞMA RİSKİ'))

print()
print('=== tasarim.json için ölçülen değerler ===')
import json
print(json.dumps({'_olculen_ayrisma': olculen, '_anasayfadan_ayrisma': ayrisma},
                 ensure_ascii=False, indent=1))
print()
if kusur:
    print('KUSURLU — palet düzeltilmeden tasarim.json yazılmaz:')
    for k in kusur:
        print('  ✗ ' + k)
    raise SystemExit(1)
print('✓ palet temiz — WCAG eşikleri, seri ayrımı, vurgu↔mürekkep, ana sayfa '
      'ayrımı ve üç körlük tipi geçti')
print('  (sessiz çiftleri ölçüldü, durdurmuyor — gerekçe dosyanın başında)')
