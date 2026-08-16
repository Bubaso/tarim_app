-- Bölüm görselleri — her bölüme isteğe bağlı fotoğraf.
--
-- Görseller Unsplash, Wikimedia veya NASA gibi telifsiz kaynaklardan
-- geliyor. credit sütunu atıf bilgisini taşıyor; boşsa sayfa görseli
-- kredisiz gösteriyor (Unsplash lisansı atıf zorunlu KILMIYOR ama
-- etik olarak öneriliyor).

alter table public.dossier_sections
  add column if not exists image_url    text,
  add column if not exists image_credit text;

notify pgrst, 'reload schema';
