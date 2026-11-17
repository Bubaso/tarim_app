#!/usr/bin/env python3
"""Yapay Zeka ve Dijital Tarım — bölüm iskeleti.

NEDEN BETİK: iskelet üç şeye birden bağlı — süreç ekseni, teknoloji
etiketleri ve otomatik güncelleme hedefleri. Elle yazılmış bir JSON'da
bir başlığın etiketi silinir ya da süreç sırası bozulursa kimse görmez.
Burada iskelet KURALLARIYLA birlikte üretiliyor ve kurallar durduruyor.

KARARLAR (KARARLAR.md):
  · 25-30 başlık (karar 9)
  · süreç ekseni ana iskelet + teknoloji etiketleriyle çapraz gezinme (13)
  · eleştirel katman KENDİ ana bölümü (36), abartılar AYRI bölüm (37)
  · tarihçe + saha hikâyeleri (41), sözlük (14), kaynakça (15)
  · başlık düzeni konuya göre değişir (12) — ama her başlık otomatik
    güncellenen alanlarını KÜNYESİNDE taşır. Biçim serbest, HEDEF KAYITLI.
  · Türkiye zorlanmaz (5): "varsa yazılır yoksa dünya kalır". Bu yüzden
    her başlığın `turkiye` alanı bir SÖZ değil bir DURUM: 'var' ya da
    'bilinmiyor' — yazım turu ölçüp güncelleyecek.

Çalıştırma: python3 content/yapay_zeka_dijital_tarim/_raw/iskelet_uret.py
"""
from __future__ import annotations
import json, pathlib, re, sys

KOK = pathlib.Path(__file__).parent

# ── TEKNOLOJİ ETİKETLERİ (çapraz eksen) ───────────────────────────────
TEKNOLOJI = {
    "goruntu":   {"tr": "Görüntü işleme",              "en": "Computer vision"},
    "tahmin":    {"tr": "Tahmin modelleri",            "en": "Predictive models"},
    "uzaktan":   {"tr": "Uzaktan algılama",            "en": "Remote sensing"},
    "robotik":   {"tr": "Robotik ve otonom sistemler", "en": "Robotics and autonomy"},
    "sensor":    {"tr": "Sensörler ve nesnelerin interneti", "en": "Sensors and IoT"},
    "dil":       {"tr": "Dil modelleri",               "en": "Language models"},
    "karar":     {"tr": "Karar destek sistemleri",     "en": "Decision support"},
    "ikiz":      {"tr": "Dijital ikiz",                "en": "Digital twin"},
    "veri":      {"tr": "Veri platformları",           "en": "Data platforms"},
    "genomik":   {"tr": "Genomik ve ıslah",            "en": "Genomics and breeding"},
}

# ── OTOMATİK GÜNCELLEME HEDEFLERİ (karar 16) ──────────────────────────
OTO = {"sayi", "dizin", "mevzuat", "gelisme"}
# sayi: sayılar ve seriler · dizin: Türkiye dizini
# mevzuat: mevzuat ve politika · gelisme: yeni gelişme + başlık önerisi

# ── KATMANLAR — merkez sayfanın haritası bunları gruplar ───────────────
KATMAN = {
    "cerceve":  {"tr": "Çerçeve",               "en": "Framework"},
    "surec":    {"tr": "Tarlanın takvimi",      "en": "The field's calendar"},
    "alan":     {"tr": "Üretim alanları",       "en": "Production domains"},
    "zincir":   {"tr": "Zincirin öteki ucu",    "en": "Along the chain"},
    "altyapi":  {"tr": "Altyapı",               "en": "Infrastructure"},
    "cografya": {"tr": "Dünya ve Türkiye",      "en": "World and Türkiye"},
    "elestiri": {"tr": "Eleştirel bakış",       "en": "Critical view"},
    "basvuru":  {"tr": "Anlatı ve başvuru",     "en": "Stories and reference"},
}

def b(no, slug, katman, tr, en, teknoloji, oto, *, surec=None, ozet_tr="", ozet_en=""):
    return {"no": no, "slug": slug, "katman": katman,
            "baslik": {"tr": tr, "en": en},
            "surec_sirasi": surec, "teknoloji": teknoloji,
            "oto_hedefler": sorted(oto),
            "turkiye": "bilinmiyor",
            "ozet": {"tr": ozet_tr, "en": ozet_en},
            "durum": "iskelet"}

