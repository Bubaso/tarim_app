-- Bölümün görsel türü.
--
-- NEDEN GEREKLİ. Hollanda dosyasının on üç bölümü tek ritimde akıyor: her biri
-- aynı hayalet rakam, aynı 48×3 vurgu çizgisi, aynı "03 / 13" sayacıyla
-- açılıyor. Tutarlı ama düz — beş bin kelime boyunca zemin hiç değişmiyor ve
-- okurun "burası farklı" diyeceği tek bir an yok. Tür, sayfaya ritim veriyor.
--
--   anlati — standart oluk, akan metin
--   belge  — ray girintili kayıt blokları, kaynak satırlı (Kurum Dosyası)
--   veri   — OLUĞU KIRAR: tablo ve grafik tam genişlikte nefes alır
--   akis   — numaralı adımlar; aktör, süre, çıktı belgesi (Kurum Dosyası)
--
-- NEDEN chart_keys'TEN TÜRETİLMİYOR. "Grafiği olan bölüm geniştir" kuralı ilk
-- bakışta yeterli görünüyor ama iki yerde kırılıyor: Kurum Dosyası'nda grafiksiz
-- bir `belge` bölümü var, ve Hollanda'nın 9. bölümü kart grafiği taşıdığı hâlde
-- anlatı ritminde kalmalı. Tür bir yayın kararı; veriden çıkarılamaz, yazılır.
--
-- Varsayılan 'anlati': mevcut satırlar bugünkü görünümlerini korur, migration
-- tek başına hiçbir sayfayı değiştirmez. Ritim, seed yeniden üretildiğinde gelir.
alter table public.dossier_sections
  add column if not exists tur text not null default 'anlati';

do $$
begin
  if not exists (
    select 1 from pg_constraint where conname = 'dossier_sections_tur_check'
  ) then
    alter table public.dossier_sections
      add constraint dossier_sections_tur_check
      check (tur in ('anlati', 'belge', 'veri', 'akis'));
  end if;
end $$;

comment on column public.dossier_sections.tur is
  'Bölümün görsel ritmi: anlati | belge | veri | akis. yayin.json/bolum_turleri''nden gelir.';
