// Seçilecek dosyaların TAM Commons adlarını doğrular. Arama çıktısı başlığı
// kırpıyor; kırpılmış adla indirme sessizce boş döner.
const API='https://commons.wikimedia.org/w/api.php';
const UA='tarimportali.net dosya arastirmasi (burhanbasoglu4@gmail.com)';
for (const p of process.argv.slice(2)) {
  const u=new URL(API);
  for (const [k,v] of Object.entries({format:'json',action:'query',list:'search',
    srsearch:`${p} filetype:bitmap`,srnamespace:6,srlimit:3})) u.searchParams.set(k,v);
  const r=await (await fetch(u,{headers:{'User-Agent':UA}})).json();
  console.log(`\n"${p}"`);
  for (const s of r.query?.search??[]) console.log('   '+s.title);
}
