#!/usr/bin/env python3
"""iskelet.json → lib/features/yapay_zeka/data/yz_iskelet.g.dart

NEDEN DART'A GÖMÜLÜYOR: iskelet ve yazılı içerik gömülü, ağ düşse de sayfa
çalışır (karar 21). Otomatik alanlar ve haber akışı veritabanından gelir;
başlıkların kendisi gelmez. Panelin başlık seçicisi ve bölüm sayfası aynı
sabiti okur — hattın başlık listesi de aynı iskeletle sınanıyor
(`~/tarim_ai_pipeline/src/utils/yz_bolumu.py`, `iskeletle_tutarli_mi`).

Üretilmiş dosya ELLE DÜZENLENMEZ. İskelet değişince önce
`_raw/iskelet_uret.py`, sonra bu betik koşturulur.

ÇİFT DOLAR TUZAĞI: Dart dizgisinde `$` interpolasyon başlatır; kaçış burada
konuyor (turkuaz_nexus/dart_uret.py ile aynı kural).
"""
import json, pathlib, subprocess, sys

KOK = pathlib.Path(__file__).resolve().parents[2]
GIRIS = KOK / "content/yapay_zeka_dijital_tarim/iskelet.json"
CIKIS = KOK / "lib/features/yapay_zeka/data/yz_iskelet.g.dart"


def dizgi(s: str) -> str:
    return json.dumps(s, ensure_ascii=False).replace("$", r"\$")


