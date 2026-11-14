#!/usr/bin/env python3
"""`duraklar.json` → `uzay_duraklar.g.dart` — belgesel akışın omurgası.

Üç katman var ve üçü ayrı dosyada:
  data.json      → ölçüm   (kilitli rakamlar, doğrulamalı)
  duraklar.json  → omurga  (durak sırası, atmosfer, ekrandaki iki cümle)
  akis.json      → derin   (uzun metin; duraklardaki "derine in" katmanı)

Ayrı olmalarının sebebi: bir cümleyi düzeltmek veri doğrulamasını yeniden
koşturmak olmasın, bir rengi değiştirmek metni tekrar okutmasın.
"""
from __future__ import annotations
import json, pathlib, re, subprocess, sys

KOK = pathlib.Path(__file__).parent
DEPO = KOK.parent.parent
CIKTI = DEPO / "lib/features/uzay_tarimi/data/uzay_duraklar.g.dart"

d = json.loads((KOK / "duraklar.json").read_text(encoding="utf-8"))
hata: list[str] = []

RENK = re.compile(r"^0xFF[0-9A-Fa-f]{6}$")
numaralar = [x["no"] for x in d["duraklar"]]
if numaralar != sorted(numaralar) or len(set(numaralar)) != len(numaralar):
    hata.append("DURAK NUMARALARI BOZUK · sıralı ve tekil olmalı")

