// Hollanda paleti "Cam ve Işık" — WCAG 2.1 kontrast denetimi.
//
// tasarim.json'daki her kontrast iddiası buradan geliyor. Palet değişirse
// önce bu betik çalıştırılır, sonra tasarim.json güncellenir.
//
// Çalıştırma:  node content/dossiers/hollanda/_raw/kontrast.cjs

const hex = (h) => [1, 3, 5].map((i) => parseInt(h.slice(i, i + 2), 16) / 255);
const lin = (c) => (c <= 0.03928 ? c / 12.92 : ((c + 0.055) / 1.055) ** 2.4);
const L = (h) => { const [r, g, b] = hex(h).map(lin); return 0.2126 * r + 0.7152 * g + 0.0722 * b; };
const oran = (a, b) => { const [x, y] = [L(a), L(b)].sort((p, q) => q - p); return (x + 0.05) / (y + 0.05); };

/// Koyu dosya sayfası — kanonik palet
const P = {
  zemin: '#0E1418',
  yuzey: '#18222A',
  murekkep: '#E8EDEF',
  sessiz: '#9BAAB3',
  vurgu: '#FF9E5E',
  ikincil: '#7FC8A9',
  cizgi: '#2A3740',
  cizgiVurgu: '#5A6E78',
};

/// Ana sayfa şeridi açık modda yaşıyor — koyulaştırılmış varyantlar
const A = {
  beyaz: '#FFFFFF',
  krem: '#F7F4EF',
  murekkep: '#16222A',
  vurguKoyu: '#AB4F16',
  ikincilKoyu: '#1F6B4E',
};

let hata = 0;
const test = (ad, fg, bg, esik) => {
  const r = oran(fg, bg);
  const gecti = r >= esik;
  if (!gecti) hata++;
  console.log(`  ${gecti ? '✓' : '✗'} ${ad.padEnd(36)} ${r.toFixed(2).padStart(6)}:1  (gerek ${esik})`);
};

console.log('═══ KOYU DOSYA SAYFASI ═══');
test('gövde  mürekkep / zemin', P.murekkep, P.zemin, 4.5);
test('gövde  mürekkep / yüzey', P.murekkep, P.yuzey, 4.5);
test('meta   sessiz / zemin', P.sessiz, P.zemin, 4.5);
test('meta   sessiz / yüzey', P.sessiz, P.yuzey, 4.5);
test('vurgu  turuncu / zemin', P.vurgu, P.zemin, 4.5);
test('vurgu  turuncu / yüzey', P.vurgu, P.yuzey, 4.5);
test('ikincil  yeşil / zemin', P.ikincil, P.zemin, 4.5);
test('ikincil  yeşil / yüzey', P.ikincil, P.yuzey, 4.5);
test('grafik ekseni  cizgiVurgu / zemin', P.cizgiVurgu, P.zemin, 3);
test('grafik ekseni  cizgiVurgu / yüzey', P.cizgiVurgu, P.yuzey, 3);

console.log('\n═══ AÇIK MOD — ana sayfa şeridi ═══');
test('şerit metni  mürekkep / krem', A.murekkep, A.krem, 4.5);
test('vurgu  vurguKoyu / krem', A.vurguKoyu, A.krem, 4.5);
test('vurgu  vurguKoyu / beyaz', A.vurguKoyu, A.beyaz, 4.5);
test('ikincil  ikincilKoyu / krem', A.ikincilKoyu, A.krem, 4.5);

console.log('\n═══ BİLGİ (başarısız olması BEKLENEN) ═══');
console.log(`  ham turuncu / beyaz             ${oran(P.vurgu, A.beyaz).toFixed(2)}:1`);
console.log(`  dekoratif çizgi / zemin         ${oran(P.cizgi, P.zemin).toFixed(2)}:1`);
console.log('  Bu ikisi kasıtlı: sodyum turuncusu açık zeminde kullanılmaz,');
console.log('  dekoratif çizgi anlam taşıyan hiçbir yerde kullanılmaz.');

console.log(hata ? `\n✗ ${hata} kontrast ihlali` : '\n✓ tüm zorunlu kontrastlar AA geçti');
process.exit(hata ? 1 : 0);
