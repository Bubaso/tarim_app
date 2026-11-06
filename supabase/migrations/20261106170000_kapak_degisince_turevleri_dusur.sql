-- Kapak değişince türevler DÜŞSÜN
--
-- SORUN. Haber görselinin türevleri (dikey hikâye kopyası, kare baloncuk,
-- bulanık önizleme) haber ALINIRKEN bir kez üretiliyor. Editör onay
-- sırasında kapağı değiştirdiğinde — ki sık yapılıyor, çoğu zaman Google
-- Haberler'in ikon görselinden kurtulmak için — türevler ESKİ görseli
-- göstermeye devam ediyor.
--
-- Sonuç: haberin kapağı doğru ama hikâyesi yanlış. Telefonda hikâye zemini
-- dikey türevi tercih ettiği için fark tam ekranda görünüyor.
--
-- ÖLÇÜM (6 Kasım 2026): 1698 haberin 109'unda dikey türev kapakla
-- uyuşmuyor. Tek bir türev (fa3b8256b814_1080x2340) dört ayrı haberde
-- kullanılıyordu — hepsinin kapağı sonradan değiştirilmişti.
--
-- ÇÖZÜM. Kapak değiştiğinde türevleri NULL'a çekmek. Boş türev, istemcide
-- kapağa düşmek demek: yanlış görsel yerine doğru görselin kendisi
-- gösteriliyor. Hat bir sonraki geçişinde türevleri yeniden üretiyor.
--
-- NEDEN TETİKLEYİCİ, NEDEN PANEL KODU DEĞİL. Kapak üç ayrı yoldan
-- değişebiliyor: yönetim panelinden, geri doldurma betiklerinden ve elle
-- SQL'den. Panele kod yazmak ilk ikisini kaçırırdı; tetikleyici hepsini
-- yakalıyor ve unutulamıyor.

create or replace function public.articles_kapak_degisti()
returns trigger
language plpgsql
as $$
begin
  -- Yalnızca adres GERÇEKTEN değiştiyse. Aynı değerle yapılan bir update
  -- (panelin bütün kaydı yeniden yazması gibi) türevleri düşürmemeli.
  if new.image_url is distinct from old.image_url then
    new.story_image_url := null;
    new.thumb_image_url := null;
    new.image_lqip      := null;
  end if;
  return new;
end;
$$;

drop trigger if exists articles_kapak_turevleri on public.articles;
create trigger articles_kapak_turevleri
  before update of image_url on public.articles
  for each row
  execute function public.articles_kapak_degisti();

comment on function public.articles_kapak_degisti() is
  'Kapak değişince görsel türevlerini düşürür; istemci kapağın kendisine döner.';
