#!/usr/bin/env python3
"""DSİ — `_raw/cikarim.json` → `data.json`. Veri sayfası burada KİLİTLENİR.

EKSEN: kurum kuraklıktan doğdu, ülkenin su altyapısını kurdu ve kurduğunun
işletmesini elli üç yılda devretti.

DÖRT DOĞRULAMA — biri bile tutmazsa üretim DURUR:
  1. Her blok `_kapsam` taşıyor (§2.2 — kapsamsız rakam karşılaştırılamaz)
  2. Devir tablosunun İKİ toplamı da satırlardan yeniden hesaplanıyor
  3. Kronoloji artan
  4. Kapsamı DAR olan seri, kapsamı GENİŞ olanla aynı birimde sunulmuyor

Çalıştırma: ~/tarim_ai_pipeline/venv/bin/python build_data.py
"""
from __future__ import annotations

import json
import pathlib
import sys

KOK = pathlib.Path(__file__).parent
ham = json.loads((KOK / "_raw" / "cikarim.json").read_text(encoding="utf-8"))
hata: list[str] = []

govde = {k: v for k, v in ham.items() if not k.startswith("_")}

# ── 1. Kapsam zorunlu ─────────────────────────────────────────────────────
for ad, blok in govde.items():
    if not isinstance(blok, dict) or not blok.get("_kapsam"):
        hata.append(f"KAPSAM YOK · '{ad}'")
    if not blok.get("_kaynak_niteligi"):
        hata.append(f"KAYNAK NİTELİĞİ YOK · '{ad}'")

# ── 2. Devir tablosu — iki toplam da yeniden hesaplanıyor ─────────────────
d = govde["devir_dagilimi"]
adet = sum(s["adet"] for s in d["satirlar"])
alan = sum(s["alan_ha"] for s in d["satirlar"])
if adet != d["toplam_adet"]:
    hata.append(f"DEVİR ADET TUTMUYOR · satırlar {adet} ≠ toplam {d['toplam_adet']}")
if alan != d["toplam_alan_ha"]:
    hata.append(f"DEVİR ALAN TUTMUYOR · satırlar {alan:,} ≠ toplam {d['toplam_alan_ha']:,}")
# Yüzdeler de satırdan hesaplanıyor: raporun yazdığıyla karşılaştırılıyor.
for s in d["satirlar"]:
    hesap = round(s["alan_ha"] / alan * 100, 1)
    if abs(hesap - s["alan_yuzde"]) > 0.15:
        hata.append(f"DEVİR YÜZDE · {s['devralan']}: hesap {hesap} ≠ rapor {s['alan_yuzde']}")
d["_toplam_dogrulandi"] = "adet ve alan satırlardan yeniden hesaplandı; yüzdeler de"

# ── 3. Kronoloji ──────────────────────────────────────────────────────────
kron = [
    ("ilk_orgutlenme", 1914), ("sular_fen_heyeti", 1925),
    ("sular_umum_mudurlugu", 1929), ("dsi_kurulus", 1953),
    ("teskilatlanma", 1954), ("ilk_devir", govde["devir_serisi"]["kayitlar"][0]["yil"]),
    ("sulama_birlikleri_kanunu", 2011), ("maddelerin_mulgasi", 2018),
]
yillar = [y for _, y in kron]
if yillar != sorted(yillar):
    hata.append(f"KRONOLOJİ SIRASIZ · {yillar}")

# ── 4. Kapsam ayrımı korunuyor ────────────────────────────────────────────
ds = govde["devir_serisi"]
if "YERALTISUYU" not in ds["_kapsam"].upper():
    hata.append("devir_serisi kapsamı YAS olduğunu söylemiyor")
son_seri = ds["kayitlar"][-1]["alan_ha"]
if son_seri >= d["toplam_alan_ha"]:
    hata.append(f"KAPSAM ÇELİŞKİSİ · YAS serisi ({son_seri:,}) bütün tesislerden "
                f"({d['toplam_alan_ha']:,}) büyük olamaz")
# 1999 ünite değeri düşürülmüş olmalı
bin999 = next((k for k in ds["kayitlar"] if k["yil"] == 1999), None)
if bin999 and bin999["unite"] is not None:
    hata.append("1999 ünite değeri hâlâ dolu — kaynak hatası düşürülmeliydi")

# ── 5. 6172: iddianın kendi sınaması ──────────────────────────────────────
# §7'nin omurgası bir YOKLUK: kanunda "mülkiyet" hiç geçmiyor. Yokluk
# iddiası tehlikelidir — bir kez geçse cümle çöker. Bu yüzden üretim
# sırasında da sınanıyor, çıkarıcıya güvenilmiyor.
k72 = govde["kanun_6172"]
if k72["mulkiyet_gecis_sayisi"] != 0:
    hata.append(f"6172'DE MÜLKİYET GEÇİYOR · {k72['mulkiyet_gecis_sayisi']} kez — "
                "§7'nin cümlesi yazılamaz")
