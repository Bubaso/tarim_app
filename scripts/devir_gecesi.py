#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Devir gecesi — TİGEM'e arşiv etiketi, Türkşeker'e hikâye baloncuğu.

26 Kasım 2026 00:00'da (TR) çalışmak üzere yazıldı.

BU İŞ KRİTİK YOLDA DEĞİL. Devrin kendisi tarih sürücülü ve veritabanına
yazılmış durumda:

  · Türkşeker'in starts_at'i 2026-11-25T21:00Z — active görünümü o anda
    kendiliğinden ona döner.
  · TİGEM'in ends_at'i aynı an — aynı anda şeritten düşer ve arşiv
    listesine girer (country_dossier_index is_active'i tarihten hesaplıyor).
  · "Yakında" kartı devir göçünde zaten Et ve Süt Kurumu'na çevrildi.

Bu betik hiç koşmasa bile okurun gördüğü her şey doğru olur. Tamamladığı
iki şey var:

  1. TİGEM satırına 'archived' ETİKETİ. Pencere kapandığı için davranış
     zaten doğru; eksik olan yalnız etiket. CLAUDE.md §2.12 bunu şart
     koşuyor.
  2. Türkşeker'in HİKÂYE BALONCUĞU. dosya_hikayeleri.py yalnız penceresi
     AÇIK dosyalara baloncuk üretiyor; Türkşeker'in penceresi 00:00'dan
     önce açık değil, o yüzden betik önceden koşturulamıyor.

ERKEN KOŞMAYA KARŞI KİLİT. Devir anından önce çalıştırılırsa TİGEM'i erken
arşivler ve kurum şeridi devre kadar BOŞ kalır. O yüzden saat sınanıyor ve
erkense hiçbir şey yapılmadan çıkılıyor.

    python3 scripts/devir_gecesi.py          # devir anından önce: çıkar
    python3 scripts/devir_gecesi.py --zorla  # kilidi atlar (elle kurtarma)
"""
import os
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path

KOK = Path(__file__).resolve().parent.parent
DEVIR = datetime(2026, 11, 25, 21, 0, 0, tzinfo=timezone.utc)
ESKI, YENI = "tigem", "turkseker"


def istemci():
    """dosya_hikayeleri.py ile AYNI yol — yazma servis anahtarı istiyor."""
    url = os.environ.get("SUPABASE_URL")
    key = (os.environ.get("SUPABASE_SERVICE_ROLE_KEY")
           or os.environ.get("SUPABASE_KEY"))
    if url and key:
        from supabase import create_client
        return create_client(url, key)
    sys.path.append(os.environ.get("TARIM_PIPELINE_PATH",
                                   "/Users/BURHAN/tarim_ai_pipeline"))
    from src.config import supabase_client  # type: ignore
    return supabase_client


def main():
    simdi = datetime.now(timezone.utc)
    zorla = "--zorla" in sys.argv
    print("=== DEVİR GECESİ ===  %s" % simdi.isoformat(timespec="seconds"))

    if simdi < DEVIR and not zorla:
        kalan = (DEVIR - simdi).total_seconds() / 60
        print("· Devir anına %.0f dakika var (%s). Hiçbir şey yapılmadı."
              % (kalan, DEVIR.isoformat()))
        print("  Erken arşivleme kurum şeridini devre kadar boş bırakırdı.")
        return 0

    db = istemci()

    # ── 1 · yeni dosya gerçekten açıldı mı ───────────────────────────────
    # ÖNCE SINA, SONRA ARŞİVLE. Türkşeker herhangi bir sebeple açılmadıysa
    # TİGEM'i arşivlemek şeridi boşaltır; o hâlde dokunmamak daha iyi.
    aktif = (db.from_("active_country_dossier")
             .select("slug").eq("tur", "kurum").execute()).data or []
    if not aktif or aktif[0]["slug"] != YENI:
        print("✗ Kurum şeridinde %s yok (%s). Arşivleme YAPILMADI."
              % (YENI, aktif[0]["slug"] if aktif else "şerit boş"))
        return 1
    print("· Kurum şeridi %s'de ✓" % YENI)

    # ── 2 · eski dosyaya arşiv etiketi ───────────────────────────────────
    eski = (db.from_("country_dossiers").select("slug, status, ends_at")
            .eq("slug", ESKI).execute()).data or []
    if not eski:
        print("✗ %s satırı yok" % ESKI)
        return 1
    if eski[0]["status"] == "archived":
        print("· %s zaten arşivde, dokunulmadı" % ESKI)
    else:
        db.from_("country_dossiers").update({"status": "archived"}) \
          .eq("slug", ESKI).execute()
        print("· %s arşive alındı (penceresi %s'de kapanmıştı)"
              % (ESKI, (eski[0]["ends_at"] or "")[:16]))

    # ── 3 · hikâye baloncuğu ─────────────────────────────────────────────
    print("· dosya_hikayeleri.py çalıştırılıyor…")
    r = subprocess.run([sys.executable, str(KOK / "scripts" / "dosya_hikayeleri.py")],
                       cwd=str(KOK), capture_output=True, text=True)
    print(r.stdout.rstrip() or "  (çıktı yok)")
    if r.returncode != 0:
        print("✗ hikâye betiği %d ile döndü" % r.returncode)
        print(r.stderr[-800:])
        return 1

    # ── 4 · baloncuk gerçekten yazıldı mı ────────────────────────────────
    hedef = "/kurum/%s" % YENI
    satir = (db.from_("portal_stories").select("id, expires_at")
             .eq("hedef_yol", hedef)
             .gt("expires_at", datetime.now(timezone.utc).isoformat())
             .limit(1).execute()).data or []
    if not satir:
        print("✗ %s için canlı hikâye satırı bulunamadı" % hedef)
        return 1
    print("· hikâye satırı var, bitiş %s ✓" % satir[0]["expires_at"][:16])
    print("\n✓ devir tamamlandı")
    return 0


sys.exit(main())
