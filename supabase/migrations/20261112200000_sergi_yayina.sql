-- UTOİFY 16 fotoğraf yarışması YAYINA ALINIYOR.
--
-- Bu bir veri değişikliği, şema değişikliği değil — ve bilerek göç olarak
-- yazıldı. Sebebi: yayına alma kararı bu projede bir KARAR ve kararın tarihi,
-- gerekçesi ve sırası izlenebilir olmalı. Konsoldan elle çalıştırılan bir
-- UPDATE hiçbir yerde iz bırakmazdı.
--
-- SIRA ÖNEMLİ VE BU GÖÇ SIRANIN SON ADIMI:
--   1) 20261112190000_sergi.sql  → veri girdi, bant HÂLÂ görünmüyordu
--   2) derle + dağıt              → 114 kare hosting'e çıktı
--   3) canlıda bir kare gözle sınandı:
--        200 image/jpeg 69932 bayt
--        tarimportali.net/sergi/utoify-16/odul-01-galib-rahman-nadim.jpg
--   4) BU GÖÇ — yayına alma
--
-- Üçüncü adım atlanıp ikinci adımdan sonra doğrudan buraya gelinseydi
-- anasayfanın altında 114 kırık görsel çıkardı ve hiçbir şey hata vermezdi.
-- Bu dosyayı bir dahaki sefere okuyan için: sıra budur.
--
-- Yayına alma kararı kullanıcınındır; 12 Kasım 2026'da açıkça verildi.

update public.sergi_yarismalari
   set yayinda = true,
       guncellendi = now()
 where kod = 'utoify-16';

-- ── Sınama ────────────────────────────────────────────────────────────────
-- Sessiz başarısızlığa karşı: yukarıdaki UPDATE hiçbir satıra dokunmasa da
-- PostgreSQL hata vermez. Yarışma kodu bir gün değişirse bu blok durdurur.
do $kontrol$
declare
  yayinda_mi boolean;
  eser_sayisi integer;
begin
  select yayinda into yayinda_mi
    from public.sergi_yarismalari where kod = 'utoify-16';

  if yayinda_mi is null then
    raise exception 'utoify-16 yarışması bulunamadı — yayına alınacak satır yok';
  end if;

  if not yayinda_mi then
    raise exception 'utoify-16 hâlâ yayında değil — UPDATE satıra ulaşmadı';
  end if;

  -- Birincil anahtar `kod` (metin); eserler ona `yarisma_kod` ile bağlı.
  -- İlk yazımda `y.id = e.yarisma_id` diye bir birleştirme vardı ve göç
  -- "column y.id does not exist" ile DURDU — yani sınama kendi hatasını da
  -- yakalamış oldu. Tahmin edilen şema yerine göçün kendi tanımı okundu.
  select count(*) into eser_sayisi
    from public.sergi_eserleri
   where yarisma_kod = 'utoify-16';

  -- Yarışma 114 kareyle girmişti. Sayı tutmuyorsa yayına almadan önce
  -- bakılması gereken bir şey var demektir.
  if eser_sayisi <> 114 then
    raise exception 'utoify-16 eser sayısı % — beklenen 114', eser_sayisi;
  end if;

  raise notice 'utoify-16 yayına alındı · % eser', eser_sayisi;
end
$kontrol$;
