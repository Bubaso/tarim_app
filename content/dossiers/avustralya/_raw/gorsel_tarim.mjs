// Tarım görsellerini mevcut künyeye EKLER (üzerine yazmaz).
// Wikimedia art arda indirmelerde 429 veriyor; her indirmeden sonra bekleniyor.
import { writeFile, readFile } from 'node:fs/promises';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
const DIR = join(dirname(fileURLToPath(import.meta.url)), 'gorseller');
const KUNYE = join(DIR, 'kunye.json');
const API='https://commons.wikimedia.org/w/api.php';
const UA='tarimportali.net dosya arastirmasi (burhanbasoglu4@gmail.com)';
const bekle = (ms) => new Promise(r => setTimeout(r, ms));
const SECIM = {
  avustralya_koyun_kirkimi: 'Tom Roberts - Shearing the rams - Google Art Project.jpg',
  avustralya_merinos: 'Merino ewes & lambs.JPG',
  avustralya_sigir_surusu: 'Muster (11561739535).jpg',
};
const temiz = (s) => (s ?? '').replace(/<[^>]+>/g,'').replace(/\s+/g,' ').trim();
const kunye = JSON.parse(await readFile(KUNYE,'utf8'));
for (const [yerel, commons] of Object.entries(SECIM)) {
  if (kunye.gorseller[yerel]) { console.log(`  · ${yerel} zaten var`); continue; }
  const u=new URL(API);
  for (const [k,v] of Object.entries({format:'json',action:'query',titles:`File:${commons}`,
    prop:'imageinfo',iiprop:'url|size|extmetadata|mime'})) u.searchParams.set(k,v);
  const d=await (await fetch(u,{headers:{'User-Agent':UA}})).json();
  const i=Object.values(d.query?.pages??{})[0]?.imageinfo?.[0];
  if (!i) { console.error(`  ✗ ${yerel}: bulunamadı — "${commons}"`); continue; }
  const m=i.extmetadata??{};
  let bayt=null;
  for (let t=1;t<=5&&!bayt;t++){
    const r=await fetch(i.url,{headers:{'User-Agent':UA}});
    if (r.ok && (r.headers.get('content-type')??'').startsWith('image/')) bayt=Buffer.from(await r.arrayBuffer());
    else { console.log(`    ${yerel}: HTTP ${r.status}, ${t*20}sn`); await bekle(t*20000); }
  }
  if (!bayt) { console.error(`  ✗ ${yerel}: indirilemedi`); continue; }
  const uz = i.mime==='image/png'?'png':'jpg';
  await writeFile(join(DIR,`${yerel}.${uz}`), bayt);
  kunye.gorseller[yerel]={dosya:`${yerel}.${uz}`,commons,
    commons_sayfasi:`https://commons.wikimedia.org/wiki/File:${encodeURIComponent(commons.replace(/ /g,'_'))}`,
    atif:temiz(m.Artist?.value)||temiz(m.Credit?.value),lisans:temiz(m.LicenseShortName?.value),
    lisans_adresi:temiz(m.LicenseUrl?.value)||null,genislik:i.width,yukseklik:i.height,
    en_boy:Number((i.width/i.height).toFixed(4)),bayt:bayt.length};
  console.log(`  ✓ ${yerel.padEnd(28)} ${i.width}×${i.height}  ${kunye.gorseller[yerel].lisans}`);
  await writeFile(KUNYE, JSON.stringify(kunye,null,2)+'\n','utf8');
  await bekle(12000);
}
console.log(`\nkunye.json — ${Object.keys(kunye.gorseller).length} görsel`);
