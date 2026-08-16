-- Ülke Dosyası — 28 günde bir dönen ülke incelemesi.
--
-- Bu, haber tablosunun bir varyantı DEĞİL. Haber uçucudur: bir kaynaktan
-- çekilir, birkaç gün yaşar, arşive düşer. Dosya ise elle yazılır, kaynakları
-- depoda kilitlidir ve 28 gün boyunca ana sayfada sabit durur. Ayrı tablo
-- olmasının sebebi bu: articles'ın hiçbir alanı (kaynak URL'i, çekme zamanı,
-- hero puanı) burada anlam taşımıyor, buranın hiçbir alanı da orada.
--
-- Veri zinciri: kaynak API/CSV → content/dossiers/<slug>/_raw/*.json →
-- data.json → bu tablo. Zincirin tamamı depoda; veritabanı yalnızca son
-- halkayı taşıyor. Bir rakam tartışmalı hâle gelirse _raw'a kadar geri
-- yürünebilir.

-- ─── Dosyalar ─────────────────────────────────────────────────────────────
create table if not exists public.country_dossiers (
  id            bigserial primary key,
  -- Adres satırında görünür: /ulke/hollanda. Ülkenin adı değişse bile slug
  -- sabit kalır — paylaşılan bağlantı ve arama motoru dizini kırılmasın.
  slug          text not null unique,
  name_tr       text not null,
  name_en       text not null,
  -- ISO 3166-1 alpha-3. FAOSTAT ve World Bank sorguları bu kodla yapıldı;
  -- bir rakam doğrulanacaksa kaynağa gitmenin anahtarı burada.
  iso3          char(3) not null,
  -- Kapaktaki "ÜLKE DOSYASI · 01" numarası. Sayı sıradan gelmiyor: dosyalar
  -- kronolojik yayınlanmayabilir (Hollanda hazır, Mısır beklerken Brezilya
  -- öne alınabilir), ama numara yayın sırasını değil sayı sırasını gösterir.
  edition       integer not null,

  -- Dosyanın tek cümlelik iddiası. Kapakta, ana sayfa şeridinde ve paylaşım
  -- görselinde aynı cümle görünür; üç yerde ayrı yazılırsa üçü birbirinden
  -- kayar.
  thesis_tr     text not null,
  thesis_en     text not null,

  -- content/dossiers/<slug>/tasarim.json'un tamamı. Renkler koda gömülmüyor:
  -- her ülkenin kendi paleti var ve palet WCAG kontrast hesabıyla birlikte
  -- saklanıyor. Flutter tarafı DossierTheme'i bu nesneden üretir.
  theme         jsonb not null,

  -- content/dossiers/<slug>/data.json'un tamamı — kilitli veri sayfası.
  -- Parçalanıp sütunlara dağıtılmadı, çünkü her ülkenin veri şekli farklı:
  -- Hollanda'da "sera" bloğu var, Mısır'da "sulama" olacak. Şemayı her ülkede
  -- değiştirmek yerine grafikler anahtar üzerinden okuyor.
  -- ~50 KB. Bu yüzden ana sayfa şeridi bu sütunu ASLA çekmez (aşağıdaki
  -- active_country_dossier görünümüne bakın).
  data          jsonb not null,

  -- content/dossiers/<slug>/grafikler.json — ÇÖZÜLMÜŞ hâli. Grafik kimliğinden
  -- (örn. 'sera_urunler') o grafiğin tam tarifine giden bir sözlük.
  --
  -- Neden data'dan ayrı bir sütun: data.json'daki etiketler tek dilli. World
  -- Bank kalemleri Türkçe ('Tarımın GSYH içindeki payı'), FAOSTAT kalemleri
  -- İngilizce ('Cocoa beans'). İki dilli bir grafik çizmek için ikinci dilin
  -- bir yerde yazılı olması gerekiyor ve o yer Dart kodu OLAMAZ — yoksa her
  -- yeni ülke bir uygulama sürümü demek olurdu. 28 günde bir ülke değişen bir
  -- bölümde bu sürdürülemez.
  --
  -- "Çözülmüş" şu demek: grafikler.json'da rakamlar data.json'a birer yol
  -- olarak yazılıyor ('@makro.3.NLD.deger'), seed betiği bu yolları okuyup
  -- yerine gerçek sayıyı koyuyor. Böylece hiçbir rakam iki kez yazılmıyor;
  -- grafikteki sayı ile metindeki sayı aynı kaynaktan geliyor. Yol bulunamazsa
  -- seed üretimi durur.
  --
  -- Grafik seçimi de bir yayın kararı: hangi verinin çubuk, hangisinin çizgi
  -- olacağı içerik klasöründe kalıyor.
  charts        jsonb not null default '{}'::jsonb,

  cover_url     text,
  -- Kapak görseli bulunana kadar sayfa tipografik iskeletle çalışır; bu iki
  -- alan boş olabilir. Ama doluysa atıf zorunlu — telifi belirsiz görsel
  -- kullanılmıyor.
  cover_credit  text,

  -- 'draft'     — yazılıyor, hiç kimse göremez
  -- 'scheduled' — bitti, starts_at bekleniyor
  -- 'published' — yayında (pencere içindeyse ana sayfada)
  -- 'archived'  — penceresi geçti, /ulkeler arşivinde durur
  status        text not null default 'draft'
                check (status in ('draft','scheduled','published','archived')),

  -- 28 günlük pencere. ends_at null bırakılırsa dosya süresiz yayında kalır;
  -- ilk dosyada bilerek kullanılabilir (ikincisi hazır değilse ana sayfa
  -- bölümü boşalmasın).
  starts_at     timestamptz,
  ends_at       timestamptz,
  check (ends_at is null or starts_at is null or ends_at > starts_at),

  published_at  timestamptz,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now()
);

create unique index if not exists country_dossiers_edition_idx
  on public.country_dossiers (edition);

-- Aktif dosya sorgusu her ana sayfa yüklemesinde çalışıyor; tarama değil
-- indeks okuması olsun.
create index if not exists country_dossiers_window_idx
  on public.country_dossiers (status, starts_at desc);

-- ─── Bölümler ─────────────────────────────────────────────────────────────
-- Metin tek blob olarak da tutulabilirdi. Bölümlere ayrılmasının üç sebebi
-- var: (1) okuma ilerleme çubuğu ve bölüm navigasyonu sıraya ihtiyaç duyuyor,
-- (2) grafik metnin ortasına giriyor ve hangi grafiğin nereye gireceği
-- satırda yazıyor, (3) 40 KB'lık markdown'ı istemcide ayrıştırmak yerine
-- sunucuda bir kez ayrıştırıp saklamak daha ucuz.
create table if not exists public.dossier_sections (
  id          bigserial primary key,
  dossier_id  bigint not null references public.country_dossiers(id) on delete cascade,
  -- 1'den başlar. Metindeki "üçüncü bölümde geri gelecek" gibi ileri
  -- göndermeler bu numaraya dayanıyor; sıra değişirse metin yalan söyler.
  ord         integer not null,
  title_tr    text not null,
  title_en    text not null,
  body_tr     text not null,
  body_en     text not null,
  -- country_dossiers.charts içindeki grafik kimlikleri: 'verim_ortualti',
  -- 'sera_urunler', 'ihracat_yigin'... Boş dizi ise bölümde grafik yok.
  --
  -- Neden dizi: Hollanda'nın 10. bölümü hem altmış yıllık ihracat eğrisini
  -- hem dünya sıralaması tablosunu taşıyor. Tek sütun olsaydı ikisinden biri
  -- metinde anlatılıp grafiksiz kalacaktı.
  --
  -- Neden veri bloğunun değil grafiğin adı: bir veri bloğu birden çok grafiğe
  -- kaynaklık ediyor (sera → hem künye hem sıralama) ve bir grafik birden çok
  -- bloktan besleniyor. Eşleme veriye yapılsaydı bu iki hâl de anlatılamazdı.
  --
  -- Kimlik kümesi ülkeden ülkeye değişiyor, o yüzden veritabanı kısıtı yok;
  -- kimliğin charts içinde tanımlı olduğunu seed betiği doğruluyor. İstemci
  -- yine de tanımsız kimliği sessizce atlar — eski bir istemci yeni bir dosyayı
  -- açtığında sayfa boş kalmasın.
  chart_keys  text[] not null default '{}',
  created_at  timestamptz not null default now(),
  unique (dossier_id, ord)
);

create index if not exists dossier_sections_order_idx
  on public.dossier_sections (dossier_id, ord);

-- ─── Aktif dosya görünümü ─────────────────────────────────────────────────
-- Ana sayfa şeridinin ihtiyacı olan her şey, HİÇBİR ağır sütun olmadan.
-- data ve theme.palet dışarıda bırakılamaz mı diye sorulabilir: theme
-- gerekiyor çünkü şerit ülkenin kendi rengiyle çiziliyor (6 KB, kabul
-- edilebilir). data 50 KB ve şeritte tek bir rakamı bile kullanılmıyor —
-- o yüzden yok.
--
-- security_invoker: görünüm çağıranın yetkisiyle çalışsın. Aksi hâlde
-- görünüm sahibinin yetkisiyle çalışır ve altındaki tablonun RLS'i baypas
-- edilir — taslak dosyalar anon'a sızardı.
create or replace view public.active_country_dossier
with (security_invoker = on) as
select
  d.slug,
  d.name_tr,
  d.name_en,
  d.iso3,
  d.edition,
  d.thesis_tr,
  d.thesis_en,
  d.theme,
  d.cover_url,
  d.cover_credit,
  d.starts_at,
  d.ends_at,
  -- Şeritte "dosya 6 gün sonra değişiyor" yazabilmek için. İstemcide
  -- hesaplamak, cihaz saatinin doğru olduğunu varsaymak demekti.
  case
    when d.ends_at is not null
    then greatest(0, ceil(extract(epoch from (d.ends_at - now())) / 86400)::integer)
  end as days_remaining,
  (select count(*) from public.dossier_sections s where s.dossier_id = d.id)
    as section_count
from public.country_dossiers d
where d.status = 'published'
  and (d.starts_at is null or d.starts_at <= now())
  and (d.ends_at   is null or d.ends_at   >  now())
-- Pencereler yanlışlıkla üst üste binerse en yeni başlayan kazanır. Ana
-- sayfada iki dosya birden görünmesindense biri görünmesin.
order by d.starts_at desc nulls last
limit 1;

-- ─── Arşiv görünümü ───────────────────────────────────────────────────────
-- /ulkeler sayfası. Yine data yok: on iki ülkelik bir liste 600 KB
-- indirmemeli.
create or replace view public.country_dossier_index
with (security_invoker = on) as
select
  d.slug,
  d.name_tr,
  d.name_en,
  d.iso3,
  d.edition,
  d.thesis_tr,
  d.thesis_en,
  d.cover_url,
  d.published_at,
  d.starts_at,
  d.ends_at,
  -- Şu an ana sayfada olan dosya listede de işaretlensin.
  (d.status = 'published'
    and (d.starts_at is null or d.starts_at <= now())
    and (d.ends_at   is null or d.ends_at   >  now())) as is_active
from public.country_dossiers d
where d.status in ('published','archived')
order by d.edition desc;

-- ─── RLS ──────────────────────────────────────────────────────────────────
-- Yayımlanmış dosya kamuya açık. Taslak açık DEĞİL: bir sonraki ülke
-- yazılırken yarısı bitmiş metin adres tahminiyle okunabilmemeli.
-- Yazma yalnızca service_role — içerik depodan, seed betiğiyle giriyor.
alter table public.country_dossiers enable row level security;
alter table public.dossier_sections enable row level security;

drop policy if exists "anon can read published dossiers" on public.country_dossiers;
create policy "anon can read published dossiers"
  on public.country_dossiers for select
  to anon, authenticated
  using (status in ('published','archived'));

-- Bölüm politikası üst tabloya bakıyor: taslak dosyanın metni, satırlar ayrı
-- tabloda diye sızmasın.
drop policy if exists "anon can read published dossier sections" on public.dossier_sections;
create policy "anon can read published dossier sections"
  on public.dossier_sections for select
  to anon, authenticated
  using (
    exists (
      select 1 from public.country_dossiers d
       where d.id = dossier_sections.dossier_id
         and d.status in ('published','archived')
    )
  );

grant select on public.country_dossiers        to anon, authenticated;
grant select on public.dossier_sections        to anon, authenticated;
grant select on public.active_country_dossier  to anon, authenticated;
grant select on public.country_dossier_index   to anon, authenticated;

notify pgrst, 'reload schema';
