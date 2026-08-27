// _raw/*.json → data.json
//
// Bu betiğin işi TÜRETMEK, uydurmak değil. Buraya elle yazılmış tek bir rakam
// yok; her değer bir ham dosyadan geliyor ve `_kaynaklar` altında hangisinden
// geldiği yazıyor.
//
// ÇİFT SAYIM DENETİMİ. Toplama yapılan her yerde `topla()` kullanılıyor ve o
// fonksiyon, toplanan listede topluluştırıcı kalem görürse ATIYOR. Hollanda
// dosyasında bu sınıf hata denetlendi ve çıkmadı (CLAUDE.md §2.2.1); burada
// tesadüfe bırakılmıyor.

import { readFile, writeFile } from 'node:fs/promises';
import { dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const DIR = dirname(fileURLToPath(import.meta.url));
const oku = async (p) => JSON.parse(await readFile(`${DIR}/${p}`, 'utf8'));

const wb = await oku('_raw/worldbank.json');
const psd = await oku('_raw/usda_psd.json');
const ct = await oku('_raw/comtrade_ikili.json');
const faoDeger = await oku('_raw/faostat_deger.json');
const faoUretim = await oku('_raw/faostat_uretim.json');
const faoIkili = await oku('_raw/faostat_ikili.json');
const kurumlar = await oku('_raw/kurumlar.json');
const tarihKultur = await oku('_raw/tarih_kultur.json');

// ─────────────────────────────────────────────────────── çift sayım denetimi

// FAOSTAT'ta bu adlar tek tek ürünlerin YANINDA durur ve onları İÇERİR.
// Ayrıntı kalemleriyle aynı toplamda buluşurlarsa sonuç şişer.
// "n.e.c." bu listede DEĞİL: o bir artık kategorisidir, içinde kalem taşımaz.
const TOPLULASTIRICI = [
  'Crops and livestock products', 'Cereals, primary', 'Food, Total',
  'Agricultural Products, Total', 'Crops, Total', 'Non-Food, Total',
  'Fruit Primary', 'Vegetables Primary', 'Cereals and Preparations',
  'Fruit and Vegetables', 'Livestock Products', 'Agriculture', 'Crops', 'Livestock',
];

function topla(kalemler, deger, etiket) {
  const kirli = kalemler.filter((k) => TOPLULASTIRICI.includes(k.ad ?? k));
  if (kirli.length) {
    throw new Error(
      `ÇİFT SAYIM: "${etiket}" toplamında topluluştırıcı kalem var — ` +
      kirli.map((k) => k.ad ?? k).join(', '),
    );
  }
  return kalemler.reduce((s, k) => s + (deger(k) ?? 0), 0);
}

// ─────────────────────────────────────────────────────── yardımcılar

const g = (kod) => wb.gostergeler[kod];
const wbSatir = (kod, etiket) => {
  const x = g(kod);
  const y = String(x._ortak_son_yil);
  return {
    etiket, birim: x.etiket, yil: x._ortak_son_yil,
    RUS: x.RUS[y] ?? null, TUR: x.TUR[y] ?? null,
    oran_RUS_TUR: x.RUS[y] && x.TUR[y] ? +(x.RUS[y] / x.TUR[y]).toFixed(2) : null,
    _ileri_not: x._ileri_not,
    kaynak: 'WB',
  };
};

const psdSeri = (ulke, urun, nitelik) => {
  const s = psd.seri[ulke]?.[urun]?.[nitelik];
  return s ? Object.fromEntries(Object.entries(s).map(([k, v]) => [Number(k), v])) : null;
};

const KESIN = psd._kesin_son_yil; // 2024 — tahmin yılları karşılaştırmaya girmez

const ctYil = (yil, flow) => ct.fasillar[yil]?.[flow] ?? {};
const ctKalem = (yil, flow, kod) => ct.kalemler[yil]?.[flow]?.[kod]?.deger_usd ?? 0;
const TARIM_FASILLARI = Array.from({ length: 24 }, (_, i) => String(i + 1).padStart(2, '0'));
const ctTarimToplam = (yil, flow) => {
  const f = ctYil(yil, flow);
  return topla(TARIM_FASILLARI.filter((k) => k in f), (k) => f[k].deger_usd, `Comtrade ${yil}/${flow}`);
};

const YILLAR = Object.keys(ct.fasillar).map(Number).sort();
const SON = Math.max(...YILLAR);

// ─────────────────────────────────────────────────────── bloklar

const sonIkili = {
  yil: SON,
  turkiyeden_rusyaya_usd: Math.round(ctTarimToplam(SON, 'X')),
  rusyadan_turkiyeye_usd: Math.round(ctTarimToplam(SON, 'M')),
};
sonIkili.denge_usd = sonIkili.turkiyeden_rusyaya_usd - sonIkili.rusyadan_turkiyeye_usd;

// Tezin dayandığı ayrım: ne aldığımız depolanabilir, ne sattığımız bozulur.
const DEPOLANABILIR = ['10', '12', '23']; // tahıl, yağlı tohum, küspe
const BOZULUR = ['03', '07', '08']; // balık, sebze, meyve
const payHesap = (yil, flow, fasillar) => {
  const f = ctYil(yil, flow);
  const t = ctTarimToplam(yil, flow);
  const alt = topla(fasillar.filter((k) => k in f), (k) => f[k].deger_usd, `pay ${yil}/${flow}`);
  return { tutar_usd: Math.round(alt), pay_yuzde: +(100 * alt / t).toFixed(1) };
};

const data = {
  _dosya: 'Rusya — Ülke Dosyası · kilitli veri sayfası',
  _uretim_tarihi: new Date().toISOString(),
  _kural:
    'Bu dosyadaki hiçbir rakam elle yazılmadı. Hepsi _raw/ altındaki ham çekimlerden ' +
    'türetildi. Metin bu dosyayı kaynak alır; buradaki bir sayı değişmeden metindeki ' +
    'karşılığı değişemez.',
  _yontem_uyarisi:
    'Rusya\'ya ait rakamların çoğu AYNA İSTATİSTİKTİR: Rusya\'nın kendi istatistik kurumu ' +
    've gümrük idaresi bu ağdan okunamadı. Türkiye–Rusya ticaretinde birincil kaynak ' +
    'Türkiye\'nin kaydıdır. Bkz. _raw/README.md "Kapalı kapılar".',

  _kaynaklar: {
    WB: { ad: 'World Bank — World Development Indicators', cekilme: wb._cekilme_tarihi, lisans: 'CC BY 4.0' },
    PSD: { ad: 'USDA FAS — Production, Supply and Distribution', cekilme: psd._cekilme_tarihi, lisans: 'ABD kamu malı', kesin_son_yil: KESIN },
    COMTRADE: { ad: 'UN Comtrade — Türkiye raporlayan (792), partner Rusya (643)', cekilme: ct._cekilme_tarihi },
    FAO_QV: { ad: 'FAOSTAT — Value of Production', cekilme: faoDeger._cekilme_tarihi, lisans: 'CC BY 4.0' },
    FAO_QCL: { ad: 'FAOSTAT — Production: Crops and Livestock', cekilme: faoUretim._cekilme_tarihi, lisans: 'CC BY 4.0' },
    FAO_TM: { ad: 'FAOSTAT — Detailed Trade Matrix, Rusya raporlayan', cekilme: faoIkili._cekilme_tarihi, lisans: 'CC BY 4.0' },
    KURUM: { ad: 'Kurumsal ve mevzuat katmanı — elle doğrulanmış', dogrulama: kurumlar._dogrulama_tarihi },
    TARIH: { ad: 'Tarih, bilim ve tarım kültürü katmanı — elle doğrulanmış', dogrulama: tarihKultur._dogrulama_tarihi },
  },

  tez: {
    cumle: 'Rusya hem pazarımız hem tedarikçimiz. Ama ondan aldığımız bir yıl bekler, ona sattığımız birkaç hafta dayanır.',
    cumle_en: 'Russia is both our market and our supplier. But what we buy keeps for a year; what we sell keeps for weeks.',
    baslik: 'Pazar dediğimiz ülke',
    dayanak: {
      _aciklama: 'Tez bir slogan değil, şu iki satırın farkı.',
      yil: SON,
      rusyadan_aldigimiz_depolanabilir: payHesap(SON, 'M', DEPOLANABILIR),
      rusyadan_aldigimiz_diger: {
        tutar_usd: Math.round(ctTarimToplam(SON, 'M')) - payHesap(SON, 'M', DEPOLANABILIR).tutar_usd,
        pay_yuzde: +(100 - payHesap(SON, 'M', DEPOLANABILIR).pay_yuzde).toFixed(1),
      },
      rusyaya_sattigimiz_bozulur: payHesap(SON, 'X', BOZULUR),
      rusyaya_sattigimiz_diger: {
        tutar_usd: Math.round(ctTarimToplam(SON, 'X')) - payHesap(SON, 'X', BOZULUR).tutar_usd,
        pay_yuzde: +(100 - payHesap(SON, 'X', BOZULUR).pay_yuzde).toFixed(1),
      },
    },
  },

  ikili_ticaret: {
    _kaynak: 'COMTRADE',
    _raporlayan: ct._raporlayan,
    _raporlayan_notu: ct._raporlayan_notu,
    _birim: 'cari ABD doları',
    _cift_sayim_kurali: ct._cift_sayim_kurali,
    son: sonIkili,
    seri: YILLAR.map((y) => ({
      yil: y,
      turkiyeden_rusyaya_usd: Math.round(ctTarimToplam(y, 'X')),
      rusyadan_turkiyeye_usd: Math.round(ctTarimToplam(y, 'M')),
      denge_usd: Math.round(ctTarimToplam(y, 'X') - ctTarimToplam(y, 'M')),
      gubre_rusyadan_usd: Math.round(ctYil(y, 'M')['31']?.deger_usd ?? 0),
    })),
    fasil_kompozisyonu: {
      yil: SON,
      turkiyeden_rusyaya: Object.entries(ctYil(SON, 'X'))
        .filter(([k]) => TARIM_FASILLARI.includes(k))
        .map(([k, v]) => ({ fasil: k, deger_usd: Math.round(v.deger_usd) }))
        .sort((a, b) => b.deger_usd - a.deger_usd).slice(0, 8),
      rusyadan_turkiyeye: Object.entries(ctYil(SON, 'M'))
        .filter(([k]) => TARIM_FASILLARI.includes(k))
        .map(([k, v]) => ({ fasil: k, deger_usd: Math.round(v.deger_usd) }))
        .sort((a, b) => b.deger_usd - a.deger_usd).slice(0, 8),
    },
  },

  ambargo_2016: {
    _aciklama:
      'Türkiye\'nin Rusya\'ya ihracatında 2015 → 2016 kırılması ve dokuz yıllık toparlanma. ' +
      'Tezin en somut kanıtı: bozulan ürünün pazarı geri gelmiyor.',
    _kaynak: 'COMTRADE',
    _birim: 'cari ABD doları',
    kalemler: ['0702', '0806', '0805'].map((kod) => ({
      kod, ad: ct._kalem_adlari[kod],
      seri: Object.fromEntries(YILLAR.map((y) => [y, Math.round(ctKalem(y, 'X', kod))])),
      zirve_oncesi_2015: Math.round(ctKalem(2015, 'X', kod)),
      dip_2016: Math.round(ctKalem(2016, 'X', kod)),
      son: Math.round(ctKalem(SON, 'X', kod)),
      toparlanma_orani_yuzde: ctKalem(2015, 'X', kod)
        ? +(100 * ctKalem(SON, 'X', kod) / ctKalem(2015, 'X', kod)).toFixed(1) : null,
    })),
  },

  tahil_donusumu: {
    _aciklama:
      'SSCB dünyanın en büyük buğday alıcısıydı; Rusya en büyük satıcısı oldu. ' +
      'SSCB ve Rusya AYRI kayıtlardır, tek seri gibi birleştirilmez.',
    _kaynak: 'PSD',
    _birim: 'bin ton',
    _pazarlama_yili_notu: psd._uyarilar[1],
    _kesin_son_yil: KESIN,
    sscb: {
      _kapsam: '1960-1986, on beş cumhuriyet',
      ithalat: psdSeri('SSCB', 'Wheat', 'Imports'),
      ihracat: psdSeri('SSCB', 'Wheat', 'Exports'),
      uretim: psdSeri('SSCB', 'Wheat', 'Production'),
    },
    rusya: {
      _kapsam: '1987-, yalnızca Rusya Federasyonu',
      ithalat: psdSeri('RUS', 'Wheat', 'Imports'),
      ihracat: psdSeri('RUS', 'Wheat', 'Exports'),
      uretim: psdSeri('RUS', 'Wheat', 'Production'),
    },
    turkiye: {
      ithalat: psdSeri('TUR', 'Wheat', 'Imports'),
      ihracat: psdSeri('TUR', 'Wheat', 'Exports'),
      uretim: psdSeri('TUR', 'Wheat', 'Production'),
    },
  },

  diger_tahillar: {
    _aciklama:
      'Dönüşüm buğdayla sınırlı değil. Çavdar ters yöne gidiyor: dünya pazarı ' +
      'olmayan üründen vazgeçilmiş.',
    _kaynak: 'PSD',
    _birim: 'bin ton',
    urunler: ['Barley', 'Corn', 'Rye'].map((u) => ({
      urun: u,
      rusya_uretim: psdSeri('RUS', u, 'Production'),
      rusya_ihracat: psdSeri('RUS', u, 'Exports'),
    })),
  },

  alan_ve_verim: {
    _aciklama:
      'Buğday üretimi iki bileşene ayrılınca ayrışma görünüyor: iki ülke de verimini ' +
      'yaklaşık yüzde elli artırdı; Rusya alanı büyüttü, Türkiye küçülttü.',
    _kaynak: 'PSD',
    _birimler: { alan: 'bin hektar', verim: 'ton/hektar', uretim: 'bin ton' },
    RUS: {
      alan: psdSeri('RUS', 'Wheat', 'Area Harvested'),
      verim: psdSeri('RUS', 'Wheat', 'Yield'),
    },
    TUR: {
      alan: psdSeri('TUR', 'Wheat', 'Area Harvested'),
      verim: psdSeri('TUR', 'Wheat', 'Yield'),
    },
  },

  karadeniz_havzasi: {
    _aciklama:
      'Ayçiçeğinde ve buğdayda Rusya tek başına ele alınamaz. Kaynak çeşitlendirmesi ' +
      'Rusya\'dan Ukrayna\'ya geçmekle olmuyor: ikisi de aynı havzada.',
    _kaynak: 'PSD',
    _birim: 'bin ton',
    aycicegi_yagi_ihracat: { RUS: psdSeri('RUS', 'Oil, Sunflowerseed', 'Exports'), UKR: psdSeri('UKR', 'Oil, Sunflowerseed', 'Exports') },
    bugday_ihracat: { RUS: psdSeri('RUS', 'Wheat', 'Exports'), UKR: psdSeri('UKR', 'Wheat', 'Exports') },
  },

  isleme_makinesi: {
    _aciklama:
      'Türkiye hammaddeyi alıp işleyip satıyor. Buğdayda un, ayçiçeğinde yağ. ' +
      'Haziran 2024\'te durdurulan şey tam olarak bu zincirdi (bkz. kurumlar.turkiye_2024_karari).',
    _kaynak: 'PSD',
    _birim: 'bin ton',
    _yil: KESIN,
    kalemler: [
      { urun: 'Buğday', psd_urun: 'Wheat' },
      { urun: 'Ayçiçeği yağı', psd_urun: 'Oil, Sunflowerseed' },
      { urun: 'Ayçiçeği tohumu', psd_urun: 'Oilseed, Sunflowerseed' },
    ].map(({ urun, psd_urun }) => ({
      urun,
      turkiye: {
        uretim: psdSeri('TUR', psd_urun, 'Production')?.[KESIN] ?? null,
        ithalat: psdSeri('TUR', psd_urun, 'Imports')?.[KESIN] ?? null,
        ihracat: psdSeri('TUR', psd_urun, 'Exports')?.[KESIN] ?? null,
      },
      rusya: {
        uretim: psdSeri('RUS', psd_urun, 'Production')?.[KESIN] ?? null,
        ihracat: psdSeri('RUS', psd_urun, 'Exports')?.[KESIN] ?? null,
      },
      // Makinenin ne zaman kurulduğu tek yılda görünmüyor; seri de taşınıyor.
      turkiye_seri: {
        uretim: psdSeri('TUR', psd_urun, 'Production'),
        ithalat: psdSeri('TUR', psd_urun, 'Imports'),
        ihracat: psdSeri('TUR', psd_urun, 'Exports'),
      },
    })),
  },

  musteriler: {
    _aciklama:
      'Rusya\'nın tarım ihracatında Türkiye kaçıncı sırada. Bu tablo ilişkinin ' +
      'karşılıklı olduğunu gösteriyor: Rusya bizim en büyük tedarikçimiz, biz de ' +
      'onun en büyük müşterisiyiz.',
    _kaynak: 'FAO_TM',
    _raporlayan: 'Rusya Federasyonu',
    _uyari: faoIkili._uyari,
    _kesinti_notu:
      'Rusya\'nın FAOSTAT\'a raporlaması 2021\'de bitiyor. Sonraki yıllar yok. ' +
      'Bu, dosyanın yöntem iddiasının veriyle görünen hâli.',
    son_yil: Math.max(...Object.keys(faoIkili.siralama).map(Number)),
    // Türkiye hep birinci DEĞİL. 1998'de 2., 2001'de 18. sırada. Birinciliğe
    // 2012'de çıkıyor ve bir yıl (2018) dışında bırakmıyor. Bu istisna
    // silinmiyor: "kesintisiz" demek yanlış olurdu.
    birincilik: (() => {
      const y = Object.keys(faoIkili.siralama).map(Number).sort((a, b) => a - b);
      const birinci = y.filter((k) => faoIkili.siralama[k].turkiye_sirasi === 1);
      const ilk = Math.min(...birinci);
      const aralik = y.filter((k) => k >= ilk);
      return {
        ilk_birincilik_yili: ilk,
        birinci_oldugu_yil_sayisi: birinci.length,
        ilk_yildan_beri_istisnalar: aralik
          .filter((k) => faoIkili.siralama[k].turkiye_sirasi !== 1)
          .map((k) => ({ yil: k, sira: faoIkili.siralama[k].turkiye_sirasi })),
        en_dusuk: (() => {
          const k = y.reduce((a, b) =>
            faoIkili.siralama[b].turkiye_sirasi > faoIkili.siralama[a].turkiye_sirasi ? b : a);
          return { yil: k, sira: faoIkili.siralama[k].turkiye_sirasi };
        })(),
      };
    })(),
    son_siralama: (() => {
      const y = Math.max(...Object.keys(faoIkili.siralama).map(Number));
      return { yil: y, ilk_5: faoIkili.siralama[y].ilk_10.slice(0, 5) };
    })(),
    seri: Object.fromEntries(
      Object.entries(faoIkili.siralama).map(([y, s]) => [y, {
        turkiye_sirasi: s.turkiye_sirasi,
        // Türkiye ilk 10'un dışındaysa (2001'de 18. sırada) değeri oradan
        // okunamıyor; ham dosyanın kendi `turkiye` bloğundan alınıyor.
        turkiye_1000usd: faoIkili.turkiye[y]?.deger_1000usd ?? null,
        toplam_1000usd: Math.round(s.toplam_1000usd),
        turkiye_payi_yuzde: faoIkili.turkiye[y]
          ? +(100 * faoIkili.turkiye[y].deger_1000usd / s.toplam_1000usd).toFixed(1)
          : null,
        partner_sayisi: s.partner_sayisi,
        ilk_5: s.ilk_10.slice(0, 5),
      }]),
    ),
  },

  uretim_degeri: {
    _aciklama:
      'Rusya\'nın üstünlüğü neredeyse tamamen tahılda. Diğer her şeyde iki ülke yakın. ' +
      'Türk tarımı geride değil, farklı uzmanlaşmış.',
    _kaynak: 'FAO_QV',
    _birim: 'bin sabit 2014-2016 uluslararası dolar',
    _uyari: faoDeger._uyari,
    kalemler: ['Agriculture', 'Crops', 'Livestock', 'Cereals, primary'].map((ad) => {
      const o = faoDeger._ortak_yillar[ad];
      const y = String(o?.ortak_son_yil);
      const r = faoDeger.kalemler[ad]?.RUS?.seri?.[y] ?? null;
      const t = faoDeger.kalemler[ad]?.TUR?.seri?.[y] ?? null;
      return {
        kalem: ad, yil: o?.ortak_son_yil ?? null, RUS: r, TUR: t,
        oran_RUS_TUR: r && t ? +(r / t).toFixed(2) : null,
        _ileri_not: o?._ileri_not ?? null,
      };
    }),
    seyir: {
      _aciklama: 'Rusya 1990\'larda çöktü ve geri geldi; Türkiye kesintisiz büyüdü.',
      yillar: [1992, 2000, 2010, 2020, 2023].map((y) => ({
        yil: y,
        RUS: faoDeger.kalemler.Agriculture?.RUS?.seri?.[y] ?? null,
        TUR: faoDeger.kalemler.Agriculture?.TUR?.seri?.[y] ?? null,
      })),
    },
  },

  toprak_ve_verim: {
    _aciklama:
      'Rusya\'nın elinde beş buçuk kat arazi var. Ama hektar başına tahıl verimi ' +
      'Türkiye\'ninkinden yüksek DEĞİL. Fark toprağın genişliğinde, veriminde değil.',
    _kaynak: 'WB',
    satirlar: [
      wbSatir('AG.LND.AGRI.K2', 'Tarım arazisi'),
      wbSatir('AG.LND.ARBL.HA.PC', 'Kişi başına işlenebilir arazi'),
      wbSatir('AG.LND.TOTL.K2', 'Kara alanı'),
      wbSatir('AG.YLD.CREL.KG', 'Tahıl verimi'),
      wbSatir('AG.CON.FERT.ZS', 'Gübre tüketimi'),
      wbSatir('SL.AGR.EMPL.ZS', 'Tarımda istihdam payı'),
      wbSatir('SP.POP.TOTL', 'Nüfus'),
    ],
    olcu_catismasi: {
      _aciklama:
        'İKİ KAYNAK TERS SONUÇ VERİYOR ve ikisi de doğru — farklı şey ölçüyorlar. ' +
        'Metinde ikisi birlikte verilir, biri seçilip diğeri gizlenmez.',
      dunya_bankasi_katma_deger: wbSatir('NV.AGR.TOTL.CD', 'Tarımsal katma değer (cari USD)'),
      fao_brut_uretim_degeri: 'uretim_degeri.kalemler[0] — sabit 2014-16 I$',
      neden: 'Biri net katma değer ve kur hareketi taşır; diğeri brüt üretim ve sabit fiyat.',
    },
  },

  girdi_kanali: {
    _aciklama:
      'Rusya Türk tarımına üç kanaldan değiyor: gıda, yem ve GİRDİ. Gübre tarım ' +
      'faslı değil (HS31), bu yüzden tarım ticareti toplamlarının dışında kalıyor.',
    _kaynak: 'COMTRADE',
    _birim: 'cari ABD doları',
    gubre_rusyadan: Object.fromEntries(
      YILLAR.map((y) => [y, Math.round(ctYil(y, 'M')['31']?.deger_usd ?? 0)]),
    ),
    // Üç kanalın karşılaştırılabilmesi için gıda ve yem serileri de burada.
    fasil_serileri: Object.fromEntries(
      [['10', 'tahil'], ['15', 'yag'], ['23', 'yem_kuspe']].map(([f, ad]) => [
        ad, Object.fromEntries(YILLAR.map((y) => [y, Math.round(ctYil(y, 'M')[f]?.deger_usd ?? 0)])),
      ]),
    ),
    kalemler: ['3102', '3105'].map((kod) => ({
      kod, ad: ct._kalem_adlari[kod],
      son_yil: SON, son_deger_usd: Math.round(ctKalem(SON, 'M', kod)),
    })),
  },

  tarih_kultur: {
    _kaynak: 'TARIH',
    _aciklama:
      'Dosyanın veriyle anlatılamayan yarısı. Buradaki her blok bir bölümü ' +
      'besliyor: çernozyom, Vavilov, ayçiçeği, kolhoz, çavdar, dacha, çay, sera.',
    _giris_yontemi: tarihKultur._giris_yontemi,
    _dogrulama_tarihi: tarihKultur._dogrulama_tarihi,
    ...Object.fromEntries(
      Object.entries(tarihKultur).filter(
        ([k]) => !k.startsWith('_') && k !== 'dogrulanamadi',
      ),
    ),
    _dogrulanmamis_kalemler: tarihKultur.dogrulanamadi,
    _dogrulanmamis_kural:
      'Yukarıdaki liste METNE GİRMEZ. Yalnızca ileride doğrulanmak üzere kayıt altındadır.',
  },

  kurumlar: {
    _kaynak: 'KURUM',
    _giris_yontemi: kurumlar._giris_yontemi,
    _dogrulama_tarihi: kurumlar._dogrulama_tarihi,
    kapali_kaynaklar: kurumlar.kapali_kaynaklar,
    ihracat_vergisi: kurumlar.ihracat_vergisi,
    ihracat_kotasi: kurumlar.ihracat_kotasi,
    limanlar: kurumlar.limanlar,
    turkiye_2024_karari: kurumlar.turkiye_2024_karari,
    _dogrulanmamis_kalemler: kurumlar.dogrulanamadi,
    _dogrulanmamis_kural:
      'Yukarıdaki liste METNE GİRMEZ. Yalnızca ileride doğrulanmak üzere kayıt altındadır.',
  },
};

// ─────────────────────────────────────────────────────── veri boşlukları
// Bulunamayan rakam gizlenmez; sayfadaki Veri Notları panelinde açıkça durur.

// ── veri boşlukları ──────────────────────────────────────────────────────
// PANEL KALDIRILDI (kullanıcı kararı, 24 Ağustos 2026). Boş dizi bırakmak
// yeterli: ekrandaki panel `bosluklar.isEmpty` olduğunda hiç çizilmiyor,
// kod değişikliği gerekmiyor.
//
// Kayıtların KENDİSİ silinmedi — hangi rakamın neden bulunamadığı ve yerine
// ne konduğu `_raw/README.md`, `_raw/kurumlar.json/dogrulanamadi` ve
// `_raw/tarih_kultur.json/dogrulanamadi` altında duruyor. Metindeki parantez
// içi kaynak notları da yerinde: okur hangi kalemin ikincil kaynaklı
// olduğunu cümlenin yanında görüyor.
data.bosluklar = [];

await writeFile(`${DIR}/data.json`, JSON.stringify(data, null, 2), 'utf8');
console.log(`data.json yazıldı — ${Object.keys(data).filter((k) => !k.startsWith('_')).length} blok`);
