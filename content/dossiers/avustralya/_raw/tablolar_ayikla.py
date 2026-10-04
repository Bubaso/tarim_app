#!/usr/bin/env python3
"""Victoria Su Sicili eğilim raporunun (2001-2024) tablolarını çıkarır.

KAYNAK : kaynak_dosyalari/egilim_2001_2024.txt
SINIF  : SİCİLİN BEYANI — piyasayı İŞLETEN idarenin kendi defteri
KAPSAM : kuzey Victoria. ÜLKE GENELİ DEĞİL.

ÇÖZÜLEN TUZAK — SABİT PENCERE. Başlıktan itibaren N karakter almak bir
sonraki tabloya taşıyor ve kolon sayıları karışıyor. İlk denemede T4'ün
örnek satırı aslında T3'ün verisiydi, T13/14/15 aynı satırı gösteriyordu.
Her tablonun sınırı artık KENDİSİNDEN SONRAKİ ilk tablo başlığı.

ÇÖZÜLEN TUZAK — KAYNAK KENDİ İÇİNDE ÇELİŞİYOR. Tablo 2'nin 2008-09 satırı
yüzdeleri 1/2/12/85 yazıyor ama aynı satırın hacimleri 0/0/125/2.163 GL ve
toplamı 2.288 GL; hacimlerden hesap 0/0/5,5/94,5 veriyor. Diğer ON YEDİ
satırın tamamında rapor kendi hacmine oturuyor. Bu dosyada yüzdeler
HACİMLERDEN hesaplanıyor ve tutarsızlık kayda geçiyor; metinde 2008-09
yüzdesi üzerine cümle kurulmuyor.

Her tablonun kendi sağlaması var. Sağlama tutmazsa üretim DURUR — yanlış
şema sessizce yanlış sayı üretmesin.
"""
import json, pathlib, re, sys

HAM = pathlib.Path('kaynak_dosyalari/egilim_2001_2024.txt')
if not HAM.exists():
    sys.exit('HATA: ham metin yok — önce cek.sh')
T = HAM.read_text(encoding='utf-8')

BAS = re.compile(r'Table\s+(\d+):\s*([^\n]{3,110})')
_yer = [(m.start(), int(m.group(1)), ' '.join(m.group(2).split())) for m in BAS.finditer(T)]

def blok(no):
    ayni = [p for p, n, _ in _yer if n == no]
    if not ayni:
        sys.exit(f'HATA: Tablo {no} bulunamadı')
    bas = max(ayni)                      # içindekiler listesi değil, tablonun kendisi
    sonra = [p for p, _, _ in _yer if p > bas]
    ad = next(a for p, n, a in _yer if p == bas)
    return T[bas: min(sonra) if sonra else len(T)], ad

HUC = re.compile(r'-?[\d,]+\.?\d*%?|-(?=\s|$)')
YIL = re.compile(r'^\s*((?:19|20)\d{2}-\d{2}(?:\d{2})?)\s+(.+)$')

def sayi(s):
    s = s.strip().rstrip('%')
    return None if s in ('-', '') else float(s.replace(',', ''))

def satirlar(no, n):
    b, ad = blok(no)
    cikti = []
    for ln in b.split('\n'):
        m = YIL.match(ln)
        if not m:
            continue
        h = HUC.findall(m.group(2))
        if len(h) == n:
            yil = m.group(1)
            if len(yil) == 9:                    # "2007-2008" → "2007-08"
                yil = yil[:5] + yil[7:]
            cikti.append((yil, [sayi(x) for x in h]))
    if not cikti:
        sys.exit(f'HATA: Tablo {no} · {n} hücreli satır yok')
    return cikti, ad

def yakin(a, b, tol):
    return a is None or b is None or abs(a - b) <= tol

def yil_no(k):
    """cizgi grafiğinin x ekseni SAYISAL olmak zorunda.

    `CizgiSeri._coz` x'i _sayi() ile okuyor; "2000-01" dizgisi oradan geçmiyor
    ve seri SESSİZCE boş kalıyor (nokta bulunamayınca null dönüyor, grafik
    atlanıyor — ne başlık ne hata). Su yılının başladığı takvim yılı.
    """
    k['yil_no'] = int(k['yil'][:4])
    return k

