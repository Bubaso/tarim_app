-- `agent_jobs` üzerindeki ESKİ politikalar adlarıyla aranıp bulunamamıştı:
-- bir önceki göç varsaydığı adları düşürdü ("does not exist, skipping"),
-- ama tabloda başka adlı, anon'a izin veren bir politika duruyordu — göçten
-- sonra da anon 12 satırı okumaya devam etti.
--
-- Ad tahmin etmek yerine tablodaki politikaların TAMAMI süpürülüyor, sonra
-- tek doğru politika kuruluyor. Aynısı günlük ve dinleyici tabloları için de.
do $$
declare p record;
begin
  for p in
    select policyname, tablename
    from pg_policies
    where schemaname = 'public'
      and tablename in ('agent_jobs', 'live_terminal_logs', 'dinleyici_durumu')
  loop
    execute format('drop policy %I on public.%I', p.policyname, p.tablename);
  end loop;
end $$;

create policy "panel isleri okur" on public.agent_jobs
  for select to authenticated using (true);
create policy "panel is yazar" on public.agent_jobs
  for insert to authenticated with check (true);
create policy "panel gunlugu okur" on public.live_terminal_logs
  for select to authenticated using (true);
create policy "panel dinleyiciyi okur" on public.dinleyici_durumu
  for select to authenticated using (true);
