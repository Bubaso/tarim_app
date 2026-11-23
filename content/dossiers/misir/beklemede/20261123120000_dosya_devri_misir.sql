-- Ülke dosyası devri — MISIR yayına giriyor, Irak arşive
--
-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  BU DOSYA supabase/migrations/ ALTINDA DEĞİL — ÖYLE OLMASI GEREKİYOR ║
-- ╚══════════════════════════════════════════════════════════════════════╝
--
-- Devir AÇIK ONAY ister ve `supabase db push` klasördeki her şeyi uygular.
-- Göç migrations/ altında dursa, ilgisiz bir sebeple atılan tek bir push
-- dosyayı onay alınmadan yayına sokardı. TMO ve TİGEM göçleri aynı
-- gerekçeyle burada beklemişti.
--
-- ONAY ALINDIĞINDA:
--   ls supabase/migrations/ | tail        # damga bundan SONRA mı, bak
--   mv content/dossiers/misir/beklemede/20261123120000_dosya_devri_misir.sql \
--      supabase/migrations/
--   supabase db push
--
-- DAMGA UYARISI (TİGEM devrinde yaşandı): CLI, uygulanmış son göçten ESKİ
-- damgalı bir göçü SESSİZCE atlıyor ve "Remote database is up to date"
-- diyor — hata vermiyor. 23 Kasım 2026'da uygulanmış son göç
-- 20261120090000; bu damga (20261123120000) ondan sonra. Taşımadan hemen
-- önce yine bakın, araya başka göç girmiş olabilir.
--
-- ── ÖN KOŞUL: seed uygulanmış olmalı ─────────────────────────────────────
--   supabase/seed/dossier_misir.sql
-- Seed içeriği DRAFT olarak yazıyor; taslak satır anon anahtarıyla
-- görünmüyor, yani içerik sessizce yerleşiyor. Bu göç yalnızca DURUM ve
-- TAKVİM değiştiriyor. Birinci sağlama seed'in uygulanmış olduğunu sınıyor.
--
-- ── NE DEĞİŞİYOR ─────────────────────────────────────────────────────────
-- 1. Mısır: draft → published, pencere BUGÜN başlıyor, 28 gün (§2.11).
-- 2. Irak: published → archived, penceresi bugün kapanıyor.
--    Kullanıcı kararı, 23 Kasım 2026: "Irak dosyası var ve 8 gün kaldı
--    ancak önemli değil, şu an Mısır'ı canlıya alabiliriz."
-- 3. Takvimdeki "Yakında" sözü Mısır'dan DANİMARKA'ya devrediliyor.
--    §2.11 sıra 7, rol Model (kooperatifçilik). Kullanıcı önce Hindistan
--    demişti; liste ile karşılaştırıldı, Hindistan on üç ülkelik rotasyonda
--    YOK ve yedinci sıra döngü gereği bir Model olmak zorunda. Kullanıcı
--    23 Kasım 2026'da listeye sadık kalmayı seçti.
--
-- ── KURUM DİZİSİNE DOKUNMUYOR ────────────────────────────────────────────
-- TİGEM'in penceresi 26 Kasım'da kapanıyor ve Türkşeker o gün devralıyor
-- (ilk Türk şekerinin yüzüncü yılı). Bu göç ülke dizisini değiştiriyor.
--
-- İçteki begin/commit yok: CLI her göçü tek işlemde çalıştırıyor (§4.1).

-- ── 1. Mısır yayına ──────────────────────────────────────────────────────
-- Pencere KOŞULSUZ yeniden yazılıyor. Seed satırı eklerken starts_at = now()
-- yazmıştı; devir o günden sonra yapılırsa pencere geçmişte başlamış olur ve
-- dosya raftaki süresinin bir kısmını kaybederdi.
update public.country_dossiers
   set status       = 'published',
       starts_at    = now(),
       ends_at      = now() + interval '28 days',
       published_at = coalesce(published_at, now())
 where slug = 'misir';

