-- Dosya hikâyeleri yayın penceresi boyunca şeritte SABİT kalsın.
--
-- Sorun iki katmanlıydı ve ikisi de sessizdi:
--
-- 1. ÖMÜR. Dosya hikâyesi 24 saat yaşıyordu; dosyanın kendi penceresi ise
--    haftalarca sürüyor. Rusya dosyası 26 Eylül'e kadar yayında ama onu
--    tanıtan baloncuk 30 Ağustos'ta düşüyordu.
--
-- 2. SIRALAMA. Şerit tazelik puanına göre diziliyor ve puan 8 saatte
--    yarılanıyor. Beş günlük bir dosya hikâyesinin puanı sıfıra yaklaşıyor,
--    `maxGroups` kesintisinde eleniyor ve teknik olarak "yayında" olduğu hâlde
--    hiç görünmüyordu.
--
-- Bu sütun ikincisini çözüyor: sabit hikâye şeritten DÜŞMÜYOR — tazelik
-- sıralamasına giriyor ama kesintiden muaf ve puanı bir tabanın altına
-- inmiyor. Birincisi üreticide çözüldü (`scripts/dosya_hikayeleri.py`).
--
-- Neden `hedef_yol is not null` koşulundan TÜRETİLMEDİ: `hedef_yol` bilerek
-- genel bırakılmıştı — "yarın bir emtia sayfası ya da hafta dosyası için de
-- hikâye üretilebilir". Böyle bir hikâyenin şeritte sabitlenmesi gerekmeyebilir.
-- Sabitlik bir YAYIN KARARI; satır bunu kendisi söylemeli, istemci
-- adresinden tahmin etmemeli.

alter table public.portal_stories
  add column if not exists sabit boolean not null default false;

comment on column public.portal_stories.sabit is
  'true ise hikâye şeritte kalıcı: tazelik kesintisinden muaf ve puanı taban '
  'değerin altına inmez. Dosya hikâyeleri için kullanılıyor; ömrü '
  'expires_at belirliyor, sabitlik sonsuza kadar değil pencere boyunca.';

-- Mevcut satırların hepsi dosya hikâyesi (başka türde habersiz hikâye henüz
-- üretilmedi), dolayısıyla geriye dönük doldurma güvenli.
update public.portal_stories
   set sabit = true
 where hedef_yol is not null
   and sabit = false;

notify pgrst, 'reload schema';