for s in d["duraklar"]:
    yer = f"durak {s['no']}"
    for alan in ("zemin", "vurgu"):
        if not RENK.match(str(s.get(alan, ""))):
            hata.append(f"{yer}: '{alan}' 0xFFRRGGBB biçiminde değil")
    if s.get("tip") not in ("sahne", "an"):
        hata.append(f"{yer}: tip 'sahne' ya da 'an' olmalı")
    if not s.get("hazir"):
        continue
    # HAZIR DURAĞIN TAM OLMASI ŞART. Yarım bir durak ekranda boş bir
    # sahne demek; akışın ortasında boşluk okuru durdurur.
    for alan in ("zaman_tr", "baslik_tr", "giris_tr", "zaman_en",
                 "baslik_tr", "giris_en"):
        if not s.get(alan):
            hata.append(f"{yer}: '{alan}' boş")
    # SAHNENİN KARESİ, ANIN MALZEMESİ OLMALI.
    #
    # İlk kural her hazır duraktan görsel istiyordu ve zaman çizgisi
    # durağında düştü: o durağın taşıyıcısı fotoğraf değil, kilometre
    # taşları. Kural türe göre ayrıldı — sahne karesiz olmaz, an da
    # malzemesiz olmaz.
    if s["tip"] == "sahne":
        g = s.get("gorsel")
        if not g:
            hata.append(f"{yer}: sahne ama karesi yok")
        else:
            for alan in ("url", "atif", "alt_tr", "alt_en"):
                if not g.get(alan):
                    hata.append(f"{yer}: görselin '{alan}' alanı boş — "
                                f"yarım künye, künyesizlikten farksız")
    else:
        tip = s.get("an_tipi")
        if not tip:
            hata.append(f"{yer}: an ama 'an_tipi' yok")
        elif tip == "zaman_cizgisi":
            tas = s.get("kilometre_taslari") or []
            if len(tas) < 6:
                hata.append(f"{yer}: zaman çizgisinde {len(tas)} durak — "
                            f"sürüklemeye değmesi için en az altı gerek")
            yillar = [t.get("yil") for t in tas]
            if yillar != sorted(y for y in yillar if isinstance(y, int)):
                hata.append(f"{yer}: kilometre taşları yıl sırasında değil")
            for t in tas:
                for alan in ("yil", "baslik_tr", "baslik_en",
                             "not_tr", "not_en", "yer_tr", "yer_en"):
                    if not t.get(alan):
                        hata.append(f"{yer}/{t.get('yil')}: '{alan}' boş")
                # ÇİZGİDEKİ NOT DA KISA. Sürüklerken okunan metin uzun
                # olursa okur sürüklemeyi bırakıp okumaya geçiyor ve
                # etkileşim ölüyor.
                for alan in ("not_tr", "not_en"):
                    if len(t.get(alan) or "") > 230:
                        hata.append(f"{yer}/{t.get('yil')}: '{alan}' "
                                    f"{len(t[alan])} karakter — çizgide "
                                    f"okunacak not kısa olmalı")
            if not s.get("_KAYNAK_NOTU"):
                hata.append(f"{yer}: zaman çizgisinin kaynak notu yok — "
                            f"yılların nereden geldiği yazılmalı")
        elif tip == "sema":
            adimlar = s.get("adimlar") or []
            if not 3 <= len(adimlar) <= 8:
                hata.append(f"{yer}: şemada {len(adimlar)} adım — üçten az "
                            f"anlatmaz, sekizden çok yorar")
            for a in adimlar:
                for alan in ("id", "baslik_tr", "baslik_en",
                             "not_tr", "not_en"):
                    if not a.get(alan):
                        hata.append(f"{yer}/{a.get('id')}: '{alan}' boş")
                for alan in ("not_tr", "not_en"):
                    if len(a.get(alan) or "") > 240:
                        hata.append(f"{yer}/{a.get('id')}: '{alan}' "
                                    f"{len(a[alan])} karakter — adım notu "
                                    f"kısa olmalı, çizim anlatıyor")
            # ÇİZİMİN KAYNAĞI YAZILMALI. Bir şema her şeyi söyleyebilir ve
            # kimse sormaz; kaynağı olmayan bir ok, kaynağı olmayan bir
            # cümleden daha tehlikeli.
            if not s.get("_KAYNAK_NOTU"):
                hata.append(f"{yer}: şemanın kaynak notu yok — çizilen her "
                            f"parçanın nereden geldiği yazılmalı")
        elif tip == "secim":
            sec = s.get("secenekler") or []
            if not 4 <= len(sec) <= 8:
                hata.append(f"{yer}: {len(sec)} seçenek — dörtten az oyun "
                            f"olmaz, sekizden çok seçim yorar")
            for o in sec:
                for alan in ("id", "ad_tr", "ad_en", "basamak",
                             "sonuc_tr", "sonuc_en", "not_tr", "not_en"):
                    if o.get(alan) is None or o.get(alan) == "":
                        hata.append(f"{yer}/{o.get('id')}: '{alan}' boş")
                b = o.get("basamak")
                if not isinstance(b, int) or not 0 <= b <= 9:
                    hata.append(f"{yer}/{o.get('id')}: basamak 0-9 arası "
                                f"olmalı (0 = sıraya hiç girmedi)")
            # SÜRPRİZ KORUNUYOR. Bu durağın bütün işi, okurun büyük
            # ihtimalle yüksek beklediği bir ekinin SIRAYA HİÇ GİRMEMİŞ
            # olması. Sıfır basamaklı seçenek kalkarsa durak sıradan bir
            # sıralama aracına döner.
            if not any(o.get("basamak") == 0 for o in sec):
                hata.append(f"{yer}: sıfır basamaklı seçenek yok — durağın "
                            f"sürprizi buna dayanıyor")
            if not any(o.get("basamak") == 9 for o in sec):
                hata.append(f"{yer}: dokuzu geçen seçenek yok — "
                            f"karşılaştıracak bir uç gerek")
        elif tip == "surgu":
            for yan in ("sol", "sag"):
                g = s.get(yan)
                if not g:
                    hata.append(f"{yer}: sürgünün '{yan}' karesi yok")
                    continue
                for alan in ("url", "atif", "alt_tr", "alt_en",
                             "etiket_tr", "etiket_en"):
                    if not g.get(alan):
                        hata.append(f"{yer}/{yan}: '{alan}' boş")
            # İKİ KARE AYRI OLMALI. Aynı kareyi iki yana koymak sürgüyü
            # anlamsız bir süse çevirir.
            if (s.get("sol") or {}).get("url") == (s.get("sag") or {}).get("url"):
                hata.append(f"{yer}: iki yanda aynı kare var")
            if not s.get("_KAYNAK_NOTU"):
                hata.append(f"{yer}: sürgünün kaynak notu yok — iki karenin "
                            f"neyi gösterdiği yazılmalı")
    # VİDEO VARSA KÜNYESİ VE BAŞLANGICI TAM OLMALI.
    # Ham NASA indirme kayıtları jenerikle açılıyor; başlangıç saniyesi
    # yazılmazsa döngü her turda künye kartını gösterir.
    v = s.get("video")
    if v:
        for alan in ("url", "atif", "baslangic_sn"):
            if v.get(alan) in (None, ""):
                hata.append(f"{yer}: videonun '{alan}' alanı boş")
        if not isinstance(v.get("baslangic_sn"), int):
            hata.append(f"{yer}: 'baslangic_sn' tam sayı olmalı")
        if not v.get("_SESSIZ"):
            hata.append(f"{yer}: videonun ses kararı yazılmamış")
        if not s.get("gorsel"):
            hata.append(f"{yer}: videolu durağın afişi (gorsel) olmalı — "
                        f"video yüklenene kadar ekran boş kalır")

    # EKRANDA EN FAZLA İKİ CÜMLE. Bu dosya bir kez metne boğuldu;
    # kural artık kodda duruyor, iyi niyette değil.
    for alan in ("giris_tr", "giris_en", "vurgu_tr", "vurgu_en"):
        v = s.get(alan) or ""
        if len(v) > 190:
            hata.append(f"{yer}: '{alan}' {len(v)} karakter — ekranda "
                        f"en fazla iki cümle, gerisi derin katmanda")
    # DERİN KATMAN ZORUNLU — AMA BİLEREK VAZGEÇİLEBİLİR.
    # Varsayılan: her durağın bir derin katmanı olur, yoksa 'derine in'
    # kapısı boşluğa açılır. Tek istisna, katmanın GEREKSİZ olduğuna karar
    # verilen durak: o zaman `derin_yok` alanına GEREKÇE yazılır. Sessizce
    # eksik bırakmakla bilerek vazgeçmek arasındaki fark, yazılı gerekçe.
    if s.get("derin_yok"):
        if len(str(s["derin_yok"])) < 25:
            hata.append(f"{yer}: 'derin_yok' bir gerekçe ister, bayrak değil")
        if s.get("derin_tr") or s.get("derin_en"):
            hata.append(f"{yer}: hem 'derin_yok' hem derin metin var — biri gitmeli")
    elif not s.get("derin_tr") or not s.get("derin_en"):
        hata.append(f"{yer}: derin katman boş — 'derine in' kapısı açılmaz")

