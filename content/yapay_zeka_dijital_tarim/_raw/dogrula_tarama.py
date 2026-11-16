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

print("\n✗ %d HATA" % len(hatalar) if hatalar else "\n✓ Tarama yapılandırması tutarlı")
sys.exit(1 if hatalar else 0)
