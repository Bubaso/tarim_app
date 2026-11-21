-- ════════════════════════════════════════════════════════════════════════
--  Tarladan Paylaşım — paylaşım dikey mi
-- ------------------------------------------------------------------------
--  NEDEN SÜTUN GEREKTİ: oEMBED YALAN SÖYLÜYOR
--
--  Gömme kutusu, YouTube'un en/boy oranını oEmbed yanıtındaki
--  `width`/`height` değerlerinden okuyordu. 20 Kasım 2026'da gerçek bir
--  Shorts ile ölçüldü:
--
--      https://youtube.com/shorts/rVSLAhOnXqw
--      shorts_mu  → True   (yönlendirme sondası, kesin)
--      oEmbed     → 200x113 — yani 16:9, YATAY
--
--  Video dikey ama oEmbed yatay bildiriyor. Orana güvenilemez. Shorts'u
--  16:9 kutuda çizmek demek, videoyu siyah bantların arasına sıkıştırmak
--  demek — köşenin asıl içeriği şahısların dikey tarla videoları olacağı
--  için bu kabul edilemez.
--
--  NASIL DOLUYOR
--    hat   : `cozucu.shorts_mu()` — `youtube.com/shorts/<id>` adresinin
--            Shorts OLMAYAN videoda 303 ile `watch?v=`'ye yönlendirmesine
--            dayanıyor. Anahtar istemiyor, tek istek.
--    panel : yapıştırılan adres `/shorts/` ya da `/reel/` biçimindeyse.
--
--  NULL "yatay" DEMEK DEĞİL, "bilmiyoruz" demek. Görünüm tarafı null'da
--  mecra başına makul varsayıma düşüyor; ölçemediğimizi yatay saymak,
--  ölçümü olmayan bilgiyi veri gibi göstermek olurdu.
-- ════════════════════════════════════════════════════════════════════════

alter table public.paylasim_birimleri
  add column if not exists dikey boolean;

comment on column public.paylasim_birimleri.dikey is
  'Paylaşım dikey mi (Shorts, reel). NULL = ölçülemedi. oEmbed en/boy '
  'değerleri Shorts''ta yanlış geldiği için ayrı tutuluyor.';

-- ─── Doğrulama ──────────────────────────────────────────────────────────
do $$
declare
  n_sutun int;
begin
  select count(*) into n_sutun from information_schema.columns
   where table_schema = 'public'
     and table_name = 'paylasim_birimleri'
     and column_name = 'dikey'
     and data_type = 'boolean'
     and is_nullable = 'YES';   -- NULL "bilmiyoruz" demek; zorunlu olamaz
  if n_sutun <> 1 then
    raise exception 'dikey sütunu yok ya da boolean/nullable değil';
  end if;

  -- Önceki göçün alanı duruyor mu; ikisi birlikte panelin gördüğü veri.
  if not exists (
    select 1 from information_schema.columns
     where table_schema = 'public' and table_name = 'paylasim_birimleri'
       and column_name = 'hat_notu'
  ) then
    raise exception 'hat_notu sütunu kayıp — göç sırası bozulmuş';
  end if;

  raise notice 'Tarladan Paylaşım: dikey eklendi (NULL = ölçülemedi)';
end $$;