# AÇIK ZEMİNLİ DURAK İŞARETLİ OLMALI. Atmosfer eğrisi beyaza çıkıyor;
# 'acik' yanlışsa o durakta beyaz üstüne beyaz metin yazılır.
for s in d["duraklar"]:
    try:
        v = int(str(s["zemin"]), 16) & 0xFFFFFF
    except Exception:
        continue
    parlaklik = (((v >> 16) & 255) * 299 + ((v >> 8) & 255) * 587 +
                 (v & 255) * 114) / 1000
    if (parlaklik > 140) != bool(s.get("acik")):
        hata.append(f"durak {s['no']}: zemin parlaklığı {parlaklik:.0f} ama "
                    f"'acik' alanı {s.get('acik')} — metin rengi ters döner")

if not d.get("giris", {}).get("atlanabilir"):
    hata.append("GİRİŞ ANİMASYONU ATLANAMIYOR · her açılışta üç saniye "
                "beklemek zorunda kalan okur ikinci kez gelmez")

if hata:
    print("OMURGA KİLİTLENMEDİ:", file=sys.stderr)
    for h in hata:
        print(f"  ✗ {h}", file=sys.stderr)
    raise SystemExit(1)


def kacir(s: str) -> str:
    return s.replace("\\", "\\\\").replace("'", "\\'").replace("$", "\\$")


def dart(v, girinti=2) -> str:
    bo, ic = " " * girinti, " " * (girinti + 2)
    if isinstance(v, str):
        return f"'{kacir(v)}'"
    if isinstance(v, bool):
        return "true" if v else "false"
    if isinstance(v, (int, float)):
        return str(v)
    if v is None:
        return "null"
    if isinstance(v, list):
        if not v:
            return "[]"
        return "[\n" + ",\n".join(ic + dart(x, girinti + 2) for x in v) + ",\n" + bo + "]"
    if isinstance(v, dict):
        if not v:
            return "{}"
        return "{\n" + ",\n".join(f"{ic}'{kacir(str(k))}': {dart(x, girinti + 2)}"
                                  for k, x in v.items()) + ",\n" + bo + "}"
    raise TypeError(type(v))


CIKTI.parent.mkdir(parents=True, exist_ok=True)
CIKTI.write_text(
    "// ÜRETİLMİŞ DOSYA — ELLE DEĞİŞTİRİLMEZ.\n"
    "// Kaynak: content/uzay_tarimi/duraklar.json\n"
    "// Üretici: content/uzay_tarimi/duraklar_uret.py\n\n"
    f"const Map<String, dynamic> uzayDuraklar = {dart(d)};\n",
    encoding="utf-8")

hazir = [s for s in d["duraklar"] if s.get("hazir")]
an = [s for s in d["duraklar"] if s.get("tip") == "an"]
print(f"✓ {CIKTI.relative_to(DEPO)}  ({CIKTI.stat().st_size/1024:.1f} KB)")
print(f"  {len(d['duraklar'])} durak · {len(an)} an · {len(hazir)} hazır")
for s in d["duraklar"]:
    im = "●" if s.get("hazir") else "○"
    print(f"  {im} {s['no']:>2} {s['tip']:<6} {s['baslik_tr'][:34]:36}"
          f"{'AÇIK' if s.get('acik') else ''}")

r = subprocess.run(["dart", "analyze", str(CIKTI)], capture_output=True,
                   text=True, cwd=DEPO)
if r.returncode:
    print(r.stdout[-1200:], file=sys.stderr)
    raise SystemExit("✗ dart analyze düştü")
print("✓ dart analyze temiz")