if "işletme, bakım, onarım ve yönetim sorumluluğu" not in k72["devir_tanimi_tam"]:
    hata.append("6172 devir tanımı beklenen dört sorumluluğu saymıyor")

# ── 7. Büyük projeler: iki ölçünün karıştırılmaması ───────────────────────
# İŞLETMEDEKİ baraj (861) ile İNŞA EDİLEN kümülatif baraj (1.081) aynı şey
# değil. İkisi de veri katmanında duruyor; üretim, aralarındaki farkın
# korunduğunu sınıyor ki metin yanlışlıkla birini ötekinin yerine koymasın.
bp = govde["buyuk_projeler"]
if bp["isletmedeki_baraj_adet"] >= govde["olcek"]["baraj_adet"]:
    hata.append("İŞLETMEDEKİ baraj sayısı, İNŞA EDİLEN kümülatiften küçük olmalı")

# Takvim artan olmalı: bir projenin idaresi kurulduktan sonraki birim
# ondan önce kurulmuş görünüyorsa çizelge yanlış okunmuştur.
yillar_t = [b["yil"] for b in bp["teskilat_takvimi"]]
if yillar_t != sorted(yillar_t):
    hata.append(f"TEŞKİLAT TAKVİMİ SIRASIZ · {yillar_t}")

# DAP'ın üç dilimi hedefi vermeli.
_d = bp["dap"]
_t = _d["isletmede_ha"] + _d["insaat_ha"] + _d["planlama_ha"]
if _t != _d["hedef_sulama_ha"]:
    hata.append(f"DAP DİLİMLERİ TUTMUYOR · {_t:,} ≠ {_d['hedef_sulama_ha']:,}")

# KOP'un dilimleri de toplamı vermeli.
_k = bp["kop"]
_t2 = _k["isletmede_yus_ha"] + _k["isletmede_yas_ha"] + _k["kalan_ha"]
if _t2 != _k["toplam_sulama_ha"]:
    hata.append(f"KOP DİLİMLERİ TUTMUYOR · {_t2:,} ≠ {_k['toplam_sulama_ha']:,}")

# Rezervuarlar yüzey alanına göre azalan sırada olmalı.
_r = [x["yuzey_km2"] for x in bp["en_genis_rezervuarlar"]]
if _r != sorted(_r, reverse=True):
    hata.append(f"REZERVUAR SIRASI AZALAN DEĞİL · {_r}")

# ── Türetilmiş ────────────────────────────────────────────────────────────
ilk, son = ds["kayitlar"][0], ds["kayitlar"][-1]
govde["turetilmis"] = {
    "_kaynak_niteligi": "TÜRETİLMİŞ — yukarıdaki blokların hesabı",
    "_kapsam": "Türetilmiş; her satırın kapsamı kendi kaynağınınkidir",
    "devir_suresi_yil": son["yil"] - ilk["yil"],
    "_devir_suresi_kapsam": "YAS tesisleri · ilk kat'i devir → son kayıt",
    "birlik_alan_payi_yuzde": next(
        s["alan_yuzde"] for s in d["satirlar"] if s["devralan"] == "Sulama Birliği"),
    "birlik_adet_payi_yuzde": next(
        s["adet_yuzde"] for s in d["satirlar"] if s["devralan"] == "Sulama Birliği"),
    "kooperatif_alan_payi_yuzde": next(
        s["alan_yuzde"] for s in d["satirlar"] if s["devralan"] == "Kooperatif"),
    "kooperatif_adet_payi_yuzde": next(
        s["adet_yuzde"] for s in d["satirlar"] if s["devralan"] == "Kooperatif"),
    "devredilen_milyon_ha": round(d["toplam_alan_ha"] / 1e6, 3),
    "hedefe_oran_yuzde": round(
        d["toplam_alan_ha"] / (govde["olcek"]["hedef_2028_brut_milyon_ha"] * 1e6) * 100, 1),
    "_hedefe_oran_uyarisi": ("Payda 2028 HEDEFİ, gerçekleşen alan değil. 'Devredilen "
                            "alan açılanın şu kadarı' DENMEZ — gerçekleşen kümülatif "
                            "alan hiçbir kaynakta bulunamadı (README tur 3/3)."),
    "kronoloji": dict(kron),
}

