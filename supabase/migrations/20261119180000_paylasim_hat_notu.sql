-- ════════════════════════════════════════════════════════════════════════
--  Tarladan Paylaşım — toplayıcının editöre bıraktığı bağlam
-- ------------------------------------------------------------------------
--  NEDEN AYRI BİR ALAN, NEDEN `baslik` DEĞİL
--
--  Toplayıcı Google Alerts akışlarını okuyor. Akış her girdi için bir
--  başlık ve özet veriyor — paylaşımın kendi başlığı DEĞİL, Google'ın o
--  sayfadan çıkardığı metin.
--
--  Bu metin editör için değerli: panel kuyruğu gömme değil metin listesi
--  gösteriyor, ve Instagram'da `hesap` da `baslik` da boş geliyor (ölçüldü:
--  Instagram'ın oEmbed'i uygulama kimliği istiyor, biz iframe adresini
--  koddan kuruyoruz). O yüzden Alerts'ten gelen aday panelde yalnız
--  "Instagram" yazısı olarak görünür — hangi paylaşım olduğu anlaşılmaz.
--
--  Ama `baslik` alanına yazılamaz: `baslik` okura çıkan bir alan (mobil
--  künye kartı onu çiziyor). Google'ın özetini paylaşımın kendi başlığıymış
--  gibi göstermek, künyeye kaynağı olmayan bir bilgi koymak olur.
--
--  Bu yüzden ayrı: `hat_notu` YALNIZ PANELDE görünür, köşe sayfası onu hiç
--  okumaz. Yayın yüzeyiyle çalışma yüzeyi ayrı kalsın.
-- ════════════════════════════════════════════════════════════════════════

alter table public.paylasim_birimleri
  add column if not exists hat_notu text;

comment on column public.paylasim_birimleri.hat_notu is
  'Toplayıcının editöre bıraktığı bağlam (ör. Google Alerts başlığı). '
  'YAYINA ÇIKMAZ — yalnız panel kuyruğunda gösterilir.';

-- ─── Doğrulama ──────────────────────────────────────────────────────────
do $$
declare
  n_sutun int;
  n_aciklama int;
begin
  select count(*) into n_sutun from information_schema.columns
   where table_schema = 'public'
     and table_name = 'paylasim_birimleri'
     and column_name = 'hat_notu';
  if n_sutun <> 1 then
    raise exception 'hat_notu sütunu bulunamadı';
  end if;

  -- Açıklama, alanın ne işe yaradığını veritabanında da tutuyor; bir
  -- sonraki okuyan şemaya bakınca yayına çıkmadığını görsün.
  select count(*) into n_aciklama
    from pg_description d
    join pg_class c on c.oid = d.objoid
   where c.relname = 'paylasim_birimleri' and d.objsubid > 0;
  if n_aciklama < 1 then
    raise exception 'hat_notu açıklaması yazılamadı';
  end if;

  -- Toplayıcı 'hat' kaynağıyla yazacak; kısıt bunu zaten kabul ediyor
  -- olmalı, yeni göç gerekmemeli.
  if not exists (
    select 1 from pg_constraint
     where conrelid = 'public.paylasim_birimleri'::regclass
       and pg_get_constraintdef(oid) like '%''hat''%'
  ) then
    raise exception '`kaynak` kısıtı ''hat'' değerini kabul etmiyor';
  end if;

  raise notice 'Tarladan Paylaşım: hat_notu eklendi, kaynak=''hat'' hazır';
end $$;
