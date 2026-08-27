-- Yaklaşan dosyalar — arşivdeki "Yakında" kartları.
--
-- NEDEN AYRI TABLO. Yaklaşan dosyayı `country_dossiers`'a `status='scheduled'`
-- satırı olarak koymak ilk akla gelen yol ama iki sorunu var: (1) o tablo
-- gövde metni, tema ve veri sayfası bekliyor — Ziraat Bankası dosyası daha
-- yazılmadı, uydurma bir satır açmak gerekirdi; (2) RLS yalnızca published ve
-- archived'ı anon'a açıyor, scheduled'ı açmak yarım yazılmış dosyaların
-- adres tahminiyle okunabilmesi demek olurdu.
--
-- Burada duran şey bir dosya değil, bir SÖZ: sıradaki başlık ve dizisi.
-- İçerik yok, okunacak bir metin yok.
create table if not exists public.dossier_takvim (
  id      bigserial primary key,
  -- 'ulke' | 'kurum'. Hangi dizinin sırasında.
  tur     text not null check (tur in ('ulke', 'kurum')),
  ad_tr   text not null,
  ad_en   text not null,
  -- Sıradaki kaçıncı. Aynı dizide birden fazla söz varsa en küçüğü önce.
  sira    integer not null default 1,
  -- Gösterilmeyi bekliyor mu. Dosya yayına girince satır silinmek yerine
  -- kapatılıyor; takvimin geçmişi kayıtta kalsın.
  etkin   boolean not null default true,
  created_at timestamptz not null default now(),
  unique (tur, sira)
);

alter table public.dossier_takvim enable row level security;

drop policy if exists "anon can read takvim" on public.dossier_takvim;
create policy "anon can read takvim"
  on public.dossier_takvim for select
  to anon, authenticated
  using (etkin);

comment on table public.dossier_takvim is
  'Yaklaşan dosya başlıkları. İçerik taşımaz; arşivdeki "Yakında" kartı budur. '
  'Geri sayım bu tablodan gelmez — yayındaki dosyanın penceresinden hesaplanır.';

insert into public.dossier_takvim (tur, ad_tr, ad_en, sira) values
  ('kurum', 'Ziraat Bankası', 'Ziraat Bankası', 1),
  ('ulke',  'Rusya',          'Russia',         1)
on conflict (tur, sira) do update set
  ad_tr = excluded.ad_tr,
  ad_en = excluded.ad_en,
  etkin = true;