BASLIKLAR = [
    # ── ÇERÇEVE ───────────────────────────────────────────────────────
    b(1, "bugun-nerede-duruyoruz", "cerceve",
      "Bugün nerede duruyoruz", "Where things stand today",
      ["tahmin", "goruntu", "uzaktan", "robotik", "dil"], {"sayi", "gelisme"},
      ozet_tr="Tezin yerine geçen durum tespiti: alanın bugünkü hâli, ölçülmüş birkaç rakamla. Tarama bu özeti günceller.",
      ozet_en="A status reading in place of a thesis: the field today in a few measured figures. The scan keeps it current."),
    b(2, "kavramlar", "cerceve",
      "Kavramlar: yapay zeka, dijital tarım, hassas tarım", "Terms: AI, digital farming, precision farming",
      ["veri", "karar"], set(),
      ozet_tr="Üç kavram sık sık birbirinin yerine kullanılıyor ve aynı şey değiller.",
      ozet_en="Three terms used as if interchangeable, which they are not."),
    b(3, "tarihce", "cerceve",
      "Kısa tarihçe", "A short history",
      ["karar", "uzaktan", "goruntu"], set(),
      ozet_tr="Uzman sistemlerden görüntü işlemeye, uydudan dil modellerine: dönüm noktaları ve kişiler.",
      ozet_en="From expert systems to computer vision, from satellites to language models: turning points and people."),

    # ── TARLANIN TAKVİMİ — süreç ekseni ───────────────────────────────
    b(4, "toprak-ve-arazi", "surec", "Toprak ve arazi", "Soil and land",
      ["uzaktan", "sensor", "tahmin", "veri"], {"sayi", "mevzuat", "gelisme"}, surec=1,
      ozet_tr="Toprak haritalama ve arazi planlaması: küresel haritanın gücü, tarla ölçeğinde sınırı, Türkiye'nin detaylı toprak etüdü.",
      ozet_en="Soil mapping and land planning: the reach of the global map, its limits at field scale, Türkiye's detailed soil survey."),
    b(5, "tohum-islah-genetik", "surec", "Tohum, ıslah ve genetik", "Seed, breeding and genetics",
      ["genomik", "tahmin", "goruntu"], {"sayi", "gelisme"}, surec=2,
      ozet_tr="Fenotipleme, genomik seçilim, ıslah süresinin kısaltılması.",
      ozet_en="Phenotyping, genomic selection, shortening the breeding cycle."),
    b(6, "ekim-ve-degisken-oran", "surec", "Ekim ve değişken oranlı uygulama", "Sowing and variable-rate application",
      ["karar", "uzaktan", "robotik", "sensor"], {"sayi", "gelisme"}, surec=3,
      ozet_tr="Tarlanın her parçasına aynı muameleyi bırakmak: değişken oranlı tohum ve gübre.",
      ozet_en="Ending uniform treatment of a field: variable-rate seed and fertiliser."),
    b(7, "sulama-ve-su", "surec", "Sulama ve su yönetimi", "Irrigation and water",
      ["sensor", "tahmin", "uzaktan", "karar"], {"sayi", "mevzuat", "gelisme"}, surec=4,
      ozet_tr="Ne zaman, ne kadar: sensör ve tahmine dayalı sulama.",
      ozet_en="When and how much: irrigation driven by sensors and forecasts."),
    b(8, "goruntu-isleme-ve-hedefli-ilaclama", "surec",
      "Görüntü işleme ve hedefli ilaçlama", "Computer vision and targeted spraying",
      ["goruntu", "robotik", "tahmin"], {"sayi", "gelisme"}, surec=5,
      ozet_tr="Yabancı otu, hastalığı ve zararlıyı görmek — ve ilacı yalnız oraya atmak.",
      ozet_en="Seeing weeds, disease and pests — and spraying only there."),
    b(9, "urun-izleme-ve-verim-tahmini", "surec", "Ürün izleme ve verim tahmini", "Crop monitoring and yield forecasting",
      ["uzaktan", "tahmin", "goruntu"], {"sayi", "gelisme"}, surec=6,
      ozet_tr="Hasattan önce rekoltenin bilinmesi: uydu, model ve belirsizlik.",
      ozet_en="Knowing the harvest before it comes: satellites, models and uncertainty."),
    b(10, "hasat-ve-robotik", "surec", "Hasat ve robotik", "Harvest and robotics",
      ["robotik", "goruntu"], {"sayi", "gelisme"}, surec=7,
      ozet_tr="Hasat zamanlaması ve robotik toplama — en zor mühendislik problemi neden meyvede.",
      ozet_en="Harvest timing and robotic picking — why fruit is the hardest engineering problem."),
    b(11, "hasat-sonrasi", "surec", "Hasat sonrası: sınıflandırma, kalite, depolama", "Post-harvest: grading, quality, storage",
      ["goruntu", "sensor", "tahmin"], {"sayi", "gelisme"}, surec=8,
      ozet_tr="Ürünün tarladan çıktıktan sonra kaybolmaması: sınıflandırma ve depolama.",
      ozet_en="Keeping produce from being lost after it leaves the field: grading and storage."),

    # ── ÜRETİM ALANLARI ───────────────────────────────────────────────
    b(12, "hayvancilik", "alan", "Hayvancılık", "Livestock",
      ["sensor", "goruntu", "tahmin", "karar"], {"sayi", "gelisme"},
      ozet_tr="Hassas hayvancılık: hastalığı belirtiden önce görmek, sürüyü tek tek tanımak.",
      ozet_en="Precision livestock farming: seeing disease before symptoms, knowing animals one by one."),
    b(13, "sera-ve-kontrollu-ortam", "alan", "Sera ve kontrollü ortam", "Greenhouse and controlled environment",
      ["sensor", "ikiz", "karar", "robotik"], {"sayi", "gelisme"},
      ozet_tr="Her değişkenin ölçüldüğü yer: iklim kontrolü, dikey tarım, dijital ikiz.",
      ozet_en="Where every variable is measured: climate control, vertical farming, digital twins."),
    b(14, "su-urunleri", "alan", "Su ürünleri", "Aquaculture and fisheries",
      ["sensor", "goruntu", "tahmin"], {"sayi", "gelisme"},
      ozet_tr="Yem, su kalitesi, balık sağlığı ve av takibi.",
      ozet_en="Feed, water quality, fish health and catch monitoring."),
    b(15, "ormancilik", "alan", "Ormancılık", "Forestry",
      ["uzaktan", "goruntu", "tahmin"], {"sayi", "mevzuat", "gelisme"},
      ozet_tr="Yangın erken uyarısı, ağaç sayımı, kaçak kesim tespiti.",
      ozet_en="Fire early warning, tree counting, detecting illegal logging."),

    # ── ZİNCİRİN ÖTEKİ UCU ────────────────────────────────────────────
    b(16, "pazar-fiyat-tedarik", "zincir", "Pazar, fiyat ve tedarik zinciri", "Markets, prices and supply chain",
      ["tahmin", "veri"], {"sayi", "gelisme"},
      ozet_tr="Fiyat tahmini, talep planlaması, izlenebilirlik.",
      ozet_en="Price forecasting, demand planning, traceability."),
    b(17, "iklim-risk-sigorta", "zincir", "İklim, risk ve tarım sigortası", "Climate, risk and crop insurance",
      ["uzaktan", "tahmin", "karar"], {"sayi", "mevzuat", "gelisme"},
      ozet_tr="Erken uyarı, hasar tespiti, endeks sigortası.",
      ozet_en="Early warning, loss assessment, index insurance."),
    b(18, "danismanlik-ve-dil-modelleri", "zincir", "Danışmanlık ve dil modelleri", "Advisory services and language models",
      ["dil", "karar"], {"sayi", "gelisme"},
      ozet_tr="Çiftçinin sorusuna cevap veren makine: yayım hizmeti ve sohbet botları.",
      ozet_en="A machine that answers the farmer: extension services and chatbots."),

    # ── ALTYAPI ───────────────────────────────────────────────────────
    b(19, "uydu-ve-uzaktan-algilama", "altyapi", "Uydu ve uzaktan algılama", "Satellites and remote sensing",
      ["uzaktan", "goruntu", "veri"], {"sayi", "gelisme"},
      ozet_tr="Tarımsal yapay zekanın en büyük açık veri kaynağı: Sentinel, Landsat, ticari uydular, İHA.",
      ozet_en="The largest open data source for agricultural AI: Sentinel, Landsat, commercial satellites, drones."),
    b(20, "sensorler-ve-iot", "altyapi", "Sensörler ve tarımsal nesnelerin interneti", "Sensors and agricultural IoT",
      ["sensor", "veri"], {"sayi", "gelisme"},
      ozet_tr="Tarladaki ölçüm cihazları ve onları birbirine bağlayan ağ — kırsal bağlantı sorunu dahil.",
      ozet_en="Measuring devices in the field and the network that links them — rural connectivity included."),
    b(21, "veri-sahiplik-platform", "altyapi", "Veri: sahiplik, platformlar, açık veri", "Data: ownership, platforms, open data",
      ["veri"], {"mevzuat", "gelisme"},
      ozet_tr="Tarladan çıkan verinin kime ait olduğu — çiftçi mi, makine üreticisi mi, platform mu.",
      ozet_en="Who owns the data that leaves the field — the farmer, the machinery maker or the platform."),

    # ── DÜNYA VE TÜRKİYE ──────────────────────────────────────────────
    b(22, "dunyada-durum", "cografya", "Dünyada durum: bölge bölge", "The world, region by region",
      ["tahmin", "goruntu", "uzaktan", "robotik", "dil"], {"sayi", "mevzuat", "gelisme"},
      ozet_tr="AB, ABD, Çin, Hindistan, İsrail, Afrika: kim nerede, hangi ölçekte.",
      ozet_en="EU, US, China, India, Israel, Africa: who is where, at what scale."),
    b(23, "turkiyede-durum", "cografya", "Türkiye'de durum", "Türkiye today",
      ["karar", "uzaktan", "veri", "goruntu"], {"sayi", "mevzuat", "dizin", "gelisme"},
      ozet_tr="Ulusal planda tarım var, bakanlık yok; yıllık programın tek yapay zeka işi, bakanlığın sahadaki izleme sistemleri, TAGEM'in projeleri ve beklemedeki strateji belgesi.",
      ozet_en="Agriculture is in the national plan, the ministry is not; the annual programme's single AI task, the ministry's monitoring systems in the field, TAGEM's projects and the pending strategy."),
    b(24, "mevzuat-ve-politika", "cografya", "Mevzuat ve politika", "Regulation and policy",
      ["veri", "karar"], {"mevzuat", "gelisme"},
      ozet_tr="AB Yapay Zeka Tüzüğü, veri ve makine mevzuatı, uydu izlemesini şart koşan tarım kuralı — ve Türkiye'de yolda olan çerçeve.",
      ozet_en="The EU AI Act, data and machinery law, the farm rule that requires satellite monitoring — and the framework on its way in Türkiye."),
    b(25, "turkiye-dizini", "cografya", "Türkiye dizini: girişimler, üniversiteler, kamu projeleri", "Türkiye directory: start-ups, universities, public projects",
      ["goruntu", "tahmin", "robotik", "sensor", "dil", "uzaktan"], {"dizin", "gelisme"},
      ozet_tr="Kamunun yapay zekâ sistemleri ve projeleri, TÜBİTAK'ın tarım projeleri, üniversite merkezleri ve girişimler — her biri kaynağıyla.",
      ozet_en="Public AI systems and projects, TÜBİTAK's agriculture projects, university centres and start-ups — each with its source."),

    # ── ELEŞTİREL BAKIŞ ───────────────────────────────────────────────
    b(26, "riskler-ve-sinirlar", "elestiri", "Riskler ve sınırlar", "Risks and limits",
      ["veri", "tahmin", "dil"], {"sayi", "gelisme"},
      ozet_tr="Laboratuvarın dışında düşen model başarısı, dijital uçurum, emek, güvenlik ve enerji — ve Türkiye'nin küçük, yaşlanan işletmeleri.",
      ozet_en="Model accuracy that falls outside the lab, the digital divide, labour, security and energy — and Türkiye's small, ageing farms."),
    b(27, "basarisizliklar-ve-abartilar", "elestiri", "Başarısız örnekler ve abartılar", "Failures and overstatements",
      ["tahmin", "goruntu", "robotik"], {"gelisme"},
      ozet_tr="Yapay zekâ vaadiyle büyüyüp iflas eden şirketler, ticarileşmeyen hasat robotları, yeniden hesaplanan bir FAO rakamı ve hedeflerinin gerisinde kalan bir Türkiye projesi.",
      ozet_en="Companies that grew on AI promises and went bankrupt, harvesting robots that never reached the market, a recalculated FAO figure and a Turkish project behind its targets."),

    # ── ANLATI VE BAŞVURU ─────────────────────────────────────────────
    b(28, "saha-hikayeleri", "basvuru", "Saha hikâyeleri", "Stories from the field",
      ["goruntu", "sensor", "dil", "robotik"], {"gelisme"},
      ozet_tr="Teknolojiyi kullanan gerçek üreticiler ve tarlalar — kaynaklı.",
      ozet_en="Real growers and fields using the technology — with sources."),
    b(29, "sozluk", "basvuru", "Sözlük", "Glossary",
      list(TEKNOLOJI), {"gelisme"},
      ozet_tr="Metinde geçen her terim; metin içinde balon olarak da açılır.",
      ozet_en="Every term used in the text; also opens as a tooltip in place."),
    b(30, "kaynakca", "basvuru", "Kaynakça", "Sources",
      [], set(),
      ozet_tr="Kaynakların listesi. Her rakamın niteliği kendi yanında duruyor.",
      ozet_en="The list of sources. Each figure's standing is shown beside the figure itself."),
]

