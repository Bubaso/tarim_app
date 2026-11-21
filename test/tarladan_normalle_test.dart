import 'package:flutter_test/flutter_test.dart';
import 'package:tarim_app/features/tarladan_paylasim/data/gomme_cozucu.dart';
import 'package:tarim_app/features/tarladan_paylasim/data/paylasim_modelleri.dart';

// ══════════════════════════════════════════════════════════════════════════
//  Bağlantı kanonikleştirme — paylasim_birimleri.url tekilliğinin bekçisi
// ──────────────────────────────────────────────────────────────────────────
//  Şemadaki `url text not null unique` İKİ İŞ yapıyor: aynı paylaşım iki kez
//  giremiyor VE reddedilmiş bir paylaşım ikinci taramada geri gelemiyor.
//  İkisi de yalnız aynı paylaşımın HER ZAMAN aynı metne indirgenmesiyle
//  çalışır.
//
//  Aşağıdaki tablo `src/sosyal/cozucu.py` içindeki `normalle()` ile AYNI.
//  İkisi ayrışırsa panel (Dart) ile hat (Python) farklı metin yazar ve
//  tekillik sessizce kırılır: Alerts'ten gelen `/reel/<kod>/` ile panele
//  yapıştırılan `/p/<kod>/` iki ayrı satır olur.
// ══════════════════════════════════════════════════════════════════════════

