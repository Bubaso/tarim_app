// ogRenderer / categoryRenderer'ı YERELDE çalıştırır ve çıktıyı CANLIYLA
// karşılaştırır.
//
// `functions/node_modules` kurulu değil ve yalnızca bu sınama için
// `npm install` yapmak gereksiz: index.js dört dış modül kullanıyor ve
// dördü de burada taklit ediliyor. Böylece ÜRETİM DOSYASININ KENDİSİ
// çalışıyor — kopyası ya da yeniden yazımı değil.
import { readFileSync, writeFileSync, mkdtempSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';

const kaynak = readFileSync(new URL('./index.js', import.meta.url), 'utf8');
const taklit = `
const onRequest = (_opts, handler) => handler;
const onSchedule = (_opts, handler) => handler;
const initializeApp = () => ({});
const getMessaging = () => ({ sendEachForMulticast: async () => ({ responses: [] }) });
import { readFileSync } from 'node:fs';
`;
const govde = kaynak
  .replace(/^import \{ readFileSync \} from 'node:fs';$/m, '')
  .replace(/^import \{ onRequest \} from 'firebase-functions\/v2\/https';$/m, '')
  .replace(/^import \{ onSchedule \} from 'firebase-functions\/v2\/scheduler';$/m, '')
  .replace(/^import \{ initializeApp \} from 'firebase-admin\/app';$/m, '')
  .replace(/^import \{ getMessaging \} from 'firebase-admin\/messaging';$/m, '');

const dizin = mkdtempSync(join(tmpdir(), 'ssr-'));
const yol = join(dizin, 'index.mjs');
writeFileSync(yol, taklit + govde);
// config.js göreli içe aktarılıyorsa yanına kopyala
try {
  writeFileSync(join(dizin, 'config.js'), readFileSync(new URL('./config.js', import.meta.url)));
} catch {}

const mod = await import(yol);

function sahteYanit() {
  const o = { kod: 0, govde: '', basliklar: {} };
  o.set = (k, v) => { o.basliklar[k] = v; return o; };
  o.status = (k) => { o.kod = k; return o; };
  o.send = (b) => { o.govde = b; return o; };
  return o;
}
export async function cagir(fn, path) {
  const res = sahteYanit();
  await mod[fn]({ path, query: {}, headers: {} }, res);
  return res;
}