# ── HABER ALAN BAŞLIKLAR (karar 32: haberler ilgili başlığın altında) ──
# Haber yalnız konu başlıklarına bağlanır. Çerçeve (1-3), dünya ve Türkiye
# özetleri (22-23), Türkiye dizini (25), saha hikâyeleri (28) ve başvuru
# sayfaları (29-30) elle yazılan sayfalar: haber almaz. Türkiye dizinine
# aday, hattın ayrı alanından (`turkiye_adayi`) kuyruğa düşer.
# Bu küme hattın (`~/tarim_ai_pipeline/src/utils/yz_bolumu.py`, BASLIKLAR)
# ve panelin başlık seçicisinin TEK kaynağı; hat ayrıştığında durur.
HABER_ALMAYAN = {1, 2, 3, 22, 23, 25, 28, 29, 30}
for x in BASLIKLAR:
    x["haber_alir"] = x["no"] not in HABER_ALMAYAN

# ── YAZIM DURUMU — elle değil, dosyalardan ───────────────────────────
# Bir başlık ancak iki dili de yazılmışsa VE kilitli kaydı varsa "yazildi"
# sayılır (dogrula_bolumler.py aynı üçlüyü sınıyor). Türkiye durumu da
# başlığın kendi kaydından okunur: ölçülmeden 'var' yazılmaz (karar 5).
for x in BASLIKLAR:
    on = f"{x['no']:02d}-{x['slug']}"
    tr = KOK.parent / "bolumler" / f"{on}.tr.md"
    en = KOK.parent / "bolumler" / f"{on}.en.md"
    kayit = KOK / f"b{x['no']:02d}_kaynaklar.json"
    if tr.exists() and en.exists() and kayit.exists():
        x["durum"] = "yazildi"
        t = (json.loads(kayit.read_text(encoding="utf-8")).get("turkiye") or {}).get("durum", "")
        x["turkiye"] = "var" if str(t).startswith("var") else ("yok" if str(t).startswith("yok") else "bilinmiyor")

