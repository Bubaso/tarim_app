// Wikimedia Commons'ta görsel arar ve LİSANS bilgisiyle birlikte döker.
//
// Atıfsız görsel yayımlanmaz (CLAUDE.md §2.4). Bu betik lisansı ve atıf
// metnini kaynağın kendisinden okuyor; el yordamıyla "herhalde serbesttir"
// denmiyor. Telifi belirsiz çıkan aday listeden düşer.
//
//   node content/dossiers/ziraat-bankasi/_raw/gorsel_ara.mjs "chernozem soil profile"

const sorgu = process.argv.slice(2).join(' ');
if (!sorgu) { console.error('kullanım: gorsel_ara.mjs "arama terimi"'); process.exit(1); }

const API = 'https://commons.wikimedia.org/w/api.php';
const KABUL = /^(cc[ -]by([ -]sa)?|cc0|public domain|pd-)/i;

const u = new URL(API);
u.search = new URLSearchParams({
  action: 'query', format: 'json', origin: '*',
  generator: 'search', gsrsearch: `filetype:bitmap ${sorgu}`,
  gsrnamespace: '6', gsrlimit: '14',
  prop: 'imageinfo', iiprop: 'url|extmetadata|size',
  iiurlwidth: '1600',
});

const res = await fetch(u, { headers: { 'User-Agent': 'tarim-app-dossier/1.0' } });
const json = await res.json();
const sayfalar = Object.values(json.query?.pages ?? {});
if (!sayfalar.length) { console.log('sonuç yok'); process.exit(0); }

console.log(`\n══ "${sorgu}" — ${sayfalar.length} aday\n`);
for (const s of sayfalar) {
  const ii = s.imageinfo?.[0];
  if (!ii) continue;
  const m = ii.extmetadata ?? {};
  const al = (k) => (m[k]?.value ?? '').replace(/<[^>]*>/g, '').trim();
  const lisans = al('LicenseShortName') || al('License');
  const temiz = KABUL.test(lisans);
  console.log(`${temiz ? '✅' : '⚠️ '} ${s.title.replace('File:', '')}`);
  console.log(`   lisans : ${lisans || '(bilinmiyor)'}`);
  console.log(`   yazar  : ${al('Artist').slice(0, 90) || '—'}`);
  console.log(`   atıf   : ${(al('Attribution') || al('Credit')).slice(0, 90) || '—'}`);
  console.log(`   ölçü   : ${ii.width}×${ii.height}`);
  console.log(`   dosya  : ${ii.thumburl ?? ii.url}`);
  console.log(`   sayfa  : https://commons.wikimedia.org/wiki/${encodeURIComponent(s.title)}`);
  console.log();
}
