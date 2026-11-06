-- Tahmin slaytı: "kaç kişi bildi" sayacı
--
-- NEDEN SUNUCUDA. 6 Kasım 2026 denetimi (Ö5): bazı kartlarda rakam hemen
-- gösterilmeyip okura sorulacak. Cevabı açarken "okurların %38'i bildi"
-- demek, soruyu bir bilgiden bir DENEYİME çeviriyor — ama bu sayı
-- paylaşılan bir durum; cihazda tutulamaz.
--
-- KİŞİ KAYDEDİLMİYOR. Tabloda yalnız iki sayaç var: kaç cevap geldi, kaçı
-- doğruydu. Kim olduğu, ne zaman cevapladığı, hangi cihazdan geldiği
-- tutulmuyor. Aynı okurun iki kez oy vermesi cihazdaki defterle
-- engelleniyor; sunucu tarafında engellemek kimlik tutmayı gerektirirdi ve
-- bir hikâye sayacı o bedele değmez.

create table if not exists public.story_guess_stats (
  story_id    uuid    not null,
  slide_index integer not null,
  toplam      integer not null default 0,
  dogru       integer not null default 0,
  updated_at  timestamptz not null default now(),
  primary key (story_id, slide_index)
);

comment on table public.story_guess_stats is
  'Tahmin slaytının toplu sonucu. Kişi bilgisi TUTULMAZ — yalnız iki sayaç.';

alter table public.story_guess_stats enable row level security;

-- Okuma herkese açık: yüzdeyi göstermek için gerekli.
drop policy if exists "tahmin okunabilir" on public.story_guess_stats;
create policy "tahmin okunabilir"
  on public.story_guess_stats for select
  using (true);

-- Yazma YALNIZCA aşağıdaki fonksiyonla. Doğrudan insert/update açık
-- bırakılsaydı sayaç istenen değere yazılabilirdi.
-- (Politika yok = yazma kapalı; fonksiyon security definer ile yazıyor.)

create or replace function public.hikaye_tahmin_kaydet(
  p_story_id uuid,
  p_slayt    integer,
  p_dogru    boolean
)
returns table (toplam integer, dogru integer)
language plpgsql
security definer
set search_path = public
as $$
begin
  -- Tek deyim: iki ayrı okuma-yazma turu olsaydı eşzamanlı cevaplar
  -- birbirinin üstüne yazardı.
  insert into public.story_guess_stats as s (story_id, slide_index, toplam, dogru)
  values (p_story_id, p_slayt, 1, case when p_dogru then 1 else 0 end)
  on conflict (story_id, slide_index) do update
    set toplam = s.toplam + 1,
        dogru  = s.dogru + case when p_dogru then 1 else 0 end,
        updated_at = now();

  return query
    select s.toplam, s.dogru
    from public.story_guess_stats s
    where s.story_id = p_story_id and s.slide_index = p_slayt;
end;
$$;

revoke all on function public.hikaye_tahmin_kaydet(uuid, integer, boolean) from public;
grant execute on function public.hikaye_tahmin_kaydet(uuid, integer, boolean) to anon, authenticated;
