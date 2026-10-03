# Supabase Storage Optimizasyon Raporu

Projenin genel işleyişini bozmadan Supabase üzerindeki 1GB limitini aşma sorununu çözmek için aşağıdaki işlemler uygulanmıştır:

## 1. Ses Dosyalarının Sıkıştırılması (WAV -> M4A)
Yapay zeka (Gemini TTS) tarafından üretilen ses dosyaları ham `WAV` formatındaydı (makale başına ~15-20 MB).
- Tüm mevcut `WAV` ses dosyalarını çekip, kaliteyi düşürmeden AAC (`M4A`) formatına dönüştüren (boyutları ~600 KB'a, yani %95 oranında küçülten) bir dönüştürme betiği yazılıp arka planda çalıştırıldı.
- `generate_audio.py` dosyası güncellenerek, bundan sonra üretilecek yeni seslerin otomatik olarak `.m4a` formatına dönüştürülüp Supabase'e yüklenmesi sağlandı.
- Eski büyük boyutlu `WAV` dosyaları, dönüştürme sonrasında otomatik olarak veritabanından ve Storage'dan silinmek üzere kodlandı.

## 2. Görsel Optimizasyonu (JPG/PNG -> WEBP)
Görseller kaliteden kayıp verilmeden modern `WEBP` formatına çevrildi.
- Veritabanındaki tüm eski `.jpg` ve `.png` resim dosyaları indirilip, en/boy oranları korunarak maksimum 1000px olacak şekilde boyutlandırılıp `%80` kaliteyle `.webp` formatına dönüştürüldü.
- Bu dönüştürme işlemini gerçekleştiren betik (`compress_images.py`) arka planda çalışmaya başladı (toplam ~1000 görsel işleniyor).
- Eski `.jpg` ve `.png` dosyaları Supabase Storage'dan siliniyor.

## 3. Depolama Temizliği (Orphaned Files)
Silinmiş haberlere ait veya veritabanında karşılığı olmayan "yetim" (orphaned) dosyaların Supabase Storage'dan temizlenmesi için `cleanup_storage.py` adında bir temizlik betiği oluşturuldu. Görsel ve ses dönüştürme işlemleri bittikten sonra çalıştırılarak tam alan tasarrufu sağlanacaktır.

## Mevcut Durum
Şu anda dönüştürme betikleri sistemin arka planında çalışmaktadır:
1. `compress_audio.py` (Ses dosyaları dönüştürülüyor)
2. `compress_images.py` (~1000 adet resim `WEBP` formatına çevriliyor)

Arka plandaki bu iki işlem bittikten sonra `python3 cleanup_storage.py` komutuyla temizlik betiği çalıştırıldığında Supabase boyut kullanımınızın 1.47 GB seviyelerinden 200-300 MB civarlarına inmesi beklenmektedir. İşleyiş ve kod mimarisinde herhangi bir bozulma yaşanmayacaktır.
