#!/usr/bin/env python3
"""veri.json → lib/features/turkuaz_nexus/data/tni_veri.g.dart

NEDEN DART'A GÖMÜLÜYOR, ASSET OLARAK OKUNMUYOR.
Uygulamada hiçbir yerde rootBundle kullanılmıyor; her şey Supabase'den geliyor.
Bu sayfanın tabanı ise ağa bağlı OLMAMALI: girişimin kurucu belgesi sabit,
sayfanın gövdesi o belgeden kilitli ve ağ düşerse sayfa boşalmamalı. Bir JSON
asset'i ikinci bir ağ isteği, ikinci bir çözümleme ve ikinci bir sessiz arıza
yolu demekti. Dart sabiti derlemeye giriyor: istek yok, çözümleme yok, yazım
hatası derlemede yakalanıyor.

Üretilmiş dosya ELLE DÜZENLENMEZ. Veri değişince veri.json düzeltilir ve bu
betik yeniden koşturulur.

ÇİFT DOLAR İŞARETİ TUZAĞI: Dart dizgi sabitinde `$` interpolasyon başlatır.
json.dumps `$`'a dokunmadığı için kaçışı burada elle koyuyoruz; konmazsa
derleme 'undefined name' diye düşer ya da daha kötüsü, adı tanımlıysa sessizce
başka bir değer basar.
"""
import json, pathlib, subprocess, sys

KOK = pathlib.Path(__file__).resolve().parents[2]
GIRIS = KOK / "content/turkuaz_nexus/veri.json"
CIKIS = KOK / "lib/features/turkuaz_nexus/data/tni_veri.g.dart"


def dizgi(s: str) -> str:
    return json.dumps(s, ensure_ascii=False).replace("$", r"\$")


def dart(x, girinti: int = 0) -> str:
    bosluk = "  " * girinti
    ic = "  " * (girinti + 1)
    if x is None:
        return "null"
    if isinstance(x, bool):
        return "true" if x else "false"
    if isinstance(x, (int, float)):
        return repr(x)
    if isinstance(x, str):
        return dizgi(x)
    if isinstance(x, list):
        if not x:
            return "<dynamic>[]"
        govde = ",\n".join(ic + dart(v, girinti + 1) for v in x)
        return "<dynamic>[\n%s,\n%s]" % (govde, bosluk)
    if isinstance(x, dict):
        if not x:
            return "<String, dynamic>{}"
        govde = ",\n".join(
            "%s%s: %s" % (ic, dizgi(str(k)), dart(v, girinti + 1)) for k, v in x.items()
        )
        return "<String, dynamic>{\n%s,\n%s}" % (govde, bosluk)
    raise TypeError("Dart'a çevrilemeyen tür: %r" % type(x))


def main() -> int:
    veri = json.loads(GIRIS.read_text(encoding="utf-8"))
    cekim = veri.get("_cekim", "?")
    govde = dart(veri, 0)
    metin = (
        "// ÜRETİLMİŞ DOSYA — ELLE DÜZENLENMEZ.\n"
        "//\n"
        "// Kaynak : content/turkuaz_nexus/veri.json\n"
        "// Üreten : content/turkuaz_nexus/dart_uret.py\n"
        "// Çekim  : %s\n"
        "//\n"
        "// Turkuaz Bağlantısallık Girişimi sayfasının GÖMÜLÜ katmanı. Kaynağı sabit\n"
        "// bir belgeye bağlı olan her şey burada; zamanla değişen durumlar\n"
        "// `public.tni_ortu` tablosundan geliyor ve bunun üzerine biniyor.\n"
        "//\n"
        "// Değişiklik için: veri.json düzeltilir, sonra\n"
        "//   python3 content/turkuaz_nexus/dart_uret.py\n"
        "\n"
        "/// Girişimin kilitli veri katmanı. Her kalem bir kaynağa bağlı.\n"
        "const Map<String, dynamic> tniVeri = %s;\n"
    ) % (cekim, govde)
    CIKIS.parent.mkdir(parents=True, exist_ok=True)
    CIKIS.write_text(metin, encoding="utf-8")
    kb = len(metin.encode()) / 1024
    print("✓ %s  (%.1f KB)" % (CIKIS.relative_to(KOK), kb))

    # Üretilen dosyanın GEÇERLİ OLDUĞU sınanıyor. Betik sessizce bozuk Dart
    # üretirse hatayı derlemede değil burada görmek istiyoruz.
    try:
        r = subprocess.run(
            ["dart", "analyze", "--fatal-infos", str(CIKIS)],
            cwd=KOK, capture_output=True, text=True, timeout=240,
        )
        if r.returncode != 0:
            print(r.stdout[-3000:] or r.stderr[-3000:])
            print("ÜRETİLEN DART GEÇERSİZ.")
            return 1
        print("✓ dart analyze temiz")
    except (FileNotFoundError, subprocess.TimeoutExpired) as e:
        print("… dart analyze koşturulamadı (%s); elle sınanmalı" % type(e).__name__)
    return 0


if __name__ == "__main__":
    sys.exit(main())
