-- Kurum dosyası devri — TİGEM yayına giriyor, DSİ arşive
--
-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  BU DOSYA supabase/migrations/ ALTINDA DEĞİL — ÖYLE OLMASI GEREKİYOR ║
-- ╚══════════════════════════════════════════════════════════════════════╝
--
-- Devir AÇIK ONAY ister ve `supabase db push` klasördeki her şeyi uygular.
-- Göç migrations/ altında dursa, ilgisiz bir sebeple atılan tek bir push
-- dosyayı onay alınmadan yayına sokardı. §37.5'te TMO göçü aynı gerekçeyle
-- buraya taşınmıştı.
--
-- ONAY ALINDIĞINDA:
--   mv content/dossiers/tigem/beklemede/20261112140000_dosya_devri_tigem.sql \
--      supabase/migrations/
--   supabase db push
--
-- 12 KASIM 2026: onay alındı, dosya taşındı ve uygulandı. Damga 120000 iken
-- 140000 yapıldı: CLI, uygulanmış son göçten (20261112130000, teaser kolonu)
-- ESKİ damgalı bir göçü sessizce atlıyor ve "Remote database is up to date"
-- diyor. Bu devir zaten o kolona bağımlı, yani sıra da böyle doğru.
--
-- Sırası ve öncesinde yapılacaklar: beklemede/OKU.md
--
-- ── NE DEĞİŞİYOR ─────────────────────────────────────────────────────────
-- 1. TİGEM: draft → published, pencere BUGÜN başlıyor, 14 gün (§8.1).
-- 2. DSİ: published → archived, penceresi bugün kapanıyor.
-- 3. Takvimdeki "Yakında" sözü TİGEM'den TÜRKŞEKER'e devrediliyor
--    (§8.13 sıra 7). Kullanıcı 12 Kasım 2026'da bunu ayrıca hatırlattı:
--    kart 12 Kasım'da "TİGEM" diyordu, yani devredilmezse dosya hem yayında
--    hem "yakında" görünürdü.
-- 4. Karta TEASER cümlesi yazılıyor: Türkşeker dosyası 26 Kasım 2026'da,
--    ilk Türk şekerinin yüzüncü yılında açılıyor (kullanıcı kararı).
--
-- ── ÖN KOŞUL: 20261112130000_takvim_teaser.sql ───────────────────────────
-- teaser_tr/teaser_en kolonlarını o göç açıyor. Uygulanmamışsa bu devir
-- kolonu bulamaz ve durur.
--
-- ── İÇERİĞE DOKUNMUYOR ───────────────────────────────────────────────────
-- Bölümler, grafikler ve tema 20261111090000_tigem_icerik_draft.sql ile
-- yazıldı. Bu göç yalnızca DURUM ve TAKVİM değiştiriyor; içerik göçünün
-- uygulanmış olması ÖN KOŞUL ve aşağıdaki birinci sağlama onu sınıyor.
--
-- ── ÜLKE DİZİSİNE DOKUNMUYOR ─────────────────────────────────────────────
-- Irak penceresi 30 Kasım'a kadar açık. Bu göç kurum dizisini değiştiriyor.
--
-- İçteki begin/commit yok: CLI her göçü tek işlemde çalıştırıyor (§4.1).

-- ── 1. TİGEM yayına ──────────────────────────────────────────────────────
-- Pencere KOŞULSUZ yeniden yazılıyor. İçerik göçü satırı eklerken
-- starts_at = now() yazmıştı; devir o günden sonra yapılırsa pencere
-- geçmişte başlamış olurdu ve dosya raftaki süresinin bir kısmını
-- kaybederdi.
update public.country_dossiers
   set status       = 'published',
       starts_at    = now(),
       ends_at      = now() + interval '14 days',
       published_at = coalesce(published_at, now())
 where slug = 'tigem';

-- ── 2. DSİ arşive ────────────────────────────────────────────────────────
-- ends_at geçmişe çekilmiyor, now() yazılıyor: arşiv listesi pencereyi
-- olduğu gibi gösteriyor ve "1–12 Kasım" doğru, "1–15 Kasım" yanlış olurdu.
update public.country_dossiers
   set status  = 'archived',
       ends_at = now()
 where slug = 'dsi';

