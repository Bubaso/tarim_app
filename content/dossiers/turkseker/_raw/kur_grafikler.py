#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""grafikler.json üreteci.

NOTLARDAKİ RAKAMLAR data.json'DAN OKUNUYOR. Mısır dosyasında notlar elle
yazılmıştı ve bir tanesinde yuvarlama hatası çıktı (281,9 ↔ 282,0); orada
denetim yakaladı, burada hata hiç doğmasın diye rakam kaynağından geliyor.
"""
import json, pathlib
from decimal import Decimal, ROUND_HALF_UP

KOK = pathlib.Path(__file__).parent.parent
D = json.loads((KOK / "data.json").read_text(encoding="utf-8"))
T = D["turetilmis"]


def yuv(x, b=1):
    return float(Decimal(str(x)).quantize(Decimal(1).scaleb(-b), rounding=ROUND_HALF_UP))


def tr_sayi(x, b=0):
    """1023820 → 1.023.820 · 36.08 → 36,08"""
    s = f"{yuv(x, b):,.{b}f}"
    return s.replace(",", "\x00").replace(".", ",").replace("\x00", ".")


def en_sayi(x, b=0):
    return f"{yuv(x, b):,.{b}f}"


def ikidil(tr, en):
    return {"tr": tr, "en": en}


# İşaret düzeni: TR'de yüzde işareti ÖNDE, EN'de ARKADA.
YUZDE = {"onek": {"tr": "%", "en": ""}, "sonek": {"tr": "", "en": "%"}}

kimlik, kota, pancar = D["kimlik"], D["kota"], D["pancar"]
seker, ciftci, kurum = D["seker"], D["ciftci"], D["kurum"]
alp, uc = kota["alpullu"], kota["uc_kesim_yuzde"]
kamu_ton = kota["turkseker_a_kotasi_ton"]

g = {}

# ── 1 · künye ────────────────────────────────────────────────────────
g["kunye_turkseker"] = {
    "tur": "kunye",
    "baslik": ikidil("Kurum rakamlarla", "The institution in figures"),
    "kaynak": "TÜRKŞEKER · Şeker Sektör Raporu 2025 ve 2024-2028 Stratejik Plan",
    "not": ikidil(
        f"Kota {kota['yil']} pazarlama yılına ait. Fabrika sayısı TESİS sayısıdır; "
        f"kota tablosundaki {len(T['kota_siralamasi'])} kalem ŞİRKET sayar ve bir şirketin "
        f"birden çok fabrikası olabilir. Personel rakamı 2022 fiili ortalamasıdır; "
        f"taranan belgelerde daha yenisi yok.",
        f"The quota is for the {kota['yil']} marketing year. The factory count is of PLANTS; "
        f"the {len(T['kota_siralamasi'])} entries in the quota table count COMPANIES, and one "
        f"company may own several plants. The staff figure is the 2022 actual average; the "
        f"documents scanned carry nothing more recent."),
    "kalemler": [
        {"deger": "@kimlik.fabrika_bugun", "ondalik": 0,
         "etiket": ikidil("şeker fabrikası", "sugar factories"),
         "alt": ikidil(f"1990 öncesi {kimlik['fabrika_1990_oncesi']}",
                       f"{kimlik['fabrika_1990_oncesi']} before 1990")},
        {"deger": "@kota.turkseker_a_kotasi_ton", "ondalik": 0, "bolen": 1000,
         "etiket": ikidil("bin ton A kotası", "thousand tonnes, A quota"),
         "alt": ikidil(f"pancar şekerinin %{tr_sayi(uc['kamu'], 2)}'i",
                       f"{en_sayi(uc['kamu'], 2)}% of beet sugar")},
        {"deger": "@ciftci.son_sayi", "ondalik": 0,
         "etiket": ikidil("pancar üreticisi", "beet growers"),
         "alt": ikidil(f"{ciftci['son_yil']} · ülke geneli",
                       f"{ciftci['son_yil']} · nationwide")},
        {"deger": "@kurum.personel_2022.toplam", "ondalik": 0,
         "etiket": ikidil("çalışan", "staff"),
         "alt": ikidil(f"alt işverenle {tr_sayi(kurum['personel_2022']['alt_isverenle_toplam'])}",
                       f"{en_sayi(kurum['personel_2022']['alt_isverenle_toplam'])} with contractors")},
    ],
}

# ── 2 · fabrikaların açılışı ─────────────────────────────────────────
g["fabrikalarin_acilisi"] = {
    "tur": "zaman_cizelgesi",
    "baslik": ikidil("Dört fabrikadan bir sanayiye", "From four factories to an industry"),
    "kaynak": "TÜRKŞEKER · Şeker Sektör Raporu 2025, Sektörün Tarihsel Gelişimi",
    "not": ikidil(
        "Uşak'ın temeli Alpullu'dan bir buçuk ay önce atıldı; Alpullu onbir ayda bitti ve ilk "
        "Türk şekerini o üretti. Uşak yirmi bir gün sonra açıldı.",
        "Uşak's foundations were laid six weeks before Alpullu's; Alpullu was finished in eleven "
        "months and made the first Turkish sugar. Uşak opened twenty-one days later."),
    "olaylar": [
        {"yil": 1925, "baslik": ikidil("İki temel atılıyor", "Two foundations are laid"),
         "aciklama": ikidil(
             "6 Kasım'da Uşak'ta, 22 Aralık'ta Alpullu'da şeker fabrikalarının temeli atılır.",
             "On 6 November at Uşak and on 22 December at Alpullu, the foundations are laid.")},
        {"yil": 1926, "baslik": ikidil("İlk Türk şekeri", "The first Turkish sugar"),
         "aciklama": ikidil(
             "26 Kasım'da Alpullu işletmeye açılır ve ilk Türk şekeri üretilir. Uşak 17 Aralık'ta açılır.",
             "On 26 November Alpullu opens and the first Turkish sugar is made. Uşak opens on 17 December.")},
        {"yil": 1933, "baslik": ikidil("Eskişehir", "Eskişehir"),
         "aciklama": ikidil("5 Aralık'ta üçüncü fabrika işletmeye açılır.",
                            "The third factory opens on 5 December.")},
        {"yil": 1934, "baslik": ikidil("Turhal", "Turhal"),
         "aciklama": ikidil("19 Ekim'de dördüncü fabrika işletmeye açılır.",
                            "The fourth factory opens on 19 October.")},
        {"yil": 1935, "baslik": ikidil("Dört şirket tek çatıda", "Four companies, one roof"),
         "aciklama": ikidil(
             f"6 Temmuz'da üç milli banka eşit paylarla ortak olur; {tr_sayi(kimlik['sirket_kurulus_sermaye_tl'] / 1e6)} "
             "milyon TL sermayeli Türkiye Şeker Fabrikaları A.Ş. kurulur.",
             f"On 6 July three national banks take equal shares; Türkiye Şeker Fabrikaları A.Ş. is "
             f"founded with a capital of {en_sayi(kimlik['sirket_kurulus_sermaye_tl'] / 1e6)} million lira.")},
        {"yil": 1956, "baslik": ikidil("Fabrika sayısı on beşe çıkıyor", "The count reaches fifteen"),
         "aciklama": ikidil(
             "1951-1956 arasında on bir yeni fabrika kurulur. Aynı yıl 6747 sayılı Şeker Kanunu çıkar.",
             "Eleven new factories are built between 1951 and 1956. The Sugar Law 6747 is passed the same year.")},
        {"yil": 2001, "baslik": ikidil("4634 sayılı Şeker Kanunu", "Sugar Law 4634"),
         "aciklama": ikidil("19 Nisan'da yürürlüğe girer; üretim kotayla planlanmaya başlar.",
                            "In force from 19 April; production begins to be planned by quota.")},
        {"yil": 2018, "baslik": ikidil("On fabrika el değiştirir", "Ten factories change hands"),
         "aciklama": ikidil(
             "Afyon, Alpullu, Bor, Çorum, Elbistan, Erzincan, Erzurum, Kırşehir, Muş ve Turhal özelleştirilir.",
             "Afyon, Alpullu, Bor, Çorum, Elbistan, Erzincan, Erzurum, Kırşehir, Muş and Turhal are privatised.")},
        {"yil": 2021, "baslik": ikidil("Sermaye Varlık Fonu'na", "Capital to the Wealth Fund"),
         "aciklama": ikidil("29 Nisan tarihli Cumhurbaşkanı Kararı ile sermayenin tamamı devredilir.",
                            "A Presidential Decision of 29 April transfers the entire capital.")},
        {"yil": 2025, "baslik": ikidil("Çarşamba MKE'ye geçer", "Çarşamba passes to MKE"),
         "aciklama": ikidil(
             f"Devir tamamlanır; TÜRKŞEKER {kimlik['fabrika_bugun']} fabrika ile üretim yapar.",
             f"The transfer is completed; TÜRKŞEKER operates {kimlik['fabrika_bugun']} factories.")},
    ],
}

# ── 3 · üç kesim · ikili çubuk ───────────────────────────────────────
ADLAR = {"kamu": ("Kamu · TÜRKŞEKER", "Public · TÜRKŞEKER"),
         "kooperatif": ("Kooperatif · 3 şirket", "Cooperative · 3 companies"),
         "ozel": ("Özel · 11 şirket", "Private · 11 companies")}
g["kota_uc_kesim"] = {
    "tur": "ikili_cubuk",
    "baslik": ikidil("Bir şirket, üçte birden fazlası", "One company, more than a third"),
    "kaynak": "TÜRKŞEKER · Şeker Sektör Raporu 2025, Tablo 24",
    # ŞEMA ÇİZİCİDEN OKUNDU, UYDURULMADI. İlk yazımda satırlara sol/sag
    # diye bir yapı konmuştu; çizici onu tanımadığı için grafik HİÇ
    # ÇİZİLMEDİ ve önizlemede boşluk olarak göründü. Doğrusu: seriler
    # grafik düzeyinde, her satırda `degerler` dizisi.
    #
    # SAYI BİÇİMİ HER SATIRDA TEKRARLANIYOR. Grafik düzeyindeki
    # onek/sonek/ondalik çizici tarafından OKUNMUYOR; biçimi satır
    # sözlüğünden kuruyor (TİGEM'de ölçülmüş: %90,93 "91" çiziliyordu).
    "seriler": [
        {"ad": ikidil("şirket sayısı", "share of companies"), "rol": "ikincil"},
        {"ad": ikidil("kota payı", "share of quota"), "rol": "vurgu"},
    ],
    "not": ikidil(
        f"Pancar şekeri A kotası {kota['yil']} için {tr_sayi(kota['pancar_sekeri_toplam_ton'])} ton. "
        f"On beş üreticinin biri TÜRKŞEKER ve tek başına %{tr_sayi(uc['kamu'], 2)} tutuyor; "
        f"üç kooperatif şirketi %{tr_sayi(uc['kooperatif'], 2)}, on bir özel şirket "
        f"%{tr_sayi(uc['ozel'], 2)}. Her satır kendi içinde oranlanıyor; satırlar birbiriyle değil.",
        f"The beet sugar A quota for {kota['yil']} is {en_sayi(kota['pancar_sekeri_toplam_ton'])} tonnes. "
        f"One of the fifteen producers is TÜRKŞEKER, holding {en_sayi(uc['kamu'], 2)}% on its own; "
        f"three cooperative companies hold {en_sayi(uc['kooperatif'], 2)}% and eleven private "
        f"companies {en_sayi(uc['ozel'], 2)}%. Each row is scaled within itself, not against the others."),
    "satirlar": [
        {"etiket": ikidil(*ADLAR[k["ad"]]),
         "degerler": [f"@turetilmis.kesimler.{i}.sirket_yuzde",
                      f"@turetilmis.kesimler.{i}.kota_yuzde"],
         "ondalik": 2, **{a: v for a, v in YUZDE.items()}}
        for i, k in enumerate(T["kesimler"])],
}

# ── 4 · şirket kotaları · sıralama ───────────────────────────────────
ilk8 = T["kota_siralamasi"][:8]
g["sirket_kotalari"] = {
    "tur": "siralama", "bolen": 1000, "ondalik": 0,
    "baslik": ikidil("On beş üretici, en büyükten en küçüğe",
                     "Fifteen producers, largest to smallest"),
    "birim": ikidil("bin ton · A kotası", "thousand tonnes · A quota"),
    "kaynak": "TÜRKŞEKER · Şeker Sektör Raporu 2025, Tablo 24",
    "not": ikidil(
        f"Listenin en küçüğü Alpullu: {tr_sayi(alp['a_kotasi_ton'])} ton, pancar şekerinin "
        f"%{tr_sayi(alp['pancar_sekerinde_pay_yuzde'], 2)}'i. İlk Türk şekeri 1926'da bu "
        f"fabrikada üretilmişti; 2018'de özelleştirildi.",
        f"The smallest on the list is Alpullu: {en_sayi(alp['a_kotasi_ton'])} tonnes, "
        f"{en_sayi(alp['pancar_sekerinde_pay_yuzde'], 2)}% of beet sugar. The first Turkish sugar "
        f"was made at this factory in 1926; it was privatised in 2018."),
    "satirlar": [
        {"etiket": ikidil(s["ad"][:46], s["ad"][:46]),
         "deger": f"@turetilmis.kota_siralamasi.{i}.a_kotasi_ton",
         "rol": "vurgu" if s["ad"].startswith("KAMU") else "sessiz"}
        for i, s in enumerate(ilk8)]
    + [{"etiket": ikidil("Binbirgıda · Alpullu", "Binbirgıda · Alpullu"),
        "deger": f"@turetilmis.kota_siralamasi.{len(T['kota_siralamasi']) - 1}.a_kotasi_ton",
        "rol": "ikincil"}],
}

# ── 5 · pancar verimi · çizgi ────────────────────────────────────────
g["pancar_verimi"] = {
    "tur": "cizgi", "bolen": 1000, "ondalik": 1,
    "baslik": ikidil("Aynı dönümden üç katı pancar", "Three times the beet from the same field"),
    "birim": ikidil("ton/hektar · şeker pancarı verimi",
                    "tonnes per hectare · sugar beet yield"),
    "kaynak": "FAOSTAT · Üretim, Türkiye (Alan Kodu 223)",
    "not": ikidil(
        f"{pancar['ilk_yil']}'de hektar başına {tr_sayi(pancar['verim_ilk'] / 1000, 1)} ton olan verim "
        f"{pancar['son_yil']}'te {tr_sayi(pancar['verim_son'] / 1000, 1)} tona çıktı: "
        f"%{tr_sayi(pancar['verim_artis_yuzde'], 0)} artış. FAOSTAT serisi 1961'de başlıyor; "
        f"ilk Türk şekeri 1926'da üretildi ve aradaki otuz beş yılın sayısı bu seride yok.",
        f"Yield rose from {en_sayi(pancar['verim_ilk'] / 1000, 1)} tonnes per hectare in "
        f"{pancar['ilk_yil']} to {en_sayi(pancar['verim_son'] / 1000, 1)} in {pancar['son_yil']}, "
        f"a rise of {en_sayi(pancar['verim_artis_yuzde'], 0)}%. The FAOSTAT series begins in 1961; "
        f"the first Turkish sugar was made in 1926 and the thirty-five years between are not in it."),
    "seriler": [{"ad": ikidil("Verim", "Yield"), "rol": "vurgu",
                 "noktalar": {"liste": "@turetilmis.verim_kayitlari", "x": "yil", "y": "verim"}}],
}

# ── 6 · dünya sıralaması ─────────────────────────────────────────────
g["dunya_pancar_sekeri"] = {
    "tur": "siralama", "ondalik": 0,
    "baslik": ikidil("Dünyada pancar şekeri: Türkiye dördüncü",
                     "Beet sugar worldwide: Türkiye is fourth"),
    "birim": ikidil("bin ton", "thousand tonnes"),
    "kaynak": "USDA Foreign Agricultural Service · Production, Supply and Distribution",
    "not": ikidil(
        f"Türkiye {tr_sayi(seker['pancar_sekeri_bin_ton'])} bin tonla dördüncü sırada. "
        f"Ülkenin kamış şekeri üretimi sıfır: şekerin tamamı pancardan geliyor.",
        f"Türkiye is fourth with {en_sayi(seker['pancar_sekeri_bin_ton'])} thousand tonnes. "
        f"The country's cane sugar output is zero: all of its sugar comes from beet."),
    "satirlar": [
        {"etiket": ikidil({"European Union": "Avrupa Birliği", "Russia": "Rusya",
                           "United States": "ABD", "Turkey": "Türkiye", "Egypt": "Mısır",
                           "Ukraine": "Ukrayna", "China": "Çin"}.get(r["ulke"], r["ulke"]),
                          "Türkiye" if r["ulke"] == "Turkey" else r["ulke"]),
         "deger": f"@turetilmis.dunya_siralamasi.{i}.bin_ton",
         "rol": "vurgu" if r["ulke"] == "Turkey" else "sessiz"}
        for i, r in enumerate(T["dunya_siralamasi"][:7])],
}

# ── 7 · NBŞ kotası · çizgi ───────────────────────────────────────────
nbs = kota["nbs_dusus"]
g["nbs_kotasi"] = {
    "tur": "cizgi", "ondalik": 1,
    "baslik": ikidil("Nişasta bazlı şekerin kotası dörtte bire indi",
                     "The starch-based sugar quota fell to a quarter"),
    "birim": ikidil("bin ton · A kotası", "thousand tonnes · A quota"),
    "kaynak": "TÜRKŞEKER · Şeker Sektör Raporu 2025, Tablo 23",
    "not": ikidil(
        f"2017/18'de {tr_sayi(nbs['_2017_18_bin_ton'])} bin ton olan kota 2019/20'de "
        f"{tr_sayi(nbs['_2019_20_bin_ton'], 1)} bin tona indi: %{tr_sayi(abs(nbs['degisim_yuzde']), 1)} azalma. "
        f"7103 sayılı Kanunun 47. maddesi ülke toplam A kotasının %10'u olan payı %5'e indirdi; "
        f"2019/20'den sonra Cumhurbaşkanı kararıyla %2,5'te tutuluyor. Aynı kanunun Geçici 11. "
        f"maddesi ortaya çıkan kota fazlasını TÜRKŞEKER'e aktardı.",
        f"The quota fell from {en_sayi(nbs['_2017_18_bin_ton'])} thousand tonnes in 2017/18 to "
        f"{en_sayi(nbs['_2019_20_bin_ton'], 1)} in 2019/20, a fall of {en_sayi(abs(nbs['degisim_yuzde']), 1)}%. "
        f"Article 47 of Law 7103 cut the share from 10 per cent of the national A quota to 5; since "
        f"2019/20 a Presidential Decision has held it at 2.5. Provisional Article 11 of the same law "
        f"transferred the resulting surplus quota to TÜRKŞEKER."),
    "seriler": [{"ad": ikidil("NBŞ kotası", "Starch-based sugar quota"), "rol": "vurgu",
                 "noktalar": {"liste": "@turetilmis.nbs_kayitlari", "x": "yil", "y": "kota"}}],
}

# ── 8 · pancarın yolu · işlem akışı ──────────────────────────────────
g["pancarin_yolu"] = {
    "tur": "islem_akisi",
    "baslik": ikidil("Çiftçi pancarını nasıl satar", "How a grower sells their beet"),
    "kaynak": "TÜRKŞEKER · Şeker Sektör Raporu 2025 · 4634 sayılı Şeker Kanunu, madde 4",
    "not": ikidil(
        "Sözleşmeli üretimin Türkiye'de ilk ve en yaygın uygulandığı ürün şeker pancarıdır. "
        "Pancar bir münavebe bitkisi: bölgeye göre üç ya da dört yılda bir ekiliyor. Süreler "
        "belgelerde yazılı olmadığı için boş bırakıldı.",
        "Sugar beet is the crop for which contract farming was first and is most widely used in "
        "Türkiye. Beet is a rotation crop, sown every three or four years depending on the region. "
        "Durations are left blank because the documents do not state them."),
    "adimlar": [
        {"aktor": ikidil("Üretici ve şirket", "Grower and company"),
         "baslik": ikidil("Sözleşme imzalanır", "The contract is signed"),
         "aciklama": ikidil("Her yıl ekimden önce Şeker Pancarı Üretim Sözleşmesi yapılır.",
                            "A Sugar Beet Production Contract is made each year before sowing."),
         "belge": ikidil("Şeker Pancarı Üretim Sözleşmesi", "Sugar Beet Production Contract")},
        {"aktor": ikidil("Şirket", "Company"),
         "baslik": ikidil("Fiyat ekimden önce belirlenir", "The price is set before sowing"),
         "aciklama": ikidil(
             "A kotası pancar fiyatı; yıllık enflasyon, üretici maliyetlerindeki artış, dünya "
             "pancar fiyatları ve alternatif ürün paritesi dikkate alınarak belirlenir.",
             "The A quota beet price is set with regard to annual inflation, the rise in growers' "
             "costs, world beet prices and the parity of alternative crops.")},
        {"aktor": ikidil("Şirket", "Company"),
         "baslik": ikidil("Avans verilir", "An advance is paid"),
         "aciklama": ikidil(
             "Tohum ve gübre gibi ayni destekler ile nakdi avanslar. Pancar teslim edilmeden önce "
             "bedelin yaklaşık yüzde 35'i faiz yansıtılmaksızın ödenir.",
             "Support in kind, such as seed and fertiliser, and cash advances. About 35 per cent of "
             "the price is paid before delivery, with no interest charged.")},
        {"aktor": ikidil("Üretici", "Grower"),
         "baslik": ikidil("Ekim ve hasat", "Sowing and harvest"),
         "aciklama": ikidil("Pancar münavebe ile ekilir; bölgeye göre üç ya da dört yılda bir.",
                            "Beet is sown in rotation, every three or four years by region.")},
        {"aktor": ikidil("Üretici", "Grower"),
         "baslik": ikidil("Pancar teslim edilir", "The beet is delivered"),
         "aciklama": ikidil("Teslimle birlikte nakliye destek ödemesi devreye girer.",
                            "Delivery brings the transport support payment into play.")},
        {"aktor": ikidil("Şirket", "Company"),
         "baslik": ikidil("Bedel ve primler ödenir", "Price and premiums are paid"),
         "aciklama": ikidil(
             "Kota tamamlama primi, pancar üretimini teşvik primi, temizleme ve yükleme primi.",
             "Quota completion premium, production incentive premium, cleaning and loading premium."),
         "secenekler": [ikidil("İstihkak posa bedelsiz verilir", "Pulp is supplied free of charge")]},
    ],
}

# ── 9 · çiftçi sayısı · çizgi ────────────────────────────────────────
dus = ciftci["dusus"]
g["ciftci_sayisi"] = {
    "tur": "cizgi", "bolen": 1000, "ondalik": 1,
    "baslik": ikidil("Çiftçi azaldı, üretim yerinde durdu",
                     "Fewer growers, the same harvest"),
    "birim": ikidil("bin kişi · pancar üreticisi", "thousand people · beet growers"),
    "kaynak": "TÜRKŞEKER · Şeker Sektör Raporu 2025, Tablo 26 ve Tablo 27",
    "not": ikidil(
        f"Ülke genelinde üretici sayısı {ciftci['zirve_yil']}'de {tr_sayi(ciftci['zirve_sayi'])} ile "
        f"zirve yaptı, {ciftci['son_yil']}'te {tr_sayi(ciftci['son_sayi'])}'e indi: "
        f"%{tr_sayi(abs(ciftci['dusus_yuzde']), 1)} azalma. Aynı aralıkta TÜRKŞEKER'in üreticisi "
        f"%{tr_sayi(abs(dus['turkseker_degisim_yuzde']), 1)}, TÜRKŞEKER dışı "
        f"%{tr_sayi(abs(dus['turkseker_disi_degisim_yuzde']), 1)} azaldı. İki satır ayrı ölçüdür ve "
        f"biri diğerinin yerine kullanılamaz.",
        f"Nationwide the number of growers peaked at {en_sayi(ciftci['zirve_sayi'])} in "
        f"{ciftci['zirve_yil']} and fell to {en_sayi(ciftci['son_sayi'])} in {ciftci['son_yil']}, "
        f"a fall of {en_sayi(abs(ciftci['dusus_yuzde']), 1)}%. Over the same span TÜRKŞEKER's growers "
        f"fell by {en_sayi(abs(dus['turkseker_degisim_yuzde']), 1)}% and growers outside TÜRKŞEKER by "
        f"{en_sayi(abs(dus['turkseker_disi_degisim_yuzde']), 1)}%. The two lines are separate measures "
        f"and neither stands for the other."),
    "seriler": [
        {"ad": ikidil("Ülke geneli", "Nationwide"), "rol": "vurgu",
         "noktalar": {"liste": "@turetilmis.ciftci_kayitlari", "x": "yil", "y": "ulke"}},
        {"ad": ikidil("TÜRKŞEKER", "TÜRKŞEKER"), "rol": "ikincil",
         "noktalar": {"liste": "@turetilmis.ciftci_kayitlari", "x": "yil", "y": "turkseker"}}],
}

# ── 10 · bugün · kartlar ─────────────────────────────────────────────
pd_ = kurum["personel_dusus"]
g["bugun_turkseker"] = {
    "tur": "kartlar",
    "baslik": ikidil("Bugün TÜRKŞEKER", "TÜRKŞEKER today"),
    "kaynak": "TÜRKŞEKER · Şeker Sektör Raporu 2025 ve 2024-2028 Stratejik Plan",
    "not": ikidil(
        f"Şeker fabrikalarının yanı sıra üç makine fabrikası, Elektromekanik Aygıtlar Fabrikası, "
        f"Alkol Fabrikası, Tohum İşleme Fabrikası ve Şeker Enstitüsü kurumun bünyesinde. Personel "
        f"rakamı 2022 fiili ortalamasıdır.",
        f"Besides the sugar factories the institution runs three machine works, an electromechanical "
        f"devices plant, an alcohol plant, a seed processing plant and the Sugar Institute. The staff "
        f"figure is the 2022 actual average."),
    "kartlar": [
        {"ust": ikidil("Fabrika", "Factories"),
         "baslik": ikidil(f"{kimlik['fabrika_bugun']} şeker fabrikası",
                          f"{kimlik['fabrika_bugun']} sugar factories"),
         "govde": ikidil(f"1990 öncesinde {kimlik['fabrika_1990_oncesi']} fabrikası vardı. "
                         f"2018'de on fabrika özelleştirildi, 2025'te Çarşamba MKE'ye devredildi.",
                         f"Before 1990 it had {kimlik['fabrika_1990_oncesi']}. Ten were privatised in "
                         f"2018 and Çarşamba passed to MKE in 2025.")},
        {"ust": ikidil("Kota", "Quota"),
         "baslik": ikidil(f"%{tr_sayi(uc['kamu'], 2)} pay", f"{en_sayi(uc['kamu'], 2)}% share"),
         "govde": ikidil(f"{kota['yil']} pazarlama yılında {tr_sayi(kamu_ton)} ton A kotası. "
                         f"Pancar şekeri üretimindeki payı ise %{D['_uc_pay']['uretim_payi_yuzde']}.",
                         f"An A quota of {en_sayi(kamu_ton)} tonnes for {kota['yil']}. Its share of "
                         f"beet sugar production is {D['_uc_pay']['uretim_payi_yuzde']}%.")},
        {"ust": ikidil("Çalışan", "Staff"),
         "baslik": ikidil(f"{tr_sayi(kurum['personel_2022']['toplam'])} kişi",
                          f"{en_sayi(kurum['personel_2022']['toplam'])} people"),
         "govde": ikidil(f"2018'de {tr_sayi(pd_['_2018'])} olan fiili ortalama 2022'de "
                         f"{tr_sayi(pd_['_2022'])}. Alt işverenle birlikte "
                         f"{tr_sayi(kurum['personel_2022']['alt_isverenle_toplam'])} kişi.",
                         f"The actual average was {en_sayi(pd_['_2018'])} in 2018 and "
                         f"{en_sayi(pd_['_2022'])} in 2022. With contractors, "
                         f"{en_sayi(kurum['personel_2022']['alt_isverenle_toplam'])} people.")},
        {"ust": ikidil("Sermaye", "Capital"),
         "baslik": ikidil("Türkiye Varlık Fonu", "Türkiye Wealth Fund"),
         "govde": ikidil("29 Nisan 2021 tarihli Cumhurbaşkanı Kararı ile sermayenin tamamı devredildi; "
                         "aynı yıl Tarım ve Orman Bakanlığı ile ilgilendirildi.",
                         "A Presidential Decision of 29 April 2021 transferred the entire capital; the "
                         "same year it was attached to the Ministry of Agriculture and Forestry.")},
    ],
}

# ── 11 · dünyada benzeri · kartlar ───────────────────────────────────
ab, rusya = T["dunya_siralamasi"][0], T["dunya_siralamasi"][1]
g["iki_model"] = {
    "tur": "kartlar",
    "baslik": ikidil("Pancar şekerini kim, nasıl üretiyor", "Who makes beet sugar, and how"),
    "kaynak": "USDA Foreign Agricultural Service · Production, Supply and Distribution",
    "not": ikidil(
        f"Dünya pancar şekeri üretimi {tr_sayi(seker['dunya_toplam_bin_ton'])} bin ton. "
        f"Kartlar üretim büyüklüğünü ve örgütlenme biçimini yan yana koyuyor; rakamlar USDA'nın "
        f"{seker['yil']} tahminleridir.",
        f"World beet sugar output is {en_sayi(seker['dunya_toplam_bin_ton'])} thousand tonnes. The "
        f"cards set output against the form of organisation; the figures are USDA estimates for "
        f"{seker['yil']}."),
    "kartlar": [
        {"ust": ikidil("Birinci", "First"),
         "baslik": ikidil(f"Avrupa Birliği · {tr_sayi(ab['bin_ton'])} bin ton",
                          f"European Union · {en_sayi(ab['bin_ton'])} thousand tonnes"),
         "govde": ikidil("Dünya pancar şekerinin en büyük üreticisi; üretim kotası 2017'de kaldırıldı.",
                         "The largest producer of beet sugar; its production quota was abolished in 2017.")},
        {"ust": ikidil("İkinci", "Second"),
         "baslik": ikidil(f"Rusya · {tr_sayi(rusya['bin_ton'])} bin ton",
                          f"Russia · {en_sayi(rusya['bin_ton'])} thousand tonnes"),
         "govde": ikidil("Pancar şekerinde ikinci sırada.", "Second in beet sugar.")},
        {"ust": ikidil("Dördüncü", "Fourth"),
         "baslik": ikidil(f"Türkiye · {tr_sayi(seker['pancar_sekeri_bin_ton'])} bin ton",
                          f"Türkiye · {en_sayi(seker['pancar_sekeri_bin_ton'])} thousand tonnes"),
         "govde": ikidil(f"Üretim kotayla planlanıyor; kamu, kooperatif ve özel sektör kotayı "
                         f"%{tr_sayi(uc['kamu'], 2)} · %{tr_sayi(uc['kooperatif'], 2)} · "
                         f"%{tr_sayi(uc['ozel'], 2)} paylaşıyor.",
                         f"Production is planned by quota; public, cooperative and private sectors "
                         f"hold {en_sayi(uc['kamu'], 2)}% · {en_sayi(uc['kooperatif'], 2)}% · "
                         f"{en_sayi(uc['ozel'], 2)}% of it.")},
    ],
}

cikti = {
    "_dosya": "Türkşeker — Kurum Dosyası Sayı 07 · grafikler",
    "_kural": ("ELLE DÜZENLENMEZ. _raw/kur_grafikler.py üretir; notlardaki rakamlar "
               "data.json'dan okunur. Değişiklik betikte yapılır."),
    "_roller": "vurgu · ikincil · sessiz. Yığın tipleri sessiz KULLANMAZ (yalnız ikincil taranır).",
    "_isaret_duzeni": "Yüzde işareti TR'de önde, EN'de arkada.",
    "grafikler": g,
}
(KOK / "grafikler.json").write_text(json.dumps(cikti, ensure_ascii=False, indent=2), encoding="utf-8")

print(f"  ✓ {len(g)} grafik yazıldı")
for k, v in g.items():
    print(f"    {v['tur']:<17} {k}")