# ══ KURALLAR — iskelet bunları geçmeden yazılmaz ══════════════════════
hata = []
if not HABER_ALMAYAN <= {x["no"] for x in BASLIKLAR}:
    hata.append(f"HABER_ALMAYAN iskelette olmayan numara taşıyor: {sorted(HABER_ALMAYAN - set(x['no'] for x in BASLIKLAR))}")
for x in BASLIKLAR:
    if x["haber_alir"] and x["katman"] in ("cerceve", "basvuru"):
        hata.append(f"§{x['no']} {x['katman']} katmanında ama haber alıyor")
if not (25 <= len(BASLIKLAR) <= 30):
    hata.append(f"başlık sayısı {len(BASLIKLAR)} — karar 9: 25-30")
nolar = [x["no"] for x in BASLIKLAR]
if nolar != list(range(1, len(BASLIKLAR) + 1)):
    hata.append(f"numaralar ardışık değil: {nolar}")
sluglar = [x["slug"] for x in BASLIKLAR]
if len(set(sluglar)) != len(sluglar):
    hata.append("slug tekrarlı")
for x in BASLIKLAR:
    # ASCII adres (§2.1) — Türkçe harf adrese girmez
    if not re.fullmatch(r"[a-z0-9]+(-[a-z0-9]+)*", x["slug"]):
        hata.append(f"§{x['no']} slug ASCII değil ya da biçimsiz: {x['slug']!r}")
    for t in x["teknoloji"]:
        if t not in TEKNOLOJI:
            hata.append(f"§{x['no']} bilinmeyen teknoloji etiketi {t!r}")
    for o in x["oto_hedefler"]:
        if o not in OTO:
            hata.append(f"§{x['no']} bilinmeyen oto hedef {o!r}")
    if x["katman"] not in KATMAN:
        hata.append(f"§{x['no']} bilinmeyen katman {x['katman']!r}")
    if not x["ozet"]["tr"] or not x["ozet"]["en"]:
        hata.append(f"§{x['no']} özet iki dilde dolu değil (karar 7)")
