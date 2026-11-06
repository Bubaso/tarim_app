"""Canlıdaki hikâyeleri yeni kurallarla yerinde tazeler.

NEDEN. 6 Kasım 2026 denetiminin üretim kuralları (T3, T4, T8, Ö5)
`generate_stories.py` içinde uygulandı ama o betik yalnızca YENİ haberlere
bakıyor. Şu an şeritte duran kartlar eski kurallarla üretilmiş: ölçümde 34
haber hikâyesinin 18'inde başlık dev rakamı tekrar ediyor ve 27'si aynı
dakikada sona eriyor. Bu betik onları yerinde düzeltiyor — ertesi sabahı
beklemeden.

NE YAPIYOR
  T4  Başlık dev rakamı tekrar ediyorsa YENİDEN yazdırılıyor.
  T8  Her karta güç puanı veriliyor; eşiğin altındakiler şeritten
      düşürülüyor (satır SİLİNMİYOR, yalnız `expires_at` geçmişe çekiliyor
      — karar geri alınabilsin diye).
  Ö5  Güçlü kartlara tahmin sorusu ekleniyor.
  T3  Ömürler konuya göre kademelendiriliyor.

NE YAPMIYOR
  Günlük tavan (GUNLUK_EN_FAZLA) geriye dönük uygulanmıyor. O kural yeni
  kart EKLEME hızını sınırlıyor; var olan kartları toplu kaldırmak için
  bir gerekçe değil.

    python3 scripts/hikayeleri_tazele.py --kuru     # yalnız rapor
    python3 scripts/hikayeleri_tazele.py            # uygula
    python3 scripts/hikayeleri_tazele.py --geri-al  # düşürülenleri geri getir
"""

import argparse
import json
import os
import sys
from datetime import datetime, timedelta, timezone

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from generate_stories import (  # noqa: E402
    StoryRules,
    baslik_rakami_tekrarliyor,
    build_clients,
    utcnow,
    _omur,
)

ISTEM = """Sen Tarım Portalı için çalışan bir sosyal medya editörüsün.
Aşağıda yayında duran bir "Instagram Story" veri kartı ve kaynağı olan haber var.
Kartı DEĞERLENDİR ve gerekiyorsa DÜZELT.

KURALLAR
1. guc: 1-10 arası tam sayı. Bu kart bir haber şeridinde kendi başına durmayı ne
   kadar hak ediyor? 10 = okurun durup bakacağı çarpıcı bir rakam. 5 = doğru ama
   sıradan. Cömert davranma.
2. headline, big_stat_value'daki SAYIYI TEKRAR ETMEYECEK. Dev punto ile yazılan
   rakam zaten ekranda; başlık aynı sayıyı bir daha yazarsa okur üç satır okuyup
   tek şey öğrenir. Rakam "ne kadar"ı söyler, başlık "ne olacak"ı.
   Mevcut başlık bu kurala uyuyorsa AYNEN koru.
   Yeni başlık en fazla 60 harf olacak, haberin gerçeğinden sapmayacak.
3. guc 9 veya 10 ise bir tahmin sorusu hazırla; değilse tahmin alanlarını boş
   bırak. Soru NADİR olmalı — okur sınava girmiyor, haber okumaya geliyor. tahmin_secenekler ÜÇ şık: biri big_stat_value'nun AYNISI, ikisi makul
   ama yanlış, üçü de birbirinden farklı ve aynı biçimde yazılmış.
   tahmin_dogru doğru şıkkın 0 tabanlı sırası.

ÇIKTIYI SADECE JSON olarak ver:
{{
    "guc": 1-10,
    "headline": "Türkçe başlık",
    "headline_en": "English headline",
    "tahmin_soru": "Soru ya da boş dize",
    "tahmin_soru_en": "Question or empty string",
    "tahmin_secenekler": ["", "", ""],
    "tahmin_secenekler_en": ["", "", ""],
    "tahmin_dogru": -1
}}

KART
  üst başlık : {ust}
  vurucu değer: {rakam}
  etiket     : {etiket}
  başlık     : {baslik}

HABER BAŞLIĞI: {haber_baslik}
HABER METNİ: {icerik}
"""


def _uc_sik(ham, rakam):
    """Tahmin şıklarını doğrular; geçersizse None."""
    if not isinstance(ham, list) or len(ham) != 3:
        return None
    s = [str(x).strip() for x in ham]
    if any(not x for x in s) or len(set(s)) != 3:
        return None
    if rakam not in s:
        return None
    return s


