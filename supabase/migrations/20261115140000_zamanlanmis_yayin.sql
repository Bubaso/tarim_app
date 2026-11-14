-- ═══════════════════════════════════════════════════════════════════════════
--  Zamanlanmış yayın — 15 Kasım 2026 (denetim maddesi 20)
-- ═══════════════════════════════════════════════════════════════════════════
--
-- Panel haberi "yarın 09:00'da çıksın" diye işaretliyor: `scheduled_at` dolu,
-- `status` hâlâ `reviewing`. Vakti gelince birinin yayına alması gerekiyor —
-- o iş Firebase'de beş dakikada bir koşan `zamanlanmisYayin` fonksiyonunda.
--
-- NEDEN SECURITY DEFINER
-- Fonksiyonlar Supabase'e ANON anahtarıyla bağlanıyor; `articles` üzerinde
-- anon'un güncelleme yetkisi yok ve olmamalı. Yayına alma işini bu işlev
-- yapıyor, çağıran yetkisiyle değil kendi yetkisiyle.
--
-- ANON'A AÇIK OLMASI NEDEN SAKINCASIZ
-- İşlev yalnızca ZATEN yöneticinin seçtiği ve vakti GELMİŞ haberleri yayına
-- alıyor. Dışarıdan çağıran birinin yapabileceği tek şey, beş dakika içinde
-- zaten olacak bir şeyi biraz erken tetiklemek. Yeni haber yaratamıyor,
-- içerik değiştiremiyor, başka satıra dokunamıyor.
create or replace function public.zamanlanmislari_yayinla()
returns integer
language plpgsql
security definer
set search_path = public
as $$
declare
  sayi integer;
begin
  with vakti_gelen as (
    update public.articles
       set status       = 'published',
           -- Program tüketildi: alan boşaltılıyor ki aynı haber bir daha
           -- yayına alınmaya çalışılmasın ve panelde "programlanmış"
           -- görünmesin.
           scheduled_at = null,
           -- `created_at` listelerin sırasını belirliyor. Programlanan haber
           -- YAYINA GİRDİĞİ anda taze sayılmalı; yoksa sabah hazırlanıp
           -- akşama programlanan haber listenin ortasında doğar.
           created_at   = now()
     where scheduled_at is not null
       and scheduled_at <= now()
       and status = 'reviewing'
    returning id
  )
  select count(*) into sayi from vakti_gelen;
  return sayi;
end;
$$;

comment on function public.zamanlanmislari_yayinla() is
  'Vakti gelen programlı haberleri yayına alır ve kaç tanesini aldığını '
  'döner. Firebase''deki zamanlanmisYayin fonksiyonu beş dakikada bir çağırır.';

grant execute on function public.zamanlanmislari_yayinla() to anon, authenticated;

-- Yayınlanınca `created_at` değiştiği için kapak türevlerini silen
-- tetikleyici tetiklenmiyor (o yalnız `image_url` değişimine bakıyor);
-- türevler yerinde kalıyor.
