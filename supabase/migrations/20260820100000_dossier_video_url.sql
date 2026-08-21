-- ═══════════════════════════════════════════════════════════════════════════
--  Dosya kapağındaki tanıtım videosu
--
--  Hollanda videosu şimdiye kadar EKRAN KODUNDA duruyordu:
--
--      if (ozet.slug.contains('hollanda')) ... DossierVideoPlayer(videoUrl: 'https://…')
--
--  Bu üç ayrı sorun üretiyordu:
--
--   1) İçerik kodda. Video değiştirmek uygulamayı yeniden derleyip yayına
--      almak demekti; oysa dosyanın diğer her parçası (metin, palet, grafik,
--      kapak görseli) veritabanından geliyor.
--   2) Mısır dosyası eklendiğinde koşul ikiye, üçüncü ülkede üçe çıkacaktı.
--      Ekran kodunda ülke adı geçmesi, dizinin bütün mimarisine aykırı.
--   3) Testler kırılıyordu. `flutter test` içinde video platformu yok;
--      koşul slug'a bağlı olduğu için üretim seed'iyle çalışan her sayfa
--      testi `UnimplementedError: init() has not been implemented` alıyordu.
--      Sütun null olabildiği için test fixture'ı videosuz dosya kurabiliyor.
--
--  Sütun `country_dossiers` tablosunda; görünümlere EKLENMİYOR. Ana sayfa
--  şeridi (`active_country_dossier`) ve arşiv listesi (`country_dossier_index`)
--  video oynatmıyor, taşımalarının anlamı yok. Dosya sayfası zaten tabloyu
--  doğrudan `select()` ile okuyor.
-- ═══════════════════════════════════════════════════════════════════════════

alter table public.country_dossiers
  add column if not exists video_url text;

comment on column public.country_dossiers.video_url is
  'Kapaktaki tanıtım videosunun genel erişime açık adresi. null ise kapakta '
  'video bloğu hiç çizilmez — sayfa videosuz da tam çalışır, tıpkı cover_url '
  'gibi.';

-- Hollanda yayında; sütun eklenirken değeri de taşınıyor ki bu migration
-- uygulandığı anda sayfa kod değişikliğini beklemeden aynı videoyu göstersin.
-- Değer content/dossiers/hollanda/yayin.json'daki `video.url` ile aynı;
-- seed betiği bundan sonra onu yazıyor.
update public.country_dossiers
   set video_url = 'https://xkwcyavcltrweunvooeu.supabase.co/storage/v1/object/public/country_folder_videos/copy_12951F0A-2908-4BF0-B083-73A1927D00B0.mp4'
 where slug = 'hollanda'
   and video_url is null;
