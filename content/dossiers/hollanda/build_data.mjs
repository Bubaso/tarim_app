// Hollanda dosyası — KİLİTLİ VERİ SAYFASI üreticisi.
//
// Bu betik `_raw/` altındaki ham çekimlerden `data.json` üretir. Dosyada
// yazacağım her cümle bu çıktıya dayanacak; hiçbir sayı hafızadan gelmeyecek.
// Betiği saklıyoruz ki bir yıl sonra "bu rakam nereden geldi" sorusunun cevabı
// tek komutla yeniden üretilebilsin.
//
// Çalıştırma:  node content/dossiers/hollanda/build_data.mjs

import { readFile, writeFile } from 'node:fs/promises';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const HERE = dirname(fileURLToPath(import.meta.url));
const RAW = join(HERE, '_raw');
const OUT = join(HERE, 'data.json');

const oku = async (f) => JSON.parse(await readFile(join(RAW, f), 'utf8'));

const wb = await oku('worldbank.json');
const fao = await oku('faostat.json');
const tic = await oku('faostat_ticaret.json');
const ikili = await oku('faostat_ikili.json');
const sira = await oku('faostat_siralama.json');
const cbs = await oku('cbs.json');
const cbsIh = await oku('cbs_ihracat.json');
const kur = await oku('kurumlar.json');
const tarih = await oku('tarih.json');
const cevre = await oku('cevre.json');

const bul = (list, ad) => list.find((r) => r.item === ad);
const sonDeger = (obj) => {
  const ys = Object.keys(obj).map(Number);
  if (!ys.length) return null;
  const y = Math.max(...ys);
  return { yil: y, deger: obj[y] };
};

/// Dünya Bankası göstergesinden tek satırlık karşılaştırma kaydı üretir.
function wbSatir(kod, etiket, birim) {
  const g = wb.gostergeler[kod];
  if (!g) return null;
  const n = sonDeger(g.NLD);
  const t = sonDeger(g.TUR);
  return {
    kod, etiket, birim,
    NLD: n, TUR: t,
    kaynak: 'World Bank — World Development Indicators',
    kaynak_url: `https://data.worldbank.org/indicator/${kod}`,
    veri_guncelleme: g.son_guncelleme,
  };
}

/// FAOSTAT verim (element 5412) karşılaştırması. Birim kg/ha → t/ha çeviriyoruz.
function verim(itemAdi, etiket) {
  const n = fao.uretim.NLD.find((r) => r.item === itemAdi && r.elementCode === '5412');
  const t = fao.uretim.TUR.find((r) => r.item === itemAdi && r.elementCode === '5412');
  if (!n || !t) return null;
  return {
    urun: etiket,
    fao_item: itemAdi,
    birim: 't/ha',
    NLD: { yil: n.son_yil, deger: +(n.son_deger / 1000).toFixed(1) },
    TUR: { yil: t.son_yil, deger: +(t.son_deger / 1000).toFixed(1) },
    kat: +(n.son_deger / t.son_deger).toFixed(1),
  };
}

const toplamYil = (list, yil) => list.reduce((s, r) => s + (r.seri[yil] ?? 0), 0);

/// Elle girilen kayıt dosyalarını (tarih.json, cevre.json) data.json'a taşır.
///
/// İki şey dışarıda bırakılır: (1) ÜST DÜZEY `_` alanları — bunlar dosyanın
/// kendi künyesi, veri değil; (2) `dogrulanamadi` listesi — metne girmesi
/// yasak olan kalemler. İkincisi silinmez, `_dogrulanmamis_kalemler` adıyla
/// kurumlar bloğundakiyle aynı biçimde kayıtta tutulur.
///
/// DİKKAT: yalnızca üst düzey `_` alanları atılır. Alt nesnelerdeki
/// `_kumes_uyarisi`, `_birim_uyarisi`, `_pay_uyarisi` gibi alanlar rakamın
/// nasıl okunacağını söylüyor; onlar rakamla birlikte seyahat etmeli.
function elleGirilen(kayit) {
  const { dogrulanamadi, ...geri } = kayit;
  const govde = Object.fromEntries(
    Object.entries(geri).filter(([k]) => !k.startsWith('_')),
  );
  return {
    ...govde,
    _giris_yontemi: kayit._giris_yontemi,
    _dogrulama_tarihi: kayit._dogrulama_tarihi,
    _dogrulanmamis_kalemler: dogrulanamadi ?? [],
    _dogrulanmamis_kural:
      'Yukarıdaki liste METNE GİRMEZ. Yalnızca ileride doğrulanmak üzere kayıt altındadır.',
  };
}