# Süreç ekseni kesintisiz ve sıralı olmalı
surec = [x["surec_sirasi"] for x in BASLIKLAR if x["katman"] == "surec"]
if surec != list(range(1, len(surec) + 1)):
    hata.append(f"süreç ekseni sıralı değil: {surec}")
# Kararla bağlı başlıklar VAR mı
for gerekli, karar in (("riskler-ve-sinirlar", 36), ("basarisizliklar-ve-abartilar", 37),
                       ("sozluk", 14), ("kaynakca", 15), ("tarihce", 41),
                       ("saha-hikayeleri", 41), ("turkiye-dizini", 38),
                       ("bugun-nerede-duruyoruz", 6)):
    if gerekli not in sluglar:
        hata.append(f"karar {karar} gereği '{gerekli}' başlığı yok")
# Her teknoloji etiketi en az bir başlıkta kullanılıyor — ölü etiket olmasın
kullanilan = {t for x in BASLIKLAR for t in x["teknoloji"]}
olu = set(TEKNOLOJI) - kullanilan
if olu:
    hata.append(f"hiçbir başlıkta kullanılmayan etiket: {sorted(olu)}")
# Türkiye dizini otomatik güncellenmeli (karar 38)
if "dizin" not in next(x for x in BASLIKLAR if x["slug"] == "turkiye-dizini")["oto_hedefler"]:
    hata.append("karar 38: Türkiye dizini otomatik güncellenmeli")

