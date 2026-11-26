#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Azize düzeltmesini göç dosyasına çevirir.

kur_duzeltme_gocu.py ile aynı yoldan gidiyor (seed'in tamamı + sağlamalar);
ayrı bir betik, çünkü her göçün üreticisi o göçün kaydı olarak kalıyor.
Depoda bu alışkanlık var: galeri_ek.py, galeri_cikar.py, galeri_eleme.py,
birlestir.py — her içerik değişiminin kendi gerekçeli betiği.

Altyazı dossier_sections'ta DEĞİL, country_dossiers.data jsonb'sinin
içinde (data.galeri.kareler[...].alt_tr). Sağlama bu yüzden data::text'e
bakıyor.

    python3 _raw/kur_goc_azize.py
"""
import pathlib
import re
import sys

KOK = pathlib.Path(__file__).resolve().parents[4]
SEED = KOK / "supabase" / "seed" / "dossier_turkseker.sql"
HEDEF = (KOK / "supabase" / "migrations" /
         "20261126150000_turkseker_azize_akrabalik.sql")

BASLIK = """-- TÜRKŞEKER — Kurum Dosyası Sayı 07 · AZİZE–BETÜL AKRABALIĞI
--
-- 26 Kasım 2026. Galeri altyazısı akrabalığı ters yazıyordu.
--
--   eski: "Aynı fotokartın arka yüzü: Azize'nin ablası Betül'e mektubu."
--   yeni: "Aynı fotokartın arka yüzü: Azize'den kardeşi Betül'e mektup."
--
-- NEDEN. Kare (galeri_salt_hasat_mektup) video için 16:9 tuvale
-- yerleştirilince el yazısı okunur hâle geldi. İmza şöyle:
--
--     "...senden mektup beklerim gözlerinden öperim ablan
--      Azize"
--
-- "ablan Azize" = Azize ABLA, Betül KARDEŞ. Hitap da bunu destekliyor:
-- "Benim canım Betülüm", "Betülcüm". Altyazı tersini söylüyordu.
--
-- Kare galeriye SALT kaydının başlığıyla yerleştirilmişti; akrabalık
-- kayıttan değil yorumdan gelmiş. Izgarada 560 piksele indiği için el
-- yazısı o ölçekte okunmuyordu.
--
-- İNGİLİZCESİ YANLIŞ DEĞİLDİ ("her sister Betül" — İngilizce abla/kardeş
-- ayrımı yapmıyor); artık bildiğimiz için "younger" eklendi.
--
-- PENCEREYE DOKUNMAZ: seed'in upsert'i starts_at / ends_at / published_at
-- için coalesce kullanıyor, 'draft' gelse bile yayındaki durumu koruyor.
--
-- DAMGA: uygulanmış son göç 20261126120000 (Uşak düzeltmesi). Bu ondan
-- sonra, yoksa CLI sessizce atlardı.
"""

SAGLAMA = """
-- ── AKRABALIK SAĞLAMALARI ──────────────────────────────────────────────
do $azize$
declare d public.country_dossiers;
begin
  select * into d from public.country_dossiers where slug = 'turkseker';
  if not found then
    raise exception 'turkseker satırı yok';
  end if;

  if d.status <> 'published' then
    raise exception 'Durum published olmalıydı, % bulundu', d.status;
  end if;
  if d.starts_at <> timestamptz '2026-11-25T21:00:00Z'
     or d.ends_at <> timestamptz '2026-12-09T21:00:00Z' then
    raise exception 'Pencere kaydı: % → %', d.starts_at, d.ends_at;
  end if;

  -- ÜÇ KARE. Aynı yazışmanın üç arka yüzü; ikisinin altyazısı tersti,
  -- biri belirsizdi.
  if d.data::text like '%ablası Betül%'
     or d.data::text like '%ablasına yazılmış%'
     or d.data::text like '%written to an elder sister%' then
    raise exception 'Ters akrabalık hâlâ data içinde';
  end if;
  if d.data::text not like '%Azize''den kardeşi Betül''e mektup%' then
    raise exception 'Düzeltilmiş altyazı data içinde yok';
  end if;
  if d.data::text not like '%Azize Kıpçak''tan kardeşi Betül''e mektup%' then
    raise exception 'Kıpçak altyazısı data içinde yok';
  end if;
  if d.data::text not like '%her younger sister Betül%' then
    raise exception 'İngilizce altyazı güncellenmemiş';
  end if;

  -- Uşak düzeltmesi de yerinde kalmalı: bu göç seed'in TAMAMINI yeniden
  -- yazıyor, yani bir önceki düzeltmeyi geri alacak bir seed ile
  -- koşturulursa sessizce kaybederdik.
  if exists (select 1 from public.dossier_sections s
              where s.dossier_id = d.id and s.ord = 2
                and s.body_tr like '%fabrika bulunmuyor%') then
    raise exception 'Uşak düzeltmesi geri alınmış';
  end if;

  raise notice 'Azize-Betül akrabalığı düzeltildi · Uşak düzeltmesi yerinde';
end
$azize$;
"""


def main():
    if not SEED.exists():
        sys.exit("✗ seed yok — önce: node content/dossiers/seed_dossier.mjs turkseker")
    sql = SEED.read_text(encoding="utf-8")

    for kalip, ad in ((r"(?m)^begin;\s*$", "begin;"), (r"(?m)^commit;\s*$", "commit;")):
        n = len(re.findall(kalip, sql))
        if n != 1:
            sys.exit("✗ seed içinde %d adet %s (1 bekleniyordu)" % (n, ad))
        sql = re.sub(kalip, "", sql, count=1)

    for yasak, ileti in (("ablası Betül", "ters akrabalık (kare 18)"),
                         ("ablasına yazılmış", "ters akrabalık (kare 117)"),
                         ("written to an elder sister", "ters akrabalık (EN)"),
                         ("fabrika bulunmuyor", "Uşak hatası")):
        if yasak in sql:
            sys.exit("✗ seed hâlâ %s taşıyor — zincir koşturuldu mu?" % ileti)

    HEDEF.write_text(BASLIK + "\n" + sql.strip() + "\n" + SAGLAMA, encoding="utf-8")
    print("✓ %s" % HEDEF.name)
    print("  %.1f KB · dış begin/commit söküldü · 9 sağlama" % (HEDEF.stat().st_size / 1024))
    return 0


sys.exit(main())
