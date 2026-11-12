-- Fotoğraf sergisi — anasayfanın altındaki galeri bandı ve kendi sayfası
--
-- İLK İÇERİK: 16. Uluslararası Tarım Orman ve İnsan Fotoğraf Yarışması
-- (UTOİFY 2026). T.C. Tarım ve Orman Bakanlığı Eğitim ve Yayın Dairesi
-- Başkanlığı düzenliyor, DenizBank destekliyor. 114 kare: 14 ödül,
-- 100 sergileme.
--
-- NEDEN İKİ TABLO. Yarışma üst verisi (tema, düzenleyen, kaynak adresleri)
-- yıl başına BİR kez geçerli; 114 satırın her birine kopyalamak, temayı
-- değiştirmek gerektiğinde 114 satırı güncellemek demekti. Sitenin kendi
-- arşivi 2009'a kadar gidiyor (on beş albüm) — bu yapı o yılların da
-- eklenebilmesi için kuruldu.
--
-- KÜNYE ZORUNLU. `fotografci` ve `eser` boş geçilemiyor, `kaynak_adres`
-- yarışma satırında zorunlu. Bir kare künyesiz yayına çıkamıyor; kısıt
-- veritabanında çünkü bir gün paneli kullanan kişi çizicinin varsayımını
-- bilemez.
--
-- SIRA ÖNEMLİ — YARIŞMA `yayinda = false` İLE GİRİYOR.
--
-- Kareler hosting'de (`web/sergi/utoify-16/`). Bu göç önce uygulanıp dağıtım
-- sonra yapılırsa anasayfanın altında 114 KIRIK GÖRSEL çıkar — üstelik
-- hiçbir şey hata vermeden, ki bu portalın en sık yaşadığı arıza biçimi.
--
-- Doğru sıra:
--   1) göç uygulanır        → veri girer, sayfa HÂLÂ görünmez
--   2) derle + dağıt        → kareler hosting'e çıkar
--   3) canlıda doğrulanır   → bir kare açılıyor mu
--   4) yayına alınır:
--        update public.sergi_yarismalari set yayinda = true, guncellendi = now()
--         where kod = 'utoify-16';
--
-- Dördüncü adım AYRI ve bilinçli: yayına alma kararı tek satırda duruyor,
-- geri alması da tek satır.
--
-- TELİF. Kareler fotoğrafçılarının telifinde. Yarışmanın katılım şartları
-- sayfası boş dönüyor ve kamuya açık bir kullanım lisansı bulunamadı.
-- Yayım kararı 12 Kasım 2026'da kullanıcıya ait: sonuçlar kamuya açık bir
-- ilan ve sergi, her kare fotoğrafçı adı, eser adı ve kaynağa bağlantıyla
-- yayımlanıyor. `yayinda` bayrağı tam bu yüzden var: itiraz gelirse tek
-- satırlık bir güncellemeyle kare de, yarışma da sayfadan kalkıyor.

create table if not exists public.sergi_yarismalari (
  kod               text primary key,
  sira              integer not null,
  yil               integer not null,
  ad_tr             text not null,
  ad_en             text not null,
  kisa              text,
  tema_tr           text,
  tema_en           text,
  duzenleyen_tr     text not null,
  duzenleyen_en     text not null,
  destekci          text,
  kaynak_adres      text not null,
  odul_listesi      text,
  sergileme_listesi text,
  yayinda           boolean not null default false,
  guncellendi       timestamptz not null default now()
);

create table if not exists public.sergi_eserleri (
  kod          text primary key,
  yarisma_kod  text not null references public.sergi_yarismalari(kod) on delete cascade,
  tur          text not null,
  kategori     text not null,
  sira         integer not null,
  odul_tr      text not null,
  odul_en      text not null,
  fotografci   text not null,
  eser         text not null,
  il           text,
  ulke_tr      text not null,
  ulke_en      text not null,
  adres        text not null,
  en           integer,
  boy          integer,
  en_boy       numeric(6,4),
  yayinda      boolean not null default true
);

alter table public.sergi_eserleri drop constraint if exists sergi_eserleri_tur;
alter table public.sergi_eserleri add constraint sergi_eserleri_tur
  check (tur in ('odul', 'sergileme'));

-- Künye boş geçilemez. Trim edilmiş hâli de boş olmamalı: " " künye değil.
alter table public.sergi_eserleri drop constraint if exists sergi_eserleri_kunye;
alter table public.sergi_eserleri add constraint sergi_eserleri_kunye
  check (length(btrim(fotografci)) > 0 and length(btrim(eser)) > 0
         and length(btrim(adres)) > 0);

create index if not exists sergi_eserleri_yarisma_sira
  on public.sergi_eserleri (yarisma_kod, sira);
create index if not exists sergi_eserleri_il
  on public.sergi_eserleri (il) where il is not null;

alter table public.sergi_yarismalari enable row level security;
alter table public.sergi_eserleri enable row level security;

drop policy if exists "anon yayindaki yarismalari okur" on public.sergi_yarismalari;
create policy "anon yayindaki yarismalari okur"
  on public.sergi_yarismalari for select to anon using (yayinda);

drop policy if exists "authenticated tum yarismalari okur" on public.sergi_yarismalari;
create policy "authenticated tum yarismalari okur"
  on public.sergi_yarismalari for select to authenticated using (true);

-- Eser, yarışması yayında DEĞİLSE görünmüyor. İki bayrağı ayrı tutup yalnız
-- esere bakmak, yayından kaldırılan bir yarışmanın karelerinin ortada
-- kalmasına yol açardı — hem de sessizce.
drop policy if exists "anon yayindaki eserleri okur" on public.sergi_eserleri;
create policy "anon yayindaki eserleri okur"
  on public.sergi_eserleri for select to anon using (
    yayinda and exists (
      select 1 from public.sergi_yarismalari y
       where y.kod = sergi_eserleri.yarisma_kod and y.yayinda));

drop policy if exists "authenticated tum eserleri okur" on public.sergi_eserleri;
create policy "authenticated tum eserleri okur"
  on public.sergi_eserleri for select to authenticated using (true);

comment on table public.sergi_yarismalari is
  'Fotoğraf yarışmaları. Bir satır = bir yıl. Kareler sergi_eserleri''nde.';
comment on column public.sergi_eserleri.yayinda is
  'Tek kareyi sayfadan kaldırmak için. Telif itirazının cevabı bu bayrak.';

-- ─── Yarışma ────────────────────────────────────────────────────────────
insert into public.sergi_yarismalari (kod, sira, yil, ad_tr, ad_en, kisa,
  tema_tr, tema_en, duzenleyen_tr, duzenleyen_en, destekci,
  kaynak_adres, odul_listesi, sergileme_listesi, yayinda)
values ('utoify-16', 16, 2026, '16. Uluslararası Tarım Orman ve İnsan Fotoğraf Yarışması', '16th International Photo Contest on Agriculture, Forest and People', 'UTOİFY',
        'Kadının Emeği, Tarımın Geleceği', 'Labour of Woman, Future of Agriculture',
        'T.C. Tarım ve Orman Bakanlığı, Eğitim ve Yayın Dairesi Başkanlığı',
        'Ministry of Agriculture and Forestry of Türkiye, Department of Training and Extension',
        'DenizBank', 'https://www.tarimormaninsan.com/',
        'https://www.tarimormaninsan.com/16th_utoify_odul.pdf',
        'https://www.tarimormaninsan.com/16th_utoify_sergileme.pdf', false)
