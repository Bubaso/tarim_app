-- Anasayfada video haber bölümü.
--
-- Portal bugüne kadar yalnızca yazılı haber ve içindeki görselleri topluyordu.
-- Bu iki tablo, kurumsal YouTube kanallarından toplanan videoları panelde
-- onaylandıktan SONRA yayına almak için.
--
-- ── Video GÖMÜLÜYOR, indirilmiyor ────────────────────────────────────────
-- Tabloda `video_id` var, dosya yok. Video kaynağın sunucusunda kalıyor,
-- oynatıcı YouTube'un kendi oynatıcısı, izlenme kaynağa sayılıyor. İndirip
-- kendi sunucumuzda yayınlamak telif ihlali olurdu ve "kaynak belirttik"
-- demek bunu değiştirmezdi. Bir bakanlık muhatabı olan portal için alınacak
-- risk değil.
--
-- ── Neden `articles` içine değil, ayrı tablo ──────────────────────────────
-- Alanlar yeterince farklı: gövde metni yok, buna karşılık kanal, süre ve
-- gömülebilirlik var. Aynı tabloya karıştırmak haber sorgularını, RSS'i ve
-- SEO tarafını kirletirdi.

-- ─── Kanal listesi ────────────────────────────────────────────────────────
-- Toplayıcının nereye bakacağı KODA GÖMÜLÜ DEĞİL, veri. Yeni bir kurum
-- kanalı eklemek dağıtım gerektirmemeli; panelden satır eklenip
-- toplayıcının bir sonraki çalışmasında devreye girmeli.
create table if not exists public.video_kanallari (
  id          bigserial primary key,
  ad          text not null,
  kanal_id    text not null unique,
  url         text,
  -- 'kurumsal' = kamu kurumu/enstitü; içeriği baştan güvenilir sayılıyor.
  -- 'aday'     = izlemeye alınmış kanal; onayda daha sıkı bakılır.
  guven       text not null default 'kurumsal',
  aktif       boolean not null default true,
  son_tarama  timestamptz,
  eklenme     timestamptz not null default now(),
  constraint video_kanallari_guven_check check (guven in ('kurumsal', 'aday'))
);

comment on table public.video_kanallari is
  'Video toplayıcının taradığı YouTube kanalları. RSS akışı: '
  'https://www.youtube.com/feeds/videos.xml?channel_id=<kanal_id>';

-- ─── Videolar ─────────────────────────────────────────────────────────────
create table if not exists public.video_haberleri (
  id             bigserial primary key,
  kaynak         text not null default 'youtube',
  video_id       text not null,
  url            text not null,

  baslik         text not null,
  aciklama       text,
  kucuk_gorsel   text,

  kanal_adi      text not null,
  kanal_id       text not null,
  kanal_url      text,

  yayim_tarihi   timestamptz,
  sure_sn        integer,

  konu           text,
  anahtar_kelimeler text[],

  -- YouTube bazı videoların gömülmesini kapatıyor; o videolar sayfada hata
  -- veren bir kutu olarak görünürdü. RSS bu bilgiyi vermiyor, bu yüzden
  -- varsayılan true ve API'li ikinci aşamada doğrulanacak.
  gomulebilir    boolean not null default true,

  durum          text not null default 'bekliyor',
  red_sebebi     text,
  -- Onaylanan videoların yayında kalıp kalmadığı düzenli olarak
  -- doğrulanmalı: video silinir, gizlenir ya da yaş sınırı alır ve
  -- anasayfada ölü bir gömme kalır.
  son_kontrol    timestamptz,

  onaylayan      uuid references auth.users(id) on delete set null,
  onay_tarihi    timestamptz,
  sira           integer not null default 0,

  eklenme        timestamptz not null default now(),

  constraint video_haberleri_kaynak_video_key unique (kaynak, video_id),
  constraint video_haberleri_durum_check
    check (durum in ('bekliyor', 'onaylandi', 'reddedildi'))
);

comment on column public.video_haberleri.durum is
  'bekliyor = panelde onay bekliyor; onaylandi = anasayfada; reddedildi = bir '
  'daha gösterilmez ama kaydı durur — aynı video ikinci kez toplandığında '
  'yeniden panele düşmesin diye.';

