#!/usr/bin/env python3
"""16. UTOİFY sergileme listesini PDF'ten çıkarır: 100 künye + görsel eşlemesi.

Bu dosya bir fotoğrafı YANLIŞ KİŞİYE yazmamak için var. Dört tuzak ölçüldü.

1) GÖRSEL SIRASI YERLEŞİM SIRASI DEĞİL. `page.images` kaynak sözlüğü sırasını
   veriyor. Sayfa 1'de metnin üçüncü satırı "The Last Racks" ama kaynak
   sırasındaki üçüncü görsel kazlardı. Sırayla eşlemek, birinin fotoğrafını
   başkasının adına yazmak demekti. Eşleşme GÖRSELİN SAYFADAKİ Y KONUMUNDAN.

2) DÜZ METİN SÜTUNLARI BİRLEŞTİRİYOR. "Abdulmecit ÇEVRİM Bulgur Şırnak,
   Türkiye" — ad nerede biter belli değil.

3) DÜZEN KİPİ SÖZCÜK BÖLÜYOR. Kerning yüzünden "Endonez ya", "Ar tvin",
   "Ispar ta", "Türk iye" çıkıyor. Düz kipte bu yok.

4) UZUN AD VE ESER İSMİ SATIR TAŞIRIYOR, hem de DÜZENSİZ yönde. Sayfa 9'da
   ad önce taşıyor ("Muzaffer Murat" / sonraki satırda "İLHAN"); sayfa 14'te
   eser ismi iki ayrı satıra dağılıyor ve araya BAŞKA bir kayıt giriyor
   ("Hollanda Lale" … "Tarlalarında Gökkuşağı" … "Dansı"). Konuma ya da
   komşuluğa dayalı hiçbir sezgi bunu doğru çözmüyor.

ÇÖZÜM — İKİ GEÇİŞ, HER BİRİ ÖTEKİNİ DOĞRULUYOR:
  Geçiş 1 (düzen kipi): sütunlardan ADAY ADLAR ve ÜLKE KÜMESİ toplanıyor.
  Geçiş 2 (düz metin):  sayfanın doğru sözcüklü metni, bulunan adlar çapa
                        alınarak kayıtlara bölünüyor; yer, ülke kümesiyle
                        sağdan ayrılıyor.
Bir ad düz metinde bulunamazsa kayıt sessizce atlanmıyor, HATA veriliyor.

Çıktı: _raw/sergileme_kunyeleri.json
"""
from __future__ import annotations

import json
import pathlib
import re
import sys

import pypdf

KOK = pathlib.Path(__file__).resolve().parent
PDF = KOK / "_raw/kaynak_dosyalari/16th_utoify_sergileme.pdf"
CIKIS = KOK / "_raw/sergileme_kunyeleri.json"
SHA = "f9271563a132180d0e603c82be0a2e09fc46712a2f01f118f889ba6639ceda15"
BASLIK = ("ESER SAHİBİ", "ULUSL", "ergilemeye")


def duz(s: str) -> str:
    return re.sub(r"\s+", " ", (s or "")).strip()


def sutunlar(satir: str) -> list[str]:
    return [m.group().strip()
            for m in re.finditer(r"\S(?:.*?\S)?(?=\s{3,}|$)", satir)
            if m.group().strip()]


def bosluksuz(s: str) -> str:
    return re.sub(r"\s+", "", s)


def metinde_ara(parca: str, metin: str) -> str | None:
    """Kerning'in böldüğü parçayı metinde bulur, metindeki DOĞRU hâlini döner.

    Karşılaştırma boşluksuz yapılıyor: "Ispar ta" ile "Isparta", "Türk iye"
    ile "Türkiye" ancak böyle eşleşiyor.
    """
    hedef = bosluksuz(parca)
    if not hedef:
        return None
    yigin = bosluksuz(metin)
    i = yigin.find(hedef)
    if i < 0:
        return None
    # Boşluksuz konumu, boşluklu metindeki aralığa geri çevir.
    harita, j = [], 0
    for k, ch in enumerate(metin):
        if not ch.isspace():
            harita.append(k)
            j += 1
    bas, son = harita[i], harita[i + len(hedef) - 1]
    return metin[bas:son + 1]