on conflict (kod) do update set
  tema_tr = excluded.tema_tr, tema_en = excluded.tema_en,
  kaynak_adres = excluded.kaynak_adres, guncellendi = now();

-- ─── 114 eser ───────────────────────────────────────────────────────────
insert into public.sergi_eserleri (kod, yarisma_kod, tur, kategori,
  sira, odul_tr, odul_en, fotografci, eser, il, ulke_tr, ulke_en,
  adres, en, boy, en_boy) values
('odul-01', 'utoify-16', 'odul', 'genel', 1, 'Genel Birincilik Ödülü', 'International First Prize', 'Galib Rahman NADİM', 'Patterns of the Harvest', null, 'Bangladeş', 'Bangladesh', 'https://tarimportali.net/sergi/utoify-16/odul-01-galib-rahman-nadim.jpg', 613, 399, 1.5363),
('odul-02', 'utoify-16', 'odul', 'genel', 2, 'Genel İkincilik Ödülü', 'International Second Prize', 'Lihe ZHOU', 'Guard Our Home', null, 'Çin', 'China', 'https://tarimportali.net/sergi/utoify-16/odul-02-lihe-zhou.jpg', 612, 399, 1.5338),
('odul-03', 'utoify-16', 'odul', 'genel', 3, 'Genel Üçüncülük Ödülü', 'International Third Prize', 'Prabır Kumar DAS', 'Evergreen Smile', null, 'Hindistan', 'India', 'https://tarimportali.net/sergi/utoify-16/odul-03-prabir-kumar-das.jpg', 612, 399, 1.5338),
('odul-04', 'utoify-16', 'odul', 'ulusal', 4, 'Ulusal Birincilik Ödülü', 'National First Prize', 'Şirzat TEMİZ', 'Ağ Onaran Kadın', null, 'Vietnam', 'Viet Nam', 'https://tarimportali.net/sergi/utoify-16/odul-04-sirzat-temiz.jpg', 613, 399, 1.5363),
('odul-05', 'utoify-16', 'odul', 'ulusal', 5, 'Ulusal İkincilik Ödülü', 'National Second Prize', 'Gülbeyaz GENCER', 'Tatlı Miras', 'Adana', 'Türkiye', 'Türkiye', 'https://tarimportali.net/sergi/utoify-16/odul-05-gulbeyaz-gencer.jpg', 612, 399, 1.5338),
('odul-06', 'utoify-16', 'odul', 'ulusal', 6, 'Ulusal Üçüncülük Ödülü', 'National Third Prize', 'Hasan UÇAR', 'Üzüm Kurutma', 'Manisa', 'Türkiye', 'Türkiye', 'https://tarimportali.net/sergi/utoify-16/odul-06-hasan-ucar.jpg', 612, 399, 1.5338),
('odul-07', 'utoify-16', 'odul', 'bakan', 7, 'Bakan Özel Ödülü', 'Minister''s Special Award', 'Ömer Oğuz ÇAPANOĞLU', 'Yün Dövme', 'Tunceli', 'Türkiye', 'Türkiye', 'https://tarimportali.net/sergi/utoify-16/odul-07-omer-oguz-capanoglu.jpg', 613, 399, 1.5363),
('odul-08', 'utoify-16', 'odul', 'su', 8, '1313: Suya Vefa Ödülü', '1313: Loyalty to Water Award', 'Esra BÜRÇÜN', 'Karagöl', 'Artvin', 'Türkiye', 'Türkiye', 'https://tarimportali.net/sergi/utoify-16/odul-08-esra-burcun.jpg', 612, 399, 1.5338),
('odul-09', 'utoify-16', 'odul', 'orman', 9, 'Orman: Geleceğe Nefes Ödülü', 'Forest: Breath for the Future Award', 'Ali ACAR', 'Tek', 'Kastamonu', 'Türkiye', 'Türkiye', 'https://tarimportali.net/sergi/utoify-16/odul-09-ali-acar.jpg', 612, 399, 1.5338),
('odul-10', 'utoify-16', 'odul', 'denizbank', 10, 'DenizBank Çalışanları Ödülü', 'DenizBank Personnel Award', 'Meral KAYA', 'Süpürge Yapımı', 'Adıyaman', 'Türkiye', 'Türkiye', 'https://tarimportali.net/sergi/utoify-16/odul-10-meral-kaya.jpg', 613, 399, 1.5363),
('odul-11', 'utoify-16', 'odul', 'tob', 11, 'Tarım ve Orman Bakanlığı Çalışanları Ödülü', 'Ministry of Agriculture and Forestry Personnel Award', 'Ender PEKŞEN', 'Lahana', 'Samsun', 'Türkiye', 'Türkiye', 'https://tarimportali.net/sergi/utoify-16/odul-11-ender-peksen.jpg', 612, 399, 1.5338),
('odul-12', 'utoify-16', 'odul', 'ogrenci', 12, 'Öğrenci Ödülü', 'Student Award', 'Berra Nur DEMİR', 'Kuzular', 'Manisa', 'Türkiye', 'Türkiye', 'https://tarimportali.net/sergi/utoify-16/odul-12-berra-nur-demir.jpg', 612, 399, 1.5338),
('odul-13', 'utoify-16', 'odul', 'tema', 13, 'Tema Ödülü: Kadının Emeği, Tarımın Geleceği', 'Theme Award: Labour of Woman, Future of Agriculture', 'Ahmet HARMANCI', 'Emek', 'Kütahya', 'Türkiye', 'Türkiye', 'https://tarimportali.net/sergi/utoify-16/odul-13-ahmet-harmanci.jpg', 613, 399, 1.5363),
('odul-14', 'utoify-16', 'odul', 'ciftci', 14, 'Çiftçi - Üretici Ödülü', 'Farmer & Producer Award', 'Ufuk SALUR', 'Orak', 'Balıkesir', 'Türkiye', 'Türkiye', 'https://tarimportali.net/sergi/utoify-16/odul-14-ufuk-salur.jpg', 620, 390, 1.5897),
('sergi-001', 'utoify-16', 'sergileme', 'sergileme', 15, 'Sergilemeye değer bulundu', 'Selected for exhibition', 'Abdulmecit ÇEVRİM', 'Bulgur', 'Şırnak', 'Türkiye', 'Türkiye', 'https://tarimportali.net/sergi/utoify-16/sergi-001-abdulmecit-cevrim.jpg', 549, 364, 1.5082),
('sergi-002', 'utoify-16', 'sergileme', 'sergileme', 16, 'Sergilemeye değer bulundu', 'Selected for exhibition', 'Abdurrahman ÇETİN', 'Özlem Bacı', 'Afyonkarahisar', 'Türkiye', 'Türkiye', 'https://tarimportali.net/sergi/utoify-16/sergi-002-abdurrahman-cetin.jpg', 549, 364, 1.5082),
('sergi-003', 'utoify-16', 'sergileme', 'sergileme', 17, 'Sergilemeye değer bulundu', 'Selected for exhibition', 'Afif MUSTHAFA', 'The Last Racks', null, 'Endonezya', 'Indonesia', 'https://tarimportali.net/sergi/utoify-16/sergi-003-afif-musthafa.jpg', 549, 364, 1.5082),
('sergi-004', 'utoify-16', 'sergileme', 'sergileme', 18, 'Sergilemeye değer bulundu', 'Selected for exhibition', 'Ahmet DİZDAR', 'Serenti', 'Trabzon', 'Türkiye', 'Türkiye', 'https://tarimportali.net/sergi/utoify-16/sergi-004-ahmet-dizdar.jpg', 549, 364, 1.5082),
('sergi-005', 'utoify-16', 'sergileme', 'sergileme', 19, 'Sergilemeye değer bulundu', 'Selected for exhibition', 'Ahmet Fatih SÖNMEZ', 'Süt Sağımı', 'Van', 'Türkiye', 'Türkiye', 'https://tarimportali.net/sergi/utoify-16/sergi-005-ahmet-fatih-sonmez.jpg', 549, 364, 1.5082),
('sergi-006', 'utoify-16', 'sergileme', 'sergileme', 20, 'Sergilemeye değer bulundu', 'Selected for exhibition', 'Ahmet HARMANCI', 'Kaz', 'Kars', 'Türkiye', 'Türkiye', 'https://tarimportali.net/sergi/utoify-16/sergi-006-ahmet-harmanci.jpg', 549, 364, 1.5082),
('sergi-007', 'utoify-16', 'sergileme', 'sergileme', 21, 'Sergilemeye değer bulundu', 'Selected for exhibition', 'Ahsen CANAN', 'Anadolu Dağlarında', 'Sivas', 'Türkiye', 'Türkiye', 'https://tarimportali.net/sergi/utoify-16/sergi-007-ahsen-canan.jpg', 549, 364, 1.5082),
('sergi-008', 'utoify-16', 'sergileme', 'sergileme', 22, 'Sergilemeye değer bulundu', 'Selected for exhibition', 'Ali Fatih AKÇAY', 'Köye İniş', 'Trabzon', 'Türkiye', 'Türkiye', 'https://tarimportali.net/sergi/utoify-16/sergi-008-ali-fatih-akcay.jpg', 549, 364, 1.5082),
('sergi-009', 'utoify-16', 'sergileme', 'sergileme', 23, 'Sergilemeye değer bulundu', 'Selected for exhibition', 'Andreja Ravnak', 'Gently Sculpted', null, 'İtalya', 'Italy', 'https://tarimportali.net/sergi/utoify-16/sergi-009-andreja-ravnak.jpg', 549, 364, 1.5082),
('sergi-010', 'utoify-16', 'sergileme', 'sergileme', 24, 'Sergilemeye değer bulundu', 'Selected for exhibition', 'Arda TAŞ', 'Üzüm Hasadı', 'Manisa', 'Türkiye', 'Türkiye', 'https://tarimportali.net/sergi/utoify-16/sergi-010-arda-tas.jpg', 549, 364, 1.5082),
('sergi-011', 'utoify-16', 'sergileme', 'sergileme', 25, 'Sergilemeye değer bulundu', 'Selected for exhibition', 'Aygül HARMANCI', 'Bülbül Teyze', 'Trabzon', 'Türkiye', 'Türkiye', 'https://tarimportali.net/sergi/utoify-16/sergi-011-aygul-harmanci.jpg', 549, 364, 1.5082),
('sergi-012', 'utoify-16', 'sergileme', 'sergileme', 26, 'Sergilemeye değer bulundu', 'Selected for exhibition', 'Aynur BOSTAN', 'Çoban Haydar', 'Erzincan', 'Türkiye', 'Türkiye', 'https://tarimportali.net/sergi/utoify-16/sergi-012-aynur-bostan.jpg', 557, 355, 1.569),
('sergi-013', 'utoify-16', 'sergileme', 'sergileme', 27, 'Sergilemeye değer bulundu', 'Selected for exhibition', 'Azim Khan RONNİE', 'Pot Making', null, 'Bangladeş', 'Bangladesh', 'https://tarimportali.net/sergi/utoify-16/sergi-013-azim-khan-ronnie.jpg', 549, 364, 1.5082),
('sergi-014', 'utoify-16', 'sergileme', 'sergileme', 28, 'Sergilemeye değer bulundu', 'Selected for exhibition', 'Beytullah ELES', 'Kırmızı Altın', 'Gaziantep', 'Türkiye', 'Türkiye', 'https://tarimportali.net/sergi/utoify-16/sergi-014-beytullah-eles.jpg', 549, 364, 1.5082),
('sergi-015', 'utoify-16', 'sergileme', 'sergileme', 29, 'Sergilemeye değer bulundu', 'Selected for exhibition', 'Beytullah ELES', 'Zor Yaylasında Hayvancılık', 'Iğdır', 'Türkiye', 'Türkiye', 'https://tarimportali.net/sergi/utoify-16/sergi-015-beytullah-eles.jpg', 549, 375, 1.464),
('sergi-016', 'utoify-16', 'sergileme', 'sergileme', 30, 'Sergilemeye değer bulundu', 'Selected for exhibition', 'Beytullah ELES', 'Kayısı Serme', 'Malatya', 'Türkiye', 'Türkiye', 'https://tarimportali.net/sergi/utoify-16/sergi-016-beytullah-eles.jpg', 549, 364, 1.5082),
('sergi-017', 'utoify-16', 'sergileme', 'sergileme', 31, 'Sergilemeye değer bulundu', 'Selected for exhibition', 'Bipul AHMED', 'The Weight of Jute', null, 'Bangladeş', 'Bangladesh', 'https://tarimportali.net/sergi/utoify-16/sergi-017-bipul-ahmed.jpg', 549, 364, 1.5082),
('sergi-018', 'utoify-16', 'sergileme', 'sergileme', 32, 'Sergilemeye değer bulundu', 'Selected for exhibition', 'Boqian CUI', 'Love', null, 'Çin', 'China', 'https://tarimportali.net/sergi/utoify-16/sergi-018-boqian-cui.jpg', 557, 355, 1.569),
('sergi-019', 'utoify-16', 'sergileme', 'sergileme', 33, 'Sergilemeye değer bulundu', 'Selected for exhibition', 'Boqian CUI', 'Auspicious Clouds Over The Plateau', null, 'Çin', 'China', 'https://tarimportali.net/sergi/utoify-16/sergi-019-boqian-cui.jpg', 557, 355, 1.569),
('sergi-020', 'utoify-16', 'sergileme', 'sergileme', 34, 'Sergilemeye değer bulundu', 'Selected for exhibition', 'Caner BAŞER', 'Allı Turnalar', 'Afyonkarahisar', 'Türkiye', 'Türkiye', 'https://tarimportali.net/sergi/utoify-16/sergi-020-caner-baser.jpg', 549, 364, 1.5082),
('sergi-021', 'utoify-16', 'sergileme', 'sergileme', 35, 'Sergilemeye değer bulundu', 'Selected for exhibition', 'Caner BAŞER', 'Tozlu Yol', 'Muğla', 'Türkiye', 'Türkiye', 'https://tarimportali.net/sergi/utoify-16/sergi-021-caner-baser.jpg', 549, 364, 1.5082),
('sergi-022', 'utoify-16', 'sergileme', 'sergileme', 36, 'Sergilemeye değer bulundu', 'Selected for exhibition', 'Ekrem ŞAHİN', 'Elma', 'Isparta', 'Türkiye', 'Türkiye', 'https://tarimportali.net/sergi/utoify-16/sergi-022-ekrem-sahin.jpg', 549, 364, 1.5082),
('sergi-023', 'utoify-16', 'sergileme', 'sergileme', 37, 'Sergilemeye değer bulundu', 'Selected for exhibition', 'Ekrem ŞAHİN', 'Filamingo ve Yavrusu', 'Konya', 'Türkiye', 'Türkiye', 'https://tarimportali.net/sergi/utoify-16/sergi-023-ekrem-sahin.jpg', 549, 364, 1.5082),
('sergi-024', 'utoify-16', 'sergileme', 'sergileme', 38, 'Sergilemeye değer bulundu', 'Selected for exhibition', 'Emre VARDAL', 'Sonbaharda Koyunlar', 'Artvin', 'Türkiye', 'Türkiye', 'https://tarimportali.net/sergi/utoify-16/sergi-024-emre-vardal.jpg', 549, 364, 1.5082),
('sergi-025', 'utoify-16', 'sergileme', 'sergileme', 39, 'Sergilemeye değer bulundu', 'Selected for exhibition', 'Emrullah AKGÜN', 'Bulutların Üstünde', 'Trabzon', 'Türkiye', 'Türkiye', 'https://tarimportali.net/sergi/utoify-16/sergi-025-emrullah-akgun.jpg', 549, 364, 1.5082),
('sergi-026', 'utoify-16', 'sergileme', 'sergileme', 40, 'Sergilemeye değer bulundu', 'Selected for exhibition', 'Emrullah AKGÜN', 'Kaz Arkadaşı', 'Şanlıurfa', 'Türkiye', 'Türkiye', 'https://tarimportali.net/sergi/utoify-16/sergi-026-emrullah-akgun.jpg', 549, 364, 1.5082),
('sergi-027', 'utoify-16', 'sergileme', 'sergileme', 41, 'Sergilemeye değer bulundu', 'Selected for exhibition', 'Ender PEKŞEN', 'Sürü', 'Samsun', 'Türkiye', 'Türkiye', 'https://tarimportali.net/sergi/utoify-16/sergi-027-ender-peksen.jpg', 549, 364, 1.5082),
('sergi-028', 'utoify-16', 'sergileme', 'sergileme', 42, 'Sergilemeye değer bulundu', 'Selected for exhibition', 'Ender PEKŞEN', 'Fındık Abaküs', 'Samsun', 'Türkiye', 'Türkiye', 'https://tarimportali.net/sergi/utoify-16/sergi-028-ender-peksen.jpg', 549, 364, 1.5082),
('sergi-029', 'utoify-16', 'sergileme', 'sergileme', 43, 'Sergilemeye değer bulundu', 'Selected for exhibition', 'Erol ÖZDEMİR', 'Sırtımdaki Hayat', 'Trabzon', 'Türkiye', 'Türkiye', 'https://tarimportali.net/sergi/utoify-16/sergi-029-erol-ozdemir.jpg', 549, 364, 1.5082),
('sergi-030', 'utoify-16', 'sergileme', 'sergileme', 44, 'Sergilemeye değer bulundu', 'Selected for exhibition', 'Esengül ALICIBİBER', 'Zamanın İlmekleri', 'Balıkesir', 'Türkiye', 'Türkiye', 'https://tarimportali.net/sergi/utoify-16/sergi-030-esengul-alicibiber.jpg', 549, 364, 1.5082),
('sergi-031', 'utoify-16', 'sergileme', 'sergileme', 45, 'Sergilemeye değer bulundu', 'Selected for exhibition', 'Fatih GÖNÜL', 'Gelenekten', null, 'Vietnam', 'Viet Nam', 'https://tarimportali.net/sergi/utoify-16/sergi-031-fatih-gonul.jpg', 549, 364, 1.5082),
('sergi-032', 'utoify-16', 'sergileme', 'sergileme', 46, 'Sergilemeye değer bulundu', 'Selected for exhibition', 'Fatih Korcan KOZAN', 'Geleceğin Samimi Niyeti', 'Bitlis', 'Türkiye', 'Türkiye', 'https://tarimportali.net/sergi/utoify-16/sergi-032-fatih-korcan-kozan.jpg', 549, 364, 1.5082),
('sergi-033', 'utoify-16', 'sergileme', 'sergileme', 47, 'Sergilemeye değer bulundu', 'Selected for exhibition', 'Fatih Korcan KOZAN', 'Toprağın Uykusu, İnsanın Umutları', 'Muş', 'Türkiye', 'Türkiye', 'https://tarimportali.net/sergi/utoify-16/sergi-033-fatih-korcan-kozan.jpg', 549, 364, 1.5082),
('sergi-034', 'utoify-16', 'sergileme', 'sergileme', 48, 'Sergilemeye değer bulundu', 'Selected for exhibition', 'Fatma SAL T', 'Mahıla', null, 'Nepal', 'Nepal', 'https://tarimportali.net/sergi/utoify-16/sergi-034-fatma-sal-t.jpg', 549, 364, 1.5082),
('sergi-035', 'utoify-16', 'sergileme', 'sergileme', 49, 'Sergilemeye değer bulundu', 'Selected for exhibition', 'Faysal KANBER', 'Emekçi Kadınlar', 'Trabzon', 'Türkiye', 'Türkiye', 'https://tarimportali.net/sergi/utoify-16/sergi-035-faysal-kanber.jpg', 549, 364, 1.5082),
('sergi-036', 'utoify-16', 'sergileme', 'sergileme', 50, 'Sergilemeye değer bulundu', 'Selected for exhibition', 'Gazi AYDIN', 'Eve Dönüş', 'Tokat', 'Türkiye', 'Türkiye', 'https://tarimportali.net/sergi/utoify-16/sergi-036-gazi-aydin.jpg', 549, 364, 1.5082),
('sergi-037', 'utoify-16', 'sergileme', 'sergileme', 51, 'Sergilemeye değer bulundu', 'Selected for exhibition', 'Gökalp BİLİCİ', 'Korkuluk', 'Ankara', 'Türkiye', 'Türkiye', 'https://tarimportali.net/sergi/utoify-16/sergi-037-gokalp-bilici.jpg', 549, 364, 1.5082),
('sergi-038', 'utoify-16', 'sergileme', 'sergileme', 52, 'Sergilemeye değer bulundu', 'Selected for exhibition', 'Guojun LIN', 'Galloping in The Snow', null, 'Çin', 'China', 'https://tarimportali.net/sergi/utoify-16/sergi-038-guojun-lin.jpg', 549, 364, 1.5082),
('sergi-039', 'utoify-16', 'sergileme', 'sergileme', 53, 'Sergilemeye değer bulundu', 'Selected for exhibition', 'Gülcan ACAR', 'Nar Zamanı', 'Antalya', 'Türkiye', 'Türkiye', 'https://tarimportali.net/sergi/utoify-16/sergi-039-gulcan-acar.jpg', 549, 364, 1.5082),
('sergi-040', 'utoify-16', 'sergileme', 'sergileme', 54, 'Sergilemeye değer bulundu', 'Selected for exhibition', 'Halit BOZKUŞ', 'Haşhaş Toplama', 'Afyonkarahisar', 'Türkiye', 'Türkiye', 'https://tarimportali.net/sergi/utoify-16/sergi-040-halit-bozkus.jpg', 549, 364, 1.5082),
('sergi-041', 'utoify-16', 'sergileme', 'sergileme', 55, 'Sergilemeye değer bulundu', 'Selected for exhibition', 'Happy MUKHERJEE', 'Changpa Woman', null, 'Hindistan', 'India', 'https://tarimportali.net/sergi/utoify-16/sergi-041-happy-mukherjee.jpg', 557, 355, 1.569),
('sergi-042', 'utoify-16', 'sergileme', 'sergileme', 56, 'Sergilemeye değer bulundu', 'Selected for exhibition', 'Hasan ZER', 'Ekmek Teknesi', 'Sakarya', 'Türkiye', 'Türkiye', 'https://tarimportali.net/sergi/utoify-16/sergi-042-hasan-zer.jpg', 549, 364, 1.5082),
('sergi-043', 'utoify-16', 'sergileme', 'sergileme', 57, 'Sergilemeye değer bulundu', 'Selected for exhibition', 'Hilmi Tunahan ERGUN', 'Neşeli Fıstıklar', 'Adana', 'Türkiye', 'Türkiye', 'https://tarimportali.net/sergi/utoify-16/sergi-043-hilmi-tunahan-ergun.jpg', 549, 364, 1.5082),
('sergi-044', 'utoify-16', 'sergileme', 'sergileme', 58, 'Sergilemeye değer bulundu', 'Selected for exhibition', 'Hüseyin KARAHAN', 'Çuval Bağlama', 'Sakarya', 'Türkiye', 'Türkiye', 'https://tarimportali.net/sergi/utoify-16/sergi-044-huseyin-karahan.jpg', 549, 355, 1.5465),
('sergi-045', 'utoify-16', 'sergileme', 'sergileme', 59, 'Sergilemeye değer bulundu', 'Selected for exhibition', 'Hüseyin KARAHAN', 'Çiçek Serası', 'Yalova', 'Türkiye', 'Türkiye', 'https://tarimportali.net/sergi/utoify-16/sergi-045-huseyin-karahan.jpg', 549, 364, 1.5082),
('sergi-046', 'utoify-16', 'sergileme', 'sergileme', 60, 'Sergilemeye değer bulundu', 'Selected for exhibition', 'İbrahim AYSÜNDÜ', 'Emeğin Silüeti', 'Malatya', 'Türkiye', 'Türkiye', 'https://tarimportali.net/sergi/utoify-16/sergi-046-ibrahim-aysundu.jpg', 549, 364, 1.5082),
('sergi-047', 'utoify-16', 'sergileme', 'sergileme', 61, 'Sergilemeye değer bulundu', 'Selected for exhibition', 'İbrahim AYSÜNDÜ', 'Mısırın Taneleri', 'Trabzon', 'Türkiye', 'Türkiye', 'https://tarimportali.net/sergi/utoify-16/sergi-047-ibrahim-aysundu.jpg', 549, 364, 1.5082),
('sergi-048', 'utoify-16', 'sergileme', 'sergileme', 62, 'Sergilemeye değer bulundu', 'Selected for exhibition', 'İlham Kazdal', 'Pamuk Tarlası', 'Şanlıurfa', 'Türkiye', 'Türkiye', 'https://tarimportali.net/sergi/utoify-16/sergi-048-ilham-kazdal.jpg', 549, 364, 1.5082),
('sergi-049', 'utoify-16', 'sergileme', 'sergileme', 63, 'Sergilemeye değer bulundu', 'Selected for exhibition', 'Jaber GHOLAMİ', 'Fresh Herbs', null, 'İran', 'Iran', 'https://tarimportali.net/sergi/utoify-16/sergi-049-jaber-gholami.jpg', 549, 364, 1.5082),
('sergi-050', 'utoify-16', 'sergileme', 'sergileme', 64, 'Sergilemeye değer bulundu', 'Selected for exhibition', 'Kemal VURĞUN', 'Lahana', 'Manisa', 'Türkiye', 'Türkiye', 'https://tarimportali.net/sergi/utoify-16/sergi-050-kemal-vurgun.jpg', 549, 364, 1.5082),
('sergi-051', 'utoify-16', 'sergileme', 'sergileme', 65, 'Sergilemeye değer bulundu', 'Selected for exhibition', 'Marzeyeh SHAHROODI', 'Mother', null, 'İran', 'Iran', 'https://tarimportali.net/sergi/utoify-16/sergi-051-marzeyeh-shahroodi.jpg', 549, 364, 1.5082),
('sergi-052', 'utoify-16', 'sergileme', 'sergileme', 66, 'Sergilemeye değer bulundu', 'Selected for exhibition', 'Mehmet PAL TA', 'Eller', 'Ordu', 'Türkiye', 'Türkiye', 'https://tarimportali.net/sergi/utoify-16/sergi-052-mehmet-pal-ta.jpg', 549, 364, 1.5082),
('sergi-053', 'utoify-16', 'sergileme', 'sergileme', 67, 'Sergilemeye değer bulundu', 'Selected for exhibition', 'Meral YEŞİLÇİÇEK', 'Merdivendeki Kadın', 'Trabzon', 'Türkiye', 'Türkiye', 'https://tarimportali.net/sergi/utoify-16/sergi-053-meral-yesilcicek.jpg', 549, 364, 1.5082),
('sergi-054', 'utoify-16', 'sergileme', 'sergileme', 68, 'Sergilemeye değer bulundu', 'Selected for exhibition', 'Metin ÖZTÜRK', 'Tarla İşleri', 'Trabzon', 'Türkiye', 'Türkiye', 'https://tarimportali.net/sergi/utoify-16/sergi-054-metin-ozturk.jpg', 549, 364, 1.5082),
('sergi-055', 'utoify-16', 'sergileme', 'sergileme', 69, 'Sergilemeye değer bulundu', 'Selected for exhibition', 'Muhammet Sinan KÖKCÜ', 'Cennet Hurması', 'Tokat', 'Türkiye', 'Türkiye', 'https://tarimportali.net/sergi/utoify-16/sergi-055-muhammet-sinan-kokcu.jpg', 549, 364, 1.5082),
('sergi-056', 'utoify-16', 'sergileme', 'sergileme', 70, 'Sergilemeye değer bulundu', 'Selected for exhibition', 'Murat CACİM', 'Mavi Yıldız Çiçeği Eşliğinde Gübreleme', 'Trabzon', 'Türkiye', 'Türkiye', 'https://tarimportali.net/sergi/utoify-16/sergi-056-murat-cacim.jpg', 549, 364, 1.5082),
('sergi-057', 'utoify-16', 'sergileme', 'sergileme', 71, 'Sergilemeye değer bulundu', 'Selected for exhibition', 'Murat DOĞAN', 'Zor Hayatlar', 'Van', 'Türkiye', 'Türkiye', 'https://tarimportali.net/sergi/utoify-16/sergi-057-murat-dogan.jpg', 549, 364, 1.5082),
('sergi-058', 'utoify-16', 'sergileme', 'sergileme', 72, 'Sergilemeye değer bulundu', 'Selected for exhibition', 'Mustafa DİNÇ', 'Nadas', 'Antalya', 'Türkiye', 'Türkiye', 'https://tarimportali.net/sergi/utoify-16/sergi-058-mustafa-dinc.jpg', 549, 364, 1.5082),
('sergi-059', 'utoify-16', 'sergileme', 'sergileme', 73, 'Sergilemeye değer bulundu', 'Selected for exhibition', 'Mustafa DİNÇ', 'Gül Toplama', 'Isparta', 'Türkiye', 'Türkiye', 'https://tarimportali.net/sergi/utoify-16/sergi-059-mustafa-dinc.jpg', 549, 364, 1.5082),
('sergi-060', 'utoify-16', 'sergileme', 'sergileme', 74, 'Sergilemeye değer bulundu', 'Selected for exhibition', 'Mustafa KILIÇ', 'Gelemiç Üzüm Bağı', 'Bursa', 'Türkiye', 'Türkiye', 'https://tarimportali.net/sergi/utoify-16/sergi-060-mustafa-kilic.jpg', 549, 364, 1.5082),
('sergi-061', 'utoify-16', 'sergileme', 'sergileme', 75, 'Sergilemeye değer bulundu', 'Selected for exhibition', 'Mustafa ZENGİN', 'Son Yaylacılar', 'Gümüşhane', 'Türkiye', 'Türkiye', 'https://tarimportali.net/sergi/utoify-16/sergi-061-mustafa-zengin.jpg', 549, 364, 1.5082),
('sergi-062', 'utoify-16', 'sergileme', 'sergileme', 76, 'Sergilemeye değer bulundu', 'Selected for exhibition', 'Muzaffer Murat İLHAN', 'Cennet Meyvesi', 'Denizli', 'Türkiye', 'Türkiye', 'https://tarimportali.net/sergi/utoify-16/sergi-062-muzaffer-murat-ilhan.jpg', 549, 364, 1.5082),
('sergi-063', 'utoify-16', 'sergileme', 'sergileme', 77, 'Sergilemeye değer bulundu', 'Selected for exhibition', 'Muzaffer Murat İLHAN', 'Sürü', 'Konya', 'Türkiye', 'Türkiye', 'https://tarimportali.net/sergi/utoify-16/sergi-063-muzaffer-murat-ilhan.jpg', 549, 364, 1.5082),
('sergi-064', 'utoify-16', 'sergileme', 'sergileme', 78, 'Sergilemeye değer bulundu', 'Selected for exhibition', 'Neşe ARI', 'Pekmez', 'Kırklareli', 'Türkiye', 'Türkiye', 'https://tarimportali.net/sergi/utoify-16/sergi-064-nese-ari.jpg', 549, 359, 1.5292),
('sergi-065', 'utoify-16', 'sergileme', 'sergileme', 79, 'Sergilemeye değer bulundu', 'Selected for exhibition', 'Nihal DÖNER', 'Ciğerci Biberi', 'Edirne', 'Türkiye', 'Türkiye', 'https://tarimportali.net/sergi/utoify-16/sergi-065-nihal-doner.jpg', 549, 364, 1.5082),
('sergi-066', 'utoify-16', 'sergileme', 'sergileme', 80, 'Sergilemeye değer bulundu', 'Selected for exhibition', 'Ningtai YU', 'Golden Duotian', null, 'Çin', 'China', 'https://tarimportali.net/sergi/utoify-16/sergi-066-ningtai-yu.jpg', 549, 364, 1.5082),
('sergi-067', 'utoify-16', 'sergileme', 'sergileme', 81, 'Sergilemeye değer bulundu', 'Selected for exhibition', 'Nuri ÇOBAN', 'Balıkçılık', 'İstanbul', 'Türkiye', 'Türkiye', 'https://tarimportali.net/sergi/utoify-16/sergi-067-nuri-coban.jpg', 549, 364, 1.5082),
('sergi-068', 'utoify-16', 'sergileme', 'sergileme', 82, 'Sergilemeye değer bulundu', 'Selected for exhibition', 'Olga KUNITSKAYA', 'Guardians of Tradition', null, 'Rusya', 'Russia', 'https://tarimportali.net/sergi/utoify-16/sergi-068-olga-kunitskaya.jpg', 549, 364, 1.5082),
('sergi-069', 'utoify-16', 'sergileme', 'sergileme', 83, 'Sergilemeye değer bulundu', 'Selected for exhibition', 'Olga KUNITSKAYA', 'Carrot Lovers', null, 'Rusya', 'Russia', 'https://tarimportali.net/sergi/utoify-16/sergi-069-olga-kunitskaya.jpg', 550, 733, 0.7503),
('sergi-070', 'utoify-16', 'sergileme', 'sergileme', 84, 'Sergilemeye değer bulundu', 'Selected for exhibition', 'Orhan KARTAL', 'Tandır Ekmeği', 'Batman', 'Türkiye', 'Türkiye', 'https://tarimportali.net/sergi/utoify-16/sergi-070-orhan-kartal.jpg', 549, 364, 1.5082),
('sergi-071', 'utoify-16', 'sergileme', 'sergileme', 85, 'Sergilemeye değer bulundu', 'Selected for exhibition', 'Orhan KÖSE', 'Lavanta', 'Isparta', 'Türkiye', 'Türkiye', 'https://tarimportali.net/sergi/utoify-16/sergi-071-orhan-kose.jpg', 549, 364, 1.5082),
('sergi-072', 'utoify-16', 'sergileme', 'sergileme', 86, 'Sergilemeye değer bulundu', 'Selected for exhibition', 'Özkan BİLGİN', 'Yaban Keçileri ve Dolunay', 'Van', 'Türkiye', 'Türkiye', 'https://tarimportali.net/sergi/utoify-16/sergi-072-ozkan-bilgin.jpg', 549, 364, 1.5082),
('sergi-073', 'utoify-16', 'sergileme', 'sergileme', 87, 'Sergilemeye değer bulundu', 'Selected for exhibition', 'Prabır Kumar DAS', 'Creative Packaging', null, 'Hindistan', 'India', 'https://tarimportali.net/sergi/utoify-16/sergi-073-prabir-kumar-das.jpg', 549, 364, 1.5082),
('sergi-074', 'utoify-16', 'sergileme', 'sergileme', 88, 'Sergilemeye değer bulundu', 'Selected for exhibition', 'Pranab BASAK', 'Golden Smile', null, 'Endonezya', 'Indonesia', 'https://tarimportali.net/sergi/utoify-16/sergi-074-pranab-basak.jpg', 549, 364, 1.5082),
('sergi-075', 'utoify-16', 'sergileme', 'sergileme', 89, 'Sergilemeye değer bulundu', 'Selected for exhibition', 'Qi CUI', 'Dancing Thin Noodles', null, 'Çin', 'China', 'https://tarimportali.net/sergi/utoify-16/sergi-075-qi-cui.jpg', 549, 741, 0.7409),
('sergi-076', 'utoify-16', 'sergileme', 'sergileme', 90, 'Sergilemeye değer bulundu', 'Selected for exhibition', 'Recep KOLCU', 'Sakız Enginar', 'İzmir', 'Türkiye', 'Türkiye', 'https://tarimportali.net/sergi/utoify-16/sergi-076-recep-kolcu.jpg', 549, 364, 1.5082),
('sergi-077', 'utoify-16', 'sergileme', 'sergileme', 91, 'Sergilemeye değer bulundu', 'Selected for exhibition', 'Reşat ÇİFTÇİ', 'Nure', 'Batman', 'Türkiye', 'Türkiye', 'https://tarimportali.net/sergi/utoify-16/sergi-077-resat-ciftci.jpg', 533, 355, 1.5014),
('sergi-078', 'utoify-16', 'sergileme', 'sergileme', 92, 'Sergilemeye değer bulundu', 'Selected for exhibition', 'Said Nuri SARGIN', 'Yörük Kadın', 'Antalya', 'Türkiye', 'Türkiye', 'https://tarimportali.net/sergi/utoify-16/sergi-078-said-nuri-sargin.jpg', 549, 364, 1.5082),
('sergi-079', 'utoify-16', 'sergileme', 'sergileme', 93, 'Sergilemeye değer bulundu', 'Selected for exhibition', 'Said Nuri SARGIN', 'Nesilden Nesile Biber Dizme', 'Denizli', 'Türkiye', 'Türkiye', 'https://tarimportali.net/sergi/utoify-16/sergi-079-said-nuri-sargin.jpg', 549, 364, 1.5082),
('sergi-080', 'utoify-16', 'sergileme', 'sergileme', 94, 'Sergilemeye değer bulundu', 'Selected for exhibition', 'Said Nuri SARGIN', 'Sağım', 'Hakkari', 'Türkiye', 'Türkiye', 'https://tarimportali.net/sergi/utoify-16/sergi-080-said-nuri-sargin.jpg', 549, 364, 1.5082),
('sergi-081', 'utoify-16', 'sergileme', 'sergileme', 95, 'Sergilemeye değer bulundu', 'Selected for exhibition', 'Sema MERMERTAŞ', 'Yün Eğirme', 'Erzincan', 'Türkiye', 'Türkiye', 'https://tarimportali.net/sergi/utoify-16/sergi-081-sema-mermertas.jpg', 549, 364, 1.5082),
('sergi-082', 'utoify-16', 'sergileme', 'sergileme', 96, 'Sergilemeye değer bulundu', 'Selected for exhibition', 'Serhat BÜRKE', 'Bingöl Yaylaları', 'Bingöl', 'Türkiye', 'Türkiye', 'https://tarimportali.net/sergi/utoify-16/sergi-082-serhat-burke.jpg', 549, 364, 1.5082),
('sergi-083', 'utoify-16', 'sergileme', 'sergileme', 97, 'Sergilemeye değer bulundu', 'Selected for exhibition', 'Serkan DALDAL', 'Fatma Teyze', 'Konya', 'Türkiye', 'Türkiye', 'https://tarimportali.net/sergi/utoify-16/sergi-083-serkan-daldal.jpg', 549, 364, 1.5082),
('sergi-084', 'utoify-16', 'sergileme', 'sergileme', 98, 'Sergilemeye değer bulundu', 'Selected for exhibition', 'Seyed Mehrdad SHARİFİ', 'Harvesting Hands', null, 'İran', 'Iran', 'https://tarimportali.net/sergi/utoify-16/sergi-084-seyed-mehrdad-sharifi.jpg', 549, 364, 1.5082),
('sergi-085', 'utoify-16', 'sergileme', 'sergileme', 99, 'Sergilemeye değer bulundu', 'Selected for exhibition', 'Seyit KONYALI', 'Gölge Kurutma', 'Konya', 'Türkiye', 'Türkiye', 'https://tarimportali.net/sergi/utoify-16/sergi-085-seyit-konyali.jpg', 549, 364, 1.5082),
('sergi-086', 'utoify-16', 'sergileme', 'sergileme', 100, 'Sergilemeye değer bulundu', 'Selected for exhibition', 'Seyit KONYALI', 'Ot Boyayan Kadınlar', 'Konya', 'Türkiye', 'Türkiye', 'https://tarimportali.net/sergi/utoify-16/sergi-086-seyit-konyali.jpg', 549, 364, 1.5082),
('sergi-087', 'utoify-16', 'sergileme', 'sergileme', 101, 'Sergilemeye değer bulundu', 'Selected for exhibition', 'So Pyay LYNN', 'Sorting the Colors of Harvest', null, 'Myanmar', 'Myanmar', 'https://tarimportali.net/sergi/utoify-16/sergi-087-so-pyay-lynn.jpg', 549, 362, 1.5166),
('sergi-088', 'utoify-16', 'sergileme', 'sergileme', 102, 'Sergilemeye değer bulundu', 'Selected for exhibition', 'Şevki KARACA', 'Susam Hasatı', 'Balıkesir', 'Türkiye', 'Türkiye', 'https://tarimportali.net/sergi/utoify-16/sergi-088-sevki-karaca.jpg', 549, 364, 1.5082),
('sergi-089', 'utoify-16', 'sergileme', 'sergileme', 103, 'Sergilemeye değer bulundu', 'Selected for exhibition', 'Şevki KARACA', 'Bahçe İlaçlama', 'Bursa', 'Türkiye', 'Türkiye', 'https://tarimportali.net/sergi/utoify-16/sergi-089-sevki-karaca.jpg', 549, 364, 1.5082),
('sergi-090', 'utoify-16', 'sergileme', 'sergileme', 104, 'Sergilemeye değer bulundu', 'Selected for exhibition', 'Ufuk TURPCAN', 'İçi Renk Dışı Emek', 'Afyonkarahisar', 'Türkiye', 'Türkiye', 'https://tarimportali.net/sergi/utoify-16/sergi-090-ufuk-turpcan.jpg', 549, 364, 1.5082),
('sergi-091', 'utoify-16', 'sergileme', 'sergileme', 105, 'Sergilemeye değer bulundu', 'Selected for exhibition', 'Ufuk TURPCAN', 'Doğa, Tarım ve Temiz Enerjinin Geometrisi', null, 'Hollanda', 'Netherlands', 'https://tarimportali.net/sergi/utoify-16/sergi-091-ufuk-turpcan.jpg', 549, 364, 1.5082),
('sergi-092', 'utoify-16', 'sergileme', 'sergileme', 106, 'Sergilemeye değer bulundu', 'Selected for exhibition', 'Ufuk TURPCAN', 'Hollanda Lale Tarlalarında Gökkuşağı Dansı', null, 'Hollanda', 'Netherlands', 'https://tarimportali.net/sergi/utoify-16/sergi-092-ufuk-turpcan.jpg', 549, 364, 1.5082),
('sergi-093', 'utoify-16', 'sergileme', 'sergileme', 107, 'Sergilemeye değer bulundu', 'Selected for exhibition', 'Uğur ÇİMEN', 'Kırmızı Emek', 'Gaziantep', 'Türkiye', 'Türkiye', 'https://tarimportali.net/sergi/utoify-16/sergi-093-ugur-cimen.jpg', 549, 364, 1.5082),
('sergi-094', 'utoify-16', 'sergileme', 'sergileme', 108, 'Sergilemeye değer bulundu', 'Selected for exhibition', 'Uğur SAĞIROĞLU', 'Tarlada', 'Erzurum', 'Türkiye', 'Türkiye', 'https://tarimportali.net/sergi/utoify-16/sergi-094-ugur-sagiroglu.jpg', 557, 355, 1.569),
('sergi-095', 'utoify-16', 'sergileme', 'sergileme', 109, 'Sergilemeye değer bulundu', 'Selected for exhibition', 'Ümit KATEKE', 'Niksar’ ın Kavakları', 'Tokat', 'Türkiye', 'Türkiye', 'https://tarimportali.net/sergi/utoify-16/sergi-095-umit-kateke.jpg', 549, 364, 1.5082),
('sergi-096', 'utoify-16', 'sergileme', 'sergileme', 110, 'Sergilemeye değer bulundu', 'Selected for exhibition', 'Xuzhong LİU', 'Dusk at Chongwu Coast', null, 'Çin', 'China', 'https://tarimportali.net/sergi/utoify-16/sergi-096-xuzhong-liu.jpg', 549, 364, 1.5082),
('sergi-097', 'utoify-16', 'sergileme', 'sergileme', 111, 'Sergilemeye değer bulundu', 'Selected for exhibition', 'Yaofu WEİ', 'Golden Autumn in Hemu', null, 'Çin', 'China', 'https://tarimportali.net/sergi/utoify-16/sergi-097-yaofu-wei.jpg', 549, 364, 1.5082),
('sergi-098', 'utoify-16', 'sergileme', 'sergileme', 112, 'Sergilemeye değer bulundu', 'Selected for exhibition', 'Yüksel YAVUZ', 'Sürü', 'Gümüşhane', 'Türkiye', 'Türkiye', 'https://tarimportali.net/sergi/utoify-16/sergi-098-yuksel-yavuz.jpg', 549, 357, 1.5378),
('sergi-099', 'utoify-16', 'sergileme', 'sergileme', 113, 'Sergilemeye değer bulundu', 'Selected for exhibition', 'Yüksel YAVUZ', 'Yürüyüş', 'Trabzon', 'Türkiye', 'Türkiye', 'https://tarimportali.net/sergi/utoify-16/sergi-099-yuksel-yavuz.jpg', 549, 364, 1.5082),
('sergi-100', 'utoify-16', 'sergileme', 'sergileme', 114, 'Sergilemeye değer bulundu', 'Selected for exhibition', 'Zhenling WANG', 'Weave Dreams in Water Caltrop Pond', null, 'Çin', 'China', 'https://tarimportali.net/sergi/utoify-16/sergi-100-zhenling-wang.jpg', 549, 364, 1.5082)
on conflict (kod) do update set
  fotografci = excluded.fotografci, eser = excluded.eser,
  il = excluded.il, adres = excluded.adres,
  odul_tr = excluded.odul_tr, odul_en = excluded.odul_en;