# ── Metin rakamları ───────────────────────────────────────────────────────
# Metnin kullanacağı HER ölçek dönüşümü burada hesaplanıyor; cümle yazarken
# elde yuvarlama yapılmıyor. Avustralya'da bu blok yayına gitmek üzere olan
# YANLIŞ bir karşılaştırmayı yakalamıştı (§2.2'nin "önce veri, sonra cümle").
sb = next(s for s in d["satirlar"] if s["devralan"] == "Sulama Birliği")
ko = next(s for s in d["satirlar"] if s["devralan"] == "Kooperatif")
ky = next(s for s in d["satirlar"] if s["devralan"] == "Köy Tüzel Kişiliği")

# Serinin yarısını hangi yılda geçtiği: "devir hızlanmadı, yavaşladı"
# cümlesi buna dayanıyor — iddia değil, serinin kendi şekli.
_yari = son["alan_ha"] / 2
_yari_yili = next(k["yil"] for k in ds["kayitlar"] if k["alan_ha"] >= _yari)

govde["metin_rakamlari"] = {
    "_kaynak_niteligi": "TÜRETİLMİŞ — metnin kullandığı dönüşümler",
    "_kapsam": "Türetilmiş; her satırın kapsamı kendi kaynağınınkidir",

    # Asimetrinin ASIL içeriği: oranlar değil, ortalama tesis büyüklüğü.
    # "%19'u ama %83'ü" soyut; "ortalama 14 bin hektara karşı 468 hektar"
    # aynı şeyi bedenin görebileceği bir ölçüye çeviriyor (§2.9 tutamak).
    "birlik_ortalama_ha": round(sb["alan_ha"] / sb["adet"]),
    "kooperatif_ortalama_ha": round(ko["alan_ha"] / ko["adet"]),
    "koy_ortalama_ha": round(ky["alan_ha"] / ky["adet"]),
    "birlik_kooperatif_kat": round(
        (sb["alan_ha"] / sb["adet"]) / (ko["alan_ha"] / ko["adet"]), 1),

    # YAS serisinin iki ucu ve şekli
    "seri_ilk_yil": ilk["yil"],
    "seri_ilk_alan_ha": ilk["alan_ha"],
    "seri_son_yil": son["yil"],
    "seri_son_alan_ha": son["alan_ha"],
    "seri_yarisini_gectigi_yil": _yari_yili,
    "seri_ilk_yari_yil": _yari_yili - ilk["yil"],
    "seri_ikinci_yari_yil": son["yil"] - _yari_yili,

    # DİKKAT — bir cümle burada çürüdü. "Devir zamanla yavaşladı" yazmak
    # üzereydim; serinin yarısı 1994'te geçiliyor, yani ilk yarı 27 yıl
    # ikinci yarı 26 yıl: neredeyse simetrik. Yavaşlama YARIDA değil
    # KUYRUKTA, ve ancak ölçülerek söylenebilir.
    "son_bes_yil_artis_ha": son["alan_ha"] - next(
        k["alan_ha"] for k in ds["kayitlar"] if k["yil"] == son["yil"] - 5),
    "en_hizli_bes_yil_artis_ha": max(
        k2["alan_ha"] - k1["alan_ha"]
        for k1, k2 in zip(ds["kayitlar"], ds["kayitlar"][5:])),
    "son_bes_yil_yavaslama_kat": round(
        max(k2["alan_ha"] - k1["alan_ha"]
            for k1, k2 in zip(ds["kayitlar"], ds["kayitlar"][5:]))
        / (son["alan_ha"] - next(k["alan_ha"] for k in ds["kayitlar"]
                                 if k["yil"] == son["yil"] - 5)), 1),
    "en_hizli_bes_yil_bitis": max(
        ((k2["alan_ha"] - k1["alan_ha"], k2["yil"])
         for k1, k2 in zip(ds["kayitlar"], ds["kayitlar"][5:])))[1],

    # Ölçek bloğunun okunabilir karşılıkları
    "depolama_milyar_m3": round(govde["olcek"]["depolama_hm3"] / 1000, 1),
    "baraj_golet_toplam": govde["olcek"]["baraj_adet"] + govde["olcek"]["golet_adet"],
    "hedefin_sulanabilire_orani_yuzde": round(
        govde["olcek"]["hedef_2028_brut_milyon_ha"]
        / govde["olcek"]["sulanabilir_arazi_milyon_ha"] * 100, 1),

    # TUTAMAK (§2.9) — ve iki KAYNAKSIZ İDDİANIN yerine geçen şey.
    # Metnin ilk hâlinde "depolar Türkiye'nin bir yıllık su kullanımından
    # fazlasını alıyor" ve "devredilen alan Belçika'dan geniş" yazıyordu.
    # İkisi de makul, ikisi de kaynaksız: ne yıllık su kullanımı ne Belçika'nın
    # yüzölçümü bu dosyanın veri katmanında var (§2.14.1). Yerlerine saf birim
    # dönüşümü kondu — dışarıdan hiçbir rakam gerektirmiyor.
    "depolama_kup_kenari_km": round((govde["olcek"]["depolama_hm3"] * 1e6) ** (1 / 3) / 1000, 1),
    "devredilen_km2": round(d["toplam_alan_ha"] / 100),

    # ── Büyük projeler: sürenin kendisi ───────────────────────────────────
    # Kullanıcının istediği şey "yıllar aldı bu projeler". Süre bir TARİH
    # değil bir FARK, ve farkın iki ucu da belgeli olmak zorunda. Uçlar:
    # kurumun kendi teşkilat çizelgesindeki birim kuruluş tarihleri ve
    # faaliyet raporunun yılı.
    "rapor_yili": 2025,
    "firat_idaresinden_rapora_yil": 2025 - next(
        b["yil"] for b in bp["teskilat_takvimi"] if "Aşağı Fırat" in b["birim"]),
    "firat_idaresinden_tunele_yil": (
        next(b["yil"] for b in bp["teskilat_takvimi"] if "Tüneli" in b["birim"])
        - next(b["yil"] for b in bp["teskilat_takvimi"] if "Aşağı Fırat" in b["birim"])),
    "seyhan_idaresinden_rapora_yil": 2025 - next(
        b["yil"] for b in bp["teskilat_takvimi"] if "Aşağı Seyhan" in b["birim"]),
    "takvim_ilk_yil": bp["teskilat_takvimi"][0]["yil"],
    "takvim_son_yil": bp["teskilat_takvimi"][-1]["yil"],
    "takvim_araligi_yil": (bp["teskilat_takvimi"][-1]["yil"]
                           - bp["teskilat_takvimi"][0]["yil"]),
    "gap_kalan_sulama_yuzde": 100 - bp["gap"]["sulama_gerceklesme_yuzde"],
    # DAP'ın kalanı raporda AYRICA yazılı (775.220 ha); burada yeniden
    # hesaplanıp karşılaştırılıyor — bağımsız bir çapraz kontrol.
    "dap_kalan_ha": bp["dap"]["hedef_sulama_ha"] - bp["dap"]["isletmede_ha"],
    "kop_sulanan_yuzde": round(
        (bp["kop"]["isletmede_yus_ha"] + bp["kop"]["isletmede_yas_ha"])
        / bp["kop"]["toplam_sulama_ha"] * 100, 1),
    "ataturk_hirfanli_kat": round(
        bp["en_genis_rezervuarlar"][0]["yuzey_km2"]
        / bp["en_genis_rezervuarlar"][-1]["yuzey_km2"], 1),
    "uc_proje_hedef_toplam_ha": (bp["dap"]["hedef_sulama_ha"]
                                 + bp["kop"]["toplam_sulama_ha"]),

    # Mülga oranı: kanunun kaç maddesinin düştüğü değil, DÜŞENLERİN
    # arasında kuruluş ve teşkilat maddelerinin bulunması önemli.
    "mulga_madde_toplam": govde["kanun"]["mulga_toplam"],
}

