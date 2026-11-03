// `grafikBloku` ve yardımcılarını ÜRETİM DOSYASINDAN çalıştırır.
//
// Kopya yazılmıyor: index.js'in gövdesi `ssr_kosum.mjs`teki yöntemle geçici
// bir modüle alınıyor, sonuna yalnızca bir `export` satırı ekleniyor. Böylece
// sınanan şey yayına giden kodun kendisi oluyor.
import { readFileSync, writeFileSync, mkdtempSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';

const kaynak = readFileSync(new URL('./index.js', import.meta.url), 'utf8');
const taklit = `
const onRequest = (_opts, handler) => handler;
const onSchedule = (_opts, handler) => handler;
const initializeApp = () => ({});
const getMessaging = () => ({ sendEachForMulticast: async () => ({ responses: [] }) });
import { readFileSync } from 'node:fs';
`;
const govde = kaynak
  .replace(/^import \{ readFileSync \} from 'node:fs';$/m, '')
  .replace(/^import \{ onRequest \} from 'firebase-functions\/v2\/https';$/m, '')
  .replace(/^import \{ onSchedule \} from 'firebase-functions\/v2\/scheduler';$/m, '')
  .replace(/^import \{ initializeApp \} from 'firebase-admin\/app';$/m, '')
  .replace(/^import \{ getMessaging \} from 'firebase-admin\/messaging';$/m, '');

const dizin = mkdtempSync(join(tmpdir(), 'ssr-grafik-'));
const yol = join(dizin, 'index.mjs');
writeFileSync(
  yol,
  taklit + govde +
    '\nexport { grafikBloku, sayiYaz, birimliYaz, grafikKunyesi, sutunlariTopla };\n',
);
try {
  writeFileSync(join(dizin, 'config.js'), readFileSync(new URL('./config.js', import.meta.url)));
} catch {}

const m = await import(yol);

let gecti = 0;
let kaldi = 0;
function ol(ad, kosul) {
  if (kosul) { gecti++; console.log(`  ✓ ${ad}`); }
  else { kaldi++; console.log(`  ✗ ${ad}`); }
}

console.log('— RAKAM YAZIMI —');
ol('binlik ayıraç Türkçe', m.sayiYaz(45000, false) === '45.000');
ol('binlik ayıraç İngilizce', m.sayiYaz(45000, true) === '45,000');
ol('tam sayıya ondalık eklenmiyor', m.sayiYaz(12, false) === '12');
ol('kesirli sayıda bir basamak', m.sayiYaz(12.44, false) === '12,4');
ol('birim boşlukla ayrı', m.birimliYaz(45000, 'TL/ton', false) === '45.000\u00A0TL/ton');
ol('yüzde Türkçede önde', m.birimliYaz(45, '%', false) === '%45');
ol('yüzde İngilizcede arkada', m.birimliYaz(45, '%', true) === '45%');
ol('sayı olmayan değer olduğu gibi', m.sayiYaz('veri yok', false) === 'veri yok');

console.log('— KÜNYE —');
ol('kaynak + tek dönem',
  m.grafikKunyesi([{ source: 'TÜİK', period: 'Ocak 2026' }], false) ===
    'Kaynak: TÜİK · Dönem: Ocak 2026');
ol('kaynak tekilleşiyor',
  m.grafikKunyesi([{ source: 'TÜİK' }, { source: 'TÜİK' }], false) === 'Kaynak: TÜİK');
ol('çok dönem varsa dönem yazılmıyor',
  m.grafikKunyesi([{ source: 'TÜİK', period: '2024' }, { source: 'TÜİK', period: '2025' }], false) ===
    'Kaynak: TÜİK');
ol('boş dizi', m.grafikKunyesi([], false) === '');
ol('Dart ile aynı etiketler (en)',
  m.grafikKunyesi([{ source: 'TurkStat', period: '2026' }], true) ===
    'Source: TurkStat · Period: 2026');

console.log('— SÜTUN BİRLEŞİMİ —');
ol('ilk satırda olmayan sütun düşmüyor',
  JSON.stringify(m.sutunlariTopla([{ a: 1 }, { a: 2, b: 3 }])) === '["a","b"]');

console.log('— TABLO HTML —');
const tablo = m.grafikBloku(
  {
    type: 'table',
    title: 'Buğday alımı',
    data: [
      { 'Değer': '45.000', 'Dönem': 'Ocak 2026' },
      { 'Değer': '46.500', 'Dönem': 'Şubat 2026', 'Ölçüm': 'alım fiyatı' },
    ],
  },
  [{ source: 'TMO' }],
  false,
);
ol('gerçek <table> üretiliyor', tablo.html.includes('<table>'));
ol('başlık <caption> içinde', tablo.html.includes('<caption>Buğday alımı'));
ol('altlık boşsa künye caption\'a giriyor', tablo.html.includes('Kaynak: TMO'));
ol('th scope="col"', tablo.html.includes('<th scope="col">Değer</th>'));
ol('ilk satırda olmayan sütun çiziliyor', tablo.html.includes('<th scope="col">Ölçüm</th>'));
ol('eksik hücre boş <td>', (tablo.html.match(/<td><\/td>/g) ?? []).length === 1);
ol('bütün hücreler var', tablo.html.includes('45.000') && tablo.html.includes('46.500'));
ol('düz metin articleBody için hazır', tablo.metin.includes('Değer: 45.000, Dönem: Ocak 2026'));

console.log('— GRAFİK HTML —');
const cubuk = m.grafikBloku(
  {
    type: 'bar',
    title: 'Buğday fiyatı',
    unit: 'TL/ton',
    data: [{ label: 'Ankara', value: 45000, change: '+12%' }],
  },
  [],
  false,
);
ol('<dl> üretiliyor', cubuk.html.includes('<dl>'));
ol('rakam biçimli ve birimli', cubuk.html.includes('45.000\u00A0TL/ton'));
ol('yapışık yazım YOK', !cubuk.html.includes('45000TL/ton'));
ol('değişim yazılıyor', cubuk.html.includes('+12%'));
ol('<figure> ile sarılı', cubuk.html.startsWith('<figure>'));

console.log('— GÜVENLİK —');
const kotu = m.grafikBloku(
  {
    type: 'table',
    title: '<script>alert(1)</script>',
    data: [{ 'a': '<img src=x onerror=alert(1)>' }],
  },
  [],
  false,
);
ol('başlık kaçırılıyor', !kotu.html.includes('<script>'));
ol('hücre kaçırılıyor', !kotu.html.includes('<img src=x'));

console.log('— BOŞ GİRDİ —');
ol('null grafik', m.grafikBloku(null, [], false).html === '');
ol('boş data', m.grafikBloku({ type: 'bar', data: [] }, [], false).html === '');
ol('data dizi değil', m.grafikBloku({ type: 'bar', data: 'x' }, [], false).html === '');

console.log(`\n  ${gecti} geçti · ${kaldi} kaldı`);
process.exit(kaldi === 0 ? 0 : 1);
