-- İş kuyruğuna HEDEF alanı — 15 Kasım 2026
--
-- `agent_jobs` şimdiye kadar tek tür iş taşıyordu: "haber çek". Artık ikinci
-- bir tür var — tek bir haberin eksik görsel türevlerini üretmek — ve o işin
-- hangi haber için olduğu yazılmalı.
--
-- Neden panelden yapılamıyor: görseli indirip yeniden boyutlandırmak ve
-- depoya yazmak sunucu işi. Panel işi kuyruğa yazıyor, Mac'teki dinleyici
-- çalıştırıyor.
alter table public.agent_jobs
  add column if not exists hedef text;

comment on column public.agent_jobs.hedef is
  'İşin hedefi — tür gerektiriyorsa. gorsel_turev için haber kimliği.';
