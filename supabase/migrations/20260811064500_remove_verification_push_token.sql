-- Yayın sonrası uçtan uca doğrulama sırasında başsız (headless) bir tarayıcı
-- gerçek bir FCM token'ı kaydetti. Tarayıcı kapandığı için token ölü; tabloda
-- kalırsa her yayında bir başarısız gönderim üretir.
--
-- Token değerinin dosyaya yazılmaması için kayıt zaman aralığıyla siliniyor.
delete from public.push_tokens
where created_at >= timestamptz '2026-08-11 06:37:00+00'
  and created_at <  timestamptz '2026-08-11 06:39:00+00';