-- ─── Anasayfa bandının günlük seçimi ─────────────────────────────────────
-- Band 114 kareyi gösteremez; on iki tane gösteriyor. Hangi on iki?
--
-- İlk akla gelen "ilk on iki" idi ve yanlış: band aylarca aynı kalır, geri
-- kalan 102 kare hiç görünmez. Rastgele seçim de yanlış: aynı gün sayfayı
-- iki kez açan okur iki farklı sergi görür, kaydırıp geri dönünce kare
-- kaybolur.
--
-- Seçim GÜNE göre belirlenimli: md5(kod || tarih). Aynı gün herkese aynı on
-- iki kare, ertesi gün başka on iki. Sunucuda, çünkü istemcide yapılsaydı
-- cihazın saat dilimi seçimi değiştirirdi.
create or replace function public.sergi_gunun_secimi(
  p_yarisma text default null, p_adet int default 12)
returns setof public.sergi_eserleri
language sql stable security definer set search_path = public as $$
  select e.* from public.sergi_eserleri e
    join public.sergi_yarismalari y on y.kod = e.yarisma_kod
   where e.yayinda and y.yayinda
     and (p_yarisma is null or e.yarisma_kod = p_yarisma)
   order by md5(e.kod || current_date::text)
   limit greatest(p_adet, 0);
