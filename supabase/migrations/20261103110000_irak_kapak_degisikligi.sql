-- Irak kapağı değişti — ÖLÇÜLEREK · 3 Kasım 2026
--
-- İlk kapak NASA'nın Irak uydu karesiydi. Canlıda BOZUK GÖRÜNDÜ: görsel
-- yükleniyordu (200, content-type image/*) ama kare çok düşük kontrastlı —
-- 5-95 persentil aralığı 60 ton, dosyanın öteki karelerinde 142-154. Kapağın
-- %0→%85 karartma gradyanıyla birlikte gri bir yıkamaya dönüşüyordu.
-- Kontrastı 2-98 persentilden gerilerek kurtarılmaya çalışıldı; std 20,9'dan
-- 62,5'e çıktı ama görüntü sahte renklere kaydı ve uydu fotoğrafı olmaktan
-- çıktı. Germe geri alındı.
--
-- Uydu karesi 18. bölüme (Kaynakça) taşındı — orada gradyan yok. Kapak
-- dosyanın tek geri dönüş hikâyesinden: bataklıkta sazdan ev, iki manda,
-- kıyıda kayık. Bölüm görselleri 11 → 17 → 18 boyunca kaydırıldı.
--
-- TÜM SEED YENİDEN ÇALIŞTIRILMADI: seed'in `on conflict do update` bloğu
-- status = excluded.status yazıyor ve excluded 'draft' taşıyor; dosyayı
-- yayından düşürürdü. Bu göç yalnız görselleri değiştiriyor.

update public.country_dossiers
   set cover_url    = $g$"https://tarimportali.net/dosya/irak/irak_bataklik_taisir.jpg"$g$::text,
       cover_credit = $g$"Taisir Mahdi — CC BY-SA 4.0"$g$::text
 where slug = 'irak';

update public.dossier_sections s set gorsel = $g${"url": "https://tarimportali.net/dosya/irak/irak_bataklik_mashoof.jpg", "atif": "Hassan Janali, U.S. Army Corps of Engineers — Public domain", "lisans": "Public domain", "alt_tr": "Sazların arasındaki dar su yolunda uzun bir kayık; biri ayakta sırıkla, biri oturarak kürek çekiyor.", "alt_en": "A long boat on a narrow channel between reeds; one person poles standing, another paddles seated.", "en_boy": 1.3662, "_commons": "https://commons.wikimedia.org/wiki/File:Marsh_Arabs_in_a_mashoof.jpg", "_gozle_dogrulandi": true}$g$::jsonb
  from public.country_dossiers d
 where s.dossier_id = d.id and d.slug = 'irak' and s.ord = 11;
update public.dossier_sections s set gorsel = $g${"url": "https://tarimportali.net/dosya/irak/irak_manda.jpg", "atif": "Adnan S mohmmod — CC BY-SA 4.0", "lisans": "CC BY-SA 4.0", "alt_tr": "Nehir kıyısındaki toprak sette duran manda sürüsü; birkaçı suya inmiş.", "alt_en": "A herd of water buffalo on an earth bank by the river, a few of them down at the water.", "en_boy": 1.6054, "_commons": "https://commons.wikimedia.org/wiki/File:River_buffalo.jpg", "_gozle_dogrulandi": true}$g$::jsonb
  from public.country_dossiers d
 where s.dossier_id = d.id and d.slug = 'irak' and s.ord = 17;
update public.dossier_sections s set gorsel = $g${"url": "https://tarimportali.net/dosya/irak/irak_kapak_uydu.jpg", "atif": "NASA — Public domain", "lisans": "Public domain", "alt_tr": "Uydudan Irak: açık kahverengi çöl ve içinden geçen ince yeşil şerit — Dicle ile Fırat'ın suladığı ova.", "alt_en": "Iraq from orbit: pale brown desert crossed by a thin green ribbon — the plain watered by the Tigris and the Euphrates.", "en_boy": 0.9632, "_commons": "https://commons.wikimedia.org/wiki/File:Satellite_image_of_Iraq_in_August_2003.jpg", "_gozle_dogrulandi": true}$g$::jsonb
  from public.country_dossiers d
 where s.dossier_id = d.id and d.slug = 'irak' and s.ord = 18;

do $kontrol_kapak$
declare n integer; s text;
begin
  select cover_url into s from public.country_dossiers where slug = 'irak';
  if s not like '%irak_bataklik_taisir%' then
    raise exception 'Kapak değişmedi: %', s;
  end if;
  -- Dosya YAYINDA KALMALI — bu göç devri bozmaz
  select status into s from public.country_dossiers where slug = 'irak';
  if s is distinct from 'published' then
    raise exception 'Irak yayından düştü: %', s;
  end if;
  -- Her bölümde hâlâ görsel var
  select count(*) into n from public.dossier_sections s2
    join public.country_dossiers d on d.id = s2.dossier_id
   where d.slug = 'irak' and (s2.gorsel is null or s2.gorsel->>'url' is null);
  if n > 0 then raise exception '% bölümün görseli yok', n; end if;
  -- 18. bölüm artık uydu karesi
  select s2.gorsel->>'url' into s from public.dossier_sections s2
    join public.country_dossiers d on d.id = s2.dossier_id
   where d.slug = 'irak' and s2.ord = 18;
  if s not like '%irak_kapak_uydu%' then
    raise exception '18. bölümün görseli uydu karesi değil: %', s;
  end if;
end
$kontrol_kapak$;
