-- Irak kapak adresi tırnak içinde kalmıştı — DÜZELTME · 3 Kasım 2026
--
-- HATA BENİM. 20261103110000 göçünde cover_url değeri Python'un json.dumps'ı
-- ile yazıldı. O işlev dizeyi TIRNAK İÇİNE alır; jsonb alanları için doğru,
-- ::text alanları için yanlış. Sonuç: veritabanında adres
--   "https://tarimportali.net/dosya/irak/irak_bataklik_taisir.jpg"
-- biçiminde, yani tırnaklarıyla birlikte duruyordu. Geçersiz bir adres
-- olduğu için kapak görseli hiçbir bekleme süresinde yüklenmedi.
--
-- Bölüm görselleri ETKİLENMEDİ: onlar jsonb olarak yazıldı ve json.dumps
-- orada doğru davranış.
--
-- Nasıl yakalandı: kullanıcı Avustralya kapağının çıktığını, Irak'ınkinin
-- hiç çıkmadığını bildirdi. Dosyalar biçim olarak birebir aynıydı (RGB,
-- progressive, ICC yok); fark veritabanındaki DEĞERDE çıktı.

update public.country_dossiers
   set cover_url    = $g$https://tarimportali.net/dosya/irak/irak_bataklik_taisir.jpg$g$,
       cover_credit = $g$Taisir Mahdi — CC BY-SA 4.0$g$
 where slug = 'irak';

do $kontrol_tirnak$
declare s text;
begin
  select cover_url into s from public.country_dossiers where slug = 'irak';
  if s like '"%' or s like '%"' then
    raise exception 'cover_url hâlâ tırnak içinde: %', s;
  end if;
  if s !~ '^https://' then
    raise exception 'cover_url https ile başlamıyor: %', s;
  end if;
  select cover_credit into s from public.country_dossiers where slug = 'irak';
  if s like '"%' then
    raise exception 'cover_credit tırnak içinde: %', s;
  end if;
  -- Bölüm görsellerinin adresleri de tırnaksız olmalı
  select count(*)::text into s from public.dossier_sections s2
    join public.country_dossiers d on d.id = s2.dossier_id
   where d.slug = 'irak' and s2.gorsel->>'url' not like 'https://%';
  if s <> '0' then raise exception '% bölüm görselinin adresi bozuk', s; end if;
end
$kontrol_tirnak$;
