-- Turkuaz Bağlantısallık Girişimi — CANLI ÖRTÜ
--
-- Sayfanın verisi iki katmanlı ve bu ayrım bilinçli.
--
--   GÖMÜLÜ KATMAN (taban)  content/turkuaz_nexus/veri.json → derlemeye giren
--     Dart sabiti. Kaynağı sabit bir belgeye bağlı olan her şey burada: üç
--     sütun, altı gerekçe rakamı, Türkiye'nin modeli, sesler, tepkiler,
--     kaynakça. Bunlar FAO'nun kurucu belgesi ve IISD tutanağıyla kilitli;
--     değişmeleri için yeni bir belge yayımlanması gerekir, o da yeni bir
--     dağıtım demektir. Ağ olmadan da çizilirler.
--
--   CANLI KATMAN (bu tablo)  Zamanla değişecek ve dağıtım beklememesi gereken
--     iki şey: taahhüt takipçisindeki halkaların DURUMU ve "henüz
--     bilinmeyenler" listesinin çözülüp çözülmediği.
--
-- Tablo bir ÖRTÜ, bir kopya değil. Yalnızca gömülü katmandan FARKLI olanı
-- taşıyor. Boşsa ya da sorgu düşerse sayfa eksiksiz çizilir — yalnızca 12
-- Kasım 2026 fotoğrafını gösterir. Bu, portalın tipik arıza imzasına karşı
-- alınmış bir tedbir: burada hiçbir şey hata vermiyor, sessizce eksiliyor.
-- Veriyi tablonun TAMAMINA koymak, tablo düşünce sayfayı boşaltırdı.
--
-- NEDEN BU İKİSİ CANLI:
--   · 10 Kasım lansmanı yapıldı ama sonuç belgesi yayımlanmadı. Yayımlandığı
--     gün halkanın durumu "gerçekleşti"ye çevrilecek. Bu bir dağıtımı
--     beklememeli.
--   · Katılımcı ülke listesi, bütçe ve sayısal hedefler bugün yok. Biri
--     açıklandığında o kalem "çözüldü" olup takipçiye taşınacak.
--
-- YAZMA KİMDE: Kullanıcı 12 Kasım 2026'da (a) seçeneğini seçti — güncellemeyi
-- biz yapıyoruz, panele ayrı bir düzenleme ekranı eklenmedi. Bu yüzden yazma
-- politikası YOK (politika yok = yazma kapalı); satırlar göçle ya da yetkili
-- oturumla yazılıyor. Panele ekran eklenirse authenticated update/insert
-- politikası o zaman açılır.

create table if not exists public.tni_ortu (
  -- 'halka:<kod>' ya da 'bilinmeyen:<kod>'. Gömülü katmandaki kodla eşleşen
  -- satır onu EZER; eşleşmeyen satır YENİ kalem olarak eklenir.
  kod          text primary key,
  tur          text not null,
  durum        text,
  baslik_tr    text,
  baslik_en    text,
  metin_tr     text,
  metin_en     text,
  -- Yalnız yeni halka için. Gömülü halkanın tarihi gömülü katmanda kalır.
  tarih        date,
  kaynak       text,
  sira         integer not null default 100,
  yayinda      boolean not null default true,
  guncellendi  timestamptz not null default now()
);

alter table public.tni_ortu
  drop constraint if exists tni_ortu_tur;
alter table public.tni_ortu
  add constraint tni_ortu_tur check (tur in ('halka', 'bilinmeyen'));

-- Durum sözlüğü TÜRE BAĞLI. Tek bir listeye izin verilseydi bir halkaya
-- "çözüldü", bir bilinmeyene "bekliyor" yazılabilirdi; çizici o değerleri
-- tanımaz ve kalem SESSİZCE çizilmezdi.
alter table public.tni_ortu
  drop constraint if exists tni_ortu_durum;
alter table public.tni_ortu
  add constraint tni_ortu_durum check (
    durum is null
    or (tur = 'halka'      and durum in ('gerceklesti', 'ciktisi_yayimlanmadi', 'bekliyor'))
    or (tur = 'bilinmeyen' and durum in ('acik', 'cozuldu'))
  );

-- İki dillilik pazarlık dışı: tek dilli bir kalem İngilizce sayfada boşluk
-- bırakır. Alan çifti ya tam ya hiç.
alter table public.tni_ortu
  drop constraint if exists tni_ortu_iki_dil;
alter table public.tni_ortu
  add constraint tni_ortu_iki_dil check (
    (baslik_tr is null) = (baslik_en is null)
    and (metin_tr is null) = (metin_en is null)
  );

-- Bir satır ya DURUM EZİYOR ya da YENİ KALEM getiriyor. İkisini de yapmayan
-- satır tabloda yer tutar, sayfada hiçbir şey değiştirmez.
alter table public.tni_ortu
  drop constraint if exists tni_ortu_bos_degil;
