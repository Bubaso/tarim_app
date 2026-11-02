// Gövde temizleyicisinin sınaması (§19.4).
//
// `sanitizeHtml` DIŞARI AÇILMIYOR: `functions/index.js`ten export edilen her
// şeyi Firebase bir bulut fonksiyonu sanmaya çalışıyor. Bu yüzden kaynak
// dosyadan metin olarak çıkarılıp burada değerlendiriliyor — üretim kodu
// test uğruna değiştirilmiyor.
import { readFileSync } from 'node:fs';

const kaynak = readFileSync(new URL('./index.js', import.meta.url), 'utf8');
function cikar(ad) {
  const i = kaynak.indexOf(`function ${ad}(`);
  if (i < 0) throw new Error(`${ad} bulunamadı`);
  let d = 0, basladi = false;
  for (let j = i; j < kaynak.length; j++) {
    if (kaynak[j] === '{') { d++; basladi = true; }
    else if (kaynak[j] === '}') { d--; if (basladi && d === 0) return kaynak.slice(i, j + 1); }
  }
  throw new Error(`${ad} kapanmıyor`);
}
// `sanitizeHtml` artık `semaTehlikeli`ye ve onun sabitine dayanıyor; sandık
// üçünü birden taşımak zorunda, yoksa test gerçek koddan sapar.
const SABIT = kaynak.match(/^const TEHLIKELI_SEMA = .+$/m)[0];
const sanitizeHtml = new Function(
  `${SABIT}\n${cikar('semaTehlikeli')}\n${cikar('sanitizeHtml')}\nreturn sanitizeHtml;`,
)();

let gecti = 0, kaldi = 0;
const olmamali = (ad, girdi, ...yasak) => {
  const c = sanitizeHtml(girdi);
  const bulunan = yasak.filter((y) => c.toLowerCase().includes(y.toLowerCase()));
  if (bulunan.length) { console.log(`  ✗ ${ad}\n      çıktı: ${c}\n      sızan: ${bulunan}`); kaldi++; }
  else { console.log(`  ✓ ${ad}`); gecti++; }
};
const korunmali = (ad, girdi, ...olmali) => {
  const c = sanitizeHtml(girdi);
  const eksik = olmali.filter((y) => !c.includes(y));
  if (eksik.length) { console.log(`  ✗ ${ad}\n      çıktı: ${c}\n      kaybolan: ${eksik}`); kaldi++; }
  else { console.log(`  ✓ ${ad}`); gecti++; }
};

console.log('— DOKUZ SALDIRI VEKTÖRÜ —');
olmamali('1 betik bloğu',        '<p>a</p><script>alert(1)</script><p>b</p>', '<script', 'alert(1)');
olmamali('2 onerror özniteliği', '<img src=x onerror=alert(1)>', 'onerror');
olmamali('3 javascript: bağ',    '<a href="javascript:alert(1)">tık</a>', 'javascript:');
olmamali('4 iframe',             '<iframe src="//kotu"></iframe>', '<iframe');
olmamali('5 object',             '<object data="kotu.swf"></object>', '<object');
olmamali('6 embed',              '<embed src="kotu">', '<embed');
olmamali('7 form',               '<form action="//kotu"><input name="p"></form>', '<form', 'action=');
olmamali('8 data: bağ',          '<a href="data:text/html;base64,PHM+">tık</a>', 'data:text/html');
olmamali('9 svg onload',         '<svg/onload=alert(1)></svg>', '<svg', 'onload');

console.log('— KAÇIŞ DENEMELERİ —');
olmamali('kapanışsız betik',     '<script src="//kotu">',               '<script');
olmamali('entity ile gizleme',   '<a href="java&#09;script:alert(1)">x</a>', 'script:');
olmamali('baştaki boşluk',       '<a href="  javascript:alert(1)">x</a>', 'javascript:');
olmamali('tek tırnak onclick',   "<p onclick='alert(1)'>x</p>",          'onclick');
olmamali('srcdoc',               '<iframe srcdoc="<script>alert(1)</script>"></iframe>', 'srcdoc', '<iframe');
olmamali('büyük harf ScRiPt',    '<ScRiPt>alert(1)</ScRiPt>',            'alert(1)');
olmamali('formaction',           '<button formaction="javascript:alert(1)">x</button>', 'formaction');

console.log('— MEŞRU İÇERİK KORUNMALI —');
korunmali('alıntılı paragraf',  '<p>Bakan "şöyle dedi"</p>', '<p>Bakan "şöyle dedi"</p>');
korunmali('ara başlık',         '<h2>Üretim Arttı</h2>', '<h2>Üretim Arttı</h2>');
korunmali('tablo',              '<table><tr><td>1.250</td></tr></table>', '<table>', '<td>1.250</td>');
korunmali('blok alıntı',        '<blockquote>Söz</blockquote>', '<blockquote>');
korunmali('görsel',             '<img src="https://x.co/a.jpg" alt="a">', 'https://x.co/a.jpg', 'alt="a"');
korunmali('dış bağlantı',       '<a href="https://x.co">kaynak</a>', 'href="https://x.co"', '>kaynak<');
korunmali('dsy sınıfı (§39.1)', '<p class="dsy-foto">Kaynak: AA</p>', 'class="dsy-foto"', 'Kaynak: AA');
korunmali('liste',              '<ul><li>bir</li><li>iki</li></ul>', '<ul>', '<li>bir</li>');

console.log(`\n  ${gecti} geçti · ${kaldi} kaldı`);
process.exit(kaldi ? 1 : 0);
