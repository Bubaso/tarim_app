-- ══════════════════════════════════════════════════════════════════════════
--  Yapay Zeka ve Dijital Tarım — onaylanan Türkiye dizini kayıtları okura
--  (karar 38: "Türkiye dizini otomatik güncellenen")
-- ──────────────────────────────────────────────────────────────────────────
--  Haber hattı (tarim_ai_pipeline: src/utils/yz_bolumu.py) haberde adı geçen
--  Türkiye kuruluşunu `bekleyen_guncellemeler`e 'dizin_adayi' olarak önerir.
--  Editör panelde onaylarsa kayıt §25'in "Dizine sonradan eklenenler"
--  listesine girer; panelin "Dizinde" sekmesinden tek tıkla çıkarılır.
--  Onaysız hiçbir kayıt okura görünmez (karar 17).
--
--  Kuyruk tablosu okura KAPALI kalır (karar notu, karar veren, ham öneriler).
--  Okur yalnız bu fonksiyonun döndürdüğü alanları görür: kuruluşun adı ve
--  türü, eklenme tarihi ve — yayındaysa — adının geçtiği haber.
--
--  UYGULAMA: kullanıcının açık onayıyla. Uygulanmadan önce okur tarafı
--  (YzDeposu.dizinEklenenler) boş liste döndürür; sayfa bozulmaz.
-- ══════════════════════════════════════════════════════════════════════════

create or replace function public.yz_dizin_eklenenler()
returns table (
  id              uuid,
  ad              text,
  tur             text,
  eklendi         timestamptz,
  haber_id        uuid,
  haber_baslik    text,
  haber_baslik_en text,
  haber_tarih     timestamptz
)
language sql
stable
security definer
set search_path = public
as $$
  select g.id,
         btrim(g.icerik->>'ad'),
         g.icerik->>'tur',
         coalesce(g.karar_at, g.created_at),
         a.id,
         a.title,
         a.title_en,
         coalesce(a.published_at, a.created_at)
    from public.bekleyen_guncellemeler g
    left join public.articles a
      on a.id = g.article_id
     and a.status = 'published'          -- yayında olmayan haber gösterilmez
   where g.bolum = 'yapay-zeka-dijital-tarim'
     and g.tur   = 'dizin_adayi'
     and g.durum = 'onaylandi'
     and coalesce(btrim(g.icerik->>'ad'), '') <> ''
   order by coalesce(g.karar_at, g.created_at) desc
   limit 200;
$$;

revoke all on function public.yz_dizin_eklenenler() from public;
grant execute on function public.yz_dizin_eklenenler() to anon, authenticated;

comment on function public.yz_dizin_eklenenler() is
  'Onaylanan Türkiye dizini kayıtları (karar 38) — yalnız okura açık alanlar.';
