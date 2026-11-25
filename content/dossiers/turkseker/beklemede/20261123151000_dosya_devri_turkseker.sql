-- Kurum dosyası devri — TÜRKŞEKER yayına giriyor
--
-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  BU DOSYA supabase/migrations/ ALTINDA DEĞİL — ÖYLE OLMASI GEREKİYOR ║
-- ╚══════════════════════════════════════════════════════════════════════╝
--
-- Devir AÇIK ONAY ister ve `supabase db push` klasördeki her şeyi uygular.
--
-- ÖN KOŞUL: 20261123140000_dossier_bolum_turu_galeri.sql ve
-- 20261123150000_turkseker_icerik_draft.sql uygulanmış olmalı.
-- Birinci sağlama bunu sınıyor.
--
-- ── NEDEN PENCERE GELECEKTE BAŞLIYOR ─────────────────────────────────────
-- İlk Türk şekeri 26 Kasım 1926'da Alpullu'da üretildi. Dosyanın ekseni bu
-- ve pencere 2026-11-25T21:00Z'de, yani 26 Kasım 00:00 Türkiye saatinde
-- açılıyor. Göç bugün uygulansa bile dosya o ana kadar GÖRÜNMEZ:
-- active görünümü `starts_at <= now()` arıyor.
--
-- TİGEM'in penceresi 2026-11-25T23:30Z'de kapanıyor. Araya 2,5 saatlik bir
-- örtüşme giriyor ve görünüm en yeni başlangıcı seçtiği için o aralıkta da
-- Türkşeker görünüyor. Boşluk yok.
--
-- ── TİGEM ARŞİVLEMESİ KOŞULLU ────────────────────────────────────────────
-- TİGEM KOŞULSUZ arşivlenseydi ve göç 26 Kasım'dan önce uygulansaydı,
-- kurum dizisi üç gün boyunca BOŞ kalırdı: arşiv satırı active görünümüne
-- girmiyor, Türkşeker ise henüz başlamamış oluyor. Bu yüzden arşivleme
-- yalnız penceresi dolmuşsa yapılıyor. Göç 26 Kasım'dan önce uygulanırsa
-- TİGEM 'published' kalır, penceresi dolunca kendiliğinden görünmez olur
-- ve arşiv etiketi bir sonraki devirde düşer.
--
-- İçteki begin/commit yok: CLI her göçü tek işlemde çalıştırıyor.

-- ── 1. Türkşeker yayına (zamanlanmış) ────────────────────────────────────
update public.country_dossiers
   set status       = 'published',
       starts_at    = timestamptz '2026-11-25T21:00:00Z',
       ends_at      = timestamptz '2026-11-25T21:00:00Z' + interval '14 days',
       published_at = coalesce(published_at, now())
 where slug = 'turkseker';

-- ── 2. TİGEM, penceresi dolmuşsa arşive ──────────────────────────────────
-- ends_at geçmişe çekilmiyor: arşiv listesi pencereyi olduğu gibi gösteriyor.
update public.country_dossiers
   set status = 'archived'
 where slug = 'tigem'
   and status = 'published'
   and ends_at <= now();

-- ── 3. "Yakında" kartı Et ve Süt Kurumu'na ───────────────────────────────
-- §8.13 kurum rotasyonu, sıra 8. Türkşeker artık yayında; takvimde onun
-- adının durması, yayına aldığımız dosyayı "Yakında" diye göstermek olurdu.
update public.dossier_takvim t
   set etkin = false,
       sira  = 1 + coalesce((select max(x.sira) from public.dossier_takvim x
                              where x.tur = t.tur and x.sira >= 90), 89)
 where t.sira < 90
   and t.tur = 'kurum';

insert into public.dossier_takvim (tur, ad_tr, ad_en, sira, etkin, teaser_tr, teaser_en)
values ('kurum', 'Et ve Süt Kurumu', 'Meat and Dairy Board', 1, true, null, null)
on conflict (tur, sira) do update set
  ad_tr     = excluded.ad_tr,
  ad_en     = excluded.ad_en,
  etkin     = true,
  teaser_tr = null,
  teaser_en = null;

