-- Turkuaz Bağlantısallık Girişimi — haber şeridi
--
-- Sayfanın alt şeridi girişimi ANAN haberleri gösteriyor. `dosya_haberleri`
-- kullanılamıyor: o fonksiyon `country_dossiers.anahtar_kelimeler`'den terim
-- okuyor, girişim ise bir dosya DEĞİL. Terimleri burada sabitliyoruz ama
-- EŞLEŞME KURALINI tekrar yazmıyoruz: mevcut `terim_geciyor` ve dosya
-- hattının puanlaması aynen kullanılıyor. İki yerde iki farklı kural olursa
-- biri düzeltilir, öteki sessizce eski kalır.
--
-- ─── ÖLÇÜM (12 Kasım 2026, 1.365 yayımlanmış haber) ──────────────────────
--
-- Tek sözcük "Turkuaz" yedi haber buluyor. Üçü girişimle ilgili, DÖRDÜ DEĞİL
-- (tağşişli gıda, orman yangınları, Sapanca Havzası ×2 — rengin adı geçiyor).
-- Aynı sabah TİGEM dosyasında tam bu hata düzeltildi: bir şerit gevşek ilgili
-- haberlerle doldurulmuş, 29 haberin 27'si konuyla ilgisiz çıkmıştı.
--
-- Öbek terimlere geçince beş haber kalıyor ve tablo şöyle:
--
--   10 Kas · "yeni girişim başlattı"            özet+spot+seo  → 3 puan
--    9 Kas · "küresel gıda güvenliği hedefleri"  spot+seo       → 3 puan
--    9 Kas · "COP31'de Turkuaz Nexus modeli"     BAŞLIK         → 3 puan
--    5 Kas · "orman yangınları verileri"         yalnız gövde   → 1 puan
--    6 Kas · "tağşişli gıdada taviz"             yalnız gövde   → 1 puan
--
-- Son ikisi gerçekten girişimi anıyor — gövdelerinde ona ayrılmış bir ara
-- başlık bile var — ama KONULARI o değil. Eşik 2 olduğunda ikisi düşüyor ve
-- şeritte tam üç haber kalıyor. Yani doğru sonucu veren şey yeni bir sezgi
-- değil, dosya hattının zaten var olan alan puanlaması.
--
-- ÜÇ HABER AZDIR AMA DÜRÜSTTÜR. Şerit zamanla kendiliğinden büyüyor.

create or replace function public.tni_haberleri(
  p_limit int default 6, p_min_puan int default 2)
returns table (
  id uuid, title text, title_en text, summary text, summary_en text,
  image_url text, published_at date, created_at timestamptz,
  source_name text, topic text, slug text, puan int
)
language sql stable security definer set search_path = public as $$
  with t as (
    -- Hepsi ÖBEK. Tek sözcük "Turkuaz" ya da "Nexus" buraya giremez.
    select unnest(array[
      'Turkuaz Bağlantısallık',
      'Turkuaz Nexus',
      'Turquoise Nexus',
      'Bağlantısallık Girişimi',
      'FAST Ortaklığı'
    ]) as terim
  ), puanli as (
    select a.id, a.title, a.title_en, a.summary, a.summary_en,
           a.image_url, a.published_at, a.created_at,
           a.source_name, a.topic, a.slug,
           max(
             case
               when terim_geciyor(a.title, t.terim) then 3
               when exists (select 1 from unnest(coalesce(a.seo_keywords, '{}')) k
                             where terim_geciyor(k, t.terim)) then 3
               when terim_geciyor(a.summary, t.terim)
                 or terim_geciyor(a.spot, t.terim) then 2
               when terim_geciyor(a.content, t.terim) then 1
               else 0
             end
           )::int as puan
      from articles a
      cross join t
     where a.status = 'published'
     group by a.id, a.title, a.title_en, a.summary, a.summary_en,
              a.image_url, a.published_at, a.created_at,
              a.source_name, a.topic, a.slug
  )
  select * from puanli
   where puan >= greatest(p_min_puan, 1)
   order by puan desc, published_at desc nulls last, created_at desc
   limit greatest(p_limit, 0);
$$;

comment on function public.tni_haberleri is
  'Turkuaz Bağlantısallık Girişimi''ni anan yayımlanmış haberler. Terimler '
  'ÖBEK; tek sözcük "Turkuaz" rengin adını da yakaladığı için kullanılmıyor. '
  'Eşik 2: yalnız gövdede anılan haber (1 puan) şeride girmiyor.';

grant execute on function public.tni_haberleri(int, int) to anon, authenticated;

-- ─── Kendi kendini sınama ────────────────────────────────────────────────
-- Buradaki sınama CANLI İÇERİĞE BAKMIYOR. Haber sayısı yarın değişebilir;
-- sınanan şey eşleşme KURALI. Üç şeyi ayrı ayrı doğruluyor.
do $kontrol$
begin
  -- 1) Öbek terim gövdede yakalanıyor mu?
  if not terim_geciyor(
       'Antalya''da Turkuaz Bağlantısallık Girişimi resmen tanıtılacaktır.',
       'Turkuaz Bağlantısallık') then
    raise exception 'terim_geciyor öbek terimi yakalamıyor';
  end if;

  -- 2) TÜRKÇE SON HARF TUZAĞI. "FAST Ortaklığı" sözcük sınırıyla aranıyor ve
  --    son harf "ı" (U+0131). Veritabanının ctype'ı bu harfi sözcük karakteri
  --    saymazsa \M sınırı kurulmaz ve terim HİÇ eşleşmez — hata vermeden.
  --    Bu yüzden ayrıca sınanıyor.
  if not terim_geciyor(
       'Girişim FAO FAST Ortaklığı kapsamında geliştirilmektedir.',
       'FAST Ortaklığı') then
    raise exception 'Türkçe sözcük sınırı çalışmıyor: "FAST Ortaklığı" eşleşmedi';
  end if;

  -- 3) Rengin adı YAKALANMAMALI. Şeridin bütün değeri bu ayrımda.
  if terim_geciyor(
       'Sapanca gölünün turkuaz suyu için eylem planı açıklandı.',
       'Turkuaz Bağlantısallık') then
    raise exception 'öbek terim gevşek eşleşiyor — rengin adı yakalandı';
  end if;

  -- 4) Fonksiyon gerçekten koşuyor mu? (Sonuç sayısı sınanmıyor.)
  perform * from public.tni_haberleri(1, 2);
end
$kontrol$;