def main() -> int:
    d = json.loads(GIRIS.read_text(encoding="utf-8"))
    b = d["basliklar"]

    # ── okura açılış bayrağı (yayin.json) ─────────────────────────────
    # Kullanıcı kararı (16 Kasım 2026): bölüm 30 başlığın TAMAMI yazılınca
    # açılır. Bayrak açık ama eşik tutmuyorsa üretim DURUR.
    yayin = json.loads((GIRIS.parent / "yayin.json").read_text(encoding="utf-8"))
    acik = bool(yayin.get("okura_acik"))
    eksik = [x["no"] for x in b if x.get("durum") != "yazildi"]
    if acik and yayin.get("acilis_esigi") == "tamami" and eksik:
        print(f"✗ okura_acik=true ama {len(eksik)} başlık yazılmadı: "
              f"{', '.join('§' + str(n) for n in eksik)} — açılış eşiği 'tamami'",
              file=sys.stderr)
        return 1
    if not b or any(x.get("haber_alir") is None for x in b):
        print("✗ iskelette `haber_alir` yok — önce _raw/iskelet_uret.py", file=sys.stderr)
        return 1

    s = []
    s.append("// ÜRETİLMİŞ DOSYA — ELLE DEĞİŞTİRİLMEZ.")
    s.append("// Kaynak: content/yapay_zeka_dijital_tarim/iskelet.json")
    s.append("// Üretici: content/yapay_zeka_dijital_tarim/dart_uret.py")
    s.append("//")
    s.append("// Yapay Zeka ve Dijital Tarım bölümünün iskeleti: başlıklar, katmanlar,")
    s.append("// teknoloji etiketleri. Haber akışı ve etiketler veritabanında")
    s.append("// (`bolum_etiketleri`); başlık ADLARI burada.")
    s.append("")
    s.append("/// Bölüm okura açık mı (content/yapay_zeka_dijital_tarim/yayin.json).")
    s.append("/// `false` iken okur rotaları kurulmaz, ana sayfa şeridi çizilmez; sabit")
    s.append("/// derleme anında bilindiği için okur ekranları pakete de girmez. Panel")
    s.append("/// bundan bağımsız. Açılış eşiği: 30 başlığın tamamı (kullanıcı kararı).")
    s.append(f"const bool kYzOkuraAcik = {'true' if acik else 'false'};")
    s.append("")
    s.append(f"const String kYzBolumu = {dizgi('yapay-zeka-dijital-tarim')};")
    s.append(f"const String kYzAdres = {dizgi(d['adres'])};")
    s.append(f"const String kYzAdTr = {dizgi(d['ad']['tr'])};")
    s.append(f"const String kYzAdEn = {dizgi(d['ad']['en'])};")
    s.append("")
    s.append("class YzBaslik {")
    s.append("  const YzBaslik(this.no, this.slug, this.katman, this.tr, this.en,")
    s.append("      this.haberAlir, this.teknoloji, this.yazildi, this.ozetTr, this.ozetEn);")
    s.append("  final int no;")
    s.append("  final String slug;")
    s.append("  final String katman;")
    s.append("  final String tr;")
    s.append("  final String en;")
    s.append("")
    s.append("  /// Haber bu başlığın altına bağlanabilir mi (karar 32). Çerçeve,")
    s.append("  /// özet, dizin ve başvuru sayfaları elle yazılır, haber almaz.")
    s.append("  final bool haberAlir;")
    s.append("  final List<String> teknoloji;")
    s.append("")
    s.append("  /// İki dili ve kilitli kaydı var, doğrulayıcıdan geçti (iskelet `durum`).")
    s.append("  final bool yazildi;")
    s.append("  final String ozetTr;")
    s.append("  final String ozetEn;")
    s.append("")
    s.append("  String ad(bool en) => en ? this.en : tr;")
    s.append("  String ozet(bool en) => en ? ozetEn : ozetTr;")
    s.append("}")
    s.append("")
    s.append("const List<YzBaslik> kYzBasliklar = [")
    for x in b:
        tek = ", ".join(dizgi(t) for t in x["teknoloji"])
        s.append(f"  YzBaslik({x['no']}, {dizgi(x['slug'])}, {dizgi(x['katman'])},")
        s.append(f"      {dizgi(x['baslik']['tr'])}, {dizgi(x['baslik']['en'])},")
        s.append(f"      {'true' if x['haber_alir'] else 'false'}, [{tek}],")
        s.append(f"      {'true' if x.get('durum') == 'yazildi' else 'false'},")
        s.append(f"      {dizgi(x['ozet']['tr'])}, {dizgi(x['ozet']['en'])}),")
    s.append("];")
    s.append("")
    s.append("/// Numarası verilen başlık; yoksa null.")
    s.append("YzBaslik? yzBaslik(int? no) {")
    s.append("  if (no == null) return null;")
    s.append("  for (final b in kYzBasliklar) {")
    s.append("    if (b.no == no) return b;")
    s.append("  }")
    s.append("  return null;")
    s.append("}")
    s.append("")
    s.append("/// Haber alabilen başlıklar — panelin başlık seçicisi bunu gösterir.")
    s.append("final List<YzBaslik> kYzHaberBasliklari =")
    s.append("    kYzBasliklar.where((b) => b.haberAlir).toList(growable: false);")
    s.append("")
    s.append("const Map<String, Map<String, String>> kYzKatmanlar = {")
    for k, v in d["katmanlar"].items():
        s.append(f"  {dizgi(k)}: {{'tr': {dizgi(v['tr'])}, 'en': {dizgi(v['en'])}}},")
    s.append("};")
    s.append("")
    s.append("const Map<String, Map<String, String>> kYzTeknoloji = {")
    for k, v in d["teknoloji"].items():
        s.append(f"  {dizgi(k)}: {{'tr': {dizgi(v['tr'])}, 'en': {dizgi(v['en'])}}},")
    s.append("};")
    s.append("")
    # Karar 57: teknolojinin metindeki izi. Desenler _raw/teknoloji_izi.py'den
    # (iskelet üzerinden); kurallar orada. Dart'taki eşleştirici
    # (yz_teknoloji_izi.dart) aynı sayıyı bulmak zorunda — eşlik testi.
    s.append("/// Teknoloji desenleri (karar 57): 'desen_tr', 'desen_en', 'haric_tr', 'haric_en'.")
    s.append("const Map<String, Map<String, List<String>>> kYzTeknolojiDesen = {")
    for k, v in d["teknoloji"].items():
        parcalar = ", ".join(f"{dizgi(a)}: [{', '.join(dizgi(x) for x in v.get(a, []))}]"
                             for a in ("desen_tr", "desen_en", "haric_tr", "haric_en"))
        s.append(f"  {dizgi(k)}: {{{parcalar}}},")
    s.append("};")
    s.append("")
    s.append("/// Teknolojinin asıl konu olduğu başlıklar (karar 57).")
    s.append("const Map<String, List<int>> kYzTeknolojiAna = {")
    for k, v in d["teknoloji"].items():
        s.append(f"  {dizgi(k)}: [{', '.join(str(n) for n in v.get('ana', []))}],")
    s.append("};")
    s.append("")
    s.append("/// Python eşleştiricisinin her başlıkta saydığı paragraf (ve tablo satırı)")
    s.append("/// sayısı: {no: {teknoloji: [tr, en]}}. Yalnız eşlik testi için.")
    s.append("const Map<int, Map<String, List<int>>> kYzTeknolojiIzi = {")
    for x in b:
        iz = x.get("teknoloji_izi") or {}
        if not iz:
            continue
        parcalar = ", ".join(f"{dizgi(k)}: [{v.get('tr', 0)}, {v.get('en', 0)}]" for k, v in iz.items())
        s.append(f"  {x['no']}: {{{parcalar}}},")
    s.append("};")
    s.append("")

    CIKIS.parent.mkdir(parents=True, exist_ok=True)
    CIKIS.write_text("\n".join(s), encoding="utf-8")

    # ── yazılmış başlıkların metni — gömülü (karar 21) ────────────────
    # Yalnız iskelette `yazildi` olanlar: iki dil + kilitli kayıt var ve
    # dogrula_bolumler.py'den geçti. Güncellik tarihi kaydın kendisinden
    # (karar 23: güncellik başlık bazında gösterilir).
    m = ["// ÜRETİLMİŞ DOSYA — ELLE DEĞİŞTİRİLMEZ.",
         "// Kaynak: content/yapay_zeka_dijital_tarim/bolumler/*.md + _raw/bNN_kaynaklar.json",
         "// Üretici: content/yapay_zeka_dijital_tarim/dart_uret.py",
         "//",
         "// Metinler Markdown'ın dar bir kesiti: `#` başlık, `>` özet, `##` alt",
         "// başlık, paragraf, **kalın**, *italik*, tablo. Çizici:",
         "// lib/features/yapay_zeka/presentation/yz_metin_gorunumu.dart",
         "",
         "class YzBolumMetni {",
         "  const YzBolumMetni(this.no, this.tr, this.en, this.guncellendi);",
         "  final int no;",
         "  final String tr;",
         "  final String en;",
         "",
         "  /// Kaydın kaynağından en son yeniden okunduğu gün (YYYY-AA-GG).",
         "  final String guncellendi;",
         "",
         "  String metin(bool isEn) => isEn ? en : tr;",
         "}",
         "",
         "const Map<int, YzBolumMetni> kYzMetinler = {"]
    yazilan = 0
    for x in b:
        if x.get("durum") != "yazildi":
            continue
        on = f"{x['no']:02d}-{x['slug']}"
        tr = (KOK / "content/yapay_zeka_dijital_tarim/bolumler" / f"{on}.tr.md").read_text(encoding="utf-8")
        en = (KOK / "content/yapay_zeka_dijital_tarim/bolumler" / f"{on}.en.md").read_text(encoding="utf-8")
        kayit = json.loads((KOK / "content/yapay_zeka_dijital_tarim/_raw" / f"b{x['no']:02d}_kaynaklar.json").read_text(encoding="utf-8"))
        tarih = kayit.get("guncellendi")
        if not tarih:
            print(f"✗ §{x['no']} kaydında `guncellendi` yok", file=sys.stderr)
            return 1
        m.append(f"  {x['no']}: YzBolumMetni({x['no']},")
        m.append(f"      {dizgi(tr)},")
        m.append(f"      {dizgi(en)},")
        m.append(f"      {dizgi(tarih)}),")
        yazilan += 1
    m.append("};")
    m.append("")
    METIN = KOK / "lib/features/yapay_zeka/data/yz_metinler.g.dart"
    METIN.write_text("\n".join(m), encoding="utf-8")

    # ── sözlük — §29 sayfası ve metin içi balon (karar 14) ────────────
    # Tanımlar `_raw/sozluk.json`dan; aynı metin §29'un .md dosyasına da
    # `_raw/sozluk_uret.py` ile yazılıyor ve orada kayda karşı sınanıyor.
    # Dosya yoksa liste boş: hiçbir terim işaretlenmez.
    SOZLUK = KOK / "lib/features/yapay_zeka/data/yz_sozluk.g.dart"
    kaynak = KOK / "content/yapay_zeka_dijital_tarim/_raw/sozluk.json"
    terimler = json.loads(kaynak.read_text(encoding="utf-8"))["terimler"] if kaynak.exists() else []
    z = ["// ÜRETİLMİŞ DOSYA — ELLE DEĞİŞTİRİLMEZ.",
         "// Kaynak: content/yapay_zeka_dijital_tarim/_raw/sozluk.json",
         "// Üretici: content/yapay_zeka_dijital_tarim/dart_uret.py",
         "//",
         "// Sözlük (karar 14): §29 sayfası ve bölüm metinlerinde terimin ilk",
         "// geçtiği yerde açılan balon aynı tanımı gösteriyor.",
         "",
         "class YzTerim {",
         "  const YzTerim(this.kimlik, this.tr, this.en, this.tanimTr, this.tanimEn,",
         "      this.kaynakTr, this.kaynakEn, this.desenTr, this.desenEn,",
         "      {this.yalniz = const [], this.haric = const [], this.temel = false});",
         "  final String kimlik;",
         "  final String tr;",
         "  final String en;",
         "  final String tanimTr;",
         "  final String tanimEn;",
         "",
         "  /// Tanımın dayandığı kaynak, okura gösterildiği biçimiyle.",
         "  final String kaynakTr;",
         "  final String kaynakEn;",
         "",
         "  /// Metinde terimi yakalayan desenler. Küçük harfli desen kelime başında",
         "  /// aranır ve kelimenin sonuna kadar uzanır (Türkçe ekler: \"makine",
         "  /// öğrenmesiyle\"). `=` ile başlayan desen büyük-küçük harfe duyarlı ve",
         "  /// tam kelime (\"=SAR\" \"sarımsak\"ın içinde yakalanmaz).",
         "  final List<String> desenTr;",
         "  final List<String> desenEn;",
         "",
         "  /// Balonun açılabileceği başlıklar; boşsa hepsi. Terim başka başlıklarda",
         "  /// başka anlamda da geçiyorsa (\"kesinlik\" §12'de kanıtın kesinliği) yalnız",
         "  /// doğru başlıklarda açılır.",
         "  final List<int> yalniz;",
         "",
         "  /// Balonun açılmayacağı başlıklar.",
         "  final List<int> haric;",
         "",
         "  /// Temel terim (karar 60): bölümün her sayfasında geçen kavram (yapay",
         "  /// zekâ, sensör…). Balonu yalnız Kavramlar sayfasında açılır; sözlükteki",
         "  /// \"geçtiği başlıklar\" listesi bundan etkilenmez.",
         "  final bool temel;",
         "",
         "  /// Balonun bu sayfada açılıp açılmadığı ([no] null: teknoloji sayfası).",
         "  bool balonda(int? no) => no == null ? !temel : baslikta(no) && (!temel || no == kYzKavramlarNo);",
         "",
         "  bool baslikta(int no) => (yalniz.isEmpty || yalniz.contains(no)) && !haric.contains(no);",
         "",
         "  String ad(bool en) => en ? this.en : tr;",
         "  String tanim(bool en) => en ? tanimEn : tanimTr;",
         "  String kaynak(bool en) => en ? kaynakEn : kaynakTr;",
         "  List<String> desen(bool en) => en ? desenEn : desenTr;",
         "}",
         "",
         "/// Kavramlar başlığının numarası: temel terimlerin balonu yalnız orada.",
         "const int kYzKavramlarNo = 2;",
         "",
         "const List<YzTerim> kYzSozluk = ["]
    for x in terimler:
        z.append(f"  YzTerim({dizgi(x['kimlik'])}, {dizgi(x['tr'])}, {dizgi(x['en'])},")
        z.append(f"      {dizgi(x['tanim_tr'])},")
        z.append(f"      {dizgi(x['tanim_en'])},")
        z.append(f"      {dizgi(x['kaynak_tr'])}, {dizgi(x['kaynak_en'])},")
        z.append(f"      [{', '.join(dizgi(d) for d in x['desen_tr'])}],")
        ek = ""
        if x.get("yalniz"):
            ek += f", yalniz: [{', '.join(str(n) for n in x['yalniz'])}]"
        if x.get("haric"):
            ek += f", haric: [{', '.join(str(n) for n in x['haric'])}]"
        if x.get("temel"):
            ek += ", temel: true"
        z.append(f"      [{', '.join(dizgi(d) for d in x['desen_en'])}]{ek}),")
    z.append("];")
    z.append("")
    SOZLUK.write_text("\n".join(z), encoding="utf-8")
    try:
        subprocess.run(["dart", "format", str(CIKIS), str(METIN), str(SOZLUK)], check=False,
                       capture_output=True, timeout=60)
    except Exception:
        pass
    # ── teknoloji sayfaları ve kesişim notları (karar 57) ─────────────
    # Sayfa: teknolojiler/<kod>.{tr,en}.md, tarihi tek_<kod>_kaynaklar.json'dan.
    # Not: _raw/kesisim_<kod>.json. Eksik olan atlanıyor (dogrula_bolumler.py
    # eksiği yakalıyor); çizici olmayanı göstermiyor.
    TEK = KOK / "lib/features/yapay_zeka/data/yz_teknoloji.g.dart"
    raw = KOK / "content/yapay_zeka_dijital_tarim/_raw"
    sayfa_klasoru = KOK / "content/yapay_zeka_dijital_tarim/teknolojiler"
    k = ["// ÜRETİLMİŞ DOSYA — ELLE DEĞİŞTİRİLMEZ.",
         "// Kaynak: content/yapay_zeka_dijital_tarim/teknolojiler/*.md, _raw/tek_*_kaynaklar.json,",
         "//         _raw/kesisim_*.json",
         "// Üretici: content/yapay_zeka_dijital_tarim/dart_uret.py",
         "//",
         "// Teknoloji ekseni (karar 57): her teknolojinin alanlar arası durum sayfası",
         "// ve her teknoloji–başlık kesişiminin tek cümlelik notu.",
         "",
         "class YzTeknolojiMetni {",
         "  const YzTeknolojiMetni(this.kod, this.tr, this.en, this.guncellendi);",
         "  final String kod;",
         "  final String tr;",
         "  final String en;",
         "",
         "  /// Kaydın en son okunduğu gün (YYYY-AA-GG).",
         "  final String guncellendi;",
         "",
         "  String metin(bool isEn) => isEn ? en : tr;",
         "}",
         "",
         "const Map<String, YzTeknolojiMetni> kYzTeknolojiMetinleri = {"]
    sayfa_sayisi = 0
    for kod in d["teknoloji"]:
        tr_yol, en_yol = sayfa_klasoru / f"{kod}.tr.md", sayfa_klasoru / f"{kod}.en.md"
        kayit_yol = raw / f"tek_{kod}_kaynaklar.json"
        if not (tr_yol.exists() and en_yol.exists() and kayit_yol.exists()):
            continue
        tarih = json.loads(kayit_yol.read_text(encoding="utf-8")).get("guncellendi", "")
        k.append(f"  {dizgi(kod)}: YzTeknolojiMetni({dizgi(kod)},")
        k.append(f"      {dizgi(tr_yol.read_text(encoding='utf-8'))},")
        k.append(f"      {dizgi(en_yol.read_text(encoding='utf-8'))},")
        k.append(f"      {dizgi(tarih)}),")
        sayfa_sayisi += 1
    k.append("};")
    k.append("")
    k.append("/// Kesişim notları: {teknoloji: {başlık no: [tr, en]}}.")
    k.append("const Map<String, Map<int, List<String>>> kYzKesisim = {")
    not_sayisi = 0
    for kod in d["teknoloji"]:
        yol = raw / f"kesisim_{kod}.json"
        if not yol.exists():
            continue
        notlar = json.loads(yol.read_text(encoding="utf-8")).get("notlar", {})
        k.append(f"  {dizgi(kod)}: {{")
        for no in sorted(notlar, key=int):
            n = notlar[no]
            k.append(f"    {int(no)}: [{dizgi(n.get('tr', ''))}, {dizgi(n.get('en', ''))}],")
            not_sayisi += 1
        k.append("  },")
    k.append("};")
    k.append("")
    TEK.write_text("\n".join(k), encoding="utf-8")

    # ── grafikler (karar 58) ───────────────────────────────────────────
    # _raw/grafikler.json → yz_grafikler.g.dart. Değerler kayda karşı
    # dogrula_bolumler.py (kural 11) ile sınanıyor; burada yalnız gömülüyor.
    GRAFIK = KOK / "lib/features/yapay_zeka/data/yz_grafikler.g.dart"
    gyol = raw / "grafikler.json"
    grafikler = json.loads(gyol.read_text(encoding="utf-8")).get("grafikler", {}) if gyol.exists() else {}
    def ikidil(x, a):
        v = x.get(a) or {}
        return dizgi(v.get("tr", "")), dizgi(v.get("en", ""))
    gr = ["// ÜRETİLMİŞ DOSYA — ELLE DEĞİŞTİRİLMEZ.",
          "// Kaynak: content/yapay_zeka_dijital_tarim/_raw/grafikler.json",
          "// Üretici: content/yapay_zeka_dijital_tarim/dart_uret.py",
          "//",
          "// Grafikler (karar 58): her değer bir kaydın sayısal alanından.",
          "",
          "import 'yz_grafik_veri.dart';",
          "",
          "const Map<String, YzGrafik> kYzGrafikler = {"]
    for kimlik, x in grafikler.items():
        bt, be = ikidil(x, "baslik")
        at, ae = ikidil(x, "aciklama")
        kt, ke = ikidil(x, "kaynak")
        brt, bre = ikidil(x, "birim")
        gr.append(f"  {dizgi(kimlik)}: YzGrafik(")
        gr.append(f"    kimlik: {dizgi(kimlik)},")
        gr.append(f"    tur: {dizgi(x['tur'])},")
        gr.append(f"    baslikTr: {bt}, baslikEn: {be},")
        gr.append(f"    aciklamaTr: {at}, aciklamaEn: {ae},")
        gr.append(f"    kaynakTr: {kt}, kaynakEn: {ke},")
        gr.append(f"    birimTr: {brt}, birimEn: {bre},")
        if x.get("eksen"):
            et, ee = ikidil(x, "eksen")
            gr.append(f"    eksenTr: {et}, eksenEn: {ee},")
        if x.get("ust") is not None:
            gr.append(f"    ust: {float(x['ust'])!r},")
        if x.get("ondalik") is not None:
            gr.append(f"    ondalik: {int(x['ondalik'])},")
        gr.append(f"    satici: {'true' if x.get('satici') or any(n.get('satici') for n in x.get('noktalar', [])) else 'false'},")
        gr.append("    diziler: [")
        for dz in x.get("diziler", []):
            rol = f", rol: {dizgi(dz['rol'])}" if dz.get("rol") else ""
            gr.append(f"      YzGrafikDizi({dizgi(dz['kod'])}, {dizgi(dz['tr'])}, {dizgi(dz['en'])}{rol}),")
        gr.append("    ],")
        gr.append("    noktalar: [")
        for n in x.get("noktalar", []):
            kt_, ke_ = dizgi(n["kategori"]["tr"]), dizgi(n["kategori"]["en"])
            # Çizilen değer: kayıttaki değer × çarpan (birim dönüşümü, ör. bin ha → milyon ha).
            deger = float(n["deger"]) * float(n.get("carpan", 1))
            ek = []
            if n.get("uc"):
                ek.append(f"uc: {dizgi(n['uc'])}")
            for alan, ad in (("ek", "ek"), ("panel", "panel")):
                if n.get(alan):
                    ek.append(f"{ad}Tr: {dizgi(n[alan]['tr'])}, {ad}En: {dizgi(n[alan]['en'])}")
            if n.get("birim"):
                ek.append(f"birimTr: {dizgi(n['birim']['tr'])}, birimEn: {dizgi(n['birim']['en'])}")
            if n.get("satici"):
                ek.append("satici: true")
            ekler = (", " + ", ".join(ek)) if ek else ""
            gr.append(f"      YzGrafikNokta({kt_}, {ke_}, {dizgi(n.get('dizi', ''))}, {round(deger, 10)!r}{ekler}),")
        gr.append("    ],")
        gr.append("  ),")
    gr.append("};")
    gr.append("")
    # Görseller (karar 58): _raw/gorseller.json; dosyalar web/yz/gorsel/ altında.
    vyol = raw / "gorseller.json"
    gorseller = json.loads(vyol.read_text(encoding="utf-8")).get("gorseller", {}) if vyol.exists() else {}
    gr.append("const Map<String, YzGorsel> kYzGorseller = {")
    for kimlik, x in gorseller.items():
        kt, ke = ikidil(x, "kunye")
        st, se = ikidil(x, "kaynak")
        adres = "/" + x["dosya"].removeprefix("web/")
        gr.append(f"  {dizgi(kimlik)}: YzGorsel(kimlik: {dizgi(kimlik)}, adres: {dizgi(adres)},")
        gr.append(f"      genislik: {int(x.get('genislik', 0))}, yukseklik: {int(x.get('yukseklik', 0))},")
        gr.append(f"      kunyeTr: {kt}, kunyeEn: {ke}, kaynakTr: {st}, kaynakEn: {se},")
        tr_adres = ("/" + x["dosya_tr"].removeprefix("web/")) if x.get("dosya_tr") else None
        lejant = (x.get("lejant") or {}).get("tr")
        gr.append(f"      yapayZeka: {'true' if x.get('yapay_zeka') else 'false'}"
                  + (f", adresTr: {dizgi(tr_adres)}" if tr_adres else "")
                  + (f", lejantTr: {dizgi(lejant)}" if lejant else "") + "),")
    gr.append("};")
    gr.append("")
    GRAFIK.write_text("\n".join(gr), encoding="utf-8")

    # ── kısaltma balonu (karar 60) ─────────────────────────────────────
    # _raw/kisaltmalar.json → yz_kisaltmalar.g.dart. Balon yalnız
    # `kisaltmalar`daki kısaltmalarda; `bilinen` ve `ad` doğrulayıcı içindir.
    kyol = raw / "kisaltmalar.json"
    kis = json.loads(kyol.read_text(encoding="utf-8")) if kyol.exists() else {}
    KIS = KOK / "lib/features/yapay_zeka/data/yz_kisaltmalar.g.dart"
    kz = ["// ÜRETİLMİŞ DOSYA — ELLE DEĞİŞTİRİLMEZ.",
          "// Kaynak: content/yapay_zeka_dijital_tarim/_raw/kisaltmalar.json",
          "// Üretici: content/yapay_zeka_dijital_tarim/dart_uret.py",
          "//",
          "// Kısaltma balonu (karar 60): az bilinen bir kısaltma bir sayfada ilk",
          "// geçtiği yerde açılmıyorsa açılımı balonla gösteriliyor.",
          "",
          "class YzKisaltma {",
          "  const YzKisaltma(this.tr, this.en);",
          "  final String tr;",
          "  final String en;",
          "  String acilim(bool en) => en ? this.en : tr;",
          "}",
          "",
          "const Map<String, YzKisaltma> kYzKisaltmalar = {"]
    for k, x in sorted(kis.get("kisaltmalar", {}).items()):
        kz.append(f"  {dizgi(k)}: YzKisaltma({dizgi(x['tr'])}, {dizgi(x['en'])}),")
    kz.append("};")
    kz.append("")
    kz.append("/// Balonsuz geçen büyük harfli sözcükler: herkesin bildiği kısaltmalar ve")
    kz.append("/// özel adlar (testin kapsama denetimi için).")
    kz.append("const Set<String> kYzKisaltmaDisi = {")
    for k in sorted(set(kis.get("bilinen", [])) | set(kis.get("ad", []))):
        kz.append(f"  {dizgi(k)},")
    kz.append("};")
    kz.append("")
    KIS.write_text("\n".join(kz), encoding="utf-8")
    try:
        subprocess.run(["dart", "format", str(KIS)], check=False, capture_output=True, timeout=60)
    except Exception:
        pass

    # ── rakamdan kaynağa (karar 58, etkileşim) ─────────────────────────
    # Her kalın rakamın kaynağı: _raw/rakam_kaynaklari.py eşliyor.
    import importlib.util as _iu
    _sp = _iu.spec_from_file_location("rakam_kaynaklari", raw / "rakam_kaynaklari.py")
    _rk = _iu.module_from_spec(_sp)
    _sp.loader.exec_module(_rk)
    esleme, kunyeler, kapsama = _rk.esle()
    RK = KOK / "lib/features/yapay_zeka/data/yz_rakam_kaynaklari.g.dart"
    rk = ["// ÜRETİLMİŞ DOSYA — ELLE DEĞİŞTİRİLMEZ.",
          "// Kaynak: bölüm ve teknoloji metinleri + kayıtlar; eşleyici _raw/rakam_kaynaklari.py",
          "// Üretici: content/yapay_zeka_dijital_tarim/dart_uret.py",
          "//",
          "// Rakamdan kaynağa (karar 58): {\"sayfa:dil\": {kalın parça: [[kaynak, alıntı], …]}}.",
          "",
          "const Map<String, Map<String, List<List<String>>>> kYzRakamKaynak = {"]
    for sayfa, diller in esleme.items():
        for dil, kalinlar in diller.items():
            rk.append(f"  {dizgi(sayfa + ':' + dil)}: {{")
            for kalin, adaylar in kalinlar.items():
                ic = ", ".join(f"[{dizgi(a)}, {dizgi(p)}]" for a, p in adaylar)
                rk.append(f"    {dizgi(kalin)}: [{ic}],")
            rk.append("  },")
    rk.append("};")
    rk.append("")
    rk.append("/// {sayfa: {kaynak: [künye, bağlantı]}}")
    rk.append("const Map<String, Map<String, List<String>>> kYzKaynakKunye = {")
    for sayfa, ky in kunyeler.items():
        rk.append(f"  {dizgi(sayfa)}: {{")
        for a, (kunye, bag) in ky.items():
            rk.append(f"    {dizgi(a)}: [{dizgi(kunye)}, {dizgi(bag)}],")
        rk.append("  },")
    rk.append("};")
    rk.append("")
    RK.write_text("\n".join(rk), encoding="utf-8")

    haber = sum(1 for x in b if x["haber_alir"])
    print(f"✓ {CIKIS.relative_to(KOK)} · {len(b)} başlık, {haber} haber alıyor")
    print(f"✓ {RK.relative_to(KOK)} · {sum(e for e, _ in kapsama.values())}/{sum(t for _, t in kapsama.values())} kalın rakam kaynağa bağlı")
    print(f"✓ {GRAFIK.relative_to(KOK)} · {len(grafikler)} grafik, {len(gorseller)} görsel")
    print(f"✓ {TEK.relative_to(KOK)} · {sayfa_sayisi} teknoloji sayfası, {not_sayisi} kesişim notu")
    print(f"✓ {METIN.relative_to(KOK)} · {yazilan} yazılmış başlık gömüldü")
    print(f"✓ {SOZLUK.relative_to(KOK)} · {len(terimler)} terim")
    print(f"✓ okura {'AÇIK' if acik else 'KAPALI'} (yayin.json) · eşik: {yayin.get('acilis_esigi')} · eksik {len(eksik)} başlık")
    return 0


if __name__ == "__main__":
    sys.exit(main())
