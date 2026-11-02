-- Irak devri — Ülke Dosyası Sayı 05 yayına giriyor · 3 Kasım 2026
--
-- Kullanıcı onayı: "önizleme yapabiliyorsan yap yoksa yayına al direk
-- göreyim canlıda."
--
-- ── SIRA (§2.12/4) ───────────────────────────────────────────────────────
-- `./deploy.sh --hosting` bu göçten ÖNCE çalıştı ve Irak'ın on dokuz
-- görselinin content-type: image/* döndüğü doğrulandı. Ters sırada dosya
-- canlıda kırık görsellerle açılır (25 Ağustos 2026'da yaşandı).
--
-- ── §2.12'NİN DÖRT ADIMI ─────────────────────────────────────────────────
-- 1. Yeni dosya: status published, pencere BUGÜN başlıyor (28 gün).
-- 2. Eski dosya: Avustralya archived VE ends_at = now(). Yalnız pencereyi
--    kapatmak yetmez — dosya_hikayeleri.py pencereye değil status'a bakıyor
--    ve arşivlenmeyen dosya ana sayfada hikâye üretmeye devam eder.
-- 3. Takvim: Avustralya devri takvime "Irak"ı Yakında olarak yazmıştı; o
--    satır kapanıyor ve yerine SIRADAKİ geliyor. Sıra tahmin edilmedi,
--    §2.11'deki kayıtlı rotasyondan okundu: döngü Model → Pazar → Rakip ve
--    listede Irak beşinci (Pazar), ALTINCI MISIR (Rakip — Nil, narenciye,
--    patates). Kullanıcı 3 Kasım 2026'da bunu açıkça istedi: "Irak yayına
--    girince yakında denilen ülke bir sonraki olsun."
-- 4. İçerik: 20261103090000 ile draft olarak YAZILDI. Bu göç yalnız
--    durumu ve pencereyi değiştiriyor, içeriğe dokunmuyor.
--
-- Avustralya penceresi zaten 6 Kasım 12:00 UTC'de düşüyordu; devir onu üç
-- gün öne çekiyor.

-- ── 1. Irak yayına ───────────────────────────────────────────────────────
update public.country_dossiers
   set status      = 'published',
       starts_at   = now(),
       ends_at     = now() + interval '28 days',
       published_at = coalesce(published_at, now())
 where slug = 'irak';

-- ── 2. Avustralya arşive ─────────────────────────────────────────────────
update public.country_dossiers
   set status  = 'archived',
       ends_at = now()
 where slug = 'avustralya';

-- ── 3. Takvim: Irak'ın "Yakında" satırı kapanıyor ────────────────────────
update public.dossier_takvim t
   set etkin = false,
       sira  = 1 + coalesce((select max(x.sira) from public.dossier_takvim x
                              where x.tur = t.tur and x.sira >= 90), 89)
 where t.sira < 90
   and t.tur = 'ulke'
   and t.ad_tr = 'Irak';

insert into public.dossier_takvim (tur, ad_tr, ad_en, sira, etkin)
values ('ulke', 'Mısır', 'Egypt', 1, true)
on conflict (tur, sira) do update set
  ad_tr = excluded.ad_tr,
  ad_en = excluded.ad_en,
  etkin = true;

-- KURUM DİZİSİNE DOKUNULMUYOR. Bu devir yalnızca ülke dosyası.

-- ════════════════════════════════════════════════════════════════════════
-- Sağlama — biri bile tutmazsa migration tümden geri alınır
-- ════════════════════════════════════════════════════════════════════════
do $kontrol_devir$
declare n integer; s text;
begin
  -- Tek aktif ülke dosyası ve o dosya Irak
  select count(*) into n from public.country_dossiers
   where tur = 'ulke' and status = 'published' and ends_at > now();
  if n <> 1 then
    raise exception 'Aktif ülke dosyası sayısı 1 olmalıydı, % bulundu', n;
  end if;
  select slug into s from public.country_dossiers
   where tur = 'ulke' and status = 'published' and ends_at > now();
  if s is distinct from 'irak' then
    raise exception 'Aktif ülke dosyası irak değil: %', s;
  end if;

  -- Avustralya gerçekten arşivde
  select status into s from public.country_dossiers where slug = 'avustralya';
  if s is distinct from 'archived' then
    raise exception 'Avustralya arşivlenmedi: %', s;
  end if;

  -- Pencere BUGÜN başlamış olmalı; ileri tarihli pencere dosyayı şeritten gizler
  select count(*) into n from public.country_dossiers
   where slug = 'irak' and starts_at <= now() and ends_at > now();
  if n <> 1 then
    raise exception 'Irak penceresi bugün açık değil';
  end if;

  -- Takvimde Irak artık "Yakında" değil, Mısır var
  select count(*) into n from public.dossier_takvim
   where tur = 'ulke' and etkin and ad_tr = 'Irak';
  if n > 0 then
    raise exception 'Takvimde Irak hâlâ Yakında görünüyor';
  end if;
  select count(*) into n from public.dossier_takvim
   where tur = 'ulke' and etkin and ad_tr = 'Mısır' and sira = 1;
  if n <> 1 then
    raise exception 'Takvimde sıradaki ülke Mısır değil';
  end if;

  -- KURUM AKTİFİ DEĞİŞMEMELİ (İspanya devrinin dersi)
  select count(*) into n from public.country_dossiers
   where tur = 'kurum' and status = 'published' and ends_at > now();
  if n <> 1 then
    raise exception 'Kurum aktifi değişmiş: % aktif kurum dosyası', n;
  end if;

  -- İçerik yerinde mi — devir göçü içeriği yazmaz, ama olmadan devredilemez
  select count(*) into n from public.dossier_sections s
    join public.country_dossiers d on d.id = s.dossier_id where d.slug = 'irak';
  if n <> 18 then
    raise exception 'Irak içeriği eksik: % bölüm', n;
  end if;
end
$kontrol_devir$;