$$;

comment on function public.sergi_gunun_secimi is
  'Anasayfa bandının günlük karesi. Gün başına belirlenimli: aynı gün herkese '
  'aynı seçim, ertesi gün başkası.';

grant execute on function public.sergi_gunun_secimi(text, int) to anon, authenticated;

-- ─── Kendi kendini sınama ────────────────────────────────────────────────
do $kontrol$
declare n int;
begin
  select count(*) into n from public.sergi_eserleri where yarisma_kod = 'utoify-16';
  if n <> 114 then
    raise exception '114 eser bekleniyordu, % bulundu', n;
  end if;
  select count(*) into n from public.sergi_eserleri
   where yarisma_kod = 'utoify-16' and tur = 'odul';
  if n <> 14 then
    raise exception '14 ödül bekleniyordu, % bulundu', n;
  end if;
  -- Künye kısıtı GERÇEKTEN reddediyor mu? Reddetmiyorsa künyesiz kare
  -- sızabilir ve bunu hiçbir şey hata vermeden yapar.
  begin
    insert into public.sergi_eserleri (kod, yarisma_kod, tur, kategori, sira,
      odul_tr, odul_en, fotografci, eser, ulke_tr, ulke_en, adres)
    values ('__deneme__', 'utoify-16', 'odul', 'genel', 999, 'x', 'x',
            '   ', 'x', 'Türkiye', 'Türkiye', 'x');
    raise exception 'künye kısıtı çalışmıyor — boş fotoğrafçı adı kabul edildi';
  exception when check_violation then null;
  end;
  if exists (select 1 from public.sergi_eserleri where kod = '__deneme__') then
    delete from public.sergi_eserleri where kod = '__deneme__';
    raise exception 'deneme satırı yazıldı';
  end if;
  -- Günlük seçim gerçekten on iki kare veriyor mu?
  --
  -- Fonksiyon `yayinda` süzüyor ve yarışma bilerek yayında DEĞİL (bkz.
  -- başlıktaki sıra notu). Sınama için geçici olarak açılıp kapatılıyor:
  -- "yayında değil, o yüzden sınamadım" demek, fonksiyonun bozuk olduğunu
  -- yayına alındığı gün öğrenmek demekti.
  update public.sergi_yarismalari set yayinda = true where kod = 'utoify-16';
  select count(*) into n from public.sergi_gunun_secimi('utoify-16', 12);
  update public.sergi_yarismalari set yayinda = false where kod = 'utoify-16';
  if n <> 12 then
    raise exception 'günlük seçim 12 kare vermedi: %', n;
  end if;

  -- Ve yayında DEĞİLKEN hiçbir şey dönmemeli: bayrak gerçekten kapatıyor mu?
  select count(*) into n from public.sergi_gunun_secimi('utoify-16', 12);
  if n <> 0 then
    raise exception 'yayinda=false iken % kare döndü — bayrak çalışmıyor', n;
  end if;
end
$kontrol$;
