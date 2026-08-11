-- RLS düzeltmesini doğrulamak için elle eklenen sahte kaydı siler.
-- Tabloda kalırsa her yayında bir başarısız FCM gönderimi üretirdi.
-- anon rolüne DELETE yetkisi verilmediği için temizlik migration ile yapılıyor.
delete from public.push_tokens where platform in ('diagnostic', 'diagnostic2');