-- ── 3. Takvim: TİGEM → Türkşeker ─────────────────────────────────────────
-- Eski satır silinmiyor, 90+ sıraya çekilip etkinliği kapatılıyor (DSİ
-- devrindeki desen): takvimin geçmişi de kayıt.
update public.dossier_takvim t
   set etkin = false,
       sira  = 1 + coalesce((select max(x.sira) from public.dossier_takvim x
                              where x.tur = t.tur and x.sira >= 90), 89)
 where t.sira < 90
   and t.tur = 'kurum'
   and t.ad_tr ilike 'T%GEM';

-- Teaser — kullanıcı isteği, 12 Kasım 2026. Kart artık sıradaki dosyanın
-- NEDEN o gün açıldığını da söylüyor. Kolon 20261112130000 ile açıldı; o göç
-- uygulanmamışsa buradaki insert kolonu bulamaz ve devir DURUR — istenen
-- davranış bu, çünkü kullanıcı kartta cümleyi görmek istedi.
--
-- TARİH BİR TESADÜF DEĞİL. TİGEM bugün devredilirse penceresi 14 gün sonra,
-- yani 26 Kasım 2026'da kapanıyor: Türkşeker tam o gün devralıyor ve o gün
-- ilk Türk şekerinin yüzüncü yılı. Devir bir gün gecikirse bu hizalanma
-- bozulur; o durumda ya Türkşeker'in penceresi bir gün geç açılır ya da
-- TİGEM'in penceresi 26 Kasım'a çekilir. Karar kullanıcının.
insert into public.dossier_takvim (tur, ad_tr, ad_en, sira, etkin, teaser_tr, teaser_en)
values ('kurum', 'Türkşeker', 'Türkşeker', 1, true,
        'İlk Türk şekeri 26 Kasım 1926''da Kırklareli''ndeki Alpullu Şeker Fabrikası''nda üretildi; dosya yüzüncü yılında açılıyor.',
        'The first Turkish sugar was produced at the Alpullu refinery in Kırklareli on 26 November 1926; the dossier opens on its centenary.')
on conflict (tur, sira) do update set
  ad_tr     = excluded.ad_tr,
  ad_en     = excluded.ad_en,
  etkin     = true,
  teaser_tr = excluded.teaser_tr,
  teaser_en = excluded.teaser_en;

