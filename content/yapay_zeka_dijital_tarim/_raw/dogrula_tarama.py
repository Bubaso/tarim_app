#!/usr/bin/env python3
"""
Yapay Zeka ve Dijital Tarım — tarama yapılandırmasının doğrulayıcısı.

    python3 dogrula_tarama.py

KURALLAR
  1. KAPSAMA. İskelette `gelisme` hedefi taşıyan her başlık ya bir akademik
     sorguya, ya bir Türkiye haber sorgusuna bağlı ya da `elle` listesinde
     GEREKÇESİYLE duruyor. Sessizce taranmayan başlık olmaz (karar 16).
  2. GEÇERLİLİK. Sorgudaki her başlık numarası iskelette var; alan terimleri
     boş değil; bir terim aynı sorguda iki kez geçmiyor.
  3. SAYFA İZLEME. erisim.json'da izlenecek resmî/kurumsal sayfa var
     (mevzuat ve kurumsal katmanda makine okunur kaynak SIFIR — Tur 1).
  4. BAŞLIĞA BAĞLI SAYFALAR (karar 16). `sayfalar` listesindeki her satır
     geçerli: başlık iskelette, tür bilinen, adres https, (adres, başlık)
     tekil.
  5. HEDEF KAPSAMASI. İskelette `sayi` hedefi taşıyan başlığın en az bir
     'seri' sayfası, `mevzuat` hedefi taşıyanın en az bir 'resmi' sayfası
     var (§24 genel mevzuat sayfalarıyla kapsanıyor) — ya da `elle_sayfa`da
     GEREKÇESİYLE duruyor. `dizin` hedefini haber hattının dizin adayları
     karşılıyor (src/utils/yz_bolumu.py).
  6. GÜNCELLEME PARAGRAFI. Karar 56'dan beri başlıklarda "Bu sayfa nasıl
     güncelleniyor" bölümü yok; taramanın neyi izlediği merkez sayfada tek
     yerde anlatılıyor. Başlıkta yeniden belirirse durur.
"""
import json, sys
from pathlib import Path

BURASI = Path(__file__).resolve().parent
hatalar = []

def hata(m):
    hatalar.append(m); print(f"  ✗ {m}")

iskelet = json.loads((BURASI.parent / "iskelet.json").read_text(encoding="utf-8"))["basliklar"]
s = json.loads((BURASI / "tarama_sorgulari.json").read_text(encoding="utf-8"))
var = {b["no"] for b in iskelet}
gelisme = {b["no"] for b in iskelet if "gelisme" in b["oto_hedefler"]}
akademik = {q["no"] for q in s["basliklar"]}
haber = {q["baslik_no"] for q in s["turkiye_haber_sorgulari"]}
elle = {int(k) for k in s.get("elle", {})}

print("1 · kapsama")
for no in sorted(gelisme):
    if no not in akademik | haber | elle:
        hata(f"§{no} 'gelisme' hedefli ama ne sorgusu ne 'elle' gerekçesi var")
for no in sorted(elle):
    if not str(s["elle"][str(no)]).strip():
        hata(f"§{no} elle listesinde gerekçesiz")
print(f"  · {len(gelisme)} başlık: {len(akademik & gelisme)} akademik, "
      f"{len(haber & gelisme)} haber, {len(elle & gelisme)} elle")

print("2 · geçerlilik")
for q in s["basliklar"]:
    if q["no"] not in var:
        hata(f"sorgu §{q['no']}: iskelette yok")
    if not q["alan"]:
        hata(f"sorgu §{q['no']}: alan terimi yok")
    terimler = [t.casefold() for t in q["alan"] + q.get("teknoloji", s["varsayilan_teknoloji"])]
    if len(terimler) != len(set(terimler)):
        hata(f"sorgu §{q['no']}: tekrarlanan terim")
for q in s["turkiye_haber_sorgulari"]:
    if q["baslik_no"] not in var:
        hata(f"haber sorgusu §{q['baslik_no']}: iskelette yok")
