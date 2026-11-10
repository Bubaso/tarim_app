def lin(c):
    c = c/255
    return c/12.92 if c <= 0.03928 else ((c+0.055)/1.055)**2.4
def L(hx):
    hx = hx.lstrip('#')
    r,g,b = (int(hx[i:i+2],16) for i in (0,2,4))
    return 0.2126*lin(r)+0.7152*lin(g)+0.0722*lin(b)
def cr(a,b):
    la,lb = L(a),L(b)
    hi,lo = max(la,lb),min(la,lb)
    return (hi+0.05)/(lo+0.05)

KAGIT="#E3E7E5"; YUZEY="#F0F2F0"; MUREKKEP="#15191A"; SESSIZ="#575F61"
RAY="#C0C6C3"; KURAL="#767E7C"
KZEMIN="#131718"; KYUZEY="#1D2325"; KMUREKKEP="#F0F2F0"; KSESSIZ="#98A1A2"

print("=== Kağıt gövde ===")
for ad,hx in [("murekkep",MUREKKEP),("sessiz",SESSIZ),("ray",RAY),("kuralVurgu",KURAL),("yuzey",YUZEY)]:
    print(f"  {ad:12} {hx}  kagit {cr(hx,KAGIT):5.2f}  yuzey {cr(hx,YUZEY):5.2f}")
print("  kagit vs app krem #F6F1E7 :", round(cr(KAGIT,"#F6F1E7"),3))

print("=== Koyu kapak ===")
for ad,hx in [("murekkep",KMUREKKEP),("sessiz",KSESSIZ),("yuzey",KYUZEY)]:
    print(f"  {ad:12} {hx}  zemin {cr(hx,KZEMIN):5.2f}")

kumeler = [
 ("Kamu gucu","#8E2B24","#E88079"),
 ("Finans","#1D5B4A","#6FC3A4"),
 ("Uretici orgutu","#8A5410","#E0A54F"),
 ("Piyasa altyapisi","#2A4E84","#86ABE8"),
 ("Bilgi","#58397F","#B294E6"),
 ("Su-toprak","#11616B","#4FC0CB"),
 ("Meslek","#5F5417","#C6B457"),
 ("Hayalet","#5C6264","#A4ABAD"),
 ("Uretim","#1F5626","#4CC756"),   # TİGEM · Sayı 06 · dizinin dokuzuncu kümesi
]
print("=== Kume vurgulari ===")
print(f"  {'kume':18} {'kagit':8} {'/kagit':>7} {'/yuzey':>7}   {'kapak':8} {'/kapak':>7}")
for ad,k,d in kumeler:
    a,b,c = cr(k,KAGIT), cr(k,YUZEY), cr(d,KZEMIN)
    flag = "" if (a>=4.5 and b>=4.5 and c>=4.5) else "   <-- AA ALTI"
    print(f"  {ad:18} {k:8} {a:7.2f} {b:7.2f}   {d:8} {c:7.2f}{flag}")

# DOKUZUNCU KÜME — TİGEM dosyasında (Sayı 06) kuruldu. Gerekçesi tasarim.json'da:
# devletin BİZZAT ÜRETİCİ olması; Türkşeker ve Et ve Süt Kurumu da buraya girer.
#
# RENK KÖRLÜĞÜ ÖLÇÜLDÜ VE SONUÇ DİZİ GENELİNİ İLGİLENDİRİYOR. Bu betik yalnız
# WCAG kontrastı hesaplıyor; kontrast oranı HUE AYRIMINI ÖLÇMEZ. Lab ΔE ve
# Viénot-Mollon benzetimiyle ölçüldüğünde (tigem/_raw/kontrast.py):
#   · mevcut sekiz kümenin kendi içindeki en küçük deuteranopi ΔE'si  1,95
#   · dokuzuncu kümenin en yakın kümeye deuteranopi ΔE'si             3,62
# Yani kümeler renk körü okur için DİZİ KURULDUĞUNDAN BERİ ayrışmıyor.
# Dokuzuncu küme bunu kötüleştirmiyor ama düzeltmiyor da. Kalıcı çözüm renk
# değil: arşiv ve şerit küme adını YAZIYLA da göstermeli.
