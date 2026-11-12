# Ham kaynaklar depoda tutulmuyor

Dosya çalışmalarının ham kaynakları — PDF'ler, ZIP'ler, yüksek çözünürlüklü
fotoğraflar — 12 Kasım 2026'da git izlemesinden çıkarıldı. **Dosyalar
silinmedi**, diskte oldukları yerde duruyorlar; yalnızca git artık onları
takip etmiyor.

## Neden

`.git` 581 MB'a çıkmıştı ve push'lar zaman aşımına uğramaya başladı: 12 Kasım
2026'da sıradan bir commit'in gönderimi HTTP 408 verdi, ancak
`http.postBuffer` 500 MB'a çıkarılarak geçti. Bu her push'ta tekrarlayacak bir
sorundu.

İzlemeden çıkarılan: **177 dosya, 464 MB.**
Depoda kalan: künye ve veri JSON'ları, betikler (145 dosya, 23,6 MB).

Kalanların kalması bilinçli: `kunye.json` görselin atfını ve lisansını,
veri JSON'ları `_kaynak_adresi` ve `_ham_dosya` alanlarını taşıyor. Yani ham
dosya yeniden indirildiğinde nereye ait olduğu ve doğru dosya olup olmadığı
depodan anlaşılabiliyor.

## Kayıt

`ham_kaynaklar.json` her dosya için yol, bayt, **sha256** ve bulunabildiği
yerde kaynak adresini taşıyor.

- Kaynak adresi bulunan: 96 dosya (195 MB) — çoğu Wikimedia Commons görseli,
  künyesinde `commons_sayfasi`, `atif`, `lisans` yazılı.
- Kaynak adresi **bulunamayan**: 81 dosya (269 MB) — DSİ istatistikleri,
  Ziraat faaliyet raporları, FAO verileri gibi kamuya açık belgeler. Hepsi
  bulunabilir belgeler ama indirildikleri adres depoya hiç yazılmamış.
  Yeni bir ham kaynak eklenirken adresini de yazmak bu boşluğu büyütmez.

## Yedek

İzlemeden çıkarılmadan önce 177 dosyanın tamamı
`~/tarim_ham_kaynaklar/` altına, depo içindeki yollarıyla kopyalandı.
Sebebi: depo iCloud dışında, yani git'ten çıkan dosyanın tek kopyası diskte
kalıyordu. Yedek, `git clean` ya da taze bir klon durumunda kaybı önlüyor.
Diskin kendisine karşı koruma değil.

## Bilinmesi gereken

`git rm --cached` **geçmişi küçültmez.** Eski blob'lar `.git` içinde duruyor;
581 MB bugün olduğu gibi kalıyor. Küçültmek geçmişi yeniden yazmak
(`filter-repo` + force-push) demek ve bu yapılmadı — ortak bir depoda
geçmişi yeniden yazmak, üzerinde çalışan herkesin klonunu bozar.

Kazanç ileriye dönük: bundan sonraki push'lar bu 464 MB'ı taşımıyor.

## Yeni ham kaynak eklerken

1. Dosyayı `_raw/` altına koy — git zaten yoksayacak.
2. Künyesine **adresini** yaz (görselse `kunye.json`, veriyse ilgili JSON'un
   `_kaynak_adresi` alanı).
3. `ham_kaynaklar.json`'u güncelle (yol, bayt, sha256, adres).
4. `~/tarim_ham_kaynaklar/` altına kopyala.