-- ════════════════════════════════════════════════════════════════════════
-- Sağlama — biri bile tutmazsa devir tümden geri alınır
-- ════════════════════════════════════════════════════════════════════════
do $devir_tigem$
declare n integer; t text;
begin
  -- 1. ÖN KOŞUL: içerik göçü uygulanmış olmalı.
  --    Bu göç içerik yazmıyor; içeriksiz bir "published" satırı okura boş
  --    bir dosya açardı.
  select count(*) into n from public.dossier_sections s
    join public.country_dossiers d on d.id = s.dossier_id
   where d.slug = 'tigem';
  if n <> 15 then
    raise exception 'TİGEM bölüm sayısı %, 15 olmalı — içerik göçü '
      '(20261111090000) uygulanmamış olabilir', n;
  end if;

  -- 2. TİGEM yayında ve penceresi açık
  if not exists (select 1 from public.country_dossiers
                  where slug = 'tigem' and status = 'published'
                    and starts_at <= now() and ends_at > now()) then
    raise exception 'TİGEM yayında değil ya da penceresi kapalı';
  end if;

  -- 3. Pencere tam 14 gün (§8.1 — kurum penceresi)
  select round(extract(epoch from (ends_at - starts_at)) / 86400)::int
    into n from public.country_dossiers where slug = 'tigem';
  if n <> 14 then
    raise exception 'TİGEM penceresi % gün, 14 olmalı', n;
  end if;

  -- 4. Yayına giren şey gerçekten KURUM dosyası
  select tur into t from public.country_dossiers where slug = 'tigem';
  if t is distinct from 'kurum' then
    raise exception 'TİGEM tur=% olarak kayıtlı, kurum olmalı', t;
  end if;

  -- 5. DSİ arşivde
  if not exists (select 1 from public.country_dossiers
                  where slug = 'dsi' and status = 'archived') then
    raise exception 'DSİ arşive alınmadı — kurum rafında iki dosya kalır';
  end if;

  -- 6. Kurum dizisinde TEK aktif dosya
  select count(*) into n from public.country_dossiers
   where tur = 'kurum' and status = 'published' and ends_at > now();
  if n <> 1 then
    raise exception 'Kurum dizisinde % aktif dosya var, 1 olmalı', n;
  end if;

  -- 7. ÜLKE DİZİSİNE DOKUNULMAMIŞ OLMALI.
  --    DSİ devrindeki gerekçeyle "en çok 1": sıfır çıkması bu devrin hatası
  --    değil (Irak'ın penceresi başka bir kararla kapanmış olabilir), ikiden
  --    fazla çıkması hatadır.
  select count(*) into n from public.country_dossiers
   where tur = 'ulke' and status = 'published';
  if n > 1 then
    raise exception 'Ülke dizisinde % yayınlanmış dosya var, en çok 1 olmalı', n;
  end if;

  -- 8. TAKVİM DEVREDİLMİŞ OLMALI — kullanıcının 12 Kasım hatırlatması.
  --    Etkin kurum sözü artık TİGEM olamaz: yayına aldığımız dosya
  --    "yakında" diye gösterilemez.
  select count(*) into n from public.dossier_takvim
   where tur = 'kurum' and etkin and ad_tr ilike 'T%GEM';
  if n > 0 then
    raise exception 'Takvimde hâlâ etkin TİGEM sözü var — yayına aldığımız '
      'dosya "Yakında" kartında görünür';
  end if;

  -- 9. Yerine Türkşeker geçmiş olmalı
  if not exists (select 1 from public.dossier_takvim
                  where tur = 'kurum' and etkin and sira = 1
                    and ad_tr = 'Türkşeker') then
    raise exception 'Takvimde etkin kurum sözü Türkşeker değil (§8.13 sıra 7)';
  end if;

  -- 9b. TEASER YAZILMIŞ OLMALI — kullanıcı kartta cümleyi istedi.
  --     Sessizce boş kalması, kullanıcının gördüğü yerde eksik bir iş olur.
  select coalesce(teaser_tr, '') into t from public.dossier_takvim
   where tur = 'kurum' and etkin and sira = 1;
  if t = '' then
    raise exception 'Türkşeker satırında teaser_tr boş — kart gerekçe '
      'cümlesini göstermez (kullanıcı isteği, 12 Kasım 2026)';
  end if;
  if t not like '%1926%' then
    raise exception 'Teaser yıldönümü tarihini taşımıyor: %', t;
  end if;

  -- 10. Etkin kurum sözü TEK olmalı
  select count(*) into n from public.dossier_takvim
   where tur = 'kurum' and etkin;
  if n <> 1 then
    raise exception 'Takvimde % etkin kurum sözü var, 1 olmalı', n;
  end if;

  -- 11. ALTYAZILAR TAHLİL DEĞİL (kullanıcı kuralı, iki kez verildi).
  --     İçerik göçünde de var; devirde tekrar sınanıyor çünkü araya giren
  --     bir düzeltme göçü altyazıyı değiştirmiş olabilir ve bu, dosyanın
  --     okura AÇILDIĞI an.
  select count(*) into n from public.dossier_sections
   where dossier_id = (select id from public.country_dossiers where slug = 'tigem')
     and gorsel is not null
     and (lower(gorsel->>'alt_tr') ~ '(arkada|ön planda|yakın planda|görülüyor|görünüyor|rengi|desenli)'
       or lower(gorsel->>'alt_en') ~ '(foreground|background|patterned|wearing)');
  if n > 0 then
    raise exception '% görselin altyazısı kareyi tahlil ediyor — altyazı '
      'fotoğrafın NE OLDUĞUNU söyler (kullanıcı kuralı)', n;
  end if;

  -- 12. Her bölümde bir görsel (kullanıcı kuralı). Kaynakça hariç 14 bölüm.
  select count(*) into n from public.dossier_sections
   where dossier_id = (select id from public.country_dossiers where slug = 'tigem')
     and gorsel is not null;
  if n <> 14 then
    raise exception 'Görseli olan bölüm %, 14 olmalı (her bölümde bir '
      'görsel — kullanıcı kuralı)', n;
  end if;
end
$devir_tigem$;