cikti, rapor = {}, []

def ekle(ad, no, n, alanlar, dogrula=None, birim=''):
    sat, baslik = satirlar(no, n)
    kayitlar = []
    for yil, h in sat:
        k = {'yil': yil}
        k.update({a: v for a, v in zip(alanlar, h) if a})
        if dogrula:
            hata = dogrula(k)
            if hata:
                sys.exit(f'HATA: Tablo {no} · {yil} · {hata}')
        kayitlar.append(yil_no(k))
    cikti[ad] = {'_tablo': f'Table {no}', '_baslik': baslik, '_birim': birim,
                 'kayitlar': kayitlar}
    rapor.append((no, ad, len(kayitlar), kayitlar[0]['yil'], kayitlar[-1]['yil']))

# ── T2: hak kimde? Dosyanın omurgası ─────────────────────────────────────
sat2, bas2 = satirlar(2, 9)
sahiplik = []
for yil, h in sat2:
    k = {'yil': yil, 'cevre_gl': h[0], 'su_kurumu_gl': h[2],
         'ozel_topraga_bagli_degil_gl': h[4], 'ozel_topraga_bagli_gl': h[6],
         'toplam_gl': h[8]}
    tp = k['toplam_gl']
    bilesen = sum(k[x] or 0 for x in ('cevre_gl', 'su_kurumu_gl',
                  'ozel_topraga_bagli_degil_gl', 'ozel_topraga_bagli_gl'))
    if abs(bilesen - tp) > 3:
        sys.exit(f'HATA: Tablo 2 · {yil} bileşen {bilesen} ≠ toplam {tp}')
    for ad_, alan in (('topraga_bagli_pay_yuzde', 'ozel_topraga_bagli_gl'),
                      ('topraga_bagli_degil_pay_yuzde', 'ozel_topraga_bagli_degil_gl'),
                      ('cevre_pay_yuzde', 'cevre_gl')):
        k[ad_] = round(100 * (k[alan] or 0) / tp, 1)
    sahiplik.append(yil_no(k))
cikti['sahiplik'] = {
    '_tablo': 'Table 2', '_baslik': bas2, '_birim': 'GL / %',
    '_2008_09_tutarsizligi': (
        "KAYNAK KENDİ İÇİNDE ÇELİŞİYOR — yalnız bu satırda. Rapor yüzdeleri "
        "çevre %1, kurum %2, topraksız %12, bağlı %85 diyor; aynı satırın "
        "hacimleri 0 / 0 / 125 / 2.163 GL, toplam 2.288 GL. Hacimlerden hesap "
        "%0 / %0 / %5,5 / %94,5. Diğer on yedi satırın tamamında rapor kendi "
        "hacmine oturuyor. Buradaki yüzdeler HESAPLANMIŞ değerlerdir. METİNDE "
        "2008-09 YÜZDESİ ÜZERİNE CÜMLE KURULMAZ; temiz seri 2009-10'da başlar."),
    'kayitlar': sahiplik}
rapor.append((2, 'sahiplik', len(sahiplik), sahiplik[0]['yil'], sahiplik[-1]['yil']))

# ── T6: toprağa bağlı hak ile fiilî kullanım ─────────────────────────────
def t6(k):
    hesap = round(100 * k['kullanim_gl'] / k['topraga_bagli_gl'])
    return None if abs(hesap - k['kullanim_oran_yuzde']) <= 1 else \
        f"kullanım oranı {hesap}% ≠ rapor {k['kullanim_oran_yuzde']}%"
ekle('kullanim', 6, 15,
     [None]*12 + ['topraga_bagli_gl', 'kullanim_gl', 'kullanim_oran_yuzde'],
     t6, birim='GL / %')

# ── T3: toprağa bağlı payın bölge dağılımı ───────────────────────────────
ekle('bolge_dagilimi', 3, 5,
     ['gmw_bolge', 'gmw_ceken', 'lmw_bolge', 'lmw_ceken', 'toplam'],
     lambda k: None if yakin(sum(k[x] for x in ('gmw_bolge','gmw_ceken','lmw_bolge','lmw_ceken')),
                             k['toplam'], 2) else 'bileşen toplamı tutmuyor', birim='GL')