-- ── Sağlamalar ───────────────────────────────────────────────────────────
do $kontrol$
declare
  n int;
  bas timestamptz;
  bit timestamptz;
begin
  -- 1 · içerik göçü uygulanmış mı
  select count(*) into n from public.dossier_sections s
    join public.country_dossiers d on d.id = s.dossier_id
   where d.slug = 'turkseker';
  -- 16 → 29 → 22. Tur 9'da on üç bölüm eklendi; 24 Kasım 2026'da yedi
  -- bölüm çifti birleşti. Galeri §21, kaynakça §22. Sayı sabit kaldığında
  -- sağlama DOĞRU içerikte düşerdi.
  if n <> 22 then
    raise exception 'Türkşeker bölüm sayısı %, 22 olmalı — içerik göçü uygulanmamış olabilir', n;
  end if;

  -- 2 · durum ve pencere
  select starts_at, ends_at into bas, bit
    from public.country_dossiers where slug = 'turkseker';
  if bas is distinct from timestamptz '2026-11-25T21:00:00Z' then
    raise exception 'Türkşeker başlangıcı % — 2026-11-25T21:00:00Z olmalı', bas;
  end if;
  if bit - bas <> interval '14 days' then
    raise exception 'Türkşeker penceresi % — 14 gün olmalı', bit - bas;
  end if;

  select count(*) into n from public.country_dossiers
   where slug = 'turkseker' and status = 'published' and tur = 'kurum' and edition = 7;
  if n <> 1 then
    raise exception 'Türkşeker yayında/kurum/sayı 7 değil';
  end if;

  -- 3 · grafik ve görsel bütünlüğü
  select count(*) into n from public.country_dossiers
   where slug = 'turkseker' and jsonb_typeof(charts) = 'object'
     and (select count(*) from jsonb_object_keys(charts)) = 11;
  if n <> 1 then
    raise exception 'Türkşeker grafik sayısı 11 değil';
  end if;

  -- 9 · GALERİ YERİNDE Mİ. Galeri data sütununun içinde; bölüm sayısı
  -- doğru olsa bile data eski sürümden gelmiş olabilir. Kareler
  -- yazılmadıysa §21 boş bir başlık olarak çıkar.
  --
  -- 79 → 173 → 160 → 167 → 118 → 142 → 139. İkinci parti 94 kare ekledi;
  -- algısal karşılaştırma 13 tekrar buldu ve çıkardı; birleşmeden boşta
  -- kalan 7 kare galeriye geçti; kullanıcı 49 kare eledi; üçüncü parti
  -- çiftçi, tarla ve şeker dışı kalemler için 24 kare ekledi; kullanıcı
  -- ikinci turda 3 kare daha eledi.
  if (select jsonb_array_length(coalesce(d.data #> '{galeri,kareler}', '[]'::jsonb))
        from public.country_dossiers d where d.slug = 'turkseker') <> 139 then
    raise exception 'Türkşeker galerisinde 139 kare yok — içerik göçü eski olabilir';
  end if;

  -- 4 · takvimde artık Türkşeker sözü yok
  select count(*) into n from public.dossier_takvim
   where tur = 'kurum' and etkin and ad_tr ilike '%rk%eker';
  if n > 0 then
    raise exception 'Takvimde hâlâ etkin Türkşeker sözü var — yayına aldığımız '
      'dosya "Yakında" kartında görünür';
  end if;

  -- 5 · "Yakında" kartı yerine oturdu
  if not exists (select 1 from public.dossier_takvim
                  where tur = 'kurum' and etkin and sira = 1
                    and ad_tr = 'Et ve Süt Kurumu') then
    raise exception 'Kurum takviminin birinci sırasında Et ve Süt Kurumu yok';
  end if;

  -- 6 · kurum dizisinde boşluk kalmadı
  -- Pencere açıldığında Türkşeker, açılmadan önce TİGEM görünür olmalı.
  select count(*) into n from public.country_dossiers
   where tur = 'kurum' and status = 'published'
     and starts_at <= now() and ends_at > now();
  if n = 0 and now() < timestamptz '2026-11-25T21:00:00Z' then
    raise exception 'Kurum dizisi BOŞ kaldı — TİGEM erken düşmüş olabilir';
  end if;
end
$kontrol$;