def tazele_slayt(model, slayt, haber, izin_var):
    """Tek slaytı değerlendirir; (yeni_slayt, guc, degisti, soru_eklendi) döner.

    [izin_var] false ise tahmin sorusu EKLENMİYOR: aynı anda yalnız bir soru
    yayında olabiliyor (kullanıcı kararı, 6 Kasım 2026 — "okur sınava
    girmiyor").
    """
    rakam = (slayt.get("big_stat_value") or "").strip()
    baslik = (slayt.get("headline") or "").strip()

    istem = ISTEM.format(
        ust=slayt.get("super_title", ""),
        rakam=rakam,
        etiket=slayt.get("stat_label", ""),
        baslik=baslik,
        haber_baslik=(haber.get("title") or "")[:200],
        icerik=(haber.get("content") or "")[: StoryRules.CONTENT_CHARS],
    )

    try:
        metin = model.generate_content(istem).text.strip()
        if metin.startswith("```json"):
            metin = metin[7:-3]
        elif metin.startswith("```"):
            metin = metin[3:-3]
        veri = json.loads(metin.strip())
    except Exception as hata:
        print(f"    ! model hatası: {hata}")
        return slayt, None, False

    try:
        guc = int(veri.get("guc") or 0)
    except (TypeError, ValueError):
        guc = 0

    yeni = dict(slayt)
    degisti = False
    soru_eklendi = False
    # Eski sürümden kalan sorular TEMİZLENİYOR: eşik 8'den 9'a çıktı ve
    # tavan kondu; mevcut kartların çoğunda soru vardı.
    for alan, bos in (
        ("tahmin_soru", ""),
        ("tahmin_soru_en", ""),
        ("tahmin_secenekler", []),
        ("tahmin_secenekler_en", []),
        ("tahmin_dogru", -1),
    ):
        if yeni.get(alan) not in (None, bos):
            yeni[alan] = bos
            degisti = True

    # ── T4 — başlık ────────────────────────────────────────────────────────
    onerilen = (veri.get("headline") or "").strip()
    if baslik_rakami_tekrarliyor(baslik, rakam):
        # Yeni başlık da tekrar ediyorsa ESKİSİ kalıyor: kötü bir başlığı
        # başka bir kötü başlıkla değiştirmenin anlamı yok.
        if (
            onerilen
            and len(onerilen) <= 70
            and not baslik_rakami_tekrarliyor(onerilen, rakam)
        ):
            yeni["headline"] = onerilen
            en = (veri.get("headline_en") or "").strip()
            if en:
                yeni["headline_en"] = en
            degisti = True
            print(f"    başlık: {baslik}")
            print(f"         -> {onerilen}")
        else:
            print("    ! başlık düzeltilemedi, eskisi kalıyor")

    # ── Ö5 — tahmin ────────────────────────────────────────────────────────
    soru = (veri.get("tahmin_soru") or "").strip()
    sikler = _uc_sik(veri.get("tahmin_secenekler"), rakam)
    try:
        sira = int(veri.get("tahmin_dogru"))
    except (TypeError, ValueError):
        sira = -1

    if (
        izin_var
        and guc >= StoryRules.TAHMIN_GUC_ESIGI
        and soru
        and sikler
        and 0 <= sira < 3
        and sikler[sira] == rakam
    ):
        yeni["tahmin_soru"] = soru
        yeni["tahmin_secenekler"] = sikler
        yeni["tahmin_dogru"] = sira
        sikler_en = _uc_sik(
            veri.get("tahmin_secenekler_en"),
            (slayt.get("big_stat_value_en") or rakam).strip(),
        )
        soru_en = (veri.get("tahmin_soru_en") or "").strip()
        if soru_en and sikler_en:
            yeni["tahmin_soru_en"] = soru_en
            yeni["tahmin_secenekler_en"] = sikler_en
        degisti = True
        soru_eklendi = True
        print(f"    + tahmin: {soru}")

    return yeni, guc, degisti, soru_eklendi


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--kuru", action="store_true", help="yazma, yalnız rapor")
    ap.add_argument("--geri-al", action="store_true",
                    help="düşürülen kartları yeniden yayına alır")
    args = ap.parse_args()

    db, model = build_clients()
    now = utcnow()

    if args.geri_al:
        # Düşürülenler: ömrü geçmişte ama son 12 saatte oluşturulmuş olanlar.
        esik = (now - timedelta(hours=12)).isoformat()
        dusuk = (
            db.from_("portal_stories")
            .select("id, group_title")
            .gt("created_at", esik)
            .lt("expires_at", now.isoformat())
            .execute()
        ).data or []
        for s in dusuk:
            db.from_("portal_stories").update(
                {"expires_at": (now + timedelta(hours=20)).isoformat()}
            ).eq("id", s["id"]).execute()
        print(f"{len(dusuk)} kart yeniden yayına alındı.")
        return 0

    satirlar = (
        db.from_("portal_stories")
        .select("*")
        .gt("expires_at", now.isoformat())
        .order("created_at", desc=True)
        .execute()
    ).data or []

    haberliler = [s for s in satirlar if s.get("article_id")]
    print(f"Aktif hikâye: {len(satirlar)} (haber {len(haberliler)}, "
          f"dosya {len(satirlar) - len(haberliler)})")
    print(f"Güç eşiği: {StoryRules.GUC_ESIGI}\n")

    zayif = []
    guclu = []  # (satır, güç) — kademeli ömür için

    # Aynı anda yayında olabilecek soru sayısı. Liste içinde tutuluyor ki
    # yardımcı işlevden azaltılabilsin.
    soru_hakki = [StoryRules.TAHMIN_EN_FAZLA_AKTIF]

    for i, satir in enumerate(haberliler, 1):
        slaytlar = satir.get("items") or []
        if not slaytlar:
            continue
        haber = (
            db.from_("articles")
            .select("title, content")
            .eq("id", satir["article_id"])
            .limit(1)
            .execute()
        ).data
        if not haber:
            continue

        print(f"[{i}/{len(haberliler)}] {satir.get('group_title')} — "
              f"{(slaytlar[0].get('headline') or '')[:50]}")

        yeni_slaytlar = []
        en_dusuk_guc = 10
        degisen = False
        for slayt in slaytlar:
            y, guc, d, eklendi = tazele_slayt(
                model, slayt, haber[0], soru_hakki[0] > 0
            )
            if eklendi:
                soru_hakki[0] -= 1
            yeni_slaytlar.append(y)
            degisen = degisen or d
            if guc is not None:
                en_dusuk_guc = min(en_dusuk_guc, guc)

        if en_dusuk_guc < StoryRules.GUC_ESIGI:
            zayif.append((satir, en_dusuk_guc))
            print(f"    · güç {en_dusuk_guc} — eşiğin altında, düşürülecek")
        else:
            guclu.append((satir, yeni_slaytlar, degisen, en_dusuk_guc))

    # ── T3 — kademeli ömür, konuya göre ───────────────────────────────────
    # Güçlüler yeniden eskiye sıralı geldiği için konudaki sıra doğal olarak
    # oluşuyor.
    sayac = {}
    print("\n── Uygulanıyor ──")
    for satir, slaytlar, degisen, guc in guclu:
        kategori = satir.get("group_title") or ""
        saat = _omur(kategori, sayac, bool(satir.get("is_breaking")))
        sayac[kategori] = sayac.get(kategori, 0) + 1

        guncel = {
            "items": slaytlar,
            # Ömür OLUŞUM anından değil ŞİMDİDEN sayılıyor: kartlar bugün
            # üretildi ve amaç şeridi bugünden itibaren kademelendirmek.
            "expires_at": (now + timedelta(hours=saat)).isoformat(),
        }
        print(f"  {kategori:<14} güç {guc}  ömür {saat} saat"
              f"{'  (metin güncellendi)' if degisen else ''}")
        if not args.kuru:
            db.from_("portal_stories").update(guncel).eq("id", satir["id"]).execute()

    for satir, guc in zayif:
        print(f"  {satir.get('group_title'):<14} güç {guc}  DÜŞÜRÜLÜYOR")
        if not args.kuru:
            db.from_("portal_stories").update(
                {"expires_at": (now - timedelta(minutes=1)).isoformat()}
            ).eq("id", satir["id"]).execute()

    print(f"\nKalan: {len(guclu)} · Düşürülen: {len(zayif)}")
    if args.kuru:
        print("(kuru çalıştırma — hiçbir şey yazılmadı)")
    elif zayif:
        print("Geri almak için: python3 scripts/hikayeleri_tazele.py --geri-al")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
