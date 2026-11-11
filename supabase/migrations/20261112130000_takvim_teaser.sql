-- "Yakında" kartına teaser cümlesi — dossier_takvim.teaser_tr / teaser_en
--
-- NEDEN. Kart bugüne kadar üç şey söylüyordu: rozet ("YAKINDA"), sıradaki
-- dosyanın adı ve bir sayaç ("14 gün sonra"). Kullanıcı 12 Kasım 2026'da
-- dördüncüsünü istedi: sıradaki dosyanın NEDEN o gün açıldığını söyleyen kısa
-- bir cümle. İlk kullanımı Türkşeker:
--
--   İlk Türk şekeri 26 Kasım 1926'da Kırklareli'ndeki Alpullu Şeker
--   Fabrikası'nda üretildi — dosya o günün yüzüncü yılında açılıyor.
--
-- Alan ZORUNLU DEĞİL. Boş bırakılan takvim satırının kartı eskisi gibi
-- çiziliyor; çizici boş teaser'ı hiç basmıyor. Yani bu göç yayındaki kartı
-- değiştirmiyor, yalnızca yerini açıyor.
--
-- İSTEMCİ UYUMU İKİ YÖNLÜ GÜVENLİ:
--   · göç uygulanıp istemci dağıtılmazsa → kolon okunmaz, kart aynı kalır
--   · istemci dağıtılıp göç uygulanmazsa → json['teaser_tr'] null, kart
--     teaser'sız çizilir
-- Bu yüzden sıra serbest ve dağıtımı bekletmiyor.

alter table public.dossier_takvim
  add column if not exists teaser_tr text,
  add column if not exists teaser_en text;

-- Kart dar: iki satırdan uzun bir cümle rozetin ve adın altında blok gibi
-- durur, "söz" havasını bozar. Sınır veritabanında, çünkü teaser'ı bir gün
-- panelden yazan biri çizicinin varsayımını bilemez.
alter table public.dossier_takvim
  drop constraint if exists dossier_takvim_teaser_boy;
alter table public.dossier_takvim
  add constraint dossier_takvim_teaser_boy check (
    coalesce(length(teaser_tr), 0) <= 140 and
    coalesce(length(teaser_en), 0) <= 160
  );

comment on column public.dossier_takvim.teaser_tr is
  'Yakında kartındaki kısa gerekçe cümlesi. Boş bırakılabilir; en çok 140 karakter.';
comment on column public.dossier_takvim.teaser_en is
  'Coming-soon card teaser. Optional; 160 characters at most.';

do $kontrol$
begin
  if not exists (select 1 from information_schema.columns
                  where table_schema = 'public' and table_name = 'dossier_takvim'
                    and column_name = 'teaser_tr') then
    raise exception 'teaser_tr kolonu eklenmedi';
  end if;
  if not exists (select 1 from information_schema.columns
                  where table_schema = 'public' and table_name = 'dossier_takvim'
                    and column_name = 'teaser_en') then
    raise exception 'teaser_en kolonu eklenmedi';
  end if;
  -- Kısıt gerçekten çalışıyor mu: 141 karakter reddedilmeli.
  begin
    insert into public.dossier_takvim (tur, ad_tr, ad_en, sira, etkin, teaser_tr)
    values ('kurum', '__kisit_denemesi__', '__x__', 999, false, repeat('a', 141));
    raise exception 'Boy kısıtı çalışmıyor — 141 karakterlik teaser kabul edildi';
  exception
    when check_violation then null;  -- beklenen
  end;
end
$kontrol$;
