// Yapay Zeka ve Dijital Tarım için statik paylaşım sayfaları — Cloud
// Function GEREKTİRMEZ. Uzayda Tarım'ın paylasim_sayfasi.mjs'iyle aynı desen.
//
// Kullanım:  node content/yapay_zeka_dijital_tarim/paylasim_sayfasi.mjs
// Çıktı:     build/web/yapay-zeka-dijital-tarim/index.html
//            build/web/yapay-zeka-dijital-tarim/<adres>/index.html  (yazılmış her başlık)
//
// Firebase Hosting statik dosyayı yönlendirmelerden ÖNCE sunuyor: derleme
// sonrası yazılan kabuk og etiketlerini taşıyor, Flutter uygulaması normal
// açılıp GoRouter ile sayfaya gidiyor.
//
// Başlık sayfasının açıklaması o başlığın GİRİŞ paragrafından (başlık
// satırından sonraki ilk düz paragraf; karar 56'dan beri ayrı özet bloğu
// yok) alınıyor — metinden, hafızadan değil. Yazılmamış başlığın kabuğu yok:
// paylaşılırsa bölümün genel kabuğuna düşmesi doğru, çünkü sayfada henüz
// paylaşılacak bir metin yok.

import { readFileSync, writeFileSync, mkdirSync, existsSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const BURASI = dirname(fileURLToPath(import.meta.url));
const KOK = join(BURASI, '..', '..');

// KANONİK ALAN ADI — statik_sayfa.mjs ve uzay_tarimi/paylasim_sayfasi.mjs
// ile AYNI olmak zorunda.
const ADRES = 'https://tarimportali.net';
const YOL = '/yapay-zeka-dijital-tarim';

// OKURA KAPALIYKEN hiçbir kabuk üretilmez (yayin.json; kullanıcı kararı:
// 30 başlığın tamamı yazılınca açılır). Çıkış kodu 0: dağıtım sürsün.
const yayin = JSON.parse(readFileSync(join(BURASI, 'yayin.json'), 'utf8'));
if (!yayin.okura_acik) {
  console.log('· Yapay Zeka ve Dijital Tarım okura kapalı — paylaşım kabuğu üretilmedi');
  process.exit(0);
}

const kabuk = join(KOK, 'build', 'web', 'index.html');
if (!existsSync(kabuk)) {
  console.error('✗ build/web/index.html yok. Önce flutter build web.');
  process.exit(1);
}
const kart = join(KOK, 'web', 'paylasim', 'yapay-zeka-dijital-tarim.jpg');
if (!existsSync(kart)) {
  console.error('✗ web/paylasim/yapay-zeka-dijital-tarim.jpg yok.');
  console.error('  Önce: node content/yapay_zeka_dijital_tarim/paylasim_karti.mjs');
  process.exit(1);
}

const iskelet = JSON.parse(readFileSync(join(BURASI, 'iskelet.json'), 'utf8'));
const gorsel = `${ADRES}/paylasim/yapay-zeka-dijital-tarim.jpg`;
const ham = readFileSync(kabuk, 'utf8');

const kac = (s) => String(s ?? '')
  .replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;')
  .replaceAll('"', '&quot;');

/** Markdown'ın ilk düz paragrafını düz metne çevirir ve ~200 karakterde keser. */
function ozetten(md) {
  const paragraf = [];
  for (const s of md.split('\n').slice(1)) {
    const t = s.trim();
    if (!t) { if (paragraf.length) break; continue; }
    if (/^(#|>|\|)/.test(t)) { if (paragraf.length) break; continue; }
    paragraf.push(t);
  }
  let metin = paragraf.join(' ');
  metin = metin.replace(/\*\*(.+?)\*\*/g, '$1').replace(/\*(.+?)\*/g, '$1').trim();
  if (metin.length <= 200) return metin;
  const kes = metin.slice(0, 200);
  return kes.slice(0, kes.lastIndexOf(' ')) + '…';
}

function yaz(altYol, baslik, ozet) {
  let html = ham;
  const adres = `${ADRES}${altYol}`;
  const degistir = (isim, deger, nitelik = 'property') => {
    const kalip = new RegExp(
      `<meta\\s+${nitelik}="${isim}"\\s+content="[^"]*"\\s*/?>`, 'i');
    const yeni = `<meta ${nitelik}="${isim}" content="${kac(deger)}">`;
    if (kalip.test(html)) { html = html.replace(kalip, yeni); return; }
    html = html.replace('</head>', `  ${yeni}\n</head>`);
  };
  html = html.replace(/<title>[^<]*<\/title>/i,
    `<title>${kac(baslik)} | Tarım Portalı</title>`);
  degistir('description', ozet, 'name');
  degistir('og:type', 'article');
  degistir('og:title', baslik);
  degistir('og:description', ozet);
  degistir('og:url', adres);
  degistir('og:image', gorsel);
  degistir('og:image:width', '1200');
  degistir('og:image:height', '630');
  degistir('og:image:type', 'image/jpeg');
  degistir('og:image:alt', 'Yapay Zeka ve Dijital Tarım');
  degistir('twitter:card', 'summary_large_image', 'name');
  degistir('twitter:title', baslik, 'name');
  degistir('twitter:description', ozet, 'name');
  degistir('twitter:image', gorsel, 'name');
  // canonical ayrı: <meta> değil <link>. Yanlışı tarama motoruna "bu
  // sayfayı değil ana sayfayı dizine al" demek.
  const kanonikKalip = /<link\s+rel="canonical"\s+href="[^"]*"\s*\/?>/i;
  const kanonik = `<link rel="canonical" href="${kac(adres)}">`;
  html = kanonikKalip.test(html)
    ? html.replace(kanonikKalip, kanonik)
    : html.replace('</head>', `  ${kanonik}\n</head>`);
  const klasor = join(KOK, 'build', 'web', ...altYol.split('/').filter(Boolean));
  mkdirSync(klasor, { recursive: true });
  writeFileSync(join(klasor, 'index.html'), html, 'utf8');
}

const toplam = iskelet.basliklar.length;
const yazilanlar = iskelet.basliklar.filter((b) => b.durum === 'yazildi');
yaz(YOL, 'Yapay Zeka ve Dijital Tarım',
  `Tarımda yapay zekâ ve dijital teknolojiler bugün nerede duruyor: ölçülmüş, `
  + `kaynaklı, düzenli taranan bir başvuru dosyası. ${toplam} başlık, `
  + `${yazilanlar.length} yazıldı.`);

for (const b of yazilanlar) {
  const on = `${String(b.no).padStart(2, '0')}-${b.slug}`;
  const md = readFileSync(join(BURASI, 'bolumler', `${on}.tr.md`), 'utf8');
  yaz(`${YOL}/${b.slug}`, `${b.baslik.tr} — Yapay Zeka ve Dijital Tarım`, ozetten(md));
}

console.log(`✓ build/web${YOL}/index.html + ${yazilanlar.length} başlık kabuğu`);