# ── T4/T5: KALICI HAKKIN FİYATI ($/ML, MEDYAN) ───────────────────────────
for ad, no, nitel in (('pay_yuksek_guvenilir', 4, 'yüksek güvenilirlikli'),
                      ('pay_dusuk_guvenilir', 5, 'düşük güvenilirlikli')):
    ekle(ad, no, 3, ['devlete_devir_gl', 'diger_devir_gl', 'medyan_fiyat_aud_ml'],
         birim='GL / AUD-ML')
    cikti[ad]['_nitelik'] = nitel

# ── T9: tahsis ticareti özeti ────────────────────────────────────────────
def t9(k):
    if not yakin(k['ticari_hacim_gl'] + k['sifir_fiyatli_hacim_gl'], k['toplam_hacim_gl'], 2):
        return 'hacim toplamı tutmuyor'
    if not yakin(k['ticari_islem'] + k['sifir_fiyatli_islem'], k['toplam_islem'], 2):
        return 'işlem sayısı toplamı tutmuyor'
    # EN SIKI SAĞLAMA: ortalama parça = hacim(ML) / işlem. Kolonlar yanlış
    # eşleşseydi bu tutmazdı — şemanın doğruluğunun kanıtı.
    for h, i, o in (('ticari_hacim_gl','ticari_islem','ort_parca_ticari_ml'),
                    ('sifir_fiyatli_hacim_gl','sifir_fiyatli_islem','ort_parca_sifir_ml'),
                    ('toplam_hacim_gl','toplam_islem','ort_parca_toplam_ml')):
        if k[i] and not yakin(k[h] * 1000 / k[i], k[o], 1.5):
            return f'{o}: hesap {k[h]*1000/k[i]:.1f} ≠ rapor {k[o]}'
    return None
ekle('tahsis_ticareti', 9, 10,
     ['ticari_hacim_gl','sifir_fiyatli_hacim_gl','toplam_hacim_gl',
      'ticari_islem','sifir_fiyatli_islem','toplam_islem','yuzde',
      'ort_parca_ticari_ml','ort_parca_sifir_ml','ort_parca_toplam_ml'],
     t9, birim='GL / adet / ML')

# ── T10–T18 ──────────────────────────────────────────────────────────────
ekle('arz_kullanim_kuzey', 10, 4,
     ['devreden_gl','yeni_mevsimlik_gl','net_ticaret_gl','kullanim_gl'], birim='GL')
ekle('arz_kullanim_goulburn_murray', 11, 5,
     ['devreden_gl','yeni_mevsimlik_gl','net_ticaret_gl','kullanim_gl',
      'medyan_tahsis_fiyat_aud_ml'], birim='GL / AUD-ML')
ekle('eyaletlerarasi_net', 12, 3, ['nsw_den_gl','sa_dan_gl','toplam_gl'],
     lambda k: None if yakin((k['nsw_den_gl'] or 0)+(k['sa_dan_gl'] or 0), k['toplam_gl'], 2)
     else 'toplam tutmuyor', birim='GL')
ekle('devir_parki', 15, 5,
     ['devir_parki_gl','diger_ticari_gl','veri_yok_gl',
      'devir_parki_medyan_fiyat_aud_ml','genel_medyan_fiyat_aud_ml'], birim='GL / AUD-ML')
ekle('topraksiz_suyun_akibeti', 16, 5,
     ['ticari_satildi_gl','sifirla_devredildi_gl','kayip_buharlasma_gl',
      'devreden_gl','devreden_yuzde'], birim='GL / %')
ekle('devreden_su', 17, 2, ['devreden_gl','devreden_yuzde'], birim='GL / %')
ekle('kaynak_dagilimi_ozet', 18, 6,
     ['devreden_gl','yeni_mevsimlik_gl','ticari_alinan_net_gl',
      'sifirla_gelen_net_gl','kullanim_gl','medyan_tahsis_fiyat_aud_ml'],
     birim='GL / AUD-ML')

