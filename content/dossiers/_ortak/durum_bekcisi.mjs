// Dosya durum bekçisi — depo ile veritabanı ayrışırsa dağıtımı durdurur.
//
// NEDEN VAR. 12 Kasım 2026'da ölçüldü: `content/dossiers/irak/yayin.json`
// içinde `"status": "draft"` yazıyordu, oysa Irak 2 Kasım'dan beri CANLIDA ve
// `country_dossiers` satırı `published` diyordu. Devir göçü veritabanını
// güncelliyor, depodaki yayin.json'ı güncellemiyor; kimse de bakmıyordu.
//
// Sonucu sessiz ve canlıydı:
//
//   1. `statik_sayfa.mjs` yalnızca published/archived için paylaşım kabuğu
//      üretiyor — draft gördüğü için Irak'ın kabuğunu üretmedi.
//   2. `statik_sayfa_db.mjs` boşluğu kapatamıyor, çünkü o yalnızca KLASÖRÜ
//      OLMAYAN dosyalar için çalışıyor; Irak'ın klasörü var.
//   3. Hosting dağıtımı genel dizini DEĞİŞTİRİYOR.
//
//   → Yani her dağıtımda /ulke/irak og etiketlerini kaybediyordu ve dosya
//     paylaşıldığında sıradan bir site kartı çıkıyordu. Dağıtım çıktısında
//     tek satır uyarı vardı ("durum 'draft' — statik sayfa üretilmedi") ve o
//     satır on gün boyunca kimseye bir şey söylemedi.
//
// Bu betik o satırı HATAYA çeviriyor. Ayrışma varsa dağıtım yapılmaz.
//
// NE SINAMAZ. Pencere tarihlerini sınamaz — `starts_at`/`ends_at` devir
// anında now() ile yazıldığı için depodaki `pencere.baslangic` çoğu dosyada
// bilerek null. Sınanan tek şey DURUM.
//
// Kullanım:  node content/dossiers/_ortak/durum_bekcisi.mjs
// Çıkış:     0 = tutarlı · 1 = ayrışma var (dağıtım durur) · 2 = sınanamadı

