-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  Tarladan Paylaşım — derleme ve birim tabloları                          ║
-- ╚══════════════════════════════════════════════════════════════════════════╝
--
-- Köşe: portalın içinde, günlük çıkan, YALNIZ gömülü paylaşımlardan oluşan
-- bir derleme. Bizim yazdığımız metin yok — ne birim notu, ne giriş yazısı.
-- Sayfada son yedi gün duruyor.
--
-- Desen `video_kanallari` → `video_haberleri` ikilisinin kardeşi: aday
-- toplanır, 'bekliyor' yazılır, YAYINA İNSAN ALIR. Hiçbir şey kendiliğinden
-- yayımlanmıyor.
--
-- ─── ÖLÇÜLMÜŞ KISITLAR (19 Kasım 2026) ────────────────────────────────────
--
-- Şemadaki boş bırakılabilir alanlar keyfî değil; dört mecranın gömme kapısı
-- ölçüldü ve farklı cömertlikte çıktı:
--
--     YouTube    hesap ✓  başlık ✓  küçük görsel ✓
--     X          hesap ✓  başlık ✗  küçük görsel ✗
--     TikTok     hesap ✗  başlık ✗  küçük görsel ✗
--     Instagram  hesap ✗  başlık ✗  küçük görsel ✗
--
-- Bu yüzden `hesap` ve `baslik` NULL olabilir. BOŞ ALAN SIFIR DEĞİL: hesap
-- NULL ise hesabı bilmiyoruz demek, hesapsız paylaşım demek değil. Gömme
-- kartının kendisi hesabı okura gösteriyor, atıf eksik kalmıyor.
--
-- SONUCU: hesaba göre süzme/sayma TikTok ve Instagram'da çalışmaz.
--
-- TARİH ALANI HİÇBİRİNDE YOK. Dört kapının dördü de paylaşımın kendi
-- tarihini vermiyor. Sıralama bu yüzden `eklendi` alanına dayanıyor —
-- elimizdeki tek güvenilir zaman o. `besleme_tarihi` yalnız hat'tan gelen
-- adaylarda dolu olur (RSS girdisi tarih taşıyor); elle eklenende NULL.
--
-- ETKİLEŞİM SAYISI DA YOK. Dört kapının hiçbiri beğeni/paylaşım sayısı
-- vermiyor, o yüzden şemada böyle bir alan açılmadı. Açılsaydı hep boş
-- kalırdı ve bir gün biri onu doldurulmuş sanırdı.