/// CBS serisinden tek satır. `pay` verilirse toplam tarım arazisine oranı da eklenir.
function cbsSatir(anahtar, pay = false) {
  const s = cbs.seri[anahtar];
  if (!s) return null;
  const r = { alan: s.etiket, yil: s.son_yil, hektar: s.son_deger };
  if (pay) r.tarim_arazisi_payi_yuzde = +(100 * s.son_deger / cbs.seri.CultuurgrondTotaal_3.son_deger).toFixed(2);
  return r;
}

/// Bir CBS serisinin ilk yıldan son yıla yüzde değişimi.
function cbsDegisim(anahtar) {
  const s = cbs.seri[anahtar];
  const ys = Object.keys(s.seri).map(Number).sort((a, b) => a - b);
  const ilk = ys[0];
  return {
    ilk_yil: ilk, ilk_deger: s.seri[ilk],
    son_yil: s.son_yil, son_deger: s.son_deger,
    degisim_yuzde: +(100 * (s.son_deger - s.seri[ilk]) / s.seri[ilk]).toFixed(1),
  };
}

// ─────────────────────────────────────────────────────────────────────────────

const data = {
  _dosya: 'Hollanda — Ülke Dosyası · kilitli veri sayfası',
  _uretim_tarihi: new Date().toISOString(),
  _kural:
    'Dosya metninde geçen HER sayı bu dosyadan gelir. Buraya girmemiş bir sayı ' +
    'metne giremez. Bir sayı güncellenecekse önce burası güncellenir, sonra metin.',
  _kaynaklar: {
    WB: { ad: 'World Bank Open Data', url: 'https://data.worldbank.org', lisans: 'CC BY 4.0', cekim: wb._cekilme_tarihi },
    FAO_QCL: { ad: 'FAOSTAT — Production: Crops and livestock products', url: 'https://www.fao.org/faostat/en/#data/QCL', cekim: fao._cekilme_tarihi },
    FAO_QV: { ad: 'FAOSTAT — Value of Agricultural Production', url: 'https://www.fao.org/faostat/en/#data/QV', cekim: fao._cekilme_tarihi },
    FAO_TCL: { ad: 'FAOSTAT — Trade: Crops and livestock products', url: 'https://www.fao.org/faostat/en/#data/TCL', cekim: tic._cekilme_tarihi },
    FAO_TM: { ad: 'FAOSTAT — Detailed Trade Matrix', url: 'https://www.fao.org/faostat/en/#data/TM', cekim: ikili._cekilme_tarihi },
    CBS: { ad: `CBS StatLine — tablo ${cbs._tablo}`, url: cbs._tablo_url, lisans: cbs._lisans, guncelleme: cbs._guncelleme, cekim: cbs._cekilme_tarihi },
    CBS_IHR: { ad: cbsIh._kaynak, url: cbsIh._kaynak_url, yayin: cbsIh._yayin_tarihi, not: cbsIh._giris_yontemi },
    KURUM: { ad: 'Kurumların kendi resmî yayınları — tek tek doğrulandı', dogrulama: kur._dogrulama_tarihi },
    TARIH: { ad: 'Rijkswaterstaat, Nieuw Land, Deltacommissie, WUR, AB tarihî arşivleri — elle doğrulandı', dogrulama: tarih._dogrulama_tarihi },
    CEVRE: { ad: 'CBS, RIVM, Emissieregistratie, RVO, Raad van State, AB Konseyi — elle doğrulandı', dogrulama: cevre._dogrulama_tarihi },
  },

  // ═══ 1. TEZ — dosyanın omurgası ═══
  tez: {
    // Faz 0.5'te onaylandı. Kapakta ve girişte birebir bu cümle kullanılır.
    cumle: 'Hollanda\'nın sırrı toprağında değil, toprağının üstüne kurduğu sistemde.',
    cumle_en: 'The Dutch secret is not in the soil, but in what they built on top of it.',
    baslik: 'Az üreten, çok satan ülke',
    ozet:
      'Türkiye tarımsal üretim değerinde Hollanda\'nın yaklaşık dört buçuk katı. ' +
      'Hollanda tarımsal ihracatta Türkiye\'nin yaklaşık dört katı. Aradaki fark ' +
      'toprakta değil, toprakla ürün arasındaki her adımda.',
    uretim_degeri: {
      birim: 'milyon I$ (sabit 2014-2016 uluslararası dolar)',
      NLD: { yil: bul(fao.uretim_degeri.NLD, 'Agriculture').son_yil, deger: Math.round(bul(fao.uretim_degeri.NLD, 'Agriculture').son_deger / 1000) },
      TUR: { yil: bul(fao.uretim_degeri.TUR, 'Agriculture').son_yil, deger: Math.round(bul(fao.uretim_degeri.TUR, 'Agriculture').son_deger / 1000) },
      kaynak: 'FAO_QV',
    },
    ihracat: {
      birim: 'milyon US$ (cari)',
      kalem: 'Crops and livestock products',
      NLD: { yil: bul(tic.ihracat.NLD, 'Crops and livestock products').son_yil, deger: Math.round(bul(tic.ihracat.NLD, 'Crops and livestock products').son_deger / 1000) },
      TUR: { yil: bul(tic.ihracat.TUR, 'Crops and livestock products').son_yil, deger: Math.round(bul(tic.ihracat.TUR, 'Crops and livestock products').son_deger / 1000) },
      kaynak: 'FAO_TCL',
    },
    ithalat: {
      birim: 'milyon US$ (cari)',
      NLD: { yil: bul(tic.ithalat.NLD, 'Crops and livestock products').son_yil, deger: Math.round(bul(tic.ithalat.NLD, 'Crops and livestock products').son_deger / 1000) },
      TUR: { yil: bul(tic.ithalat.TUR, 'Crops and livestock products').son_yil, deger: Math.round(bul(tic.ithalat.TUR, 'Crops and livestock products').son_deger / 1000) },
      kaynak: 'FAO_TCL',
    },
    UYARI:
      'Üretim değeri sabit I$, ihracat cari US$ cinsinden. İkisinin ORANI ' +
      '(7,1 vs 0,37) ekonomik olarak birebir karşılaştırılabilir bir sayı DEĞİL; ' +
      'metinde oran olarak verilmeyecek, olgu olarak anlatılacak.',
  },

  // ═══ 2. MAKRO — Dünya Bankası ═══
  makro: [
    wbSatir('NV.AGR.TOTL.ZS', 'Tarımın GSYH içindeki payı', '%'),
    wbSatir('NV.AGR.TOTL.CD', 'Tarımsal katma değer', 'cari US$'),
    wbSatir('SL.AGR.EMPL.ZS', 'Tarımda istihdam payı', '%'),
    wbSatir('SP.POP.TOTL', 'Nüfus', 'kişi'),
    wbSatir('SP.RUR.TOTL.ZS', 'Kırsal nüfus payı', '%'),
    wbSatir('NY.GDP.MKTP.CD', 'GSYH', 'cari US$'),
    wbSatir('NY.GDP.PCAP.CD', 'Kişi başına GSYH', 'cari US$'),
  ].filter(Boolean),

  // ═══ 3. TOPRAK VE SU ═══
  toprak_su: [
    wbSatir('AG.LND.TOTL.K2', 'Kara alanı', 'km²'),
    wbSatir('AG.LND.AGRI.K2', 'Tarım arazisi', 'km²'),
    wbSatir('AG.LND.AGRI.ZS', 'Tarım arazisinin kara alanına oranı', '%'),
    wbSatir('AG.LND.ARBL.HA', 'İşlenebilir arazi', 'hektar'),
    wbSatir('AG.LND.ARBL.HA.PC', 'Kişi başına işlenebilir arazi', 'hektar'),
    wbSatir('AG.LND.IRIG.AG.ZS', 'Sulanan arazi payı', '%'),
    wbSatir('ER.H2O.FWAG.ZS', 'Tarımın tatlı su çekimindeki payı', '%'),
    wbSatir('AG.CON.FERT.ZS', 'Gübre tüketimi', 'kg/ha'),
  ].filter(Boolean),

  // ═══ 4. VERİM — dosyanın en keskin bulgusu ═══
  //
  // DİKKAT: Bu bölümün ilk taslağı "açık tarla ürünlerinde fark neredeyse yok"
  // diyordu. Veri bunu YALANLADI — buğday 2,6× ve arpa 2,3×. İddia üç kademeye
  // ayrıldı ve tahıl farkının seyri ayrıca kayda alındı. Metin bu üç kademeyi
  // anlatacak; "fark yok" cümlesi kullanılmayacak.
  verim: {
    aciklama:
      'Fark tek bir sayı değil, üç kademe. (1) Örtüaltı sebzede 5–12 kat — bu ' +
      'kademe mühendislik ürünü. (2) Yumru ve kök ürünlerde 1,1–1,2 kat — pratikte ' +
      'fark yok. (3) Tahılda 2,2–2,6 kat — gerçek bir fark, ama kapanıyor. ' +
      'Hollanda mucizesi genel bir tarım üstünlüğü DEĞİL; farkın büyüklüğü ürünün ' +
      'cam altına alınıp alınmadığına göre değişiyor. Dosyanın en önemli tespiti budur.',
    ortualti: [
      verim('Cucumbers and gherkins', 'Salatalık'),
      verim('Tomatoes', 'Domates'),
      verim('Chillies and peppers, green (Capsicum spp. and Pimenta spp.)', 'Biber'),
    ].filter(Boolean),
    acik_tarla: [
      verim('Potatoes', 'Patates'),
      verim('Onions and shallots, dry (excluding dehydrated)', 'Kuru soğan'),
      verim('Wheat', 'Buğday'),
      verim('Barley', 'Arpa'),
      verim('Sugar beet', 'Şeker pancarı'),
    ].filter(Boolean),
    kaynak: 'FAO_QCL (element 5412 Yield, kg/ha → t/ha)',

    // Tahıl farkı neden var ve ne yöne gidiyor? İddia etmeden önce ölçtük.
    tahil_farki: {
      _neden_burada:
        'Tahıl farkı örtüaltı farkıyla aynı şey değil: sera farkı mühendislikle ' +
        'açılıyor, tahıl farkı girdi ve iklimle birlikte kapanıyor. Metinde bu ikisi ' +
        'birbirine karıştırılmayacak.',
      seyir: [1990, 2000, 2010, 2020, 2023]
        .map((y) => {
          const g = wb.gostergeler['AG.YLD.CREL.KG'];
          const n = g?.NLD?.[y];
          const t = g?.TUR?.[y];
          if (n == null || t == null) return null;
          return { yil: y, NLD: Math.round(n), TUR: Math.round(t), kat: +(n / t).toFixed(2) };
        })
        .filter(Boolean),
      seyir_birim: 'kg/ha — Dünya Bankası AG.YLD.CREL.KG',
      girdi_farklari: [
        wbSatir('AG.LND.PRCP.MM', 'Ortalama yağış', 'mm/yıl'),
        wbSatir('AG.CON.FERT.ZS', 'Gübre tüketimi', 'kg/ha'),
        wbSatir('AG.LND.IRIG.AG.ZS', 'Sulanan arazi payı', '%'),
      ].filter(Boolean),
      yagis_uyarisi:
        'AG.LND.PRCP.MM YILLIK DEĞİL uzun dönem ortalamasıdır — 1990-2022 arasındaki ' +
        '33 kaydın hepsi aynı sayıyı verir. "2022 yağışı" diye yazılamaz; ' +
        '"uzun dönem ortalaması" denir.',
      _yorum_siniri:
        'Bu üç girdi farkı tahıl farkıyla BİRLİKTE bulunuyor; nedensellik kanıtı ' +
        'değildir. Metin "şu kadarı iklimden" diye pay dağıtmayacak.',
    },
  },

  // ═══ 5. SERA — mekanizmanın ölçüsü (Boşluk 1) ═══
  sera: {
    aciklama:
      'Verim farkını yaratan alan, Hollanda tarım arazisinin yüzde birinden küçük. ' +
      'Üstelik 2000\'den bu yana BÜYÜMEDİ, küçüldü. "Hollanda mucizesi" bir yayılma ' +
      'değil, sabit ve küçük bir alanın yoğunlaştırılması hikâyesi.',
    toplam_tarim_arazisi: cbsSatir('CultuurgrondTotaal_3'),
    ortualti: cbsSatir('TuinbouwOnderGlasTotaal_326', true),
    cam_alti_sebze: cbsSatir('GlasgroentenTotaal_359', true),
    sus_bitkisi: cbsSatir('BloemkwekerijgewassenTotaal_327', true),
    sebzeler: ['TomatenTotaal_370', 'PaprikaSTotaal_365', 'Komkommers_364', 'Aubergines_360'].map((k) => cbsSatir(k)).filter(Boolean),
    susler: ['SnijbloemenTotaal_334', 'PotplantenTotaal_331', 'Chrysanten_338', 'Rozen_344', 'Orchideeen_343', 'Tulpen_345'].map((k) => cbsSatir(k)).filter(Boolean),
    sera_alani_seyri: cbsDegisim('TuinbouwOnderGlasTotaal_326'),
    isletme_sayisi_seyri: cbsDegisim('AantalLandbouwbedrijvenTotaal_1'),
    ortualti_isletme: cbsSatir('TuinbouwOnderGlasTotaal_376'),
    ortalama_sera_buyuklugu_ha: +(cbs.seri.TuinbouwOnderGlasTotaal_326.son_deger / cbs.seri.TuinbouwOnderGlasTotaal_376.son_deger).toFixed(2),
    capraz_dogrulama:
      'FAOSTAT\'ın Hollanda domates hasat alanı (5312) ile CBS\'nin cam altı domates ' +
      'alanı BİREBİR aynı: 1.770 ha. İki bağımsız kaynak aynı sayıyı veriyor — ' +
      'Hollanda\'da domates neredeyse tamamen cam altında demektir.',
    turkiye_karsilastirmasi: (() => {
      const t = fao.uretim.TUR.find((r) => r.item === 'Tomatoes' && r.elementCode === '5312');
      const n = fao.uretim.NLD.find((r) => r.item === 'Tomatoes' && r.elementCode === '5312');
      return { urun: 'Domates hasat alanı', birim: 'hektar', TUR: { yil: t.son_yil, deger: t.son_deger }, NLD: { yil: n.son_yil, deger: n.son_deger }, kat: Math.round(t.son_deger / n.son_deger) };
    })(),
    kaynak: 'CBS',
  },

  // ═══ 6. İHRACATIN KOMPOZİSYONU — manşet ile gerçek arası (Boşluk 2) ═══
  ihracat_kompozisyonu: {
    aciklama:
      'Hollanda\'nın kendi istatistik kurumu, manşet ihracat rakamının Hollanda ' +
      'ekonomisine bıraktığı payı ayrı hesaplıyor. Dosyanın dürüstlük düzeltmesi burada.',
    yil: cbsIh.yil,
    birim: cbsIh._birim,
    toplam: cbsIh.toplam_ihracat,
    artis_yuzde: cbsIh.toplam_ihracat_artis_yuzde,
    hollanda_yapimi: cbsIh.kompozisyon.hollanda_yapimi,
    yeniden_ihracat: cbsIh.kompozisyon.yeniden_ihracat,
    yeniden_ihracat_payi_yuzde: +(100 * cbsIh.kompozisyon.yeniden_ihracat / cbsIh.toplam_ihracat).toFixed(1),
    kazanc: cbsIh.ihracat_kazanci,
    kazanc_icinde_yeniden_ihracat_payi_yuzde: +(100 * cbsIh.ihracat_kazanci.yeniden_ihracattan / cbsIh.ihracat_kazanci.toplam).toFixed(1),
    deger_tutma_orani: {
      hollanda_yapimi_yuzde: +(100 * cbsIh.ihracat_kazanci.hollanda_yapimindan / cbsIh.kompozisyon.hollanda_yapimi).toFixed(1),
      yeniden_ihracat_yuzde: +(100 * cbsIh.ihracat_kazanci.yeniden_ihracattan / cbsIh.kompozisyon.yeniden_ihracat).toFixed(1),
      _not: 'Hollanda\'da üretilen her 100 avroluk ihracattan ~49 avro ülkede kalıyor; yeniden ihraç edilen her 100 avrodan ~12 avro.',
    },
    kritik_bulgu: cbsIh.ihracat_kazanci._kritik_bulgu,
    buyume_nedeni: cbsIh.buyume_nedeni,
    ilk_10_pazar: cbsIh.ilk_10_pazar,
    ilk_10_notu: cbsIh._ilk_10_notu,
    UYARI: cbsIh._uyari,
    kaynak: 'CBS_IHR',
  },

  // ═══ 7. KAKAO — "üretmeden satmak"ın somut kanıtı ═══
  kakao: {
    aciklama:
      'Hollanda tek bir kakao ağacı yetiştirmez. Batı Afrika\'dan çekirdek alır, ' +
      'öğütür, yağını ve ezmesini satar. Dosyanın tezinin en temiz örneği.',
    hollanda_uretimi: 'FAOSTAT üretim kaydı yok — Hollanda kakao yetiştirmiyor',
    kalemler: ['Cocoa beans', 'Cocoa butter, fat and oil', 'Cocoa paste not defatted', 'Cocoa powder and cake']
      .map((ad) => {
        const ih = bul(tic.ihracat.NLD, ad);
        const it = bul(tic.ithalat.NLD, ad);
        return {
          kalem: ad,
          ithalat: it ? { yil: it.son_yil, milyon_usd: Math.round(it.son_deger / 1000) } : null,
          ihracat: ih ? { yil: ih.son_yil, milyon_usd: Math.round(ih.son_deger / 1000) } : null,
        };
      }),
    kaynak: 'FAO_TCL',
  },

  // ═══ 8. TÜRKİYE İLE — ikili ticaret ═══
  turkiye_ile: {
    aciklama:
      'Türkiye Hollanda\'ya kuru meyve ve sert kabuklu satıyor; Hollanda Türkiye\'ye ' +
      'işlenmiş sanayi girdisi satıyor. İlişkinin kendisi dosyanın tezini tekrarlıyor.',
    raportor: 'Hollanda (tek raportör — iki ülkenin beyanları birbirini tutmaz)',
    birim: 'milyon US$ (cari)',
    yillar: [2020, 2021, 2022, 2023, 2024].map((y) => ({
      yil: y,
      hollandadan_turkiyeye: Math.round(toplamYil(ikili.hollandadan_turkiyeye, y) / 1000),
      turkiyeden_hollandaya: Math.round(toplamYil(ikili.turkiyeden_hollandaya, y) / 1000),
    })).filter((r) => r.hollandadan_turkiyeye || r.turkiyeden_hollandaya),
    hollandanin_sattiklari: ikili.hollandadan_turkiyeye.slice(0, 15)
      .map((r) => ({ kalem: r.item, yil: r.son_yil, milyon_usd: +(r.son_deger / 1000).toFixed(1) })),
    turkiyenin_sattiklari: ikili.turkiyeden_hollandaya.slice(0, 15)
      .map((r) => ({ kalem: r.item, yil: r.son_yil, milyon_usd: +(r.son_deger / 1000).toFixed(1) })),
    kaynak: 'FAO_TM',
  },

  // ═══ 9. HOLLANDA İHRACATININ TARİHSEL SEYRİ ═══
  ihracat_seyri: {
    birim: 'milyon US$ (cari)',
    kalem: 'Crops and livestock products',
    seri: Object.fromEntries(
      Object.entries(bul(tic.ihracat.NLD, 'Crops and livestock products').seri)
        .map(([y, v]) => [y, Math.round(v / 1000)]),
    ),
    kaynak: 'FAO_TCL',
  },

  // ═══ 10. DÜNYA SIRALAMASI — iddiayı tekrarlamak yerine hesapladık ═══
  dunya_siralamasi: {
    tanim: 'FAOSTAT "Crops and livestock products", ihracat değeri (element 5922), cari US$',
    kapsam: '198 ülke, beş bölge dosyasının tamamı; bölge ve grup agregaları elendi',
    UYARI: sira._uyari,
    yillar: sira.siralama,
    kaynak: 'FAO_TCL',
  },

  // ═══ 11. KURUMLAR — "nasıl" sorusunun cevabı (Boşluk 3) ═══
  kurumlar: {
    aciklama: kur._amac,
    ozet_tez: kur._ozet_tez,
    liste: kur.kurumlar.map((k) => ({
      id: k.id, ad: k.ad, tur: k.tur, kurulus: k.kurulus ?? null,
      neden_onemli: k.neden_onemli,
      veriler: k.veriler,
      kritik_bulgu: k.kritik_bulgu ?? null,
      kaynak: k.kaynak, kaynak_url: k.kaynak_url,
      yayin_tarihi: k.yayin_tarihi ?? k.kaynak_guncelleme ?? null,
    })),
    _dogrulanmamis_kalemler: kur.kurumlar
      .filter((k) => k.dogrulanmamis)
      .map((k) => ({ kurum: k.ad, kalemler: k.dogrulanmamis })),
    _dogrulanmamis_kural: 'Yukarıdaki liste METNE GİRMEZ. Yalnızca ileride doğrulanmak üzere kayıt altındadır.',
    kaynak: 'KURUM',
  },

  // ═══ 12. TARİH — metnin 8. bölümü buradan yazıldı ═══
  //
  // API'si olmayan tek blok. Her kalem kurumun kendi sayfası açılarak elle
  // girildi; kaynak URL'i ve çoğunda birebir alıntı satırın yanında duruyor.
  // Ölçülebilir olduğu için burada: 165.000 hektar kazanılmış arazi, tüm
  // seraların 16 katı — dosyanın tezini tersinden kanıtlayan sayı.
  tarih: elleGirilen(tarih),

  // ═══ 13. ÇEVRE — metnin 12. bölümü (azot krizi) buradan yazıldı ═══
  //
  // Modelin sınırının toprak değil TAVAN olduğunu gösteren blok. Üç ayrı
  // birim tuzağı içeriyor (kg NH3 ≠ kg N; %56 tarım arazisi çökelmesi ≠
  // Natura 2000; iki ayrı kümes serisi uyuşmuyor) — uyarılar rakamların
  // yanında duruyor, ayrılamaz.
  cevre: elleGirilen(cevre),

  // ═══ 14. VERİ BOŞLUKLARI — dürüstlük bölümü ═══
  //
  // Her kalem İKİ DİLLİ. Panel sayfanın sonunda okura "hangi rakamı neden
  // bulamadık, yerine ne koyduk" diyor; İngilizce sayfada Türkçe kalsaydı bu
  // bölüm tam da güven vermesi gereken yerde okunmaz olurdu. Çeviri metin
  // dosyalarında değil burada, çünkü kaynağı metin değil veri üretimi.
  bosluklar: [
    {
      konu: 'Hollanda ürün bazlı üretim değeri',
      konu_en: 'Dutch production value by commodity',
      sorun: 'FAOSTAT QV\'de Hollanda için ürün bazlı seri 2017\'de kesiliyor (59 kalem). Türkiye 2023\'e gidiyor.',
      sorun_en: 'In FAOSTAT QV the Dutch commodity-level series stops in 2017 (59 items). The Turkish series runs to 2023.',
      cozum: 'Ürün bazlı önem sıralaması üretim DEĞERİ ile değil, üretim MİKTARI (2024) ve TİCARET DEĞERİ (2023-24) ile kurulacak. 2017 rakamı güncelmiş gibi sunulmayacak.',
      cozum_en: 'Commodity ranking is built from production VOLUME (2024) and TRADE VALUE (2023–24), not production value. The 2017 figure is never presented as current.',
    },
    {
      konu: 'Sera alanı',
      konu_en: 'Greenhouse area',
      sorun: 'FAOSTAT ve Dünya Bankası sera alanı yayımlamıyor.',
      sorun_en: 'Neither FAOSTAT nor the World Bank publishes greenhouse area.',
      cozum: 'CBS StatLine tablo 81302ned\'den 16 alan çekildi (`_raw/cbs_fetch.mjs`). FAOSTAT domates hasat alanıyla birebir çapraz doğrulandı (1.770 ha = 1.770 ha).',
      cozum_en: '16 fields were pulled from CBS StatLine table 81302ned (`_raw/cbs_fetch.mjs`) and cross-checked exactly against the FAOSTAT tomato harvested area (1,770 ha = 1,770 ha).',
      durum: 'KAPANDI',
    },
    {
      konu: 'Yeniden ihracat payı',
      konu_en: 'Share of re-exports',
      sorun: 'FAOSTAT ihracatı brüt akış olarak verir; Hollanda ihracatının bir kısmı yeniden ihracattır (kendi üretimi değil). Bu ayrımı FAOSTAT yapmaz.',
      sorun_en: 'FAOSTAT reports exports as gross flows; part of Dutch exports is re-export rather than domestic output, and FAOSTAT does not separate the two.',
      cozum: 'CBS + Wageningen SER\'in 2026-01-16 tarihli ortak yayınından alındı ve cbs.nl\'den doğrulandı: 137,5 milyar EUR\'nun 49,1\'i yeniden ihracat, ama kazancın yalnızca 5,7/49,0\'ı. Seri EUR cinsinden; FAOSTAT\'ın USD serisiyle KARIŞTIRILMAYACAK.',
      cozum_en: 'Taken from the joint CBS + Wageningen SER release of 16 Jan 2026 and verified on cbs.nl: of EUR 137.5 bn, 49.1 is re-export, yet it yields only 5.7 of 49.0 in earnings. This series is in EUR and is never mixed with the FAOSTAT USD series.',
      durum: 'KAPANDI',
    },
    {
      konu: 'Dünya sıralaması',
      konu_en: 'World ranking',
      sorun: '"Dünyanın 2. büyük tarım ihracatçısı" ifadesi çok tekrarlanıyor ama yıl ve tanım belirtilmeden kullanılıyor.',
      sorun_en: 'The claim "world\'s second-largest agricultural exporter" is repeated everywhere, always without a year or a definition.',
      cozum: '198 ülke için sıralama hesaplandı. FAOSTAT tanımıyla Hollanda 2023 ve 2022\'de 3. sırada (ABD ve Brezilya\'nın arkasında). Metinde "2." denmeyecek; sıra verilirken tanım ve yıl yazılacak.',
      cozum_en: 'The ranking was computed for 198 countries. On the FAOSTAT definition the Netherlands is 3rd in both 2023 and 2022, behind the USA and Brazil. The text never says "2nd"; every rank is given with its definition and year.',
      durum: 'KAPANDI',
    },
    {
      konu: 'Kurumlar (WUR, FloraHolland, ıslah, Greenport, Topsector)',
      konu_en: 'Institutions (WUR, FloraHolland, plant breeding, Greenport, Topsector)',
      sorun: 'Sayısal veri değil kurumsal bilgi; API yok.',
      sorun_en: 'Institutional rather than numerical information; no API exists.',
      cozum: 'Beş kurum kendi resmî yayınlarından tek tek doğrulandı (`_raw/kurumlar.json`). Teyit edilemeyen kalemler ayrı bir "dogrulanmamis" bloğuna alındı ve metne girmeyecek.',
      cozum_en: 'All five institutions were verified one by one against their own official publications (`_raw/kurumlar.json`). Items that could not be confirmed were quarantined in a separate "unverified" block and kept out of the text.',
      durum: 'KAPANDI',
      _kalan_belirsizlik: 'Royal FloraHolland kendi sitesi 403 döndürdüğü için rakamlar çatı örgütü NCR üzerinden alındı. Greenport West-Holland bölgesel rakamları teyit edilemedi.',
      _kalan_belirsizlik_en: 'Royal FloraHolland\'s own site returns 403, so its figures come via the umbrella body NCR. Greenport West-Holland regional figures could not be confirmed.',
    },
  ],
};

// Hiçbir boşluk açık kalmamalı — kalırsa derleme uyarı verir.
const acik = data.bosluklar.filter((b) => b.durum === 'BEKLİYOR');

await writeFile(OUT, JSON.stringify(data, null, 2), 'utf8');
console.log(`data.json yazıldı → ${OUT}`);
console.log(`makro:${data.makro.length} · toprak_su:${data.toprak_su.length} · ` +
  `verim:${data.verim.ortualti.length + data.verim.acik_tarla.length} · ` +
  `sera:${data.sera.sebzeler.length + data.sera.susler.length} · ` +
  `kurum:${data.kurumlar.liste.length} · ` +
  `ikili yıl:${data.turkiye_ile.yillar.length} · boşluk:${data.bosluklar.length}`);
console.log(`tarih blokları:${Object.keys(data.tarih).length - 4} · ` +
  `çevre blokları:${Object.keys(data.cevre).length - 4} · ` +
  `metne giremeyen kalem:${data.tarih._dogrulanmamis_kalemler.length + data.cevre._dogrulanmamis_kalemler.length}`);
console.log(acik.length ? `⚠ AÇIK BOŞLUK: ${acik.map((b) => b.konu).join(', ')}` : '✓ açık boşluk yok');
