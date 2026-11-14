# Dağıtımdan SONRA uygulanacak göçler

Buradaki dosyalar `supabase/migrations/` içinde **değil** ve olmamalı:
`supabase db push` onları da uygular ve o anda **canlı site kararır**.

## Neden

Flutter derlemesi haber sorgusunda sütunları ADLARIYLA istiyor
(`home_repository.dart`, `_listeSutunlari`). PostgREST olmayan bir sütun
istendiğinde satır döndürmüyor, **hata** veriyor:

    column articles.publish_at does not exist   (42703)

Yani bir sütunu düşürmek, o sütunu isteyen derleme hâlâ yayındayken
siteyi tamamen durdurur — tek bir haber bile yüklenmez. Ölçüldü:
`tarimportali.net/main.dart.js` içinde `audio_url`, `is_radio` ve
`publish_at` geçiyor.

## Doğru sıra

1. `./deploy.sh` ile yeni derlemeyi yayına al. Yeni derleme bu sütunları
   artık istemiyor.
2. Siteyi aç, bir haber yüklendiğini gör.
3. Dosyayı `supabase/migrations/` içine taşı ve `supabase db push` çalıştır.

Ters sırada yapılırsa site, göç ile dağıtım arasındaki süre boyunca kapalı
kalır.

## Bekleyen

Şu an bekleyen göç yok.

## Geçmiş

- `20261115150000_ses_ozelligi_kaldirildi.sql` — ses sütunları ve
  kullanılmayan `publish_at`. **15 Kasım 2026'da doğru sırayla uygulandı:**
  önce dağıtım yapıldı, canlının yeni derlemesinin artık o sütunları
  istemediği `main.dart.js` içinde arama yapılarak doğrulandı (audio_url 0,
  is_radio 0, publish_at 0 eşleşme), sonra göç uygulandı ve ana sayfa
  yeniden sınandı. Göç `supabase/migrations/` altına taşındı.
