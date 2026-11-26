#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Uşak düzeltmesini göç dosyasına çevirir.

Girdi:  supabase/seed/dossier_turkseker.sql (seed_dossier.mjs üretir)
Çıktı:  supabase/migrations/20261126120000_turkseker_usak_duzeltme.sql

NEDEN SEED'İN TAMAMI. Yalnız dört gövdeyi güncelleyen küçük bir UPDATE de
yazılabilirdi, ama o zaman metin iki yerde dururdu: metin_tr.md'de ve göçün
içinde. Depo zaten "seed → göç" yolundan gidiyor ve seed'in upsert'i
yayındaki dosya için GÜVENLİ:

  status       = draft gelirse yayındaki durumu KORUR
  starts_at    = coalesce(var olan, yeni)   → pencere kaymaz
  ends_at      = coalesce(var olan, yeni)   → sayaç sıfırlanmaz
  published_at = coalesce(var olan, yeni)

seed_dossier.mjs'in kendi yorumu bu durumu adıyla anıyor: "yayındaki bir
dosyanın metninde yazım hatası düzeltmek için seed'i yeniden çalıştırmak,
28 günlük sayacı sıfırlamamalı."

begin/commit SÖKÜLÜYOR. CLI her göçü tek işlemde koşturuyor; içeride kalan
bir commit, sondaki sağlamalar düşse bile içeriği yazılı bırakırdı.

    python3 _raw/kur_duzeltme_gocu.py
"""
import pathlib
import re
import sys

# _raw → turkseker → dossiers → content → depo kökü
KOK = pathlib.Path(__file__).resolve().parents[4]
SEED = KOK / "supabase" / "seed" / "dossier_turkseker.sql"
HEDEF = (KOK / "supabase" / "migrations" /
         "20261126120000_turkseker_usak_duzeltme.sql")

BASLIK = """-- TÜRKŞEKER — Kurum Dosyası Sayı 07 · UŞAK DÜZELTMESİ
--
-- 26 Kasım 2026. Dosya yayına girdikten SONRA bulunan iki maddi hatayı
-- düzeltir. Kullanıcı onayı alındı; düzeltme iki dilde.
--
-- NE YANLIŞTI. İkisi de aynı yanlış okumadan doğdu: 2025/26 kota çizelgesi
-- ŞİRKETLERİ sayıyor, fabrikaları değil. Çizelgede "KAMU TÜRKŞEKER
-- (14 Fabrika)" tek satır — Uşak adı o yüzden listede görünmüyor. Buradan
-- "Uşak'ta fabrika yok" sonucu çıkarılmış.
--
--   §2  "Bugün Uşak'ta pancar şekeri üreten bir fabrika bulunmuyor."
--   §19 "İki fabrika da artık TÜRKŞEKER'e ait değil."
--
-- KAYNAK NE DİYOR. TÜRKŞEKER haberi, 22 Eylül 2026 törenleri:
--   "Türkiye Şeker Fabrikaları A.Ş.'ye (TÜRKŞEKER) bağlı Uşak, Elazığ ve
--    Ağrı Şeker Fabrikalarında 2026/2027 pancar alımı ve işleme kampanyası
--    22 Eylül'de yapılan törenlerle başladı."
--   "…Nuri Şeker Uşak Şeker Fabrikası … 101. kampanyasına başladı."
--
-- Alpullu için "artık TÜRKŞEKER'e ait değil" DOĞRUYDU — 2018'de satıldı,
-- bugün Binbirgıda'nın. Hata Uşak'ı onunla aynı kefeye koymaktı. Genel
-- müdürün 12 Kasım 2026 sözü de yalnız "bu iki fabrikada 101'inci kampanya
-- yürütülüyor" diyor; mülkiyete dair bir cümle kaynakta YOK.
--
-- PENCEREYE DOKUNMAZ. Seed'in upsert'i starts_at / ends_at / published_at
-- için coalesce kullanıyor ve 'draft' gelse bile yayındaki durumu koruyor.
-- Dosya 2026-11-25T21:00Z'de açıldı, 2026-12-09T21:00Z'de kapanıyor;
-- aşağıdaki sağlama bunu sınıyor.
--
-- DAMGA: uygulanmış son göç 20261123151000. Bu damga ondan sonra, yoksa
-- CLI göçü sessizce atlayıp "Remote database is up to date" derdi.
--
-- ONAY ALINDIĞINDA:
--   supabase db push
--   python3 scripts/devir_sonrasi.py      # bayrak zaten published, dokunmaz
--   ./deploy.sh --hosting
"""

SAGLAMA = """
-- ── DÜZELTME SAĞLAMALARI ───────────────────────────────────────────────
-- Seed'in kendi "22 bölüm" sağlaması yukarıda. Buradakiler düzeltmenin
-- GERÇEKTEN yazıldığını ve pencerenin kaymadığını sınıyor. Düşerse göç
-- tümüyle geri alınır.
do $duzeltme$
declare
  d   public.country_dossiers;
  g2  text;
  g19 text;
  e2  text;
  e19 text;
