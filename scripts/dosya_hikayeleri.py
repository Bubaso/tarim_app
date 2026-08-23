#!/usr/bin/env python3
"""Dosya hikâyeleri — Ülke ve Kurum Dosyası için tanıtım baloncukları.

`generate_stories.py`den AYRI çalışır ve ondan üç yerde ayrılır:

  1. **Model kullanmaz.** Metin `content/dossiers/<slug>/yayin.json` içindeki
     `hikaye` bloğunda elle yazılı. Dosya dizisinin kuralı burada da geçerli:
     hiçbir rakam hafızadan yazılmaz, dolayısıyla hiçbir rakam modele de
     yazdırılmaz.
  2. **MAX_ACTIVE limitine tabi değil.** Haber hikâyeleri kapasiteyi
     doldurduğunda dosya hikâyesi düşmemeli; dosya yirmi sekiz (ya da on dört)
     gün boyunca ana sayfada duran bir yayın, günlük bir haber değil.
  3. **Habere bağlı değil.** `article_id` boş, `hedef_yol` dosyanın adresi,
     `gorsel_url` dosyanın paylaşım kartı.

Her dizi türünden EN FAZLA BİR tane yayında olur: yeni satır yazılmadan önce
o türün eski satırları süresi doldurulmuş sayılır. Böylece iki ülke dosyası
hikâyesi yan yana düşmez.

Mevcut haber hikâyelerine dokunmaz.

    python3 scripts/dosya_hikayeleri.py
"""
import json
import os
import re
import sys
from datetime import datetime, timedelta, timezone
from pathlib import Path


KOK = Path(__file__).resolve().parent.parent
ICERIK = KOK / "content" / "dossiers"
ADRES = "https://tarim-app-2026.web.app"

#: Bir baloncuktaki slayt sayısı sınırları.
#:
#: Üst sınır istemcideki `StoryRules.maxItemsPerGroup` ile aynı: beşten uzun
#: bir diziyi kimse sonuna kadar izlemiyor ve fazlası sessizce kırpılır.
#: Alt sınır bir yayın kararı — tek kancayla dosyaya davet zayıf kalıyor.
MIN_SLAYT = 3
MAX_SLAYT = 5

#: Hikâyenin ömrü. Dosyanın kendi yayın penceresiyle sınırlanıyor: pencere
#: kapandığında baloncuk da düşsün, kapanmış bir dosyaya çağıran kart kalmasın.
VARSAYILAN_OMUR_SAAT = 24


def istemci():
    """Supabase istemcisi — generate_stories.py ile AYNI yoldan.

    Önce ortam değişkenleri (sunucu/CI), yoksa geliştirici makinesindeki
    `tarim_ai_pipeline` kurulumu. Yazma yapıldığı için servis anahtarı
    gerekiyor; depodaki .env yalnızca anon anahtarı taşıyor.
    """
    url = os.environ.get("SUPABASE_URL")
    key = (os.environ.get("SUPABASE_SERVICE_ROLE_KEY")
           or os.environ.get("SUPABASE_KEY"))
    if url and key:
        from supabase import create_client
        return create_client(url, key)

    pipeline = os.environ.get("TARIM_PIPELINE_PATH",
                              "/Users/BURHAN/tarim_ai_pipeline")
    sys.path.append(pipeline)
    from src.config import supabase_client  # type: ignore
    return supabase_client


def simdi():
    return datetime.now(timezone.utc)


def tarih_coz(ham):
    """PostgREST zaman damgasını ayrıştırır.

    `datetime.fromisoformat` Python 3.11 öncesinde salise kısmını yalnızca 3
    veya 6 hane olduğunda kabul ediyor; PostgREST ise gereksiz sıfırları
    kırpıp '…:00.8162+00:00' gibi 4 haneli değerler döndürebiliyor. Salise
    altı haneye tamamlanıyor.
    """
    m = re.match(r"^(.*?)(?:\.(\d+))?([+-]\d{2}:?\d{2}|Z)?$", ham.strip())
    if not m:
        return None
    govde, salise, ofset = m.group(1), m.group(2) or "", m.group(3) or "+00:00"
    if ofset == "Z":
        ofset = "+00:00"
    salise = (salise + "000000")[:6]
    try:
        return datetime.fromisoformat(f"{govde}.{salise}{ofset}")
    except ValueError:
        return None


def yayin_oku(slug):
    p = ICERIK / slug / "yayin.json"
    if not p.exists():
        return None
    return json.loads(p.read_text(encoding="utf-8"))


