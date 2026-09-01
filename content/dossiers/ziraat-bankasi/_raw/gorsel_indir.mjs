// kunye.json'daki görselleri Commons'tan indirir, ham hâllerini _raw altına,
// yayın hâllerini web/dosya/ziraat-bankasi/ altına yazar.
//
// Adresi künyede TUTMUYORUZ: Commons'ın thumb adresleri değişebiliyor. Dosya
// adı ve Commons başlığı sabit; adres her çalıştırmada API'den yeniden çözülüyor.
//
//   node content/dossiers/ziraat-bankasi/_raw/gorsel_indir.mjs

import { readFile, writeFile, mkdir } from 'node:fs/promises';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const RAW = dirname(fileURLToPath(import.meta.url));
const KOK = join(RAW, '..', '..', '..', '..');
const HAM = join(RAW, 'gorseller');
const YAYIN = join(KOK, 'web', 'dosya', 'ziraat-bankasi');

const kunye = JSON.parse(await readFile(join(HAM, 'kunye.json'), 'utf8'));
await mkdir(HAM, { recursive: true });
await mkdir(YAYIN, { recursive: true });

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

async function adresCoz(baslik) {
  const u = new URL('https://commons.wikimedia.org/w/api.php');
  u.search = new URLSearchParams({
    action: 'query', format: 'json', titles: `File:${baslik}`,
    prop: 'imageinfo', iiprop: 'url|extmetadata', iiurlwidth: '1800',
  });
  for (let d = 1; d <= 5; d++) {
    const r = await fetch(u, { headers: { 'User-Agent': 'tarim-app-dossier/1.0' } });
    const t = await r.text();
    if (t.startsWith('You are making too many')) { await sleep(4000 * d); continue; }
    const j = JSON.parse(t);
    const s = Object.values(j.query?.pages ?? {})[0];
    const ii = s?.imageinfo?.[0];
    if (!ii) throw new Error('Commons\'ta bulunamadı');
    const lisans = (ii.extmetadata?.LicenseShortName?.value ?? '').replace(/<[^>]*>/g, '').trim();
    return { url: ii.thumburl ?? ii.url, tamBoy: ii.url, lisans };
  }
  throw new Error('hız sınırı aşılamadı');
}

/// Gövdeyi indirir ve GERÇEKTEN görsel olduğunu sihirli baytından doğrular.
/// Görsel değilse null döner — çağıran yedek adrese geçer.
async function indir(url, deneme = 5) {
  const JPEG = [0xff, 0xd8, 0xff];
  const PNG = [0x89, 0x50, 0x4e, 0x47];
  for (let d = 1; d <= deneme; d++) {
    const r = await fetch(url, { headers: { 'User-Agent': 'tarim-app-dossier/1.0' } });
    // 429 gerçek bir bekleme istiyor; kısa aralık işe yaramıyor.
    if (!r.ok) { await sleep(r.status === 429 ? 9000 * d : 2500 * d); continue; }
    const b = Buffer.from(await r.arrayBuffer());
    const jpeg = JPEG.every((v, i) => b[i] === v);
    const png = PNG.every((v, i) => b[i] === v);
    if ((jpeg || png) && b.length > 20000) return b;
    await sleep(6000 * d);
  }
  return null;
}

let hata = 0;
for (const g of kunye.gorseller) {
  process.stdout.write(`${g.id.padEnd(16)} `);
  try {
    const mevcut = await readFile(join(YAYIN, g.dosya)).catch(() => null);
    if (mevcut && mevcut.length > 20000 && (mevcut[0] === 0xff || mevcut[0] === 0x89)) {
      console.log(`⏭  zaten var (${(mevcut.length / 1024).toFixed(0)} KB)`);
      continue;
    }
    const { url, tamBoy, lisans } = await adresCoz(g.commons);

    // Künyedeki lisans ile kaynaktaki lisans TUTMALI. Tutmuyorsa görsel
    // alınmaz: künye eskimiş demektir ve atıf yanlış olur.
    const norm = (s) => s.toLowerCase().replace(/[^a-z0-9]/g, '');
    // Künye Türkçe yazılıyor (atıf satırı okura Türkçe görünüyor), Commons
    // İngilizce döndürüyor. Karşılaştırma ANLAM üzerinden yapılmalı; yoksa
    // doğru lisanslı bir görsel yalnızca etiketin dili yüzünden reddediliyor.
    const TR_EN = {
      'kamu malı': 'publicdomain',
      'kısıtlama yok': 'norestrictions',
      'telifsiz': 'publicdomain',
    };
    const bekleniyor = TR_EN[g.lisans.toLowerCase()] ?? norm(g.lisans);
    if (!norm(lisans).startsWith(bekleniyor) && !bekleniyor.startsWith(norm(lisans))) {
      throw new Error(`LİSANS UYUŞMUYOR — künye "${g.lisans}", kaynak "${lisans}"`);
    }

    // Küçük resim sunucusu bazen hata SAYFASI döndürüyor; durum kodu 200
    // olduğu için fark edilmiyor ve HTML, .jpg adıyla diske yazılıyor.
    // Bir kez oldu: beş dosya 2 KB'lık "Wikimedia Error" sayfası olarak indi
    // ve betik hepsine ✅ dedi. Bu yüzden içerik SİHİRLİ BAYTINDAN sınanıyor.
    const veri = await indir(url) ?? await indir(tamBoy);
    if (!veri) throw new Error('görsel gövdesi alınamadı (küçük resim ve tam boy)');
    await writeFile(join(HAM, g.dosya), veri);
    await writeFile(join(YAYIN, g.dosya), veri);
    console.log(`✅ ${(veri.length / 1024).toFixed(0)} KB  ${lisans}`);
  } catch (e) {
    console.log(`❌ ${e.message}`);
    hata++;
  }
  await sleep(3000);
}
console.log(hata ? `\n${hata} görsel alınamadı.` : '\nHepsi alındı.');
