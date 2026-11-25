#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Göçten SONRA, dağıtımdan ÖNCE koşar: depoyu veritabanına eşitler.

NEDEN AYRI BİR ADIM. `durum_bekcisi.mjs` sıralamayı kesin kılıyor:

  · yayin.json 'published' + veritabanında satır YOK  → DAĞITIM DURUR
  · yayin.json 'draft'     + veritabanı 'published'   → DAĞITIM DURUR
                                                        (og kabuğunu siler)

Yani bayrak göçten önce de sonra da çevrilemez — tam arasında çevrilir.
Irak'ta on gün süren sessiz hata buydu (CLAUDE.md §2.12/5).

    python3 scripts/devir_sonrasi.py

Çıkış 0 ise sıradaki adım: ./deploy.sh --hosting
"""
import json
import pathlib
import sys
import urllib.request

KOK = pathlib.Path(__file__).resolve().parent.parent
SLUG = "turkseker"
BEKLENEN_BASLANGIC = "2026-11-25T21:00:00+00:00"


def env():
    d = {}
    for s in (KOK / ".env").read_text(encoding="utf-8").splitlines():
        if "=" in s and not s.strip().startswith("#"):
            i = s.index("=")
            d[s[:i].strip()] = s[i + 1:].strip()
    return d


def q(U, K, yol):
    r = urllib.request.Request(U + "/rest/v1/" + yol,
                               headers={"apikey": K, "Authorization": "Bearer " + K})
    with urllib.request.urlopen(r, timeout=30) as y:
        return json.loads(y.read().decode("utf-8"))


def main():
    e = env()
    U, K = e["SUPABASE_URL"], e["SUPABASE_ANON_KEY"]

    satir = q(U, K, "country_dossiers?select=slug,status,starts_at,ends_at"
                    "&slug=eq." + SLUG)
    if not satir:
        print("✗ Veritabanında %s satırı yok — göç uygulanmamış." % SLUG)
        print("  Önce: mv content/dossiers/turkseker/beklemede/*.sql "
              "supabase/migrations/ && supabase db push")
        return 1
    d = satir[0]
    if d["status"] != "published":
        print("✗ %s durumu '%s' — devir göçü uygulanmamış." % (SLUG, d["status"]))
        return 1
    if not (d["starts_at"] or "").startswith(BEKLENEN_BASLANGIC[:16]):
        print("✗ %s başlangıcı %s — %s bekleniyordu."
              % (SLUG, d["starts_at"], BEKLENEN_BASLANGIC))
        return 1
    print("· veritabanı: %s published · %s → %s"
          % (SLUG, d["starts_at"][:16], (d["ends_at"] or "")[:16]))

    tigem = q(U, K, "country_dossiers?select=slug,status,ends_at&slug=eq.tigem")
    if tigem and not (tigem[0]["ends_at"] or "").startswith(BEKLENEN_BASLANGIC[:16]):
        print("✗ TİGEM bitişi %s — Türkşeker başlangıcıyla aynı olmalı."
              % tigem[0]["ends_at"])
        return 1
    print("· TİGEM bitişi Türkşeker başlangıcına eşit ✓ (boşluksuz devir)")

    # ── bayrağı çevir ────────────────────────────────────────────────────
    yol = KOK / "content" / "dossiers" / SLUG / "yayin.json"
    Y = json.loads(yol.read_text(encoding="utf-8"))
    if Y.get("status") == "published":
        print("· yayin.json zaten 'published', dokunulmadı")
    else:
        Y["status"] = "published"
        # Sıra alanın yerini değiştirmesin: json.dumps eklenen anahtarı sona
        # atardı, burada var olan anahtar güncelleniyor.
        yol.write_text(json.dumps(Y, ensure_ascii=False, indent=2) + "\n",
                       encoding="utf-8")
        print("· yayin.json 'draft' → 'published'")

    print("\n  Sıradaki adım:  ./deploy.sh --hosting")
    print("  (og kabuğu ancak bu dağıtımda üretilir — CLAUDE.md §2.12/6)")
    return 0


sys.exit(main())