# ── T1: piyasa katılımı (DEVRİK — yıllar kolonda) ────────────────────────
b1, ad1 = blok(1)
yillar, hesap = [], {}
for ln in b1.split('\n'):
    l = ' '.join(ln.split())
    m = re.match(r'Water year ((?:(?:19|20)\d{2}-\d{2}\s*)+)$', l)
    if m:
        yillar = m.group(1).split()
    for etiket, alan in (('Frequent trader accounts','sik_ticaret_yapan'),
                         ('All other trader accounts','diger'),
                         ('Total unique accounts trading','toplam')):
        if l.startswith(etiket):
            hesap[alan] = [sayi(x) for x in HUC.findall(l[len(etiket):])]
if not yillar or len(hesap) != 3:
    sys.exit('HATA: Tablo 1 devrik yerleşimi okunamadı')
k1 = []
for i, y in enumerate(yillar):
    k = {'yil': y, **{a: hesap[a][i] for a in hesap}}
    if not yakin(k['sik_ticaret_yapan'] + k['diger'], k['toplam'], 1):
        sys.exit(f'HATA: Tablo 1 · {y} hesap toplamı tutmuyor')
    k['sik_ticaret_yapan_yuzde'] = round(100 * k['sik_ticaret_yapan'] / k['toplam'], 2)
    k1.append(yil_no(k))
cikti['piyasa_katilimi'] = {'_tablo':'Table 1','_baslik':ad1,'_birim':'hesap adedi','kayitlar':k1}
rapor.append((1,'piyasa_katilimi',len(k1),k1[0]['yil'],k1[-1]['yil']))

# ── T19: suyun kaynağı, kategori kırılımlı (yıl başlıklı bloklar) ────────
b19, ad19 = blok(19)
KAT = ('GMW Districts','GMW Diverters','LMW Districts','LMW Diverters','Subtotal')
ADL = dict(zip(KAT, ('gmw_bolge','gmw_ceken','lmw_bolge','lmw_ceken','ara_toplam')))
ALAN = ('devreden_gl','yeni_mevsimlik_gl','net_ticaret_gl','kullanim_gl')
k19, suan = [], None
for ln in b19.split('\n'):
    l = ' '.join(ln.split())
    y = re.fullmatch(r'((?:19|20)\d{2}-\d{2})', l)
    if y:
        suan = {'yil': y.group(1)}; k19.append(suan); continue
    for kat in KAT:
        if suan and l.startswith(kat):
            h = [sayi(x) for x in HUC.findall(l[len(kat):])]
            if len(h) == 4:
                suan[ADL[kat]] = dict(zip(ALAN, h))
k19 = [k for k in k19 if 'ara_toplam' in k]
for k in k19:
    for alan in ALAN:
        t = sum(k[a][alan] for a in ('gmw_bolge','gmw_ceken','lmw_bolge','lmw_ceken') if a in k)
        if not yakin(t, k['ara_toplam'][alan], 3):
            sys.exit(f'HATA: Tablo 19 · {k["yil"]} · {alan}: {t} ≠ {k["ara_toplam"][alan]}')
    yil_no(k)
if not k19:
    sys.exit('HATA: Tablo 19 okunamadı')
cikti['kaynak_dagilimi'] = {'_tablo':'Table 19','_baslik':ad19,'_birim':'GL','kayitlar':k19}
rapor.append((19,'kaynak_dagilimi',len(k19),k19[0]['yil'],k19[-1]['yil']))

veri = {
 '_kaynak': 'Victorian Water Register — Water Market Trends: Trends in Northern '
            'Victorian Water Trade 2001–2024 (2025 güncellemesi)',
 '_kaynak_niteligi': 'SİCİLİN BEYANI',
 '_kapsam': 'kuzey Victoria — Avustralya geneli değil',
 '_ham_dosya': str(HAM),
 '_not': "T4/T5 fiyatları MEDYAN. T9 'ticari' = fiyatı $0'dan büyük işlemler. "
         "T15 yalnızca 2020-21'den itibaren: 'ticaret gerekçesi' verisi o yıl "
         "toplanmaya başladı.",
 **cikti}
pathlib.Path('tablolar.json').write_text(
    json.dumps(veri, ensure_ascii=False, indent=2), encoding='utf-8')

print(f'{"T":>3s}  {"anahtar":<30s} {"satır":>5s}  aralık')
for no, ad, n, i, s in sorted(rapor):
    print(f'{no:>3d}  {ad:<30s} {n:>5d}  {i} → {s}')
print(f'\n✓ {len(rapor)} tablo · tablolar.json')
