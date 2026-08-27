-- Yayımlanmış dosyaların haber eşleştirme terimleri.
--
-- Kaynak: content/dossiers/<slug>/yayin.json → anahtar_kelimeler
--
-- Seed'in tamamını yeniden çalıştırmak yerine yalnızca bu sütun güncelleniyor:
-- metin, grafik ve görsellerde değişiklik yok, 170 KB SQL'i tekrar uygulamanın
-- karşılığı yok. Pencere de korunmuş oluyor.

update public.country_dossiers
   set anahtar_kelimeler = array['Hollanda', 'Felemenk', 'Rotterdam', 'Amsterdam', 'Wageningen', 'Aalsmeer', 'FloraHolland']::text[]
 where slug = 'hollanda';

update public.country_dossiers
   set anahtar_kelimeler = array['TMO', 'Toprak Mahsulleri Ofisi', 'Toprak Mahsulleri']::text[]
 where slug = 'tmo';
