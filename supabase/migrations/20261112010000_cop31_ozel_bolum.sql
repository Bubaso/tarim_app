-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  Süreli anasayfa bölümü işareti — ilk kullanıcısı COP31                  ║
-- ╚══════════════════════════════════════════════════════════════════════════╝
--
-- COP31 iklim zirvesi 9-20 Kasım 2026, Antalya. Anasayfada "Türkiye'den
-- Haberler"in altında kendi kimliğiyle bir blok duracak, 25 Kasım'da kalkacak.
--
-- NEDEN YENİ KATEGORİ DEĞİL
-- `category_id` bu projede hiç kullanılmıyor: 1831 haberin tamamında NULL.
-- Haberin gerçek yerini `topic` (Genel/Ekonomi/YYT/Tarım-Bilim/...) ve
-- `region` (Türkiye/Dünya) tutuyor. Özel bölüm bunların YERİNE geçmiyor,
-- ÜSTÜNE biniyor: işaretlenen haber Dünya/Türkiye/Hayvancılık kimliğini
-- hiç kaybetmiyor.
--
-- 25 KASIM'DA VERİ TAŞINMAYACAK
-- Bölümün ömrü uygulamadaki tek bir tarih sabiti. Süre dolunca kural susuyor
-- ve haberler kendi topic/region bölümlerine kendiliğinden akıyor. O gün
-- betik çalıştırmak, sütunu temizlemek, deploy etmek gerekmiyor. "Haberler
-- ilgili kategorilerine taşınacak" şartı, hiçbir şeyi taşımamakla sağlanıyor.
--
-- METİN, ENUM DEĞİL
-- İkinci bir zirve ya da süreli dosya geldiğinde yeni bir göç gerekmesin.

alter table public.articles
  add column if not exists ozel_bolum text;

comment on column public.articles.ozel_bolum is
  'Süreli anasayfa bölümü işareti (örn. ''cop31''). topic/region''ı DEĞİŞTİRMEZ, üstüne biner. Bölümün ömrü uygulama tarafındaki tarih sabitinde.';

-- Bölüm ortak listeyi SÜZMÜYOR, kendi sorgusunu yapıyor: ortak liste en yeni
-- 500 haber ve COP31'in Eylül'deki hazırlık haberleri o pencerenin dışında
-- kalıyor — köşe yazarı şeridindeki §26.2 ile birebir aynı sebep.
--
-- Kısmi indeks: işaretli satırlar toplamın ~%2'si, tam indeks boşa yer tutar.
create index if not exists articles_ozel_bolum_idx
  on public.articles (ozel_bolum, created_at desc)
  where ozel_bolum is not null;