if hata:
    print("İSKELET YAZILMADI:", file=sys.stderr)
    for h in hata:
        print("  ✗", h, file=sys.stderr)
    sys.exit(1)

cikti = {
    "_ne": "Yapay Zeka ve Dijital Tarım — bölüm iskeleti",
    "_uretim": "_raw/iskelet_uret.py — elle düzenlenmez",
    "_kural": ("Biçim serbest (karar 12), HEDEF KAYITLI: her başlığın "
               "`oto_hedefler`i taramanın o başlıkta neyi güncelleyebileceğini "
               "söylüyor. Listede olmayan alanı tarama ÖNERMEZ."),
    "_turkiye_notu": ("`turkiye` bir söz değil bir durum: 'var' ya da "
                      "'bilinmiyor'. Kullanıcı kararı (5): 'her başlıkta "
                      "Türkiye ile ilgili bir şey yazacağım diye kasmayalım.' "
                      "Yazım turu ölçüp günceller; ölçülmeden 'var' yazılmaz."),
    "adres": "/yapay-zeka-dijital-tarim",
    "ad": {"tr": "Yapay Zeka ve Dijital Tarım", "en": "AI and Digital Agriculture"},
    "katmanlar": KATMAN,
    "teknoloji": TEKNOLOJI,
    "oto_hedef_tanimi": {
        "sayi": "Sayılar ve seriler — kaynağı kilitli olanlar tazelenir",
        "dizin": "Türkiye dizini — yeni kayıt taslak olarak önerilir",
        "mevzuat": "Mevzuat ve politika — Resmî Gazete, bakanlık, AB",
        "gelisme": "Yeni gelişme ve başlık önerisi",
    },
    "basliklar": BASLIKLAR,
}
(KOK.parent / "iskelet.json").write_text(
    json.dumps(cikti, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

print(f"✓ iskelet.json · {len(BASLIKLAR)} başlık · {len(KATMAN)} katman · "
      f"{len(TEKNOLOJI)} teknoloji etiketi")
for k in KATMAN:
    grup = [x for x in BASLIKLAR if x["katman"] == k]
    print(f"  {KATMAN[k]['tr']:22s} {len(grup):2d} · " +
          ", ".join(f"§{x['no']}" for x in grup))
oto_say = {o: sum(o in x["oto_hedefler"] for x in BASLIKLAR) for o in sorted(OTO)}
print("  oto hedef dağılımı:", oto_say)