begin
  -- `found` KULLANILIYOR, `d is null` DEĞİL. Bileşik bir değişken için
  -- IS NULL yalnız BÜTÜN alanlar null'sa doğru; satır yokken de öyle olur
  -- ama niyeti anlatmıyor ve tek alanı dolu bozuk bir satırı kaçırırdı.
  select * into d from public.country_dossiers where slug = 'turkseker';
  if not found then
    raise exception 'turkseker satırı yok';
  end if;

  if d.status <> 'published' then
    raise exception 'Durum published olmalıydı, % bulundu', d.status;
  end if;
  if d.starts_at <> timestamptz '2026-11-25T21:00:00Z' then
    raise exception 'Pencere başlangıcı kaydı: %', d.starts_at;
  end if;
  if d.ends_at <> timestamptz '2026-12-09T21:00:00Z' then
    raise exception 'Pencere bitişi kaydı: %', d.ends_at;
  end if;

  select s.body_tr, s.body_en into g2, e2
    from public.dossier_sections s
   where s.dossier_id = d.id and s.ord = 2;
  select s.body_tr, s.body_en into g19, e19
    from public.dossier_sections s
   where s.dossier_id = d.id and s.ord = 19;

  -- Hatalı ifadeler GİTMİŞ olmalı.
  if g2  like '%pancar şekeri üreten bir fabrika bulunmuyor%' then
    raise exception '§2 TR hatalı ifade duruyor';
  end if;
  if e2  like '%no beet sugar factory at Uşak%' then
    raise exception '§2 EN hatalı ifade duruyor';
  end if;
  if g19 like '%İki fabrika da artık%' then
    raise exception '§19 TR hatalı ifade duruyor';
  end if;
  if e19 like '%Neither belongs to TÜRKŞEKER%' then
    raise exception '§19 EN hatalı ifade duruyor';
  end if;

  -- Düzeltilmiş ifadeler YAZILMIŞ olmalı. Yokluk sınaması tek başına
  -- yetmez: bölüm bomboş da olsa geçerdi.
  if g2  not like '%Nuri%Şeker Uşak Şeker Fabrikası%' then
    raise exception '§2 TR düzeltmesi yazılmamış';
  end if;
  if e2  not like '%Nuri Şeker Uşak Sugar Factory%' then
    raise exception '§2 EN düzeltmesi yazılmamış';
  end if;
  if g19 not like '%Uşak hâlâ TÜRKŞEKER%' then
    raise exception '§19 TR düzeltmesi yazılmamış';
  end if;
  if e19 not like '%Uşak still belongs to TÜRKŞEKER%' then
    raise exception '§19 EN düzeltmesi yazılmamış';
  end if;

  raise notice 'Uşak düzeltmesi dört paragrafta doğrulandı · pencere korundu';
end
$duzeltme$;
"""


def main():
    if not SEED.exists():
        sys.exit("✗ seed yok — önce: node content/dossiers/seed_dossier.mjs turkseker")
    sql = SEED.read_text(encoding="utf-8")

    # DIŞ İŞLEM SÖKÜLÜYOR. Sayım korumalı: beklenmeyen sayıda bulursak
    # dosyayı hiç yazmıyoruz.
    for kalip, ad in ((r"(?m)^begin;\s*$", "begin;"), (r"(?m)^commit;\s*$", "commit;")):
        n = len(re.findall(kalip, sql))
        if n != 1:
            sys.exit("✗ seed içinde %d adet %s (1 bekleniyordu)" % (n, ad))
        sql = re.sub(kalip, "", sql, count=1)

    if "pancar şekeri üreten bir fabrika bulunmuyor" in sql:
        sys.exit("✗ seed hâlâ hatalı §2 metnini taşıyor — duzelt_usak.py koştu mu?")
    if "İki fabrika da artık" in sql:
        sys.exit("✗ seed hâlâ hatalı §19 metnini taşıyor")

    HEDEF.write_text(BASLIK + "\n" + sql.strip() + "\n" + SAGLAMA, encoding="utf-8")
    print("✓ %s" % HEDEF.name)
    print("  %.1f KB · dış begin/commit söküldü · 12 sağlama eklendi"
          % (HEDEF.stat().st_size / 1024))
    print("\n  Onay verilirse:  supabase db push")
    return 0


sys.exit(main())
