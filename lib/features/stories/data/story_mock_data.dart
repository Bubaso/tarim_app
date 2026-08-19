import 'models/story_item.dart';

final List<StoryGroup> mockStories = [
  StoryGroup(
    id: 's1',
    title: 'Piyasa Özeti',
    avatarUrl: 'https://images.unsplash.com/photo-1600880292203-757bb62b4baf?w=400&q=80',
    isNew: true,
    items: [
      const StoryItem(
        id: 's1_1',
        superTitle: 'GÜNLÜK PİYASA',
        headline: 'Küresel buğday fiyatlarında Karadeniz gerilimi kaynaklı sert yükseliş',
        bigStatValue: '+%4.2',
        statLabel: 'Chicago Borsası (CBOT) Günlük Artış',
        backgroundUrl: 'https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?w=1200&q=80',
      ),
      const StoryItem(
        id: 's1_2',
        superTitle: 'GİRDİ MALİYETLERİ',
        headline: 'Üre gübresi uluslararası piyasalarda düşüş eğilimini sürdürüyor',
        bigStatValue: '-\$15',
        statLabel: 'Ton başına haftalık azalış',
        backgroundUrl: 'https://images.unsplash.com/photo-1625246333195-78d9c38ad449?w=1200&q=80',
      ),
    ],
  ),
  StoryGroup(
    id: 's2',
    title: 'İklim & Kuraklık',
    avatarUrl: 'https://images.unsplash.com/photo-1541818222956-613d9dd839d4?w=400&q=80',
    isNew: true,
    items: [
      const StoryItem(
        id: 's2_1',
        superTitle: 'FAO KÜRESEL RAPOR',
        headline: 'El Niño etkisiyle Güney Yarımküre\'de tarımsal rekolte alarm veriyor',
        bigStatValue: '12%',
        statLabel: 'Beklenen Küresel Üretim Kaybı',
        backgroundUrl: 'https://images.unsplash.com/photo-1541818222956-613d9dd839d4?w=1200&q=80',
      ),
      const StoryItem(
        id: 's2_2',
        superTitle: 'SU KRİZİ',
        headline: 'İç Anadolu baraj doluluk oranları son 5 yılın en düşük seviyesinde',
        bigStatValue: '%32.4',
        statLabel: 'Güncel Ortalama Doluluk',
        backgroundUrl: 'https://images.unsplash.com/photo-1444201983204-c43cbd584d93?w=1200&q=80',
      ),
    ],
  ),
  StoryGroup(
    id: 's3',
    title: 'TMO Alımları',
    avatarUrl: 'https://images.unsplash.com/photo-1621501103258-3e1346be76e2?w=400&q=80',
    isNew: false,
    items: [
      const StoryItem(
        id: 's3_1',
        superTitle: 'HASAT 2024',
        headline: 'Toprak Mahsulleri Ofisi yeni sezon hububat alım fiyatlarını açıkladı',
        bigStatValue: '9.25₺',
        statLabel: 'Makarnalık Buğday Başlangıç Fiyatı',
        backgroundUrl: 'https://images.unsplash.com/photo-1599839619722-39751411ea63?w=1200&q=80',
      ),
    ],
  ),
];