alter table public.tni_ortu
  add constraint tni_ortu_bos_degil check (
    durum is not null or baslik_tr is not null
  );

-- Yeni halkanın tarihi olmak zorunda: takipçi halkaları tarihe göre diziyor,
-- tarihsiz halka çizelgede yerini bulamaz.
alter table public.tni_ortu
  drop constraint if exists tni_ortu_yeni_halka_tarih;
alter table public.tni_ortu
  add constraint tni_ortu_yeni_halka_tarih check (
    tur <> 'halka' or baslik_tr is null or tarih is not null
  );

alter table public.tni_ortu enable row level security;

drop policy if exists "anon tni ortusunu okur" on public.tni_ortu;
create policy "anon tni ortusunu okur"
  on public.tni_ortu for select
  to anon using (yayinda);

drop policy if exists "authenticated tni ortusunu okur" on public.tni_ortu;
create policy "authenticated tni ortusunu okur"
  on public.tni_ortu for select
  to authenticated using (true);

comment on table public.tni_ortu is
  'Turkuaz Bağlantısallık Girişimi sayfasının canlı örtüsü. Gömülü veri.json '
  'tabandır; buradaki satırlar yalnızca DEĞİŞENİ taşır. Tablo boşsa sayfa '
  'eksiksiz çizilir.';
comment on column public.tni_ortu.kod is
  'halka:<kod> ya da bilinmeyen:<kod>. Gömülü kodla eşleşirse ezer, eşleşmezse ekler.';
comment on column public.tni_ortu.durum is
  'halka: gerceklesti | ciktisi_yayimlanmadi | bekliyor — bilinmeyen: acik | cozuldu';

-- ─── Kendi kendini sınama ────────────────────────────────────────────────
-- Göç "uygulandı" demesi tabloların işe yaradığı anlamına gelmiyor. Aşağıdaki
-- blok kısıtların GERÇEKTEN reddettiğini sınıyor; reddetmezlerse göç düşüyor.
do $kontrol$
begin
  if not exists (select 1 from information_schema.tables
                  where table_schema = 'public' and table_name = 'tni_ortu') then
    raise exception 'tni_ortu tablosu kurulmadı';
  end if;

  -- 1) Yanlış tür reddedilmeli
  begin
    insert into public.tni_ortu (kod, tur, durum) values ('__dn1__', 'duyuru', 'bekliyor');
    raise exception 'tur kısıtı çalışmıyor — gecersiz tur kabul edildi';
  exception when check_violation then null;
  end;

  -- 2) Halkaya bilinmeyen durumu yazılamamalı
  begin
    insert into public.tni_ortu (kod, tur, durum) values ('__dn2__', 'halka', 'cozuldu');
    raise exception 'durum kısıtı çalışmıyor — halkaya cozuldu yazıldı';
  exception when check_violation then null;
  end;

  -- 3) Tek dilli başlık reddedilmeli
  begin
    insert into public.tni_ortu (kod, tur, baslik_tr, tarih)
    values ('__dn3__', 'halka', 'yalnız Türkçe', current_date);
    raise exception 'iki dil kısıtı çalışmıyor — tek dilli kalem kabul edildi';
  exception when check_violation then null;
  end;

  -- 4) Ne durum ne başlık taşıyan satır reddedilmeli
  begin
    insert into public.tni_ortu (kod, tur, kaynak) values ('__dn4__', 'bilinmeyen', 'hiçbir şey');
    raise exception 'bos_degil kısıtı çalışmıyor — boş satır kabul edildi';
  exception when check_violation then null;
  end;

  -- 5) Tarihsiz YENİ halka reddedilmeli
  begin
    insert into public.tni_ortu (kod, tur, baslik_tr, baslik_en)
    values ('__dn5__', 'halka', 'tarihsiz', 'undated');
    raise exception 'yeni_halka_tarih kısıtı çalışmıyor — tarihsiz halka kabul edildi';
  exception when check_violation then null;
  end;

  -- 6) Geçerli satır KABUL EDİLMELİ. Kısıtlar her şeyi reddediyorsa tablo
  --    işe yaramaz; o hâli yukarıdaki beş deneme yakalamaz.
  insert into public.tni_ortu (kod, tur, durum, kaynak)
  values ('__dn6__', 'halka', 'gerceklesti', 'kurulum denemesi');
  if not exists (select 1 from public.tni_ortu where kod = '__dn6__') then
    raise exception 'geçerli satır yazılamadı';
  end if;
  delete from public.tni_ortu where kod like '\_\_dn%' escape '\';

  if exists (select 1 from public.tni_ortu where kod like '\_\_dn%' escape '\') then
    raise exception 'deneme satırları silinemedi';
  end if;
end
$kontrol$;