def slayta_cevir(s):
    """yayin.json slaytı -> portal_stories.items öğesi."""
    return {
        "super_title": s.get("ust", ""),
        "super_title_en": s.get("ust_en", ""),
        "headline": s.get("baslik", ""),
        "headline_en": s.get("baslik_en", ""),
        "big_stat_value": s.get("rakam", ""),
        "big_stat_value_en": s.get("rakam_en", ""),
        "stat_label": s.get("etiket", ""),
        "stat_label_en": s.get("etiket_en", ""),
        # Slayt kendi görselini taşıyor. Paylaşım kartı KULLANILMIYOR: kartın
        # üstünde zaten dosyanın adı ve tanıtım cümlesi var, görüntüleyici
        # kendi metnini bindirince ikisi birbirine giriyordu. Bunun yerine
        # dosyanın içindeki fotoğraflar — konusuyla eşleşen olanı.
        "gorsel_url": s.get("gorsel", ""),
    }


def calistir():
    print("=== DOSYA HİKÂYELERİ ===")
    db = istemci()
    now = simdi()

    # Yayındaki dosyalar: pencere içinde olan her diziden bir tane.
    dosyalar = (
        db.from_("country_dossiers")
        .select("slug, tur, name_tr, ends_at, status")
        .eq("status", "published")
        .execute()
    ).data or []

    if not dosyalar:
        print("Yayında dosya yok. İşlem yok.")
        return

    for d in dosyalar:
        slug, tur = d["slug"], d.get("tur") or "ulke"
        yayin = yayin_oku(slug)
        hikaye = (yayin or {}).get("hikaye")
        if not hikaye:
            print(f"· {slug}: yayin.json içinde `hikaye` bloğu yok, atlanıyor.")
            continue

        slaytlar = [slayta_cevir(s) for s in hikaye.get("slaytlar", [])]
        slaytlar = [s for s in slaytlar if s["headline"] and s["big_stat_value"]]
        if len(slaytlar) < MIN_SLAYT:
            print(f"· {slug}: {len(slaytlar)} slayt — en az {MIN_SLAYT} gerekiyor, "
                  "atlanıyor.")
            continue
        if len(slaytlar) > MAX_SLAYT:
            print(f"· {slug}: {len(slaytlar)} slayt, ilk {MAX_SLAYT} alınıyor "
                  "(istemci fazlasını zaten çizmiyor).")
            slaytlar = slaytlar[:MAX_SLAYT]

        grup = hikaye.get("grup_tr", "Dosya")
        # Grup adının İngilizcesi ilk slaytta saklanıyor — haber hikâyelerinde
        # de aynı yerde duruyor, istemci orayı okuyor.
        slaytlar[0]["group_title_en"] = hikaye.get("grup_en", "")

        hedef = f"/{'kurum' if tur == 'kurum' else 'ulke'}/{slug}"
        # Satır düzeyindeki görsel yalnızca YEDEK: slaytların hepsinde kendi
        # görseli varsa buraya hiç düşülmüyor. Yine de dolu olmak zorunda —
        # şema kısıtı habersiz satırdan görsel istiyor.
        ilk = next((s for s in slaytlar if s.get("gorsel_url")), None)
        gorsel = (ilk or {}).get("gorsel_url") or f"{ADRES}/paylasim/{slug}.jpg"

        # Ömür dosyanın penceresini aşmıyor.
        bitis = now + timedelta(hours=VARSAYILAN_OMUR_SAAT)
        if d.get("ends_at"):
            pencere = tarih_coz(d["ends_at"])
            if pencere is not None:
                bitis = min(bitis, pencere)
        if bitis <= now:
            print(f"· {slug}: yayın penceresi kapanmış, hikâye üretilmiyor.")
            continue

        # Aynı türden eski dosya hikâyeleri düşürülüyor: iki ülke dosyası
        # baloncuğu yan yana durmasın. Haber hikâyelerine DOKUNULMUYOR —
        # süzgeç yalnızca hedef_yol'u dolu olan satırları tutuyor.
        eski = (
            db.from_("portal_stories")
            .select("id, hedef_yol")
            .not_.is_("hedef_yol", "null")
            .gt("expires_at", now.isoformat())
            .execute()
        ).data or []
        onek = f"/{'kurum' if tur == 'kurum' else 'ulke'}/"
        for satir in eski:
            if (satir.get("hedef_yol") or "").startswith(onek):
                db.from_("portal_stories").update(
                    {"expires_at": now.isoformat()}
                ).eq("id", satir["id"]).execute()
                print(f"  · eski {tur} hikâyesi düşürüldü")

        db.from_("portal_stories").insert({
            "article_id": None,
            "group_title": grup,
            "is_breaking": False,
            "items": slaytlar,
            "hedef_yol": hedef,
            "gorsel_url": gorsel,
            "expires_at": bitis.isoformat(),
        }).execute()

        print(f"✓ [{grup}] {len(slaytlar)} slayt → {hedef} "
              f"(bitiş {bitis.isoformat()[:16]})")

    print("=== TAMAMLANDI ===")


if __name__ == "__main__":
    calistir()
