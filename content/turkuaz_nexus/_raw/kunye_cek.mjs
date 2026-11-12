// Seçilen Commons dosyalarının KÜNYESİNİ çeker: açıklama, tarih, yazar, lisans.
// Altyazı buradan yazılıyor, kareden DEĞİL ([[gorsel-altyazisi-kunyedir]]).
const UA = 'tarimportali.net arastirma';
const API = 'https://commons.wikimedia.org/w/api.php';
const temiz = (s) => (s ?? '').replace(/<[^>]+>/g, ' ').replace(/&#?\w+;/g, ' ')
                              .replace(/\s+/g, ' ').trim();
const dosyalar = process.argv.slice(2);
const u = new URL(API);
for (const [k, v] of Object.entries({
  format: 'json', action: 'query', titles: dosyalar.map(d => 'File:' + d).join('|'),
  prop: 'imageinfo', iiprop: 'extmetadata|url|size|mime',
})) u.searchParams.set(k, v);
const r = await fetch(u, { headers: { 'User-Agent': UA } });
if (!r.ok) { console.error('HTTP ' + r.status); process.exit(1); }
const j = await r.json();
const cikti = [];
for (const s of Object.values(j.query?.pages ?? {})) {
  const ii = s.imageinfo?.[0]; if (!ii) { console.log('YOK: ' + s.title); continue; }
  const m = ii.extmetadata ?? {};
  const al = (k) => temiz(m[k]?.value);
  const kayit = {
    dosya: s.title.replace(/^File:/, ''),
    aciklama: al('ImageDescription'),
    tarih: al('DateTimeOriginal') || al('DateTime'),
    yazar: al('Artist'),
    lisans: al('LicenseShortName'),
    lisans_adresi: al('LicenseUrl'),
    kaynak_sayfa: 'https://commons.wikimedia.org/wiki/' + encodeURIComponent(s.title),
    adres: ii.url, en: ii.width, boy: ii.height, mime: ii.mime,
  };
  cikti.push(kayit);
  console.log('\n══ ' + kayit.dosya);
  for (const [k, v] of Object.entries(kayit)) if (k !== 'dosya') console.log('   ' + k.padEnd(14) + (v ?? '—'));
}
const { writeFileSync } = await import('node:fs');
writeFileSync('gorseller/kunye_ham.json', JSON.stringify(cikti, null, 1));
console.log('\n→ gorseller/kunye_ham.json (' + cikti.length + ' kayıt)');