-- ── 2. Irak arşive ───────────────────────────────────────────────────────
-- ends_at geçmişe çekilmiyor, now() yazılıyor: arşiv listesi pencereyi
-- olduğu gibi gösteriyor.
--
-- NOT: active_country_dossier görünümü zaten "en yeni başlayan kazanır"
-- diyor (order by starts_at desc limit 1), yani Irak arşive alınmasa da
-- şerit Mısır'ı gösterirdi. Yine de arşive alınıyor: iki dosyanın birden
-- "published" kalması, görünümün 7. sağlamasını ve okurun arşiv
-- listesindeki "yayında" işaretini yanıltırdı.
update public.country_dossiers
   set status  = 'archived',
       ends_at = now()
 where slug = 'irak';

-- ── 3. Takvim: Mısır → Danimarka ─────────────────────────────────────────
-- Eski satır silinmiyor, 90+ sıraya çekilip etkinliği kapatılıyor: takvimin
-- geçmişi de kayıt.
update public.dossier_takvim t
   set etkin = false,
       sira  = 1 + coalesce((select max(x.sira) from public.dossier_takvim x
                              where x.tur = t.tur and x.sira >= 90), 89)
 where t.sira < 90
   and t.tur = 'ulke';

-- Teaser BİLEREK BOŞ. TİGEM devrinde Türkşeker'e teaser yazılmıştı çünkü o
-- dosyanın açılış günü bir yıldönümüne bağlıydı ve kullanıcı cümleyi
-- istemişti. Danimarka'nın tarihi böyle bir güne bağlı değil; uydurma bir
-- gerekçe cümlesi yazmak yerine alan boş bırakılıyor. Kart boşsa eskisi
-- gibi çiziliyor (20261112130000'in kendi notu).
insert into public.dossier_takvim (tur, ad_tr, ad_en, sira, etkin)
values ('ulke', 'Danimarka', 'Denmark', 1, true)
on conflict (tur, sira) do update set
  ad_tr     = excluded.ad_tr,
  ad_en     = excluded.ad_en,
  etkin     = true,
  teaser_tr = null,
  teaser_en = null;

-- ════════════════════════════════════════════════════════════════════════
-- Sağlama — biri bile tutmazsa devir tümden geri alınır
-- ════════════════════════════════════════════════════════════════════════
do $devir_misir$
declare n integer; t text;
begin
  -- 1. ÖN KOŞUL: seed uygulanmış olmalı.
  --    Bu göç içerik yazmıyor; içeriksiz bir "published" satırı okura boş
  --    bir dosya açardı.
  select count(*) into n from public.dossier_sections s
    join public.country_dossiers d on d.id = s.dossier_id
   where d.slug = 'misir';
  if n <> 18 then
    raise exception 'Mısır bölüm sayısı %, 18 olmalı — seed '
      '(supabase/seed/dossier_misir.sql) uygulanmamış olabilir', n;
  end if;

  -- 2. Mısır yayında ve penceresi açık
  if not exists (select 1 from public.country_dossiers
                  where slug = 'misir' and status = 'published'
                    and starts_at <= now() and ends_at > now()) then
    raise exception 'Mısır yayında değil ya da penceresi kapalı';
  end if;

  -- 3. Pencere tam 28 gün (§2.11 — ülke penceresi)
  select round(extract(epoch from (ends_at - starts_at)) / 86400)::int
    into n from public.country_dossiers where slug = 'misir';
  if n <> 28 then
    raise exception 'Mısır penceresi % gün, 28 olmalı', n;
  end if;

  -- 4. Yayına giren şey gerçekten ÜLKE dosyası
  select tur into t from public.country_dossiers where slug = 'misir';
  if t is distinct from 'ulke' then
    raise exception 'Mısır tur=% olarak kayıtlı, ulke olmalı', t;
  end if;

  -- 5. Irak arşivde
  if not exists (select 1 from public.country_dossiers
                  where slug = 'irak' and status = 'archived') then
    raise exception 'Irak arşive alınmadı — ülke rafında iki dosya kalır';
  end if;

  -- 6. Ülke dizisinde TEK aktif dosya
  select count(*) into n from public.country_dossiers
   where tur = 'ulke' and status = 'published' and ends_at > now();
  if n <> 1 then
    raise exception 'Ülke dizisinde % aktif dosya var, 1 olmalı', n;
  end if;

  -- 7. KURUM DİZİSİNE DOKUNULMAMIŞ OLMALI.
  --    "En çok 1": sıfır çıkması bu devrin hatası değil (TİGEM'in penceresi
  --    26 Kasım'da kendiliğinden kapanıyor), ikiden fazla çıkması hatadır.
  select count(*) into n from public.country_dossiers
   where tur = 'kurum' and status = 'published';
  if n > 1 then
    raise exception 'Kurum dizisinde % yayınlanmış dosya var, en çok 1 olmalı', n;
  end if;

  -- 8. TAKVİM DEVREDİLMİŞ OLMALI.
  --    Etkin ülke sözü artık Mısır olamaz: yayına aldığımız dosya "yakında"
  --    diye gösterilemez. TİGEM devrinde kullanıcı bunu ayrıca hatırlatmıştı.
  select count(*) into n from public.dossier_takvim
   where tur = 'ulke' and etkin and ad_tr ilike 'M%s%r';
  if n > 0 then
    raise exception 'Takvimde hâlâ etkin Mısır sözü var — yayına aldığımız '
      'dosya "Yakında" kartında görünür';
  end if;

  -- 9. Yerine Danimarka geçmiş olmalı (§2.11 sıra 7)
  if not exists (select 1 from public.dossier_takvim
                  where tur = 'ulke' and etkin and sira = 1
                    and ad_tr = 'Danimarka') then
    raise exception 'Takvimde etkin ülke sözü Danimarka değil (§2.11 sıra 7)';
  end if;

  -- 10. Etkin ülke sözü TEK olmalı
  select count(*) into n from public.dossier_takvim
   where tur = 'ulke' and etkin;
  if n <> 1 then
    raise exception 'Takvimde % etkin ülke sözü var, 1 olmalı', n;
  end if;

  -- 11. ALTYAZILAR TAHLİL DEĞİL (kullanıcı kuralı, iki kez verildi).
  --     Dosyanın okura AÇILDIĞI an yeniden sınanıyor: araya giren bir
  --     düzeltme altyazıyı değiştirmiş olabilir.
  select count(*) into n from public.dossier_sections s
    join public.country_dossiers d on d.id = s.dossier_id
   where d.slug = 'misir'
     and (s.gorsel->>'alt_tr' ilike '%arka planda%'
       or s.gorsel->>'alt_tr' ilike '%ön planda%'
       or s.gorsel->>'alt_tr' ilike '%görülüyor%'
       or s.gorsel->>'alt_tr' ilike '%görünüyor%');
  if n > 0 then
    raise exception '% altyazı kadraj tahlili yapıyor — altyazı künyedir', n;
  end if;

  -- 12. YAZIM SÜRECİ DİLİ GÖVDEDE OLAMAZ (kullanıcı kuralı, 17 Kasım 2026).
  --     Bu, o kuraldan SONRA yayına giren ilk ülke dosyası. Metin 23 Kasım'da
  --     elden geçirildi ve otuz dört yerde temizlendi; sağlama, araya giren
  --     bir düzeltmenin süreç dilini geri getirmediğini sınıyor.
  select count(*) into n from public.dossier_sections s
    join public.country_dossiers d on d.id = s.dossier_id
   where d.slug = 'misir'
     and (s.body_tr ilike '%bu dosyada ölçül%'
       or s.body_tr ilike '%elimizdeki%'
       or s.body_tr ilike '%bulunamadı%'
       or s.body_tr ilike '%veri sayfasından okundu%'
       or s.body_tr ilike '%kota başına sayıld%');
  if n > 0 then
    raise exception '% bölümde yazım süreci dili var — canlıya giden metin '
      'okur içindir (kullanıcı kuralı, 17 Kasım 2026)', n;
  end if;

  -- 13. İKİNCİ BÖLÜMDE "PARA" GEÇMİYOR (kullanıcı kuralı, 10 Kasım 2026).
  --     Kural iki dilde geçerli.
  select count(*) into n from public.dossier_sections s
    join public.country_dossiers d on d.id = s.dossier_id
   where d.slug = 'misir' and s.ord = 2
     and (s.body_tr ~* '\mpara' or s.body_en ~* '\m(money|monies|cash)\M');
  if n > 0 then
    raise exception 'İkinci bölümde "para" geçiyor — kullanıcı kuralı, '
      '10 Kasım 2026, iki dilde';
  end if;

  raise notice 'Mısır devri tamam — 13 sağlamanın 13''ü geçti';
end
$devir_misir$;
