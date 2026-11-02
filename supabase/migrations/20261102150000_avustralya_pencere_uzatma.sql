-- Avustralya penceresi bir gün uzatılıyor — 2 Kasım 2026
--
-- Kullanıcı kararı. Pencere bugün 12:00'de (UTC) kapandı ve ÜLKE RAFI BOŞ
-- KALDI: `active_country_dossier` `ends_at > now()` istiyor, dolayısıyla ana
-- sayfadaki ülke şeridi hiçbir şey göstermiyor.
--
-- Irak (ülke 05) hazırlanıyor ama bugün yayına girecek durumda değil; o gelene
-- kadar rafın boş durmaması için pencere uzatılıyor.
--
-- NEDEN DEVİR DEĞİL: bu bir devir değil, bir UZATMA. Avustralya published
-- kalıyor, arşivlenmiyor, takvime dokunulmuyor. §2.12'nin dört adımı
-- çalışmıyor çünkü yerine geçen bir dosya yok.
--
-- TARİH SABİT YAZILMIYOR: mevcut ends_at'e bir gün ekleniyor. now()+1 gün
-- yazılsaydı pencere 28 günün dışına taşar ve "kaç gün kaldı" rozeti
-- (§8.14.5) kendi hesabıyla çelişirdi.
update public.country_dossiers
   set ends_at    = ends_at + interval '1 day',
       updated_at = now()
 where slug = 'avustralya'
   and tur = 'ulke'
   and status = 'published';

do $$
declare n integer; bitis timestamptz;
begin
  select ends_at into bitis from public.country_dossiers where slug = 'avustralya';
  if bitis is null or bitis <= now() then
    raise exception 'Avustralya penceresi hâlâ kapalı: %', bitis;
  end if;

  -- Ülke rafında tam bir aktif dosya olmalı
  select count(*) into n from public.country_dossiers
   where tur = 'ulke' and status = 'published' and ends_at > now();
  if n <> 1 then
    raise exception 'Ülke rafında % aktif dosya var, 1 olmalı', n;
  end if;

  -- KURUM DİZİSİNE DOKUNULMADI
  if not exists (select 1 from public.country_dossiers
                  where slug = 'dsi' and status = 'published' and ends_at > now()) then
    raise exception 'DSİ etkilendi — bu migration kurum dizisine dokunmamalıydı';
  end if;

  -- Uzatma tam bir gün olmalı: 2 Kasım 12:00 → 3 Kasım 12:00
  if bitis::date <> date '2026-11-03' then
    raise exception 'Yeni bitiş % — 3 Kasım olmalıydı', bitis;
  end if;
end $$;
