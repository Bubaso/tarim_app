-- Doğrulama sırasında yazılan tıklama kayıtlarını sil.
--
-- `log_notification_click` fonksiyonunun canlıda gerçekten çalıştığını
-- kanıtlamanın tek yolu onu bir kez çağırmaktı. Bıraktığı satırlar tür bazlı
-- dönüşüm oranının ilk okumasını şişirirdi: defter şu an boş olduğu için tek
-- bir sahte tıklama bile 'breaking' türünün oranını görünür biçimde bozar.
--
-- Yol sabit ve bize ait olduğu için silme nokta atışı; gerçek bir tıklama
-- kaydına dokunmuyor.
delete from public.notification_click
 where path = '/haber/test-dogrulama';
