# Türkiye il ızgara haritası: 81 il, kabaca coğrafi konumuna göre kare hücrelere.
# Koordinatlar il merkezlerinin yaklaşık boylam/enlemi (yalnız yerleşim için;
# haritada veri olarak gösterilmiyor).
import json, math, itertools, sys
IL = {
 1:("Adana",35.32,37.00), 2:("Adıyaman",38.28,37.76), 3:("Afyonkarahisar",30.54,38.76), 4:("Ağrı",43.05,39.72),
 5:("Amasya",35.83,40.65), 6:("Ankara",32.86,39.93), 7:("Antalya",30.71,36.90), 8:("Artvin",41.82,41.18),
 9:("Aydın",27.84,37.85), 10:("Balıkesir",27.88,39.65), 11:("Bilecik",29.98,40.14), 12:("Bingöl",40.50,38.88),
 13:("Bitlis",42.11,38.40), 14:("Bolu",31.61,40.74), 15:("Burdur",30.29,37.72), 16:("Bursa",29.06,40.19),
 17:("Çanakkale",26.41,40.15), 18:("Çankırı",33.62,40.60), 19:("Çorum",34.96,40.55), 20:("Denizli",29.09,37.78),
 21:("Diyarbakır",40.23,37.91), 22:("Edirne",26.56,41.68), 23:("Elazığ",39.22,38.67), 24:("Erzincan",39.49,39.75),
 25:("Erzurum",41.27,39.90), 26:("Eskişehir",30.52,39.78), 27:("Gaziantep",37.38,37.07), 28:("Giresun",38.39,40.91),
 29:("Gümüşhane",39.48,40.46), 30:("Hakkari",43.74,37.58), 31:("Hatay",36.16,36.20), 32:("Isparta",30.55,37.76),
 33:("Mersin",34.64,36.81), 34:("İstanbul",28.98,41.01), 35:("İzmir",27.14,38.42), 36:("Kars",43.10,40.60),
 37:("Kastamonu",33.78,41.38), 38:("Kayseri",35.49,38.73), 39:("Kırklareli",27.22,41.73), 40:("Kırşehir",34.17,39.15),
 41:("Kocaeli",29.92,40.77), 42:("Konya",32.49,37.87), 43:("Kütahya",29.98,39.42), 44:("Malatya",38.31,38.35),
 45:("Manisa",27.43,38.61), 46:("Kahramanmaraş",36.94,37.58), 47:("Mardin",40.74,37.31), 48:("Muğla",28.36,37.22),
 49:("Muş",41.49,38.75), 50:("Nevşehir",34.71,38.62), 51:("Niğde",34.68,37.97), 52:("Ordu",37.88,40.98),
 53:("Rize",40.52,41.02), 54:("Sakarya",30.40,40.78), 55:("Samsun",36.33,41.29), 56:("Siirt",41.94,37.93),
 57:("Sinop",35.15,42.03), 58:("Sivas",37.02,39.75), 59:("Tekirdağ",27.51,40.98), 60:("Tokat",36.55,40.31),
 61:("Trabzon",39.72,41.00), 62:("Tunceli",39.55,39.11), 63:("Şanlıurfa",38.79,37.16), 64:("Uşak",29.41,38.68),
 65:("Van",43.38,38.49), 66:("Yozgat",34.81,39.82), 67:("Zonguldak",31.79,41.45), 68:("Aksaray",34.03,38.37),
 69:("Bayburt",40.23,40.26), 70:("Karaman",33.21,37.18), 71:("Kırıkkale",33.51,39.85), 72:("Batman",41.13,37.89),
 73:("Şırnak",42.46,37.52), 74:("Bartın",32.34,41.64), 75:("Ardahan",42.70,41.11), 76:("Iğdır",44.04,39.92),
 77:("Yalova",29.27,40.65), 78:("Karabük",32.62,41.20), 79:("Kilis",37.12,36.72), 80:("Osmaniye",36.25,37.07),
 81:("Düzce",31.16,40.84),
}
SUTUN, SATIR = int(sys.argv[1]), int(sys.argv[2])
lon0,lon1,lat0,lat1 = 26.2,44.1,36.2,42.0
def hedef(lon,lat):
    x=(lon-lon0)/(lon1-lon0)*(SUTUN-1); y=(lat1-lat)/(lat1-lat0)*(SATIR-1)
    return x,y
hucreler=[(c,r) for r in range(SATIR) for c in range(SUTUN)]
h={p:hedef(v[1],v[2]) for p,v in IL.items()}
def maliyet(p,c): return (h[p][0]-c[0])**2 + 1.6*(h[p][1]-c[1])**2
# açgözlü başlangıç: en yoğun bölgeden başlayarak en yakın boş hücre
atama={}; dolu=set()
for p in sorted(IL, key=lambda p: min(maliyet(p,c) for c in hucreler)):
    c=min((c for c in hucreler if c not in dolu), key=lambda c: maliyet(p,c)); atama[p]=c; dolu.add(c)
# iyileştirme: ikili takas ve boş hücreye taşıma
def toplam(): return sum(maliyet(p,c) for p,c in atama.items())
iyilesti=True
while iyilesti:
    iyilesti=False
    ps=list(atama)
    for a,b in itertools.combinations(ps,2):
        ca,cb=atama[a],atama[b]
        if maliyet(a,cb)+maliyet(b,ca) < maliyet(a,ca)+maliyet(b,cb)-1e-9:
            atama[a],atama[b]=cb,ca; iyilesti=True
    bos=[c for c in hucreler if c not in set(atama.values())]
    for p in ps:
        for c in bos:
            if maliyet(p,c) < maliyet(p,atama[p])-1e-9 and c not in set(atama.values()):
                atama[p]=c; iyilesti=True
print('toplam maliyet %.1f' % toplam())
izgara=[['  .  ']*SUTUN for _ in range(SATIR)]
for p,(c,r) in atama.items(): izgara[r][c]=f'{IL[p][0][:5]:>5}'
for satir in izgara: print(' '.join(satir))
json.dump({str(p):{'ad':IL[p][0],'sutun':c,'satir':r} for p,(c,r) in sorted(atama.items())},
          open(sys.argv[3],'w'),ensure_ascii=False,indent=0)