void main() {
  group('normalle — aynı paylaşım tek metne iniyor', () {
    test('Instagram: p, reel ve tv aynı yere iniyor', () {
      const beklenen = 'https://www.instagram.com/p/Df640PQyKan/';
      for (final girdi in [
        'https://www.instagram.com/p/Df640PQyKan/',
        'https://www.instagram.com/reel/Df640PQyKan/',
        'https://www.instagram.com/tv/Df640PQyKan/?utm_source=ig_web',
        'https://instagram.com/p/Df640PQyKan/',
        '  https://www.instagram.com/reel/Df640PQyKan/  ',
      ]) {
        expect(GommeCozucu.normalle(girdi), beklenen, reason: girdi);
      }
    });

    test('X: twitter.com ve izleme kuyruğu eleniyor', () {
      const beklenen = 'https://x.com/jack/status/20';
      for (final girdi in [
        'https://x.com/jack/status/20',
        'https://twitter.com/jack/status/20',
        'https://twitter.com/jack/status/20?s=20',
        'https://www.x.com/jack/status/20',
      ]) {
        expect(GommeCozucu.normalle(girdi), beklenen, reason: girdi);
      }
    });

    test('YouTube: watch, youtu.be ve shorts aynı yere iniyor', () {
      const beklenen = 'https://www.youtube.com/watch?v=dQw4w9WgXcQ';
      for (final girdi in [
        'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
        'https://www.youtube.com/watch?v=dQw4w9WgXcQ&t=10s',
        'https://youtu.be/dQw4w9WgXcQ',
        'https://www.youtube.com/shorts/dQw4w9WgXcQ',
      ]) {
        expect(GommeCozucu.normalle(girdi), beklenen, reason: girdi);
      }
    });

    test('TikTok: izleme kuyruğu eleniyor', () {
      const beklenen = 'https://www.tiktok.com/@tiktok/video/6718335390845095173';
      for (final girdi in [
        'https://www.tiktok.com/@tiktok/video/6718335390845095173',
        'https://www.tiktok.com/@tiktok/video/6718335390845095173?is_from_webapp=1&sender_device=pc',
      ]) {
        expect(GommeCozucu.normalle(girdi), beklenen, reason: girdi);
      }
    });

    test('tanınmayan adres olduğu gibi kalıyor', () {
      // Kanonikleştirme tanımadığı şeyi uydurmuyor; `coz()` zaten reddedecek.
      const yabanci = 'https://ornek.com/bir-sayfa';
      expect(GommeCozucu.normalle(yabanci), yabanci);
      expect(GommeCozucu.normalle(''), '');
    });

    test('kanonik biçim kendi kendinin sabit noktası', () {
      // İki kez uygulamak sonucu değiştirmemeli; yoksa aynı paylaşım
      // hattın kaçıncı turundan geçtiğine göre farklı metin alır.
      for (final girdi in [
        'https://www.instagram.com/reel/Df640PQyKan/',
        'https://twitter.com/jack/status/20?s=20',
        'https://youtu.be/dQw4w9WgXcQ',
        'https://www.tiktok.com/@tiktok/video/6718335390845095173?x=1',
      ]) {
        final bir = GommeCozucu.normalle(girdi);
        expect(GommeCozucu.normalle(bir), bir, reason: girdi);
      }
    });
  });

  group('hat_notu — toplayıcının bıraktığı bağlam', () {
    test('modele okunuyor', () {
      final b = PaylasimBirimi.fromJson({
        'id': 'a',
        'durum': 'bekliyor',
        'mecra': 'instagram',
        'url': 'https://www.instagram.com/p/Df4Xj7qo5wk/',
        'kaynak': 'hat',
        'eklendi': '2026-11-19T18:00:00Z',
        'hat_notu': '[INSTAGRAM] Ekrem Çiftçi İlkokulu — İHALE TARİHİ',
      });
      expect(b.hatNotu, contains('İHALE TARİHİ'));
      // `baslik` İLE KARIŞMIYOR. Biri paylaşımın kendi künyesi, öteki
      // akışın o sayfadan çıkardığı metin; panel ikisini ayrı gösteriyor,
      // köşe sayfası hat_notu'yu hiç okumuyor.
      expect(b.baslik, isNull);
      expect(b.gorunenAd, 'Instagram');
    });

    test('alan yoksa null, satır yine kuruluyor', () {
      // Göç uygulanmadan önce yazılmış satırlar böyle geliyor.
      final b = PaylasimBirimi.fromJson({
        'id': 'a',
        'durum': 'bekliyor',
        'mecra': 'x',
        'url': 'https://x.com/jack/status/20',
        'kaynak': 'elle',
        'eklendi': '2026-11-19T18:00:00Z',
      });
      expect(b.hatNotu, isNull);
      expect(b.kaynak, 'elle');
    });
  });

  group('dikey — Shorts geometrisi', () {
    test('ölçülmüş değer oEmbed oranını yener', () {
      // 20 Kasım 2026'da ölçüldü: gerçek bir Shorts'ta oEmbed 200x113,
      // yani 16:9 bildiriyor. Orana güvenilemez; ölçülmüş alan kazanmalı.
      final b = PaylasimBirimi.fromJson({
        'id': 'a', 'durum': 'bekliyor', 'mecra': 'youtube',
        'url': 'https://www.youtube.com/watch?v=rVSLAhOnXqw',
        'kaynak': 'hat', 'eklendi': '2026-11-20T09:00:00Z',
        'gomme_html': '<iframe width="200" height="113" src="x"></iframe>',
        'dikey': true,
      });
      expect(b.gommeOrani, closeTo(1.77, 0.01)); // oEmbed yatay diyor
      expect(b.dikeyCiz, isTrue);                // ölçüm dikey diyor
    });

    test('ölçüm yoksa gömme oranına düşülüyor', () {
      final yatay = PaylasimBirimi.fromJson({
        'id': 'a', 'durum': 'bekliyor', 'mecra': 'youtube',
        'url': 'https://www.youtube.com/watch?v=x',
        'kaynak': 'elle', 'eklendi': '2026-11-20T09:00:00Z',
        'gomme_html': '<iframe width="200" height="113" src="x"></iframe>',
      });
      expect(yatay.dikeyCiz, isFalse);

      // TikTok'ta oran doğru geliyor — orada geri düşüş işe yarıyor.
      final dik = PaylasimBirimi.fromJson({
        'id': 'b', 'durum': 'bekliyor', 'mecra': 'tiktok',
        'url': 'https://www.tiktok.com/@a/video/1',
        'kaynak': 'elle', 'eklendi': '2026-11-20T09:00:00Z',
        'gomme_html': '<iframe width="325" height="575" src="x"></iframe>',
      });
      expect(dik.dikeyCiz, isTrue);
    });

    test('hiçbir ipucu yoksa yatay varsayılıyor', () {
      final b = PaylasimBirimi.fromJson({
        'id': 'a', 'durum': 'bekliyor', 'mecra': 'instagram',
        'url': 'https://www.instagram.com/p/abc/',
        'kaynak': 'elle', 'eklendi': '2026-11-20T09:00:00Z',
      });
      expect(b.gommeOrani, isNull);
      expect(b.dikeyCiz, isFalse);
    });
  });

  group('mecrayiTani', () {
    test('dört mecra tanınıyor, yabancı adres tanınmıyor', () {
      expect(GommeCozucu.mecrayiTani('https://x.com/a/status/1'), 'x');
      expect(GommeCozucu.mecrayiTani('https://youtu.be/abc'), 'youtube');
      expect(GommeCozucu.mecrayiTani('https://www.tiktok.com/@a/video/1'),
          'tiktok');
      expect(GommeCozucu.mecrayiTani('https://www.instagram.com/reel/abc/'),
          'instagram');
      expect(GommeCozucu.mecrayiTani('https://ornek.com/x'), isNull);
      // Profil adresi paylaşım adresi değil.
      expect(GommeCozucu.mecrayiTani('https://www.instagram.com/kevin/'), isNull);
    });
  });
}