import { readFileSync, existsSync, readdirSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const KOK = join(dirname(fileURLToPath(import.meta.url)), '..', '..', '..');
const DOSYALAR = join(KOK, 'content', 'dossiers');

const env = Object.fromEntries(
  readFileSync(join(KOK, '.env'), 'utf8').split('\n')
    .filter((s) => s.includes('=') && !s.trimStart().startsWith('#'))
    .map((s) => { const i = s.indexOf('='); return [s.slice(0, i).trim(), s.slice(i + 1).trim()]; }));

const { SUPABASE_URL: U, SUPABASE_ANON_KEY: K } = env;
if (!U || !K) { console.error('✗ .env içinde SUPABASE_URL/ANON_KEY yok.'); process.exit(2); }

// Supabase kapalıyken dağıtımı KİLİTLEMEZ. 10 Kasım 2026'da proje kota
// aşımından kısıtlandı ve her uç 402 verdi; o gün bu bekçi hata verse
// fonksiyon düzeltmesi dağıtılamazdı. Sınanamıyorsa uyarıp geçiyor —
// ama sessizce değil.
let satirlar;
try {
  const yanit = await fetch(
    `${U}/rest/v1/country_dossiers?select=slug,status`,
    { headers: { apikey: K, Authorization: `Bearer ${K}` } });
  if (!yanit.ok) throw new Error(`Supabase ${yanit.status}`);
  satirlar = await yanit.json();
} catch (e) {
  console.warn(`  ⚠ Durum bekçisi SINAYAMADI (${e.message}) — depo/veritabanı`);
  console.warn('    tutarlılığı bu dağıtımda DENETLENMEDİ.');
  process.exit(0);
}

const db = new Map(satirlar.map((r) => [r.slug, r.status]));

// İKİ AYRI AĞIRLIK VAR ve bu ayrım bekçinin işe yaraması için şart.
//
// DURDURAN (kabuk kayboluyor):
//   · depo 'draft'  · veritabanı published/archived  → Irak vakası. statik_sayfa.mjs
//     draft gördüğü için kabuk üretmiyor, dağıtım da canlıdakini siliyor.
//   · depo published/archived · veritabanında satır yok → dosya kendini yayında
//     sanıyor ama seed hiç çalıştırılmamış.
//
// UYARAN (kabuk üretiliyor, yalnızca etiket eski):
//   · depo 'published' · veritabanı 'archived' → statik_sayfa.mjs İKİSİ için de
//     kabuk üretiyor, yani og etiketleri yerinde. Arşivlenen dosyanın yayin.json'ı
//     güncellenmiyor ve 12 Kasım 2026 ölçümünde beş dosya böyleydi. Bunu da
//     DURDURAN yapmak bekçiyi kullanılamaz kılardı: her arşivlemeden sonra
//     dağıtım kilitlenir, ilk sıkışan da onu atlamanın yolunu arar.
//
// Bekçi yalnızca yangını durdurur, dağınıklığı bildirir.
const durduran = [];
const uyaran = [];
const CANLI = (d) => d === 'published' || d === 'archived';

for (const slug of readdirSync(DOSYALAR).sort()) {
  if (slug.startsWith('_')) continue;
  const yol = join(DOSYALAR, slug, 'yayin.json');
  if (!existsSync(yol)) continue;

  let depo;
  try {
    depo = JSON.parse(readFileSync(yol, 'utf8')).status;
  } catch (e) {
    durduran.push(`${slug}: yayin.json okunamadı — ${e.message}`);
    continue;
  }

  const canli = db.get(slug);

  if (canli === undefined) {
    if (depo !== 'draft') {
      durduran.push(`${slug}: depo '${depo}' diyor, veritabanında SATIR YOK. ` +
                    'Seed çalıştırılmamış ya da yayin.json erken işaretlenmiş.');
    }
    continue;
  }

  if (depo === canli) continue;

  if (depo === 'draft' && CANLI(canli)) {
    durduran.push(`${slug}: depo 'draft' · veritabanı '${canli}' ` +
                  '→ bu dağıtım o dosyanın og kabuğunu SİLER (Irak vakası)');
  } else {
    uyaran.push(`${slug}: depo '${depo}' · veritabanı '${canli}'`);
  }
}

if (durduran.length) {
  console.error('');
  console.error('✗ DAĞITIM DURDURULDU — dosya durumları depo ile veritabanında AYRIŞMIŞ.');
  console.error('');
  for (const a of durduran) console.error(`      • ${a}`);
  console.error('');
  console.error('  Bunun sessiz sonucu: statik_sayfa.mjs yalnızca published/archived');
  console.error('  için paylaşım kabuğu üretiyor, hosting dağıtımı ise genel dizini');
  console.error('  DEĞİŞTİRİYOR. Ayrışan dosya her dağıtımda og etiketlerini kaybeder.');
  console.error('');
  console.error("  Yapılacak şey bu bekçiyi atlamak DEĞİL: yayin.json'daki durumu");
  console.error('  veritabanındaki gerçekle eşitlemek. Devir yapılırken İKİSİ de');
  console.error('  güncellenmeli (CLAUDE.md §2.12).');
  process.exit(1);
}

if (uyaran.length) {
  console.warn(`  ⚠ ${uyaran.length} dosyanın yayin.json durumu eski (og kabuğu etkilenmiyor):`);
  for (const a of uyaran) console.warn(`      · ${a}`);
}

console.log(`  ✓ ${db.size} veritabanı satırı ile depodaki durumlar sınandı` +
            (uyaran.length ? ` — ${uyaran.length} eski etiket, kabuk kaybı yok` : ' — ayrışma yok'));
