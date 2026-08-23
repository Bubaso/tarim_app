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
]
print("=== Kume vurgulari ===")
print(f"  {'kume':18} {'kagit':8} {'/kagit':>7} {'/yuzey':>7}   {'kapak':8} {'/kapak':>7}")
for ad,k,d in kumeler:
    a,b,c = cr(k,KAGIT), cr(k,YUZEY), cr(d,KZEMIN)
    flag = "" if (a>=4.5 and b>=4.5 and c>=4.5) else "   <-- AA ALTI"
    print(f"  {ad:18} {k:8} {a:7.2f} {b:7.2f}   {d:8} {c:7.2f}{flag}")
