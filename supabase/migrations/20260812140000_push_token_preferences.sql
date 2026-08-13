-- push_tokens: bildirim tercihleri ve dil.
--
-- ── Tasarımın tek kuralı ─────────────────────────────────────────────────
-- Tercihi OLMAYAN cihaz, bugün ne alıyorsa aynısını almaya devam eder.
--
-- Bu kural pazarlık konusu değil. Filtreleme "kimin alacağını" belirleyen bir
-- mekanizma ve buradaki bir hata bildirim sistemini sessizce karartabilir:
-- kimse hata görmez, kimse bildirim almaz. Bu yüzden `kinds` NULL olduğunda
-- cihaz TÜM türleri alır; `locale` NULL ise metin Türkçe gider.
--
-- Yani en kötü durumda (sütunlar okunamaz, uygulama hiç yazmaz, RLS engeller)
-- davranış bugünküyle birebir aynı olur.
--
-- ── NULL ile BOŞ DİZİ aynı şey DEĞİL ──────────────────────────────────────
-- NULL  = kullanıcı hiç seçim yapmadı → hepsini alır.
-- '{}'  = kullanıcı hepsini kapattı   → hiçbirini almaz.
--
-- İkisi bir tutulsaydı bildirimleri kapatan kullanıcı hepsini almaya devam
-- ederdi. Uygulama bu diziyi yalnızca kullanıcı bir anahtara DOKUNDUKTAN sonra
-- yazıyor (bkz. lib/core/services/notification_prefs.dart); yani boş dizi her
-- zaman bilinçli bir tercihtir, yüklenmemiş bir durumun yan etkisi değildir.

-- ─── Sütunlar ─────────────────────────────────────────────────────────────

-- Cihazın almak İSTEDİĞİ bildirim türleri: 'breaking' | 'morning' | 'weekly'
-- | 'author'. NULL = hepsi.
--
-- Ad neden `topics` değil: `articles` tablosunda zaten bir `topic` sütunu var
-- ve o HABER konusunu (tarım-bilim, ekonomi…) tutuyor. Aynı adı burada
-- bildirim türü için kullanmak, ileride bu iki kavramı karıştıran bir sorguya
-- davetiye çıkarırdı.
alter table public.push_tokens add column if not exists kinds text[];

-- Bildirim metninin dili: 'tr' | 'en'. NULL = 'tr'.
--
-- Yalnızca BİLDİRİM metnini etkiler; uygulamanın arayüz dili ayrı ve
-- cihazda tutuluyor. İngilizce karşılığı (`title_en`) olmayan bir haberde
-- metin yine Türkçe gider — boş bir bildirim göndermektense.
alter table public.push_tokens add column if not exists locale text;

-- ─── RLS ──────────────────────────────────────────────────────────────────
-- Mevcut politikalar `token` uzunluğunu doğruluyordu; yeni sütunlar için de
-- doğrulama ekleniyor. Doğrulama olmadan tabloya rastgele değer yazılabilir ve
-- Cloud Function tarafında sessizce eşleşmeyen bir filtre oluşurdu.

drop policy if exists "anon can register push token" on public.push_tokens;
drop policy if exists "anon can refresh push token"  on public.push_tokens;

create policy "anon can register push token"
  on public.push_tokens for insert
  to anon, authenticated
  with check (
    token is not null
    and length(token) between 20 and 500
    and (kinds is null or kinds <@ array['breaking','morning','weekly','author']::text[])
    and (locale is null or locale in ('tr','en'))
  );

create policy "anon can refresh push token"
  on public.push_tokens for update
  to anon, authenticated
  using (true)
  with check (
    token is not null
    and length(token) between 20 and 500
    and (kinds is null or kinds <@ array['breaking','morning','weekly','author']::text[])
    and (locale is null or locale in ('tr','en'))
  );

notify pgrst, 'reload schema';