def main() -> int:
    if not PDF.exists():
        print("HAM PDF YOK: %s" % PDF)
        print("İkili ham kaynaklar git'te tutulmuyor; _raw/README.md'deki")
        print("adresten indirilip sha256 %s ile doğrulanmalı." % SHA[:16])
        return 1

    r = pypdf.PdfReader(str(PDF))
    kayitlar, hatalar = [], []

    for sno, sayfa in enumerate(r.pages, start=1):
        duzm = duz(sayfa.extract_text())
        for b in ("ESER SAHİBİ ESER İSMİ ÜLKESİ ESERİ",):
            duzm = duzm.replace(b, " ")
        duzm = re.sub(r"16\.\s*ULUSL\s*ARARASI.*?Fotoğraflar", " ", duzm)
        duzm = duz(duzm)

        # ── Geçiş 1a: ülke kümesi ─────────────────────────────────────────
        # Önce toplanıyor çünkü 1b'de LAZIM: sayfa 4'te tek başına kalan
        # "Türkiye" satırı, sonraki kaydın adının önüne yapışıp ("Türkiye
        # Ekrem ŞAHİN") önceki kaydın yerini yiyordu. Düz metinde o dizi
        # gerçekten geçtiği için metin sınaması da bunu yakalamıyordu.
        # Ülke adı asla ad öneki olamaz.
        ulkeler = set()
        for ln in (sayfa.extract_text(extraction_mode="layout") or "").split("\n"):
            if not ln.strip() or any(b in ln for b in BASLIK):
                continue
            p = sutunlar(ln)
            if len(p) < 3:
                continue
            ham_ulke = p[-1].split(",")[-1].strip()
            ulkeler.add(metinde_ara(ham_ulke, duzm) or ham_ulke)

        # ── Geçiş 1b: düzen kipinden adlar ────────────────────────────────
        adaylar = []
        bekleyen = ""      # taşmış ad önekİ
        for ln in (sayfa.extract_text(extraction_mode="layout") or "").split("\n"):
            if not ln.strip() or any(b in ln for b in BASLIK):
                continue
            p = sutunlar(ln)
            if len(p) == 1:
                # Tek parça: ya taşmış ad öneki ya da taşmış eser parçası.
                # Ad ise SONRAKİ satırın ilk parçasıyla birleşince düz metinde
                # bulunur; bulunmazsa ad değildir ve atılır (eser parçasıdır,
                # düz metinden zaten gelecek).
                bekleyen = "" if p[0] in ulkeler else p[0]
                continue
            if len(p) == 2:
                # İKİ PARÇA KAYIT DEĞİL. Taşmış eser isminin devamı ve onu
                # izleyen ülke ("Hayvancılık ⟂ Türkiye"). Kayıt sayılırsa
                # eserin bir parçası FOTOĞRAFÇI ADI oluyordu — 106 kayıt
                # çıkmasının ve altı görselin eşleşmemesinin sebebi buydu.
                # Sözcükleri düz metinden zaten önceki kaydın kuyruğuna
                # geliyor; burada yapılacak bir şey yok.
                bekleyen = ""
                continue
            ad = (bekleyen + " " + p[0]).strip() if bekleyen else p[0]
            if bekleyen and not metinde_ara(ad, duzm):
                ad = p[0]          # önek bu ada ait değilmiş
            bekleyen = ""
            adaylar.append(ad)


        # ── Geçiş 2: düz metni adlardan bölerek kayıtlara ayır ────────────
        yerler = []
        imlec = 0
        for ad in adaylar:
            bulunan = metinde_ara(ad, duzm[imlec:])
            if bulunan is None:
                hatalar.append("sayfa %d: ad düz metinde yok → %r" % (sno, ad))
                continue
            bas = duzm.index(bulunan, imlec)
            yerler.append((bas, bas + len(bulunan), bulunan))
            imlec = bas + len(bulunan)

        # ── Görseller: sayfadaki y konumuna göre yukarıdan aşağı ──────────
        gors = []

        def once(op, args, cm, tm):
            if op == b"Do" and args:
                gors.append((round(cm[5], 1), str(args[0])))

        sayfa.extract_text(visitor_operand_before=once)
        gors.sort(key=lambda g: -g[0])

        if len(yerler) != len(gors):
            hatalar.append("sayfa %d: %d kayıt, %d görsel — EŞLEŞMİYOR"
                           % (sno, len(yerler), len(gors)))

        for i, (bas, son, ad) in enumerate(yerler):
            kuyruk = (duzm[son:yerler[i + 1][0]] if i + 1 < len(yerler)
                      else duzm[son:]).strip()
            # Yer sağdan ayrılıyor: "<İl>, Türkiye" ya da çıplak ülke adı.
            il, ulke = "", ""
            for u in sorted(ulkeler, key=len, reverse=True):
                if u and kuyruk.endswith(u):
                    govde = kuyruk[:-len(u)].rstrip()
                    if govde.endswith(","):
                        govde = govde[:-1].rstrip()
                        parca = govde.rsplit(" ", 1)
                        il = parca[-1] if len(parca) > 1 else govde
                        eser = parca[0] if len(parca) > 1 else ""
                    else:
                        il, eser = "", govde
                    ulke = u
                    break
            else:
                eser = kuyruk
                hatalar.append("sayfa %d: yer ayrılamadı → %r" % (sno, kuyruk))

            kayitlar.append({
                "kod": "sergi-%03d" % (len(kayitlar) + 1),
                "sayfa": sno,
                "im": gors[i][1] if i < len(gors) else None,
                "kategori": "sergileme",
                "fotografci": duz(ad),
                "eser": duz(eser),
                "il": duz(il),
                "ulke": duz(ulke),
            })

    # ── Doğrulama ────────────────────────────────────────────────────────
    for k in kayitlar:
        if not k["fotografci"] or not k["eser"] or not k["ulke"]:
            hatalar.append("%s: boş alan → %s" % (k["kod"], k))
        if k["im"] is None:
            hatalar.append("%s: görsel eşleşmedi" % k["kod"])
    if len(kayitlar) != 100:
        hatalar.append("kayıt sayısı 100 değil: %d" % len(kayitlar))

    for h in hatalar:
        print("  ! " + h)

    CIKIS.write_text(json.dumps({
        "_ne": "16. UTOİFY sergilemeye uygun görülen 100 eserin künyesi.",
        "_nasil": "content/utoify/kunye_cikar.py — adlar düzen kipinden, "
                  "sözcükler ve kayıt sınırları düz kipten, görsel eşlemesi "
                  "sayfadaki y konumundan.",
        "_kaynak": "_raw/kaynak_dosyalari/16th_utoify_sergileme.pdf (sha256 %s)" % SHA,
        "sayi": len(kayitlar),
        "uyari_sayisi": len(hatalar),
        "kayitlar": kayitlar,
    }, ensure_ascii=False, indent=1), encoding="utf-8")
    print("%s %d künye → %s"
          % ("✓" if not hatalar else "⚠", len(kayitlar),
             CIKIS.relative_to(KOK.parent.parent)))
    return 1 if hatalar else 0


if __name__ == "__main__":
    sys.exit(main())