for no in elle - var:
    hata(f"elle §{no}: iskelette yok")

print("3 · sayfa izleme")
sayfalar = [k for k in json.loads((BURASI / "erisim.json").read_text(encoding="utf-8"))["kaynaklar"]
            if k.get("katman") in ("mevzuat", "kurumsal") and k.get("beklenen") == "html"
            and k.get("teshis") == "AÇIK"]
if not sayfalar:
    hata("izlenecek sayfa yok — erisim_haritasi.py yeniden koşmalı")
print(f"  · {len(sayfalar)} resmî/kurumsal sayfa izleniyor")

TURLER = {"seri", "resmi", "dizin", "satici", "kayit"}
ozel = s.get("sayfalar", [])
elle_sayfa = {int(k): v for k, v in s.get("elle_sayfa", {}).items()}

print("4 · başlığa bağlı sayfalar")
gorulen = set()
for k in ozel:
    ad = f"sayfa '{k.get('ad', '?')}'"
    if k.get("baslik_no") not in var:
        hata(f"{ad}: §{k.get('baslik_no')} iskelette yok")
    if k.get("tur") not in TURLER:
        hata(f"{ad}: tür '{k.get('tur')}' bilinmiyor ({', '.join(sorted(TURLER))})")
    if not str(k.get("adres", "")).startswith("https://"):
        hata(f"{ad}: adres https değil")
    if not str(k.get("ad", "")).strip():
        hata("adsız sayfa satırı")
    anahtar = (k.get("adres"), k.get("baslik_no"))
    if anahtar in gorulen:
        hata(f"{ad}: §{k.get('baslik_no')} için iki kez")
    gorulen.add(anahtar)
for no, neden in elle_sayfa.items():
    if no not in var or not str(neden).strip():
        hata(f"elle_sayfa §{no}: iskelette yok ya da gerekçesiz")
print(f"  · {len(ozel)} başlığa bağlı sayfa, {len({k['adres'] for k in ozel})} farklı adres")

print("5 · hedef kapsaması")
def sayfa_var(no, tur):
    return any(k.get("baslik_no") == no and k.get("tur") == tur for k in ozel)
for b in iskelet:
    no, hedef = b["no"], set(b["oto_hedefler"])
    if "sayi" in hedef and not sayfa_var(no, "seri") and no not in elle_sayfa:
        hata(f"§{no} 'sayi' hedefli ama 'seri' sayfası da 'elle_sayfa' gerekçesi de yok")
    if ("mevzuat" in hedef and no != 24 and not sayfa_var(no, "resmi")
            and no not in elle_sayfa):
        hata(f"§{no} 'mevzuat' hedefli ama 'resmi' sayfası da 'elle_sayfa' gerekçesi de yok")

print("6 · güncelleme paragrafları")
# Karar 56: başlıklarda "Bu sayfa nasıl güncelleniyor" bölümü yok; taramanın
# ne izlediği okura merkez sayfada tek yerde anlatılıyor. Başlıkta yeniden
# belirirse dogrula_bolumler.py (kural 8) de durdurur; burada izleme
# listesiyle karşılaştırılacak bir söz kalmadığını not ediyoruz.
BOLUMLER = BURASI.parent / "bolumler"
import re as _re
for yol in sorted(BOLUMLER.glob("[0-2][0-9]-*.md")):
    if _re.search(r"^## (Bu sayfa nasıl güncelleniyor|How this page is kept up to date)",
                  yol.read_text(encoding="utf-8"), _re.M):
        hata(f"{yol.name}: başlıkta güncelleme paragrafı var (karar 56: yalnız merkez sayfada)")
print("  · başlıklarda güncelleme paragrafı yok (karar 56)")

print("\n✗ %d HATA" % len(hatalar) if hatalar else "\n✓ Tarama yapılandırması tutarlı")
sys.exit(1 if hatalar else 0)