create table if not exists public.paylasim_derlemeleri (
  id            uuid primary key default gen_random_uuid(),
  -- Günde bir derleme. Tekillik kısıtı aynı güne ikinci derleme açılmasını
  -- engelliyor; köşenin ritmi bu.
  tarih         date not null unique,
  durum         text not null default 'taslak'
                check (durum in ('taslak', 'yayinda')),
  yayim_zamani  timestamptz,
  -- Paylaşım kartının zemini: günün öne çıkan karesi. Kart derleme başına
  -- (50 sorunun 40'ı), zemini öne çıkan birimin görseli (42).
  kart_birimi_id uuid,
  olusturuldu   timestamptz not null default now()
);

create table if not exists public.paylasim_birimleri (
  id            uuid primary key default gen_random_uuid(),
  -- Aday henüz bir derlemeye bağlı değilken NULL. Derlemeye girmesi,
  -- insanın işaretlemesiyle oluyor.
  derleme_id    uuid references public.paylasim_derlemeleri(id) on delete set null,
  durum         text not null default 'bekliyor'
                check (durum in ('bekliyor', 'yayinda', 'reddedildi')),
  mecra         text not null
                check (mecra in ('x', 'youtube', 'tiktok', 'instagram')),
  -- TEKİLLİK İKİ İŞ YAPIYOR: aynı paylaşım iki kez derlemeye giremiyor, VE
  -- reddedilmiş bir paylaşım ikinci taramada yeniden panele düşemiyor.
  -- İkincisi video toplayıcısının kayıtlı gerekçesi: "reddedilmiş bir
  -- videonun yeniden panele düşmesi, editörün verdiği kararı her gün
  -- yeniden vermesini istemek olurdu."
  url           text not null unique,
  hesap         text,
  hesap_url     text,
  baslik        text,
  kucuk_gorsel  text,
  -- X/YouTube/TikTok hazır `html` veriyor; Instagram yalnız iframe adresi.
  gomme_html    text,
  gomme_iframe  text,
  kaynak        text not null default 'elle'
                check (kaynak in ('hat', 'okur', 'elle')),
  besleme_tarihi timestamptz,
  -- Okur "beni çıkarın" derse hemen kaldırılıyor (50 sorunun 47'si). Kayıt
  -- SİLİNMİYOR, çünkü url tekilliği aynı paylaşımın geri gelmesini de
  -- engelliyor: talep kalıcı olsun.
  kaldirma_talebi boolean not null default false,
  eklendi       timestamptz not null default now(),

  -- Gömülemeyen birim çizilemez; ikisinden biri olmak zorunda.
  constraint birim_gomulebilir
    check (gomme_html is not null or gomme_iframe is not null),
  -- Yayındaki birim bir derlemeye ait olmak zorunda.
  constraint yayindaki_birim_derlemeli
    check (durum <> 'yayinda' or derleme_id is not null),
  -- Kaldırma talebi gelen birim yayında kalamaz.
  constraint kaldirilan_yayinda_degil
    check (not kaldirma_talebi or durum <> 'yayinda')
);

alter table public.paylasim_derlemeleri
  drop constraint if exists paylasim_derlemeleri_kart_birimi_fkey;
alter table public.paylasim_derlemeleri
  add constraint paylasim_derlemeleri_kart_birimi_fkey
  foreign key (kart_birimi_id) references public.paylasim_birimleri(id)
  on delete set null;

create index if not exists paylasim_birimleri_derleme_idx
  on public.paylasim_birimleri (derleme_id, eklendi desc);
create index if not exists paylasim_birimleri_kuyruk_idx
  on public.paylasim_birimleri (durum, eklendi desc)
  where durum = 'bekliyor';
create index if not exists paylasim_derlemeleri_tarih_idx
  on public.paylasim_derlemeleri (tarih desc);

-- ─── RLS ───────────────────────────────────────────────────────────────────
-- Okuma: anon YALNIZ yayındakini görür. Panel (authenticated) hepsini görür.
-- YEDİ GÜNLÜK PENCERE BURADA DEĞİL SORGUDA: pencere bir yayın kararı, veri
-- kaybı değil. Eski derlemeler duruyor, sayfa yalnız son yediyi çiziyor.

alter table public.paylasim_derlemeleri enable row level security;
alter table public.paylasim_birimleri   enable row level security;

drop policy if exists "anon yayindaki derlemeyi okur" on public.paylasim_derlemeleri;
create policy "anon yayindaki derlemeyi okur"
  on public.paylasim_derlemeleri for select
  to anon using (durum = 'yayinda');

drop policy if exists "authenticated tum derlemeleri okur" on public.paylasim_derlemeleri;
create policy "authenticated tum derlemeleri okur"
  on public.paylasim_derlemeleri for select
  to authenticated using (true);

drop policy if exists "authenticated derleme yazar" on public.paylasim_derlemeleri;
create policy "authenticated derleme yazar"
  on public.paylasim_derlemeleri for all
  to authenticated using (true) with check (true);

drop policy if exists "anon yayindaki birimi okur" on public.paylasim_birimleri;
create policy "anon yayindaki birimi okur"
  on public.paylasim_birimleri for select
  to anon using (
    durum = 'yayinda'
    and exists (
      select 1 from public.paylasim_derlemeleri d
       where d.id = derleme_id and d.durum = 'yayinda'
    )
  );

drop policy if exists "authenticated tum birimleri okur" on public.paylasim_birimleri;
create policy "authenticated tum birimleri okur"
  on public.paylasim_birimleri for select
  to authenticated using (true);

drop policy if exists "authenticated birim yazar" on public.paylasim_birimleri;
create policy "authenticated birim yazar"
  on public.paylasim_birimleri for all
  to authenticated using (true) with check (true);

-- OKUR ÖNERİSİ POLİTİKASI BİLEREK AÇILMADI. `kaynak` sütunu 'okur' değerini
-- kabul ediyor, yani şema hazır; ama anon'a INSERT vermek ayrı bir karar ve
-- kullanıcı onu henüz vermedi. Açılacaksa kendi göçüyle, kendi oran
-- sınırıyla açılmalı — politikasız bir kutu, köşeyi çöplüğe çevirir.

-- ─── Sağlama ───────────────────────────────────────────────────────────────
do $$
declare
  n_tablo int;
  n_kisit int;
  n_politika int;
begin
  select count(*) into n_tablo from information_schema.tables
   where table_schema = 'public'
     and table_name in ('paylasim_derlemeleri', 'paylasim_birimleri');
  if n_tablo <> 2 then
    raise exception 'İki tablo bekleniyordu, % bulundu', n_tablo;
  end if;

  select count(*) into n_kisit from pg_constraint
   where conrelid = 'public.paylasim_birimleri'::regclass
     and conname in ('birim_gomulebilir', 'yayindaki_birim_derlemeli',
                     'kaldirilan_yayinda_degil');
  if n_kisit <> 3 then
    raise exception 'Üç kısıt bekleniyordu, % bulundu', n_kisit;
  end if;

  select count(*) into n_politika from pg_policies
   where schemaname = 'public'
     and tablename in ('paylasim_derlemeleri', 'paylasim_birimleri');
  if n_politika < 6 then
    raise exception 'En az altı politika bekleniyordu, % bulundu', n_politika;
  end if;

  -- Okur önerisi politikası KASITLI OLARAK yok; varsa biri sessizce açmış.
  if exists (
    select 1 from pg_policies
     where schemaname = 'public' and tablename = 'paylasim_birimleri'
       and cmd = 'INSERT' and 'anon' = any(roles)
  ) then
    raise exception 'anon INSERT politikası var — okur önerisi kararı henüz verilmedi';
  end if;

  raise notice 'Tarladan Paylaşım: 2 tablo, 3 kısıt, % politika', n_politika;
end $$;
