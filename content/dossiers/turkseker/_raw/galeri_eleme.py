#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Kullanıcının elediği kareleri galeriden çıkarır.

24 Kasım 2026, kullanıcı galeriyi gözden geçirip numara verdi:

  "galeriden çıkarılacak görseller: 80,81,84,86,90,92,94,101,110,111,112,
   115,116,118,120-131 arası, 133,134,135,137,138,140,142,143,153-167
   arası. bunları kaldır. gerisi kalsın."

NUMARA DEĞİL KİMLİK YAZILI. Numara galerideki SIRA demek ve ilk kare
çıkarıldığı anda bütün numaralar kayıyor; betik ikinci kez koşsaydı bambaşka
kareleri silerdi. Numaralar çözüldüğü anda kimliğe çevrildi ve buraya
donduruldu. Çözüm tablosu aşağıda, denetlenebilsin diye numarasıyla duruyor.

DOSYALAR DİSKTE SİLİNMİYOR. Bir kare galeriden çıkınca dosyası
_raw/gorseller/ altında kalıyor; kullanıcı fikir değiştirirse yeniden
indirmek gerekmesin. kur_yayin_gorselleri.py kullanılmayanları sayıyor,
silmiyor.

161-167 ARASI BİRLEŞMEDEN GELENLER. Yedi bölüm çifti birleşince boşta kalan
bölüm görselleri galerinin sonuna eklenmişti; kullanıcı yedisini de eledi.
"""
import json
import pathlib
import sys

RAW = pathlib.Path(__file__).parent

# sıra → kimlik (eleme anındaki galeri sırası, 167 karelik hâl)
ELENEN = {
    80: "galeri_alpullu_kopru_22",
    81: "galeri_alpullu_kopru_24",
    84: "galeri_alpullu_lokomotif",
    86: "galeri_kurum_tbmm",
    90: "galeri_kurum_haymana_1",
    92: "galeri_salt_alb_002",
    94: "galeri_salt_alb_004",
    101: "galeri_kurum_laboratuvar_1",
    110: "galeri_kurum_kamyon",
    111: "galeri_salt_etim_fabrika_arka",
    112: "galeri_salt_usak_kart_arka",
    115: "galeri_kurum_eskisehir_kapi",
    116: "galeri_kurum_kastamonu_hava",
    118: "galeri_kurum_susurluk_hava",
    120: "galeri_salt_alb_023",
    121: "galeri_salt_alb_024",
    122: "galeri_salt_alb_025",
    123: "galeri_salt_alb_026",
    124: "galeri_salt_alb_028",
    125: "galeri_salt_alb_029",
    126: "galeri_salt_alb_030",
    127: "galeri_salt_alb_032",
    128: "galeri_salt_alb_033",
    129: "galeri_salt_alb_034",
    130: "galeri_salt_alb_035",
    131: "galeri_salt_alb_038",
    133: "galeri_kurum_malatya_salon",
    134: "galeri_kurum_kozet_bandi",
    135: "galeri_kurum_malatya_koridor",
    137: "galeri_kurum_ilgin_makine",
    138: "galeri_kurum_ilgin_gezi",
    140: "galeri_kurum_cuval_doldurma",
    142: "galeri_kurum_ilgin_depo",
    143: "galeri_kurum_cuval_depo",
    153: "galeri_seker_sokak_3",
    154: "galeri_seker_sokak_4",
    155: "galeri_seker_sokak_5",
    156: "galeri_etimesgut_c_tipi",
    157: "galeri_etimesgut_lojman_yikim",
    158: "galeri_kurum_fidan_1",
    159: "galeri_kurum_fidan_2",
    160: "galeri_kurum_fidan_3",
    161: "galeri_turkseker_usak_hisse",
    162: "galeri_turkseker_s17_kampanya",
    163: "galeri_turkseker_s18_burdur",
    164: "galeri_turkseker_s07_ozbekistan",
    165: "galeri_turkseker_pancar_kiyim",
    166: "galeri_turkseker_s26_turbin",
    167: "galeri_turkseker_s21_malatya",
}

# İKİNCİ TUR — üçüncü parti eklendikten sonra (24 Kasım 2026):
#   "132,138,140 nolu görselleri sil gerisi kalsın"
# Numaralar o anki 142 karelik sıraya aitti; yine kimliğe çevrilip
# donduruldu.
ELENEN2 = {
    132: "galeri_ciftci_sozlesme_kitapcik",
    138: "galeri_yukleme_filo",
    140: "galeri_urun_kristal",
}

# (liste, önceki sayı, sonraki sayı)
TURLAR = [(ELENEN, 167, 118), (ELENEN2, 142, 139)]


def tur_uygula(SEC, KUDOSYA, ALT, liste, once, sonra):
    """Tek eleme turu. Döndürdüğü: uygulandı mı."""
    kimlikler = set(liste.values())
    if len(kimlikler) != len(liste):
        sys.exit("✗ eleme listesinde tekrar eden kimlik var")
    var = {k["kimlik"] for k in SEC["kareler"]}
    kalan = kimlikler & var
    if not kalan:
        return False
    # YARIM UYGULAMA OLMASIN: ya hepsi duruyor ya hiçbiri.
    if kalan != kimlikler:
        sys.exit("✗ liste yarım uygulanmış, elle bak: "
                 + ", ".join(sorted(kimlikler - var)))
    if len(SEC["kareler"]) != once:
        sys.exit("✗ galeri %d kare, bu tur %d karelik sıraya göre yazıldı"
                 % (len(SEC["kareler"]), once))
    SEC["kareler"] = [k for k in SEC["kareler"] if k["kimlik"] not in kimlikler]
    for kimlik in kimlikler:
        KUDOSYA["kareler"].pop(kimlik, None)
        ALT.pop(kimlik, None)
    if len(SEC["kareler"]) != sonra:
        sys.exit("✗ %d kare kaldı, %d bekleniyordu" % (len(SEC["kareler"]), sonra))
    print("  ✓ %d kare elendi · galeri %d → %d" % (len(kimlikler), once, sonra))
    for n, kimlik in sorted(liste.items()):
        print("     − %3d  %s" % (n, kimlik))
    return True


def main():
    sec_yol = RAW / "galeri_secim.json"
    ku_yol = RAW / "gorseller" / "galeri_kunye.json"
    alt_yol = RAW / "galeri_altyazilar.json"
    SEC = json.loads(sec_yol.read_text(encoding="utf-8"))
    KUDOSYA = json.loads(ku_yol.read_text(encoding="utf-8"))
    ALT = json.loads(alt_yol.read_text(encoding="utf-8"))

    uygulanan = 0
    for liste, once, sonra in TURLAR:
        if tur_uygula(SEC, KUDOSYA, ALT, liste, once, sonra):
            uygulanan += 1
    if uygulanan == 0:
        print("  · eleme zaten uygulanmış (%d kare)" % len(SEC["kareler"]))
        return

    SEC["_eleme"] = (
        "24 Kasım 2026: kullanıcı galeriyi iki kez gözden geçirip eledi — "
        "önce 49 kare (167 → 118), sonra üçüncü parti eklendikten sonra 3 "
        "kare (142 → 139). Numaralar o günkü sıraya aitti ve kimliğe "
        "çevrilip _raw/galeri_eleme.py içine donduruldu.")
    sec_yol.write_text(json.dumps(SEC, ensure_ascii=False, indent=2), encoding="utf-8")
    ku_yol.write_text(json.dumps(KUDOSYA, ensure_ascii=False, indent=2), encoding="utf-8")
    alt_yol.write_text(json.dumps(ALT, ensure_ascii=False, indent=2), encoding="utf-8")

    from collections import Counter
    print("\n  galeri: %d kare · parti dağılımı %s"
          % (len(SEC["kareler"]),
             dict(sorted(Counter(k.get("parti", 1) for k in SEC["kareler"]).items()))))


main()
