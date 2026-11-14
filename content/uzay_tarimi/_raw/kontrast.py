#!/usr/bin/env python3
"""Uzayda Tarım — palet kontrast ve renk körlüğü hesabı.

uzay_tasarim.dart'taki hiçbir kontrast sayısı elle yazılmaz; hepsi buradan.
WCAG 2.1: gövde metni ≥4,5 · GRAFİK NESNESİ ≥3,0 · seri ayrımı ≥1,4
(normal görme VE üç körlük tipinde, Viénot-Mollon benzetimiyle).

ÜÇÜNCÜ KANAL — RENK TEK BAŞINA TAŞIMIYOR. Ölçüm şunu gösterdi: gündüz
modunda vurgu da elenen de KOYU olmak zorunda (biri metin eşiğini, öteki
grafik eşiğini tutturmak için) ve iki koyu renk parlaklıkla ayrışamıyor.
Çözüm rengi zorlamak değil, DOLGU BİÇİMİ eklemek:

    GEÇEN  → dolu
    ELENEN → içi boş + kenarlıklı

Nexus sayfasının kuralıyla aynı: durum renk, simge ve dolguyla birlikte
işaretlenir. `gece_led_yaprak`, `gunduz_led_yaprak` ve `gunduz_led_elenen`
çiftleri bu yüzden ÖLÇÜLÜYOR ama DURDURMUYOR — ayrımı biçim taşıyor.
Durduran tek çift `gece_led_elenen`: hunideki asıl karşıtlık o.

PALETİN KAYNAĞI. Klişe "uzay = lacivert + yıldız" bilerek kullanılmadı.
Renkler konunun KENDİ maddesinden: Veggie ve Advanced Plant Habitat
odalarının kırmızı+mavi LED'leri birleşince çıkan MOR ışık — uzayda bitki
yetiştirmenin gerçek rengi, her fotoğrafında görünen şey — ve yaprağın
kendisi. Zemin istasyon içinin nötr karanlığı.
"""
def lin(c):
    c = c / 255
    return c / 12.92 if c <= 0.03928 else ((c + 0.055) / 1.055) ** 2.4
def L(h):
    h = h.lstrip('#'); return (0.2126*lin(int(h[0:2],16)) + 0.7152*lin(int(h[2:4],16))
                               + 0.0722*lin(int(h[4:6],16)))
def cr(a,b):
    la,lb=L(a),L(b); return (max(la,lb)+0.05)/(min(la,lb)+0.05)
def oran(a,b): return max(L(a),L(b))/min(L(a),L(b))
def _rgb(h): return [lin(int(h.lstrip('#')[i:i+2],16)) for i in (0,2,4)]
def _hx(v):
    def g(c):
        c=max(0.0,min(1.0,c)); c=12.92*c if c<=0.0031308 else 1.055*c**(1/2.4)-0.055
        return round(c*255)
    return '#%02X%02X%02X'%tuple(g(c) for c in v)
def _mm(M,v): return [sum(M[i][j]*v[j] for j in range(3)) for i in range(3)]
_R2L=[[.31399,.63951,.04649],[.15537,.75789,.08670],[.01775,.10945,.87253]]
_L2R=[[5.47221,-4.6419,.16963],[-1.1252,2.29317,-.1678],[.02980,-.19318,1.16364]]
KORLUK={'protanopi':[[0,1.05118,-.05116],[0,1,0],[0,0,1]],
        'deuteranopi':[[1,0,0],[.9513,0,.04315],[0,0,1]],
        'tritanopi':[[1,0,0],[0,1,0],[-.86744,1.86727,0]]}
def benzet(h,t): return _hx(_mm(_L2R,_mm(KORLUK[t],_mm(_R2L,_rgb(h)))))

# ── GECE ──────────────────────────────────────────────────────────────────
G_ZEMIN='#121014'; G_YUZEY='#1C1A21'; G_METIN='#ECE8EE'; G_IKINCIL='#A6A0AC'
G_CIZGI='#2A2731'; G_CIZGIV='#6E6878'
G_LED='#E86FBE'      # LED moru — GEÇEN, dolu
G_YAPRAK='#8ACB55'   # yaprak — bitki deneyi / ikinci seri
G_ELENEN='#6E6878'   # ELENEN — içi boş + kenarlıklı çizilir

