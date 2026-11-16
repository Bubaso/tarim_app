-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  Yapay Zeka ve Dijital Tarım — haber etiketleri, güncelleme kuyruğu,     ║
-- ║  tarama kaydı                                                            ║
-- ╚══════════════════════════════════════════════════════════════════════════╝
--
-- Kararlar: content/yapay_zeka_dijital_tarim/_raw/KARARLAR.md (Tur 0,
-- 16 Kasım 2026). Bu göç D ve G bölümlerini taşıyor.
--
-- ── 1. NEDEN `articles`'A SÜTUN DEĞİL, AYRI TABLO ──────────────────────────
-- COP31 tek sütunla çözüldü (`articles.ozel_bolum`, 12 Kasım). O bir süreli
-- bölümdü ve bir haber yalnız ona ait olabiliyordu. Bu bölüm KALICI (karar 2)
-- ve çakışmada haber iki bölümde birden görünüyor (karar 31): yapay zekâlı
-- bir COP31 haberi hem COP31'de hem burada. Tek sütun bunu taşıyamaz.
-- Haber kendi `topic`'inde kalıyor (karar 26, ÇAPRAZ ETİKET); bu tablo
-- `topic`'e dokunmuyor.
--
-- ── 2. ÜÇ DURUM ────────────────────────────────────────────────────────────
--   aktif      — bölümde görünür. Panelden tek tıkla kaldırılır (karar 33).
--   sinirda    — anahtar kelime kapısından geçti ama editör ajanı kanıtlı bir
--                EVET vermedi. Bölümde GÖRÜNMEZ; panelde tek tıkla eklenir.
--                Ölçüm (son 300 haber): model aynı olayın haberlerini farklı
--                sınıflandırabiliyor. Kapıdan geçen hiçbir haber kayıtsız
--                kalmasın diye bu durum var.
--   kaldirildi — editör kaldırdı. Hat ve geriye dönük tarama bunu EZMEZ.
-- `kaynak = 'editor'` olan satıra da hat dokunmuyor: editör kararı ajanı
-- ezer, tersi değil.
--
-- ── 3. KUYRUK — BİLDİRİM YOK, ONAY PANELDE ────────────────────────────────
-- Tarama TASLAK üretir, kullanıcı onaylar (karar 17); bildirim gönderilmez,
-- yalnız kuyruğa düşer (karar 20); onay yönetim panelinde (karar 47).
-- `anahtar` aynı önerinin iki kez düşmesini engelliyor (ör. 'doi:10.1016/…',
-- 'sayfa:<adres>:<özet>', 'dizin:<haber id>').
--
-- ── 4. TARAMA KAYDI ────────────────────────────────────────────────────────
-- Kapsamlı tarama aylık hatırlatılıyor (karar 19). Hatırlatmanın ölçüsü son
-- başarılı kapsamlı taramanın tarihi; panel buradan okuyor.
-- `izlenen_sayfalar`: makine okunur akışı olmayan resmî ve kurumsal sayfalar
-- (Tur 1 ölçümü: mevzuat ve kurumsal katmanda makine okunur kaynak SIFIR).
-- Tarama onları okumuyor, yalnız "değişti" diyor; okumak onaya kalıyor.
--
-- DELETE politikası YOK: yanlış basılan bir düğme geri getirilemeyecek bir
-- kaydı yok etmesin (articles'taki kalıp). Haber silinirse etiketi de gider
-- (on delete cascade).

-- ── bolum_etiketleri ──────────────────────────────────────────────────────
create table if not exists public.bolum_etiketleri (
  article_id uuid        not null references public.articles(id) on delete cascade,
  bolum      text        not null,
  durum      text        not null default 'aktif'
                         check (durum in ('aktif', 'sinirda', 'kaldirildi')),
  -- Haber hangi başlığın altında duruyor (karar 32). Sınırdaki haberde boş
  -- olabilir; editör eklerken seçer.
  baslik_no  smallint    check (baslik_no between 1 and 60),
  kaynak     text        not null default 'ajan'
                         check (kaynak in ('ajan', 'geriye_donuk', 'editor')),
  -- Ajanın gerekçesi: kapıyı açan anahtarlar, karar, metinden birebir kanıt
  -- cümlesi ve kanıtın metinde bulunup bulunmadığı. Panel bunu gösteriyor:
  -- editör tek tıkla karar verirken neye dayandığını görüyor.
  gerekce    jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  primary key (article_id, bolum)
);

comment on table public.bolum_etiketleri is
  'Kalıcı bölüm etiketleri (ilki yapay-zeka-dijital-tarim). topic''e dokunmaz, üstüne biner. Durum: aktif | sinirda | kaldirildi.';

create index if not exists bolum_etiketleri_liste_idx
  on public.bolum_etiketleri (bolum, durum, baslik_no, created_at desc);

create or replace function public.bolum_etiketleri_guncellendi()
returns trigger language plpgsql as $$
begin
  new.updated_at := now();
  return new;
end $$;

drop trigger if exists bolum_etiketleri_guncellendi on public.bolum_etiketleri;
create trigger bolum_etiketleri_guncellendi
  before update on public.bolum_etiketleri
  for each row execute function public.bolum_etiketleri_guncellendi();

alter table public.bolum_etiketleri enable row level security;

-- Okur yalnız aktif etiketi görür. Haberin kendisi zaten `articles`'ın anon
-- politikasıyla süzülüyor: yayında olmayan haberin etiketi tek başına bir
-- kimlikten ibaret.
drop policy if exists "herkes aktif etiketi okur" on public.bolum_etiketleri;
create policy "herkes aktif etiketi okur" on public.bolum_etiketleri
  for select to anon using (durum = 'aktif');

drop policy if exists "panel tum etiketleri okur" on public.bolum_etiketleri;
create policy "panel tum etiketleri okur" on public.bolum_etiketleri
  for select to authenticated using (true);

drop policy if exists "panel etiket duzenler" on public.bolum_etiketleri;
create policy "panel etiket duzenler" on public.bolum_etiketleri
  for update to authenticated using (true) with check (true);

drop policy if exists "panel etiket ekler" on public.bolum_etiketleri;
create policy "panel etiket ekler" on public.bolum_etiketleri
  for insert to authenticated with check (true);

-- ── bekleyen_guncellemeler ────────────────────────────────────────────────
create table if not exists public.bekleyen_guncellemeler (
  id          uuid        primary key default gen_random_uuid(),
  bolum       text        not null,
  tur         text        not null check (tur in (
                'dizin_adayi',      -- haberde adı geçen Türkiye kuruluşu (§25, karar 38)
                'yeni_kaynak',      -- akademik/veri/sektör akışından yeni kayıt
                'sayfa_degisti',    -- izlenen resmî/kurumsal sayfa değişti
                'sayi_guncelleme',  -- bir serinin yeni değeri (karar 16)
                'baslik_onerisi',   -- tarama yeni bir başlık önerdi (karar 10)
                'gelisme'           -- "bugün nerede duruyoruz" için yeni gelişme
              )),
  baslik_no   smallint,
  kaynak      text        not null,   -- 'haber' | 'tarama:arxiv' | 'tarama:sayfa' …
  article_id  uuid        references public.articles(id) on delete set null,
  anahtar     text        unique,
  icerik      jsonb       not null,
  durum       text        not null default 'bekliyor'
                          check (durum in ('bekliyor', 'onaylandi', 'reddedildi')),
  karar_notu  text,
  karar_veren uuid        references auth.users(id),
  karar_at    timestamptz,
  created_at  timestamptz not null default now()
);

comment on table public.bekleyen_guncellemeler is
  'Bölüm güncelleme kuyruğu. Tarama ve hat yalnız ÖNERİR; hiçbir satır onaysız yayına girmez (karar 17).';

create index if not exists bekleyen_guncellemeler_kuyruk_idx
  on public.bekleyen_guncellemeler (bolum, durum, created_at desc);

alter table public.bekleyen_guncellemeler enable row level security;

-- Kuyruk okura ait değil: anon politikası YOK.
drop policy if exists "panel kuyrugu okur" on public.bekleyen_guncellemeler;
create policy "panel kuyrugu okur" on public.bekleyen_guncellemeler
  for select to authenticated using (true);

drop policy if exists "panel kuyrukta karar verir" on public.bekleyen_guncellemeler;
create policy "panel kuyrukta karar verir" on public.bekleyen_guncellemeler
  for update to authenticated using (true) with check (true);

-- ── tarama_kayitlari ──────────────────────────────────────────────────────
create table if not exists public.tarama_kayitlari (
  id      uuid        primary key default gen_random_uuid(),
  bolum   text        not null,
  tur     text        not null check (tur in ('hafif', 'kapsamli')),
  basladi timestamptz not null default now(),
  bitti   timestamptz,
  ozet    jsonb,      -- kaynak başına bakılan / önerilen / hata sayısı
  hata    text
);

create index if not exists tarama_kayitlari_son_idx
  on public.tarama_kayitlari (bolum, tur, bitti desc);

alter table public.tarama_kayitlari enable row level security;

drop policy if exists "panel taramalari okur" on public.tarama_kayitlari;
create policy "panel taramalari okur" on public.tarama_kayitlari
  for select to authenticated using (true);

-- ── izlenen_sayfalar ──────────────────────────────────────────────────────
create table if not exists public.izlenen_sayfalar (
  adres         text        primary key,
  bolum         text        not null,
  katman        text,               -- mevzuat | kurumsal | …
  son_ozet      text,               -- bağlantı kümesinin SHA-256'sı
  -- "Sayfa değişti" bağlantı kümesiyle ölçülüyor, metinle DEĞİL: liste
  -- sayfalarında tarih, sayaç ve saat her bakışta değişir, metin özeti her
  -- seferinde "değişti" derdi. Yeni bir duyuru ise yeni bir BAĞLANTI olarak
  -- gelir; kuyruğa düşen de yalnız yeni bağlantılar.
  son_baglantilar jsonb,
  son_bakis     timestamptz,
  son_degisim   timestamptz,
  -- Kaynak düşerse eski değer korunur, yalnız durum yazılır (karar 24).
  son_durum     text                -- 'acik' | 'kapali' | 'hata'
);

alter table public.izlenen_sayfalar enable row level security;

drop policy if exists "panel izlenen sayfalari okur" on public.izlenen_sayfalar;
create policy "panel izlenen sayfalari okur" on public.izlenen_sayfalar
  for select to authenticated using (true);

-- Hat ve tarama servis anahtarıyla bağlanıyor; service_role RLS'i zaten
-- atlıyor, ayrıca politika gerekmiyor.

-- ─── Sağlama ───────────────────────────────────────────────────────────────
do $$
declare
  n int;
begin
  select count(*) into n from pg_tables
   where schemaname = 'public'
     and tablename in ('bolum_etiketleri', 'bekleyen_guncellemeler',
                       'tarama_kayitlari', 'izlenen_sayfalar');
  if n <> 4 then
    raise exception 'Dört tablo olmalıydı, % bulundu', n;
  end if;

  select count(*) into n from pg_policies
   where schemaname = 'public' and tablename = 'bolum_etiketleri';
  if n <> 4 then
    raise exception 'bolum_etiketleri dört politika taşımalıydı, % var', n;
  end if;

  -- Okur kuyruğu ve tarama kaydını GÖRMEMELİ.
  select count(*) into n from pg_policies
   where schemaname = 'public'
     and tablename in ('bekleyen_guncellemeler', 'tarama_kayitlari', 'izlenen_sayfalar')
     and 'anon' = any(roles);
  if n <> 0 then
    raise exception 'Kuyruk/tarama tablolarında anon politikası olmamalı, % var', n;
  end if;

  -- Hiçbir tabloda DELETE politikası yok.
  select count(*) into n from pg_policies
   where schemaname = 'public'
     and tablename in ('bolum_etiketleri', 'bekleyen_guncellemeler',
                       'tarama_kayitlari', 'izlenen_sayfalar')
     and cmd = 'DELETE';
  if n <> 0 then
    raise exception 'DELETE politikası olmamalı, % var', n;
  end if;
end $$;