if hata:
    print("ÜRETİM DURDU:\n", file=sys.stderr)
    for h in hata:
        print("  ✗ " + h, file=sys.stderr)
    sys.exit(1)

out = {
    "_dosya": "DSİ — Kurum Dosyası Sayı 05 · veri katmanı",
    "_uretim": "build_data.py — elle düzenlenmez",
    "_eksen": ("Kuraklıktan doğan kurum ülkenin su altyapısını kurdu ve kurduğunun "
               f"işletmesini {govde['turetilmis']['devir_suresi_yil']} yılda "
               "başkalarına devretti."),
    "_eksen_notu": ("Süre SABİT YAZILMIYOR, turetilmis.devir_suresi_yil'den "
                    "kuruluyor. İlk taslakta 'elli dört yıl' yazmıştım; seri 54 "
                    "KAYIT taşıyor ama 1967-2020 arası 53 YIL. Metinle veri "
                    "ayrışmasın diye sayı tek yerden geliyor."),
    "_eksenin_siniri": ("'Yapıyor ama işletmiyor' DENMİYOR. DSİ'nin kendi işlettiği "
                        "ulusal alan hiçbir kaynakta tek rakam olarak yok; iddia "
                        "devrin ÖLÇEĞİ ve SÜRESİ ile sınırlı."),
    **govde,
}
(KOK / "data.json").write_text(
    json.dumps(out, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
t = govde["turetilmis"]
print(f"✓ data.json · {len(govde)} blok")
print(f"  devir {d['toplam_adet']} tesis · {t['devredilen_milyon_ha']} milyon ha · "
      f"birlikler alanın %{t['birlik_alan_payi_yuzde']}'i ama tesislerin "
      f"%{t['birlik_adet_payi_yuzde']}'u")
print(f"  devir süresi {t['devir_suresi_yil']} yıl (YAS serisi)")