# ── GÜNDÜZ ────────────────────────────────────────────────────────────────
A_ZEMIN='#F6F4F7'; A_YUZEY='#FFFFFF'; A_METIN='#191622'; A_IKINCIL='#5A5465'
A_CIZGI='#E0DCE4'; A_CIZGIV='#8B8496'
A_LED='#8E2C72'; A_YAPRAK='#3F6B16'
# ELENEN GÜNDÜZDE KENAR ÇİZGİSİ RENGİDİR, dolgu değil. Çubuk içi boş
# çiziliyor; 3,0 eşiğini tutturması gereken şey dolgu değil o çizgi.
# İlk değer #9E98A8 idi ve 2,56 ile kaldı — açık zeminde bir dolgu tonu
# olarak seçilmişti, oysa taşıyıcı öğe çizgi.
A_ELENEN='#767080'

kusur=[]
def blok(ad, zemin, yuzey, kalemler):
    print(f'\n=== {ad} ===')
    for n,h,e in kalemler:
        z,y=cr(h,zemin),cr(h,yuzey)
        if e and min(z,y)<e: kusur.append(f'{ad}/{n} eşik altı ({min(z,y):.2f}<{e})')
        im='' if not e else ('  ✓' if min(z,y)>=e else '  ✗')
        print(f'  {n:10} {h}  zemin {z:5.2f}  yüzey {y:5.2f}{im}')

blok('Gece', G_ZEMIN, G_YUZEY, [
    ('metin',G_METIN,4.5),('ikincil',G_IKINCIL,4.5),('led',G_LED,4.5),
    ('yaprak',G_YAPRAK,4.5),('elenen',G_ELENEN,3.0),('cizgiV',G_CIZGIV,3.0),
    ('cizgi',G_CIZGI,0),('yuzey',G_YUZEY,0)])
blok('Gündüz', A_ZEMIN, A_YUZEY, [
    ('metin',A_METIN,4.5),('ikincil',A_IKINCIL,4.5),('led',A_LED,4.5),
    ('yaprak',A_YAPRAK,4.5),('elenen',A_ELENEN,3.0),('cizgiV',A_CIZGIV,3.0),
    ('cizgi',A_CIZGI,0)])

olculen={}
def cift(ad,a,b,durdur=True):
    print(f'\n=== {ad} ===')
    o=oran(a,b); d={'normal':round(o,2)}
    print(f'  normal      {o:.2f}'+('  ✓' if o>=1.4 else '  ✗'))
    if o<1.4 and durdur: kusur.append(f'{ad} normal {o:.2f}')
    for t in KORLUK:
        ob=oran(benzet(a,t),benzet(b,t)); d[t]=round(ob,2)
        print(f'  {t:11} {ob:.2f}'+('  ✓' if ob>=1.4 else '  ✗'))
        if ob<1.4 and durdur: kusur.append(f'{ad} {t} {ob:.2f}')
    olculen[ad]=d
cift('gece_led_yaprak',G_LED,G_YAPRAK,durdur=False)
cift('gece_led_elenen',G_LED,G_ELENEN)
cift('gunduz_led_yaprak',A_LED,A_YAPRAK,durdur=False)
cift('gunduz_led_elenen',A_LED,A_ELENEN,durdur=False)

# Vurgu gövde metninden ayrışmalı — rakam rengi cümle içinde kullanılıyor
for ad,v,m in (('gece',G_LED,G_METIN),('gunduz',A_LED,A_METIN)):
    o=oran(v,m); print(f'\n{ad} led ↔ metin {o:.2f}'+('  ✓' if o>=1.4 else '  ✗'))
    if o<1.4: kusur.append(f'{ad} led mürekkepten ayrışmıyor ({o:.2f})')

import json
print('\n=== tasarım dosyasına yazılacak ===')
print(json.dumps(olculen, ensure_ascii=False, indent=1))
if kusur:
    print('\nKUSURLU:'); [print('  ✗',k) for k in kusur]; raise SystemExit(1)
print('\n✓ palet temiz')
