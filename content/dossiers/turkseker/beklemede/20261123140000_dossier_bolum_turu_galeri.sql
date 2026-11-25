-- Bölüm türüne 'galeri' ekleniyor — Türkşeker dosyasının ÖN KOŞULU
--
-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  BU DOSYA supabase/migrations/ ALTINDA DEĞİL — ÖYLE OLMASI GEREKİYOR ║
-- ╚══════════════════════════════════════════════════════════════════════╝
--
-- NEDEN VAR. 20260821100000 bölüm türü kısıtını dört türle kurdu:
-- anlati, belge, veri, akis. Türkşeker (Kurum Dosyası Sayı 07) dizinin ilk
-- galerisini getiriyor ve galeri bölümü `tur = 'galeri'` taşıyor.
--
-- Tür DÖRT yere tanıtılmıştı — Flutter modelindeki DossierSection._turler,
-- seed_dossier.mjs'teki GECERLI_TURLER, galeri denetçisi ve yayın
-- denetçisi — ama BEŞİNCİSİ, veritabanı kısıtı, atlanmıştı. 24 Kasım
-- 2026'da `supabase db push` tam bu yüzden düştü: içerik göçü galeri
-- bölümünü yazarken dossier_sections_tur_check'i ihlal etti ve göç bütün
-- olarak geri alındı. Veritabanına hiçbir şey yazılmadı.
--
-- DAMGA İÇERİK GÖÇÜNDEN ÖNCE. Bu dosya 20261123140000; içerik göçü
-- 20261123150000. CLI damga sırasına göre uyguluyor, yani kısıt içerik
-- yazılmadan ÖNCE genişliyor. Damga, uygulanmış son göçten (20261123120000)
-- de sonra: CLI daha eski damgalı bir göçü sessizce atlıyor.
--
-- ÜÇÜ BİRLİKTE GİDER. Bu dosya geride kalırsa içerik göçü yine düşer;
-- dogrula_goc.py 5. kural damga sırasını, 4. kural da üçünün beklemede
-- durduğunu sınıyor.
--
-- ONAY ALINDIĞINDA, SIRAYLA:
--   ls supabase/migrations/ | tail
--   mv content/dossiers/turkseker/beklemede/*.sql supabase/migrations/
--   supabase db push          # listede ÜÇ göç görünmeli
--
-- İçteki begin/commit yok: CLI her göçü tek işlemde çalıştırıyor.

-- ── Kısıt genişliyor ──────────────────────────────────────────────────────
-- DROP + ADD, ALTER değil: PostgreSQL'de bir CHECK kısıtının koşulu
-- yerinde değiştirilemiyor.
alter table public.dossier_sections
  drop constraint if exists dossier_sections_tur_check;

alter table public.dossier_sections
  add constraint dossier_sections_tur_check
  check (tur in ('anlati', 'belge', 'veri', 'akis', 'galeri'));

-- ── Sağlamalar ────────────────────────────────────────────────────────────
do $kontrol$
declare
  tanim text;
  t     text;
begin
  select pg_get_constraintdef(oid) into tanim
    from pg_constraint
   where conname = 'dossier_sections_tur_check'
     and conrelid = 'public.dossier_sections'::regclass;

  if tanim is null then
    raise exception 'dossier_sections_tur_check kurulamadı';
  end if;

  -- BEŞ TÜRÜN HEPSİ ARANIYOR, yalnız galeri değil. Kısıt yeniden
  -- kurulurken eski bir tür unutulsaydı hata burada değil, aylar sonra o
  -- türü kullanan bir dosyada çıkardı.
  foreach t in array array['anlati', 'belge', 'veri', 'akis', 'galeri'] loop
    if position('''' || t || '''' in tanim) = 0 then
      raise exception 'dossier_sections_tur_check % turunu tanimiyor: %', t, tanim;
    end if;
  end loop;

  -- Mevcut satırların hiçbiri kısıt dışında kalmadı.
  if exists (select 1 from public.dossier_sections
              where tur not in ('anlati', 'belge', 'veri', 'akis', 'galeri')) then
    raise exception 'dossier_sections icinde kisit disi tur var';
  end if;
end
$kontrol$;
