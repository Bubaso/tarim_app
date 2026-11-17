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
  6. GÜNCELLEME PARAGRAFI. Her başlığın "Bu sayfa nasıl güncelleniyor"
     paragrafı yalnız taramanın gerçekten yaptığını söylüyor: "hakemli" diyen
     başlığın akademik sorgusu, "haber" diyen başlığın haber sorgusu, "yeni
     sürüm" diyen başlığın 'seri' sayfası, "resmî … / Resmî Gazete" diyen
     başlığın `mevzuat` hedefi ya da 'resmi'/'seri' sayfası var (yalnız
     "Resmî Gazete" diyen başlığa Resmî Gazete'yi süzen kendi sayfası da
     yeter); "izliyor" diyen her başlığın en az bir
     kendi izleme kaynağı (sorgu ya da sayfa) var. Paragraf okura söz
     veriyor; tutulmayan söz yayına çıkmaz (karar 55).
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
import re as _re
BOLUMLER = BURASI.parent / "bolumler"
sayac = 0
for b in iskelet:
    no = b["no"]
    yol = next(iter(BOLUMLER.glob(f"{no:02d}-*.tr.md")), None)
    if yol is None or no in (29, 30):
        continue
    metin = yol.read_text(encoding="utf-8")
    m = _re.search(r"^## Bu sayfa nasıl güncelleniyor\s*\n(.*)", metin, _re.S | _re.M)
    if not m:
        hata(f"§{no}: 'Bu sayfa nasıl güncelleniyor' bölümü yok")
        continue
    p = m.group(1)
    sayac += 1
    kendi = (no in akademik) or (no in haber) or any(k.get("baslik_no") == no for k in ozel) \
        or no in (22, 23, 24)            # genel sayfalar bu üç başlığa düşüyor
    if "hakemli" in p and no not in akademik:
        hata(f"§{no}: paragraf hakemli çalışma izlediğini söylüyor ama akademik sorgusu yok")
    if _re.search(r"\bhaber", p) and no not in haber:
        hata(f"§{no}: paragraf haber izlediğini söylüyor ama haber sorgusu yok")
    if "yeni sürüm" in p and not sayfa_var(no, "seri"):
        hata(f"§{no}: paragraf kaynakların yeni sürümlerini izlediğini söylüyor ama 'seri' sayfası yok")
    resmi_soz = _re.search(r"[Rr]esmî (gelişme|düzenleme|istatistik|belge)", p)
    rg_soz = "Resmî Gazete" in p
    if resmi_soz or rg_soz:
        dayanak = "mevzuat" in b["oto_hedefler"] or sayfa_var(no, "resmi") or sayfa_var(no, "seri")
        # Resmî Gazete'yi kendi süzgeciyle izleyen bir 'dizin' ya da 'kayit'
        # sayfası da yeter (ör. §25: üniversite merkezi yönetmelikleri).
        if not dayanak and rg_soz and not resmi_soz:
            dayanak = any(k.get("baslik_no") == no and "resmigazete.gov.tr" in k.get("adres", "")
                          for k in ozel)
        if not dayanak:
            hata(f"§{no}: paragraf resmî belge izlediğini söylüyor ama 'mevzuat' hedefi ya da sayfası yok")
    if "izliyor" in p and not kendi:
        hata(f"§{no}: paragraf 'izliyor' diyor ama başlığın kendi izleme kaynağı yok")
print(f"  · {sayac} paragraf yapılandırmayla karşılaştırıldı")

print("\n✗ %d HATA" % len(hatalar) if hatalar else "\n✓ Tarama yapılandırması tutarlı")
sys.exit(1 if hatalar else 0)