-- Panelin ilk sorgusu "bekleyenler, yeniden eskiye".
create index if not exists video_haberleri_durum_idx
  on public.video_haberleri (durum, yayim_tarihi desc);

-- ─── RLS ──────────────────────────────────────────────────────────────────
-- Okuma herkese açık AMA yalnızca onaylanmışlar. Bekleyen ve reddedilen
-- kayıtlar editoryal süreçtir; anasayfaya sızmamalı. Süzgeç görünümde değil
-- POLİTİKADA: görünüm atlanabilir, politika atlanamaz.
alter table public.video_kanallari  enable row level security;
alter table public.video_haberleri  enable row level security;

drop policy if exists "anon onayli videolari okur" on public.video_haberleri;
create policy "anon onayli videolari okur"
  on public.video_haberleri for select
  to anon using (durum = 'onaylandi');

drop policy if exists "authenticated tum videolari okur" on public.video_haberleri;
create policy "authenticated tum videolari okur"
  on public.video_haberleri for select
  to authenticated using (true);

-- Panel onaylıyor: giriş yapmış kullanıcı durumu değiştirebiliyor.
drop policy if exists "authenticated video onaylar" on public.video_haberleri;
create policy "authenticated video onaylar"
  on public.video_haberleri for update
  to authenticated using (true) with check (true);

drop policy if exists "kanallari herkes okur" on public.video_kanallari;
create policy "kanallari herkes okur"
  on public.video_kanallari for select
  to anon, authenticated using (true);

drop policy if exists "authenticated kanal ekler" on public.video_kanallari;
create policy "authenticated kanal ekler"
  on public.video_kanallari for all
  to authenticated using (true) with check (true);

-- Yazma (toplayıcı) service_role ile; RLS onu zaten atlıyor.

-- ─── Anasayfa görünümü ────────────────────────────────────────────────────
create or replace view public.yayindaki_videolar
with (security_invoker = on) as
select
  v.id, v.video_id, v.url, v.baslik, v.aciklama, v.kucuk_gorsel,
  v.kanal_adi, v.kanal_url, v.yayim_tarihi, v.sure_sn, v.konu
from public.video_haberleri v
where v.durum = 'onaylandi'
  and v.gomulebilir
order by v.sira desc, v.yayim_tarihi desc nulls last;

grant select on public.yayindaki_videolar to anon, authenticated;

-- ─── Başlangıç kanalları ──────────────────────────────────────────────────
-- Akışları tek tek doğrulandı (25 Ağustos 2026). Yayın sıklıkları çok
-- farklı: Bakanlık kanalı gün aşırı video koyuyor, enstitüler ayda birden
-- seyrek. Bölüm bu yüzden ilk aşamada ağırlıkla Bakanlık içeriğiyle dolacak.
--
-- Bahri Dağdaş UTAEM kanalı bilerek eklenmedi: son videosu 2016 tarihli,
-- taramak boşuna istek demek.
insert into public.video_kanallari (ad, kanal_id, url, guven) values
  ('Tarım ve Orman Bakanlığı', 'UCq0ojLlKO4ssS5cQd5E9yZg',
   'https://www.youtube.com/channel/UCq0ojLlKO4ssS5cQd5E9yZg', 'kurumsal'),
  ('Toprak Mahsulleri Ofisi (TMO)', 'UCBR3jBDRHKNdklpjap58Ong',
   'https://www.youtube.com/channel/UCBR3jBDRHKNdklpjap58Ong', 'kurumsal'),
  ('TAGEM', 'UC8Ux7TujKprd8TXj8zcbV1Q',
   'https://www.youtube.com/channel/UC8Ux7TujKprd8TXj8zcbV1Q', 'kurumsal'),
  ('GAP Tarımsal Araştırma Enstitüsü', 'UCnxA9SNG-T2Dg8jZubPdu6A',
   'https://www.youtube.com/channel/UCnxA9SNG-T2Dg8jZubPdu6A', 'kurumsal')
on conflict (kanal_id) do nothing;

notify pgrst, 'reload schema';
