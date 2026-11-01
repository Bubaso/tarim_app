-- TAGEM arşive alınıyor — 30 Ekim 2026
--
-- Penceresi 13 Ekim'de KENDİLİĞİNDEN kapandı ve dosya o gün ana sayfadan
-- düştü (`active_country_dossier` `ends_at > now()` istiyor). Ama durumu hâlâ
-- `published` kalmıştı: devir yapılmadığı için §2.12/2'deki ikinci adım hiç
-- çalışmadı.
--
-- NEDEN ÖNEMLİ. `dosya_hikayeleri.py` pencereye DEĞİL `status = 'published'`
-- alanına bakıyor; arşivlenmeyen dosya ana sayfada hikâye baloncuğu üretmeye
-- devam edebilir. Şu an üretmiyor — çünkü TAGEM'in kaynak klasörü 4 Ekim'deki
-- kayıpta gitti ve betik `hikaye` bloğunu bulamayıp dosyayı atlıyor. Yani
-- bizi kazara koruyan şey başka bir kayıp. Durum alanı doğru olmalı.
--
-- ends_at'e DOKUNULMUYOR. §2.12 devirde `ends_at = now()` yazdırıyor, çünkü
-- orada pencere ERKEN kapatılıyor. Burada pencere zamanında kapandı; bugünün
-- tarihini yazmak dosyanın on yedi gün daha yayında kalmış gibi görünmesine
-- yol açardı. Kayıt olduğu gibi kalıyor: 29 Eylül → 13 Ekim.
--
-- Arşive düşen dosya kaybolmuyor: country_dossier_index, dosya_haberleri ve
-- haber_dosyalari üçü de `archived`'ı kabul ediyor (§2.12).

update public.country_dossiers
   set status     = 'archived',
       updated_at = now()
 where slug = 'tagem'
   and status = 'published';

do $$
declare n integer; s text;
begin
  if not exists (select 1 from public.country_dossiers
                  where slug = 'tagem' and status = 'archived') then
    raise exception 'TAGEM arşivlenmedi';
  end if;

  -- Penceresi korunmuş olmalı.
  if exists (select 1 from public.country_dossiers
              where slug = 'tagem' and ends_at::date <> date '2026-10-13') then
    raise exception 'TAGEM penceresi değişmiş — ends_at korunmalıydı';
  end if;

  -- Kurum dizisinde artık yayında dosya kalmamalı (DSİ henüz hazır değil).
  select count(*) into n from public.country_dossiers
   where tur = 'kurum' and status = 'published';
  if n <> 0 then
    raise exception 'Kurum dizisinde hâlâ % yayında dosya var', n;
  end if;

  -- ÜLKE DİZİSİNE DOKUNULMADIĞI kanıtlanıyor (§8.14.4'ün sağlaması).
  select slug into s from public.active_country_dossier where tur = 'ulke';
  if s is distinct from 'avustralya' then
    raise exception 'Ülke dizisinin aktifi değişmiş: %', s;
  end if;
end $$;
