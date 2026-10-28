// Wikimedia Commons'ta görsel arar ve LİSANSIYLA BİRLİKTE listeler.
//
// TUZAKLAR — hepsi bu dosyada ölçüldü:
//  1) `srnamespace=6` konmazsa arama dosyalarda değil galeri sayfalarında
//     geziyor ve boş liste dönebiliyor.
//  2) PDF TUFANI. "irrigation" geçen sorgularda 19. yüzyıl literatürünün
//     taramaları alaka sıralamasını domine ediyor: bir sorgu 611 dosya buldu
//     ve ilk on ikisinin TAMAMI PDF'ti. Bu yüzden sorguya `filetype:bitmap`
//     ekleniyor — süzgeç sonuçta değil ARAMADA.
//  3) YER ADI. Genel tanım sıfır sonuç veriyor, özel yer adı çalışıyor:
//     "Barmah choke Murray" → 0, "Barmah" → 117.
//  4) TÜR ADI DÜNYA ÇAPINDA EŞLEŞİYOR. "river red gum Murray" 525 dosya
//     verdi ve ilk on ikisi Meksika, İspanya, Fransa ve Hawaii'den okaliptüs
//     yakın çekimleriydi. Hiçbiri alınmadı.
//
// LİSANS SÜZGECİ BURADA, gözde değil. Atıfsız görsel yayımlanmaz (§2.4).
const KABUL = [/^cc0/i, /^cc[- ]by(-sa)?[- ]?[0-9.]*( au)?$/i, /^public domain$/i,
               /^pd[- ]/i, /^cc[- ]by[- ]sa/i, /^cc[- ]by/i];
const API = 'https://commons.wikimedia.org/w/api.php';
const UA = 'tarimportali.net dosya arastirmasi (burhanbasoglu4@gmail.com)';
const sorgular = process.argv.slice(2);
if (!sorgular.length) { console.error('Kullanım: node gorsel_ara.mjs "merino sheep" [...]'); process.exit(1); }
async function api(p) {
  const u = new URL(API);
  for (const [k, v] of Object.entries({ format: 'json', ...p })) u.searchParams.set(k, v);
  const r = await fetch(u, { headers: { 'User-Agent': UA } });
  if (!r.ok) throw new Error(`HTTP ${r.status}`);
  return r.json();
}
const temiz = (s) => (s ?? '').replace(/<[^>]+>/g, '').replace(/\s+/g, ' ').trim();
for (const q of sorgular) {
  const ara = await api({ action: 'query', list: 'search',
    srsearch: `${q} filetype:bitmap`, srnamespace: 6, srlimit: 12 });
  const bas = (ara.query?.search ?? []).map((x) => x.title);
  console.log(`\n══ "${q}" — ${ara.query?.searchinfo?.totalhits ?? 0} dosya, ilk ${bas.length}`);
  if (!bas.length) continue;
  const bilgi = await api({ action: 'query', titles: bas.join('|'), prop: 'imageinfo',
    iiprop: 'url|size|extmetadata|mime' });
  for (const s of Object.values(bilgi.query?.pages ?? {})) {
    const i = s.imageinfo?.[0]; if (!i) continue;
    const m = i.extmetadata ?? {};
    const lis = temiz(m.LicenseShortName?.value);
    const atf = temiz(m.Artist?.value) || temiz(m.Credit?.value) || '—';
    const gor = /^image\/(jpeg|png|webp)$/.test(i.mime ?? '');
    if (!(gor && KABUL.some((r) => r.test(lis)))) continue;
    console.log(`   ✓ ${s.title.slice(5, 62)}`);
    console.log(`       ${i.width}×${i.height}  ${(i.width/i.height).toFixed(3)}  ${lis}  ·  ${atf.slice(0,44)}`);
  }
}
