// Yapay Zeka ve Dijital Tarım — rakamın makbuzu: bir alıntının yerel PDF
// kopyasındaki sayfası ve istenirse o yerin vurgulu kesiti.
//
//     swift makbuz.swift <iş.json>
//
// Sürücüsü `makbuz_uret.py` (iş JSON'unu kurar, PNG'yi WebP'ye çevirir).
//
// Girdi (JSON):
//   {"isler": [{"pdf": "<yol>", "alintilar": [{"kimlik": "…", "alinti": "…",
//                                              "cikis": "<png yolu>" | null}]}],
//    "satir": 30, "tavan": 1400, "baglam": 3}
// Çıktı (stdout, JSON): {"sonuclar": [{kimlik, sayfa (1'den) | null,
//   sayfa_sayisi, yontem ("tam" | "parca" | "sira_disi" | null), kapsama (0-1),
//   kutu [x0, y0, x1, y1] (sayfa uzayında, vurgulanan harflerin birleşimi),
//   kesit {genislik, yukseklik, kutu, donus, olcek} | null, neden (bulunamadıysa)}]}
//
// ARAMA. Sayfa metni (PDFPage.string) ve alıntı aynı biçime katlanıyor: NFKD,
// işaretler atılıyor, küçük harf, ı → i, yalnız harf ve rakam kalıyor. Satır
// sonu tirelemesi ("au-\ntomation"), boşluk, tırnak ve kesme farkı böylece
// eşleşmeyi bozmuyor; sayfa sınırını aşan cümle de bulunuyor. Üç yol, sırayla:
//   1. tam: bütün alıntı tek parça.
//   2. parca: alıntının AYIRT EDİCİ bir parçası — en uzun kelime penceresi,
//      belgede tek geçen (ya da 40 harften uzun); sağı ve solu aynı yerin
//      yakınında, daha kısa pencerelerle kapatılıyor (kayıttaki parantez içi
//      not, bozuk bir bağ harfi).
//   3. sira_disi: parça yolu alıntının tamamını kapatamadıysa. Tablo satırı,
//      grafik etiketi ya da paragrafın ilk satırı PDF metninde başka sırayla
//      duruyor ("Tarım Sigortası Destekleme⏎19 200,0 … Hizmetleri"; tabloda
//      sütunlar art arda). Alıntının kelime (ve harf/rakam) koşuları, en
//      uzunu çapa olmak üzere, çapanın SAYFASINDA sıradan bağımsız ve
//      örtüşmeden yerleştiriliyor; bir koşu birden çok yerde geçiyorsa
//      yerleşmişlerin satır bandındaki (tablo satırı), yoksa en yakın geçiş.
//      Yalnız bütün kelimeler yerleşirse kabul ediliyor; kesit o zaman
//      vurgunun hepsini kapsıyor. Her koşu PDF metninde kelime sınırında
//      başlayıp bitmeli. Parça yolunun eksiği kayda EKLENMİŞ bir notsa (eksik
//      öbeğin iki yanındaki parçalar belgede bitişik) bu yol denenmiyor:
//      notun kelimeleri sayfanın başka satırlarında geçse de toplanmasın.
//
// HARF KUTUSU. PDFPage.characterBounds(at:) GLİF sırasıyla çalışıyor; bağ
// harfi (ﬁ, ﬂ) ya da ayrışmış harf (İ = I + ◌̇) içeren sayfada dizgideki
// sıradan kayıyor (ölçüldü: fao_2022_sofa s. 20'de vurgu bir satır aşağıya
// düşüyordu). Kutu bu yüzden SEÇİMDEN (PDFSelection) alınıyor: dizgi
// sırasıyla doğru, döndürülmüş yazıda da. Seçimin kutusu SATIR boyunda; aynı
// satırda iri yazı varsa (dergi kapağında logo) küçük harfin kutusu da iri
// oluyor: o harfte dikey yer, yatayda örtüşen glif kutusundan alınıyor.
//
// KESİT. `cikis` verilmişse: alıntının en çok harfinin düştüğü sayfada
// vurgulu satırların çevresi — üstte ve altta [baglam] görsel satır, yatayda
// o satırların sütunu. Ölçek, vurgulu satır ~[satir] piksel boyunda olacak
// biçimde; genişlik [tavan]ı aşmıyor. Harfler kelime kelime fosforlu kalem
// sarısıyla (çarpma kipinde: kâğıt sararıyor, mürekkep koyu kalıyor)
// boyanıyor; kenarda dikey çizgi YOK. Yan yatırılmış sayfada (tablo) kesit
// okuma yönüne döndürülüyor.
//
// macOS PDFKit; PDF yalnız okunur ve çizilir, içindeki hiçbir şey
// çalıştırılmaz.
import AppKit
import Foundation
import PDFKit

struct AlintiIsi: Decodable {
    let kimlik: String
    let alinti: String
    let cikis: String?
}

struct BelgeIsi: Decodable {
    let pdf: String
    let alintilar: [AlintiIsi]
}

struct Girdi: Decodable {
    let isler: [BelgeIsi]
    let satir: Double?
    let tavan: Double?
    let baglam: Int?
}

// ── Katlama ──────────────────────────────────────────────────────────────

final class Katlayici {
    private var onbellek: [UInt32: [UInt16]] = [:]
    private let i = Array("i".utf16)

    func katla(_ s: Unicode.Scalar) -> [UInt16] {
        if let c = onbellek[s.value] { return c }
        var cikti: [UInt16] = []
        for a in String(s).decomposedStringWithCompatibilityMapping.unicodeScalars {
            switch a.properties.generalCategory {
            case .nonspacingMark, .spacingMark, .enclosingMark: continue
            default: break
            }
            for b in String(a).lowercased().unicodeScalars {
                if b == "ı" { cikti += i; continue }
                switch b.properties.generalCategory {
                case .uppercaseLetter, .lowercaseLetter, .titlecaseLetter, .otherLetter,
                     .decimalNumber, .letterNumber, .otherNumber:
                    cikti += Array(String(b).utf16)
                default: continue
                }
            }
        }
        onbellek[s.value] = cikti
        return cikti
    }

    func katla(_ s: String) -> [UInt16] {
        var c: [UInt16] = []
        for sc in s.unicodeScalars { c += katla(sc) }
        return c
    }
}

// ── Belgenin katlanmış metni ─────────────────────────────────────────────

final class Belge {
    let pdf: PDFDocument
    var birim: [UInt16] = []
    /// Her katlanmış birimin sayfası (0'dan), kaynak skalerin sayfa metnindeki
    /// UTF-16 başı ve uzunluğu.
    var sayfa: [Int32] = []
    var konum: [Int32] = []
    var uzunluk: [UInt8] = []
    var metinliSayfa = 0
    private(set) var ns: NSString = ""

    init?(yol: String, k: Katlayici) {
        guard let b = PDFDocument(url: URL(fileURLWithPath: yol)) else { return nil }
        pdf = b
        for i in 0..<b.pageCount {
            guard let p = b.page(at: i), let s = p.string, !s.isEmpty else { continue }
            metinliSayfa += 1
            var u = 0
            for sc in s.unicodeScalars {
                let n = sc.utf16.count
                for c in k.katla(sc) {
                    birim.append(c)
                    sayfa.append(Int32(i))
                    konum.append(Int32(u))
                    uzunluk.append(UInt8(n))
                }
                u += n
            }
        }
        ns = NSString(characters: birim, length: birim.count)
    }

    var butun: NSRange { NSRange(location: 0, length: ns.length) }

    func bul(_ igne: [UInt16], _ alan: NSRange) -> NSRange? {
        guard !igne.isEmpty, alan.length >= igne.count else { return nil }
        let r = ns.range(of: String(utf16CodeUnits: igne, count: igne.count), options: .literal, range: alan)
        return r.location == NSNotFound ? nil : r
    }

    /// Belgede tek mi geçiyor.
    func tek(_ igne: [UInt16], _ ilk: NSRange) -> Bool {
        let sonra = ilk.location + 1
        return bul(igne, NSRange(location: sonra, length: ns.length - sonra)) == nil
    }

    /// İki sınır arasında, belgenin içinde kalan aralık.
    func aralik(_ bas: Int, _ son: Int) -> NSRange {
        let b = max(0, bas), s = min(ns.length, son)
        return NSRange(location: b, length: max(0, s - b))
    }

    /// Bir sayfanın katlanmış metindeki aralığı (birimler sayfa sırasıyla).
    func sayfaAraligi(_ p: Int) -> NSRange {
        var lo = 0, hi = sayfa.count
        while lo < hi { let m = (lo + hi) / 2; if Int(sayfa[m]) < p { lo = m + 1 } else { hi = m } }
        var son = lo
        while son < sayfa.count && Int(sayfa[son]) == p { son += 1 }
        return NSRange(location: lo, length: son - lo)
    }

    /// Katlanmış aralığın sayfa metnindeki (UTF-16) karşılığı; aralık tek sayfada.
    func ozgun(_ r: NSRange) -> NSRange {
        let bas = Int(konum[r.location])
        let son = Int(konum[r.location + r.length - 1]) + Int(uzunluk[r.location + r.length - 1])
        return NSRange(location: bas, length: son - bas)
    }

    /// Katlanmış aralığın sayfadaki kutusu (seçimden; sayfa uzayında).
    func kutu(_ p: PDFPage, _ r: NSRange) -> CGRect {
        p.selection(for: ozgun(r))?.bounds(for: p) ?? .null
    }

    /// Katlanmış aralık sayfa metninde kelime sınırında başlayıp bitiyor mu
    /// ("Field trials" içindeki "field trial" sınırda bitmiyor).
    func sinirda(_ r: NSRange, _ metin: NSString) -> Bool {
        let o = ozgun(r)
        func harf(_ i: Int) -> Bool {
            guard i >= 0, i < metin.length, let s = Unicode.Scalar(metin.character(at: i)) else { return false }
            switch s.properties.generalCategory {
            case .uppercaseLetter, .lowercaseLetter, .titlecaseLetter, .otherLetter, .modifierLetter,
                 .decimalNumber, .letterNumber, .otherNumber: return true
            default: return false
            }
        }
        return !harf(o.location - 1) && !harf(o.location + o.length)
    }
}

// ── Eşleştirme ───────────────────────────────────────────────────────────

struct Eslesme {
    var araliklar: [NSRange]
    var yontem: String
    var kapsama: Double
}

/// Parça aramada komşu pencerelerin aranacağı uzaklık (katlanmış harf).
let yakinlik = 2500

/// Parça eşleşmesi: (belgedeki aralık, alıntıdaki kelime başı, kelime sonu),
/// alıntı sırasıyla.
func kapla(_ b: Belge, _ k: [[UInt16]], _ lo: Int, _ hi: Int, _ alan: NSRange, ust: Bool) -> [(NSRange, Int, Int)] {
    let enAzKelime = ust ? 4 : 2
    let enAzBirim = ust ? 20 : 10
    guard hi - lo >= enAzKelime, alan.length > 0 else { return [] }
    var w = hi - lo
    while w >= enAzKelime {
        var s = lo
        while s + w <= hi {
            let igne = Array(k[s..<(s + w)].joined())
            if igne.count >= enAzBirim, let r = b.bul(igne, alan),
               !ust || igne.count >= 40 || b.tek(igne, r) {
                let sol = b.aralik(max(alan.location, r.location - yakinlik), r.location)
                let sag = b.aralik(r.location + r.length,
                                   min(alan.location + alan.length, r.location + r.length + yakinlik))
                return kapla(b, k, lo, s, sol, ust: false) + [(r, s, s + w)] + kapla(b, k, s + w, hi, sag, ust: false)
            }
            s += 1
        }
        w -= 1
    }
    return []
}

/// Parça eşleşmesinin eksiği kayda EKLENMİŞ bir şey mi (parantez içi not,
/// köşeli ayraçlı açıklama): eksik her kelime öbeğinin iki yanında bulunmuş
/// parça var ve o iki parça belgede bitişik. Öyleyse eksik kelimeler PDF'te
/// yok; sayfanın başka yerinde geçseler de sıra dışı eşleşme denenmiyor.
func eklemeMi(_ parcalar: [(NSRange, Int, Int)], kelime: Int) -> Bool {
    let p = parcalar.sorted { $0.1 < $1.1 }
    guard let ilk = p.first, let son = p.last, ilk.1 == 0, son.2 == kelime else { return false }
    for (a, c) in zip(p, p.dropFirst()) where c.1 > a.2 {
        if c.0.location != a.0.location + a.0.length { return false }
    }
    return true
}

/// Sıra dışı eşleşmenin birimleri: kelimeler ayrıca harf ve rakam
/// koşularına bölünüyor ("Mar/2028Farmers" → mar, 2028, farmers); tablo
/// hücresiyle satır başlığı PDF metninde bitişik olmayabiliyor.
func jetonlar(_ alinti: String, _ kat: Katlayici) -> [[UInt16]] {
    var j: [[UInt16]] = []
    for w in alinti.split(whereSeparator: { $0.isWhitespace }) {
        var cur: [UInt16] = []
        var rakam: Bool?
        for c in kat.katla(String(w)) {
            let r = c >= 0x30 && c <= 0x39
            if let o = rakam, o != r { j.append(cur); cur = [] }
            cur.append(c)
            rakam = r
        }
        if !cur.isEmpty { j.append(cur) }
    }
    return j
}

/// İki kutunun arasındaki boşluk (örtüşen eksende 0).
func uzaklik(_ a: CGRect, _ b: CGRect) -> CGFloat {
    let dx = max(0, max(a.minX - b.maxX, b.minX - a.maxX))
    let dy = max(0, max(a.minY - b.maxY, b.minY - a.maxY))
    return (dx * dx + dy * dy).squareRoot()
}

/// Sıra dışı eşleşme (bkz. başlıktaki ARAMA, 3). Çapa: en çok harfli jeton
/// koşusu (en az 8 harf); her geçişi için çapanın SAYFASINDA kalan jetonlar,
/// en uzun koşu önce, örtüşmeden yerleştiriliyor. Bir koşunun birden çok
/// geçişi varsa yerleşmiş kutuların satır bandındaki (tablo satırı) geçiş,
/// yoksa en yakını seçiliyor. Tek rakamlık koşu kendi başına yerleşmiyor.
func siraDisi(_ b: Belge, _ j: [[UInt16]]) -> [NSRange]? {
    var adaylar: [(Int, Int, Int)] = []   // (baş, jeton sayısı, harf)
    for s in 0..<j.count {
        var n = 0
        for e in s..<j.count {
            n += j[e].count
            if n >= 8 { adaylar.append((s, e - s + 1, n)) }
        }
    }
    adaylar.sort { $0.2 != $1.2 ? $0.2 > $1.2 : $0.0 < $1.0 }
    var denenen = 0
    for (s, w, _) in adaylar {
        let igne = Array(j[s..<(s + w)].joined())
        var alan = b.butun
        while let r = b.bul(igne, alan) {
            let sonra = r.location + 1
            alan = NSRange(location: sonra, length: b.ns.length - sonra)
            let page = b.pdf.page(at: Int(b.sayfa[r.location]))!
            guard b.sinirda(r, (page.string ?? "") as NSString) else { continue }
            denenen += 1
            if denenen > 30 { return nil }
            if let sonuc = yerlestir(b, j, s, w, r) { return sonuc }
        }
    }
    return nil
}

func yerlestir(_ b: Belge, _ j: [[UInt16]], _ s: Int, _ w: Int, _ capa: NSRange) -> [NSRange]? {
    let pi = Int(b.sayfa[capa.location])
    let page = b.pdf.page(at: pi)!
    let metin = (page.string ?? "") as NSString
    let sayfaAlani = b.sayfaAraligi(pi)
    var yerli = [Bool](repeating: false, count: j.count)
    for i in s..<(s + w) { yerli[i] = true }
    var dolu = [capa]
    var kutular = [b.kutu(page, capa)]
    while yerli.contains(false) {
        var adaylar: [(Int, Int, Int)] = []
        var i = 0
        while i < j.count {
            if yerli[i] { i += 1; continue }
            var e = i
            while e < j.count && !yerli[e] { e += 1 }
            for a in i..<e {
                var n = 0
                for z in a..<e {
                    n += j[z].count
                    adaylar.append((a, z - a + 1, n))
                }
            }
            i = e
        }
        adaylar.sort { $0.2 != $1.2 ? $0.2 > $1.2 : $0.0 < $1.0 }
        // Satır bandı: yerleşmiş kutuların okuma yönüne dik kapsamı.
        let birlesik = kutular.reduce(CGRect.null) { $0.union($1) }
        let dikey = kutular[0].height > kutular[0].width   // yan yatırılmış yazı
        func bantta(_ k: CGRect) -> Bool {
            dikey ? (k.midX >= birlesik.minX - 1 && k.midX <= birlesik.maxX + 1)
                  : (k.midY >= birlesik.minY - 1 && k.midY <= birlesik.maxY + 1)
        }
        var yerlesti = false
        for (a, w2, n) in adaylar {
            if w2 == 1 && n < 2 { continue }
            let igne = Array(j[a..<(a + w2)].joined())
            var gecisler: [(NSRange, CGRect)] = []
            var alan = sayfaAlani
            while let r = b.bul(igne, alan), gecisler.count < 60 {
                if !dolu.contains(where: { NSIntersectionRange($0, r).length > 0 }), b.sinirda(r, metin) {
                    gecisler.append((r, b.kutu(page, r)))
                }
                let sonra = r.location + 1
                alan = NSRange(location: sonra, length: sayfaAlani.location + sayfaAlani.length - sonra)
            }
            func puan(_ g: (NSRange, CGRect)) -> CGFloat {
                (bantta(g.1) ? 0 : 100_000) + (kutular.map { uzaklik(g.1, $0) }.min() ?? 0)
            }
            guard let secilen = gecisler.min(by: { puan($0) < puan($1) }) else { continue }
            dolu.append(secilen.0)
            kutular.append(secilen.1)
            for z in a..<(a + w2) { yerli[z] = true }
            yerlesti = true
            break
        }
        if !yerlesti { return nil }
    }
    return dolu.sorted { $0.location < $1.location }
}

func eslestir(_ b: Belge, _ kat: Katlayici, _ alinti: String) -> Eslesme? {
    let tam = kat.katla(alinti)
    guard !tam.isEmpty else { return nil }
    if tam.count >= 12, let r = b.bul(tam, b.butun) {
        return Eslesme(araliklar: [r], yontem: "tam", kapsama: 1)
    }
    let kelimeler = alinti.split(whereSeparator: { $0.isWhitespace })
        .map { kat.katla(String($0)) }
        .filter { !$0.isEmpty }
    let parcalar = kapla(b, kelimeler, 0, kelimeler.count, b.butun, ust: true)
    let araliklar = parcalar.map(\.0)
    let bulunan = araliklar.reduce(0) { $0 + $1.length }
    if bulunan < tam.count, tam.count >= 12, !eklemeMi(parcalar, kelime: kelimeler.count),
       let s = siraDisi(b, jetonlar(alinti, kat)) {
        return Eslesme(araliklar: s, yontem: "sira_disi", kapsama: 1)
    }
    guard !araliklar.isEmpty else { return nil }
    return Eslesme(araliklar: araliklar, yontem: "parca", kapsama: min(1, Double(bulunan) / Double(tam.count)))
}

/// Eşleşmenin en çok harfinin düştüğü sayfa ve o sayfadaki özgün (sayfa
/// metninde, UTF-16) aralıklar; yakın aralıklar birleşiyor.
func sayfaAraliklari(_ b: Belge, _ e: Eslesme) -> (Int, [NSRange]) {
    var harf: [Int: Int] = [:]
    var parcalar: [Int: [(Int, Int)]] = [:]
    for r in e.araliklar {
        var i = r.location
        let son = r.location + r.length
        while i < son {
            let p = Int(b.sayfa[i])
            var j = i
            while j < son && Int(b.sayfa[j]) == p { j += 1 }
            harf[p, default: 0] += j - i
            let bas = Int(b.konum[i])
            let bit = Int(b.konum[j - 1]) + Int(b.uzunluk[j - 1])
            parcalar[p, default: []].append((bas, bit))
            i = j
        }
    }
    let p = harf.max { a, c in a.value != c.value ? a.value < c.value : a.key > c.key }!.key
    var birlesik: [(Int, Int)] = []
    for (bas, bit) in parcalar[p]!.sorted(by: { $0.0 < $1.0 }) {
        // Yalnız bitişik (aradaki boşluk kadar) aralıklar birleşiyor: sıra
        // dışı eşleşmede araya giren yabancı hücre boyanmasın.
        if let son = birlesik.last, bas - son.1 <= 2 {
            birlesik[birlesik.count - 1].1 = max(son.1, bit)
        } else {
            birlesik.append((bas, bit))
        }
    }
    return (p, birlesik.map { NSRange(location: $0.0, length: $0.1 - $0.0) })
}

// ── Geometri ─────────────────────────────────────────────────────────────
//
// Üç uzay: SAYFA (PDF'in kendi koordinatları; seçim kutuları burada), ÇİZİM
// (PDFPage.transform(for: .cropBox) sonrası: sayfanın döndürmesi ve kırpma
// kutusunun başlangıcı uygulanmış) ve OKUMA (yazı yatay okunsun diye çizim
// uzayı gerekirse ±90° döndürülmüş: yan yatırılmış tablo). Kesit okuma
// uzayında hesaplanıp çiziliyor.

func ortanca(_ x: [CGFloat]) -> CGFloat {
    guard !x.isEmpty else { return 10 }
    let s = x.sorted()
    return s[s.count / 2]
}

func bosMu(_ c: unichar) -> Bool {
    c == 0x20 || c == 0x0A || c == 0x0D || c == 0x09 || c == 0xA0 || c == 0x2028 || c == 0x2029
}

func gecerli(_ r: CGRect) -> Bool {
    !r.isNull && !r.isInfinite && r.width > 0.1 && r.height > 0.1
}

/// Sayfanın görsel satırları (sayfa uzayında, PDFKit'in satırları).
func sayfaSatirlari(_ p: PDFPage) -> [CGRect] {
    (p.selection(for: p.bounds(for: .cropBox))?.selectionsByLine() ?? [])
        .map { $0.bounds(for: p) }.filter(gecerli)
}

/// Aralıklardaki boşluk olmayan her harfin kutusu (sayfa uzayında), metin
/// sırasıyla. Bkz. başlıktaki HARF KUTUSU.
///
/// Seçim kutusu satır boyunun çok üstündeyse iki durum var; ikisinde de
/// harfin glifi characterBounds'ta aranıyor (glif sırası dizgi sırasından
/// birkaç adım kaymış olabilir: yatay kapsamı seçimle örtüşen EN YAKIN
/// sıradaki glif) ve glifin altı taban çizgisi sayılıyor:
///  · birleşmiş satır: kutu puntonun 2,4 katından uzun (dergi kapağında
///    logoyla aynı satırdaki küçük yazı, paragrafın iri baş harfinin
///    yanındaki satır). Aynı satırın harfleri tek taban çizgisine (ortanca)
///    oturtuluyor; kutu yazı tipinin çıkıntısı ile inişi kadar.
///  · iri yazı: punto satır boyunun 2,5 katından büyük (logo, baş harf).
///    Satır kutusunun boşluğu iri yazıda bir satır yazıyı örtecek kadar
///    büyük; kutu, glif kutularının birleşimi.
func harfKutulari(_ p: PDFPage, _ metin: NSString, _ araliklar: [NSRange], satirH: CGFloat) -> [[CGRect?]] {
    var kutular: [[CGRect?]] = araliklar.map { r in
        (r.location..<(r.location + r.length)).map { i -> CGRect? in
            if i >= metin.length || bosMu(metin.character(at: i)) { return nil }
            guard let b = p.selection(for: NSRange(location: i, length: 1))?.bounds(for: p),
                  gecerli(b) else { return nil }
            return b
        }
    }
    var uzun: [(a: Int, t: Int, b: CGRect, f: NSFont, glif: CGRect, iri: Bool)] = []
    var eksik: [(a: Int, t: Int, b: CGRect, punto: CGFloat)] = []
    for (a, r) in araliklar.enumerated() {
        for t in 0..<r.length {
            let i = r.location + t
            guard let b = kutular[a][t], b.height > 1.8 * satirH, b.height > b.width,
                  let f = p.selection(for: NSRange(location: i, length: 1))?.attributedString?
                      .attribute(.font, at: 0, effectiveRange: nil) as? NSFont,
                  f.pointSize > 0 else { continue }
            let iri = f.pointSize > 2.5 * satirH
            guard iri || b.height > 2.4 * f.pointSize else { continue }
            var enIyi: (Int, CGRect)?
            let pay = max(1.5, 0.05 * f.pointSize)   // iri glifin yan boşluğu da iri
            for k in -80...80 {
                let j = i + k
                guard j >= 0, j < metin.length else { continue }
                let c = p.characterBounds(at: j)
                guard !c.isNull, !c.isInfinite, c.width > 0.1,
                      abs(c.minX - b.minX) < pay, abs(c.maxX - b.maxX) < pay,
                      c.midY > b.minY, c.midY < b.maxY else { continue }
                if enIyi == nil || abs(k) < abs(enIyi!.0) { enIyi = (k, c) }
            }
            if let (_, c) = enIyi {
                uzun.append((a, t, b, f, c, iri))
            } else {
                eksik.append((a, t, b, f.pointSize))
            }
        }
    }
    // Taban çizgileri satırlara: punto'nun üçte birinden yakın olanlar aynı satır.
    let sirali = uzun.indices.sorted { uzun[$0].glif.minY < uzun[$1].glif.minY }
    var grup: [Int] = []
    func kapat() {
        guard !grup.isEmpty else { return }
        let taban = grup.map { uzun[$0].glif.minY }.sorted()[grup.count / 2]
        let murekkep = grup.map { uzun[$0].glif }.filter { $0.height > 0.1 }.reduce(CGRect.null) { $0.union($1) }
        for g in grup {
            let u = uzun[g]
            if u.iri && !murekkep.isNull {
                let pay = 0.06 * u.f.pointSize
                kutular[u.a][u.t] = CGRect(x: u.b.minX, y: murekkep.minY - pay, width: u.b.width,
                                           height: murekkep.height + 2 * pay)
            } else {
                kutular[u.a][u.t] = CGRect(x: u.b.minX, y: taban + u.f.descender, width: u.b.width,
                                           height: u.f.ascender - u.f.descender)
            }
        }
        grup = []
    }
    for g in sirali {
        if let son = grup.last, uzun[g].glif.minY - uzun[son].glif.minY > uzun[g].f.pointSize / 3
            || uzun[g].iri != uzun[son].iri { kapat() }
        grup.append(g)
    }
    kapat()
    // Glifi bulunamayan harf (ör. satırın ilki) aynı satırdaki, aynı
    // puntodaki en yakın düzeltilmiş komşusunun dikey kapsamını alıyor.
    for e in eksik {
        let komsu = uzun.filter { $0.a == e.a && $0.b.minY == e.b.minY && $0.b.maxY == e.b.maxY
            && abs($0.f.pointSize - e.punto) < 0.1 * e.punto }
            .min { abs($0.t - e.t) < abs($1.t - e.t) }
        if let k = komsu, let d = kutular[k.a][k.t] {
            kutular[e.a][e.t] = CGRect(x: e.b.minX, y: d.minY, width: e.b.width, height: d.height)
        }
    }
    return kutular
}

/// Okuma yönü: çizim uzayında ardışık harflerin ortalama ilerleyişi. Yazı
/// dikey akıyorsa ±90° döndürme (radyan), yatay akıyorsa 0.
func okumaDonusu(_ harfler: [[CGRect?]], _ t: CGAffineTransform) -> CGFloat {
    var dx: CGFloat = 0, dy: CGFloat = 0
    for dizi in harfler {
        var onceki: CGRect?
        for h in dizi {
            guard let h else { onceki = nil; continue }
            let b = h.applying(t)
            if let o = onceki {
                let x = b.midX - o.midX, y = b.midY - o.midY
                // Satır atlaması sayılmasın: yalnız harf boyu kadar yakın komşular.
                if abs(x) + abs(y) < 3 * max(b.width, b.height, 1) { dx += x; dy += y }
            }
            onceki = b
        }
    }
    guard abs(dy) > 2 * abs(dx) else { return 0 }
    // Yukarı akan yazı saat yönünde, aşağı akan ters yönde döndürülür.
    return dy > 0 ? -.pi / 2 : .pi / 2
}

/// Okuma uzayında fosforlu kalem darbeleri: harfler kelimeye, aynı satırda
/// kelime aralığı kadar yakın kelimeler tek darbeye birleşiyor. Tablo
/// hücreleri arasındaki boşluk boyanmıyor; satır başından değil, alıntının
/// ilk harfinden başlıyor.
func darbeler(_ harfler: [[CGRect?]], _ t: CGAffineTransform) -> [CGRect] {
    // Boyları iki kattan fazla ayrışan kutular (logo ve yanındaki küçük yazı)
    // aynı darbeye girmiyor.
    func benzer(_ a: CGRect, _ b: CGRect) -> Bool { max(a.height, b.height) < 2 * min(a.height, b.height) }
    var kelimeler: [CGRect] = []
    for dizi in harfler {
        var k = CGRect.null
        var son = CGRect.null
        for h in dizi {
            guard let h else {
                if !k.isNull { kelimeler.append(k); k = .null }
                continue
            }
            let b = h.applying(t)
            if !k.isNull {
                let ortak = min(k.maxY, b.maxY) - max(k.minY, b.minY)
                if ortak < 0.5 * min(k.height, b.height) || b.minX < k.minX - 1 || !benzer(son, b) {
                    kelimeler.append(k)
                    k = .null
                }
            }
            k = k.isNull ? b : k.union(b)
            son = b
        }
        if !k.isNull { kelimeler.append(k) }
    }
    var sonuc: [CGRect] = []
    for w in kelimeler {
        if let s = sonuc.last {
            let ortak = min(s.maxY, w.maxY) - max(s.minY, w.minY)
            let bosluk = w.minX - s.maxX
            if ortak > 0.5 * min(s.height, w.height), bosluk > -2, bosluk < 0.6 * max(s.height, w.height),
               benzer(s, w) {
                sonuc[sonuc.count - 1] = s.union(w)
                continue
            }
        }
        sonuc.append(w)
    }
    return sonuc
}

/// Sayfanın görsel satırları (okuma uzayında): dikeyde örtüşen ve yan yana
/// bitişik kutular tek satır; sütun aralığıyla ayrılanlar ayrı kalıyor.
func gorselSatirlar(_ kutular: [CGRect]) -> [CGRect] {
    var satirlar: [CGRect] = []
    for k in kutular.sorted(by: { $0.minX < $1.minX }) {
        if let i = satirlar.firstIndex(where: { s in
            let ortak = min(s.maxY, k.maxY) - max(s.minY, k.minY)
            let bosluk = max(k.minX - s.maxX, s.minX - k.maxX)
            return ortak > 0.5 * min(s.height, k.height) && bosluk < 0.8 * min(s.height, k.height)
        }) {
            satirlar[i] = satirlar[i].union(k)
        } else {
            satirlar.append(k)
        }
    }
    return satirlar
}

/// Vurgunun dikeyde bitişik en büyük kümesi: iki sütuna ya da sayfa
/// sırasında uzak iki yere düşen alıntıda kesit tek yerde kalsın.
func anaKume(_ darbe: [CGRect], satirH: CGFloat) -> [CGRect] {
    var kumeler: [[CGRect]] = []
    for s in darbe.sorted(by: { $0.midY > $1.midY }) {
        if let i = kumeler.firstIndex(where: { k in
            let u = k.reduce(CGRect.null) { $0.union($1) }
            return s.maxY > u.minY - 2.5 * satirH && s.minY < u.maxY + 2.5 * satirH
                && s.minX < u.maxX + 20 && u.minX < s.maxX + 20
        }) {
            kumeler[i].append(s)
        } else {
            kumeler.append([s])
        }
    }
    return kumeler.max { a, b in
        a.reduce(0) { $0 + $1.width * $1.height } < b.reduce(0) { $0 + $1.width * $1.height }
    } ?? darbe
}

/// Kesitin kutusu (okuma uzayında): vurgunun üstünde ve altında [baglam]
/// görsel satır; yatayda vurguyla örtüşen satırların sütunu. [butun]:
/// vurgunun hepsi (sıra dışı eşleşme: tablo satırının hücreleri, grafiğin
/// etiketleri birbirinden uzak ama tek yerin parçaları).
func kesitKutusu(darbe: [CGRect], satirlar: [CGRect], alan: CGRect, baglam: Int, butun: Bool) -> CGRect {
    let satirH = ortanca(satirlar.map(\.height))
    let ana = butun ? darbe : anaKume(darbe, satirH: satirH)
    let v = ana.reduce(CGRect.null) { $0.union($1) }
    let pencere = CGFloat(baglam + 1) * satirH * 2.5
    // Kenar boşluğundaki dikey yazı (raporun adı) ya da şekil gibi boyu
    // satırlardan çok büyük kutular bağlama girmiyor.
    let enUzun = max(2.5 * satirH, 1.5 * v.height)
    let aday = satirlar.filter { s in
        let yatay = min(s.maxX, v.maxX) - max(s.minX, v.minX)
        return yatay > 0.3 * min(s.width, v.width) && s.height <= enUzun
            && s.minY < v.maxY + pencere && s.maxY > v.minY - pencere
    }
    // Bağlam satırları vurgudan dışa doğru alınıyor; araya satır boyunun 1,5
    // katından geniş boşluk girince (bölüm başlığı, şekil) duruluyor.
    var ustte: [CGRect] = []
    var ustSinir = v.maxY
    for s in aday.filter({ $0.midY > v.maxY }).sorted(by: { $0.minY < $1.minY }) {
        if ustte.count == baglam || s.minY - ustSinir > 1.5 * satirH { break }
        ustte.append(s)
        ustSinir = max(ustSinir, s.maxY)
    }
    var altta: [CGRect] = []
    var altSinir = v.minY
    for s in aday.filter({ $0.midY < v.minY }).sorted(by: { $0.maxY > $1.maxY }) {
        if altta.count == baglam || altSinir - s.maxY > 1.5 * satirH { break }
        altta.append(s)
        altSinir = min(altSinir, s.minY)
    }
    let icinde = aday.filter { $0.midY <= v.maxY && $0.midY >= v.minY }
    var k = v
    for s in ustte + altta + icinde { k = k.union(s) }
    let pay = 0.45 * satirH
    let ust = (ustte.isEmpty ? v.maxY + 1.2 * satirH : k.maxY) + pay
    let alt = (altta.isEmpty ? v.minY - 1.2 * satirH : k.minY) - pay
    let yanPay: CGFloat = max(8, satirH)
    return CGRect(x: k.minX - yanPay, y: alt, width: k.width + 2 * yanPay, height: ust - alt).intersection(alan)
}

// ── Kesit ────────────────────────────────────────────────────────────────

struct Kesit {
    let genislik: Int
    let yukseklik: Int
    let kutu: CGRect
    let donus: Int
    let olcek: Double
}

/// Fosforlu kalem sarısı; çarpma kipinde kâğıt sararıyor, mürekkep koyu kalıyor.
let kalem = CGColor(red: 1, green: 0.886, blue: 0.302, alpha: 1)

func kesitCiz(_ p: PDFPage, _ harfler: [[CGRect?]], satir: Double, tavan: Double, baglam: Int,
              butun: Bool, cikis: String) -> Kesit? {
    let t0 = p.transform(for: .cropBox)
    let donus = okumaDonusu(harfler, t0)
    let r = CGAffineTransform(rotationAngle: donus)
    let t = t0.concatenating(r)
    let darbe = darbeler(harfler, t)
    guard !darbe.isEmpty else { return nil }
    let alan = p.bounds(for: .cropBox).applying(t)
    let tumu = sayfaSatirlari(p).map { $0.applying(t) }
    let satirlar = gorselSatirlar(tumu + darbe)
    let kutu = kesitKutusu(darbe: darbe, satirlar: satirlar, alan: alan, baglam: baglam, butun: butun)
    guard gecerli(kutu) else { return nil }
    // Ölçek: vurgulu satır ~[satir] piksel boyunda (her kesitte yazı aynı
    // irilikte); genişlik [tavan]ı, ölçek 4'ü aşmıyor. Vurguda iri ve küçük
    // yazı birlikteyse (kapaktaki logo ve sayı) küçük olan okunsun: alt çeyrek.
    let darbeH = Double(darbe.map(\.height).sorted()[(darbe.count - 1) / 4])
    let w0 = Double(kutu.width)
    let olcek = min(4, tavan / w0, satir / max(darbeH, 1))
    let w = Int((w0 * olcek).rounded())
    let h = Int((Double(kutu.height) * olcek).rounded())
    guard w > 0, h > 0, w * h < 40_000_000,
          let ctx = CGContext(data: nil, width: w, height: h, bitsPerComponent: 8, bytesPerRow: 0,
                              space: CGColorSpace(name: CGColorSpace.sRGB)!,
                              bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { return nil }
    ctx.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 1))
    ctx.fill(CGRect(x: 0, y: 0, width: w, height: h))
    ctx.scaleBy(x: olcek, y: olcek)
    ctx.translateBy(x: -kutu.minX, y: -kutu.minY)
    ctx.saveGState()
    // okuma uzayı ← çizim uzayı. Çizim uzayını draw(with:to:) KENDİSİ kuruyor
    // (transform(for: .cropBox): döndürme ve kırpma kutusunun başlangıcı);
    // kırpma kutusu sıfırdan başlamayan sayfada (agrosens, y = 7,83) vurgu
    // yazıyla hizalı çıkıyor — gözle bakıldı.
    ctx.concatenate(r)
    p.draw(with: .cropBox, to: ctx)
    ctx.restoreGState()
    ctx.setBlendMode(.multiply)
    ctx.setFillColor(kalem)
    // Bütün darbeler tek yolda, tek dolguyla: üst üste binen iki satırın
    // kesişimi iki kat koyulaşmıyor.
    for d in darbe {
        let k = d.insetBy(dx: -0.12 * d.height, dy: -0.04 * d.height)
        ctx.addPath(CGPath(roundedRect: k, cornerWidth: 0.12 * d.height, cornerHeight: 0.12 * d.height, transform: nil))
    }
    ctx.fillPath()
    guard let resim = ctx.makeImage(),
          let png = NSBitmapImageRep(cgImage: resim).representation(using: .png, properties: [:]),
          (try? png.write(to: URL(fileURLWithPath: cikis))) != nil else { return nil }
    return Kesit(genislik: w, yukseklik: h, kutu: kutu, donus: Int((donus * 180 / .pi).rounded()),
                 olcek: (olcek * 1000).rounded() / 1000)
}

// ── Ana akış ─────────────────────────────────────────────────────────────

func kutuDizisi(_ r: CGRect) -> [Double] {
    [r.minX, r.minY, r.maxX, r.maxY].map { (Double($0) * 100).rounded() / 100 }
}

let arg = CommandLine.arguments
guard arg.count == 2, let veri = FileManager.default.contents(atPath: arg[1]),
      let girdi = try? JSONDecoder().decode(Girdi.self, from: veri) else {
    FileHandle.standardError.write("kullanım: swift makbuz.swift <iş.json>\n".data(using: .utf8)!)
    exit(2)
}
let satir = girdi.satir ?? 30
let tavan = girdi.tavan ?? 1400
let baglam = girdi.baglam ?? 3
let kat = Katlayici()
var sonuclar: [[String: Any]] = []

for is_ in girdi.isler {
    let belge = Belge(yol: is_.pdf, k: kat)
    for a in is_.alintilar {
        var s: [String: Any] = ["kimlik": a.kimlik, "sayfa": NSNull(), "yontem": NSNull(),
                                "kapsama": 0, "kutu": NSNull(), "kesit": NSNull()]
        guard let belge else {
            s["neden"] = "PDF açılamadı"
            sonuclar.append(s)
            continue
        }
        s["sayfa_sayisi"] = belge.pdf.pageCount
        if belge.metinliSayfa == 0 {
            s["neden"] = "PDF'te metin katmanı yok"
            sonuclar.append(s)
            continue
        }
        guard let e = eslestir(belge, kat, a.alinti) else {
            s["neden"] = "alıntı PDF metninde bulunamadı"
            sonuclar.append(s)
            continue
        }
        let (pi, araliklar) = sayfaAraliklari(belge, e)
        let p = belge.pdf.page(at: pi)!
        let metin = (p.string ?? "") as NSString
        let satirH = ortanca(sayfaSatirlari(p).map { min($0.width, $0.height) })
        let harfler = harfKutulari(p, metin, araliklar, satirH: satirH)
        let kutu = harfler.joined().compactMap { $0 }.reduce(CGRect.null) { $0.union($1) }
        s["sayfa"] = pi + 1
        s["yontem"] = e.yontem
        s["kapsama"] = (e.kapsama * 1000).rounded() / 1000
        if !gecerli(kutu) {
            s["neden"] = "sayfa bulundu, harf kutuları alınamadı"
        } else {
            s["kutu"] = kutuDizisi(kutu)
            if let cikis = a.cikis {
                if let k = kesitCiz(p, harfler, satir: satir, tavan: tavan, baglam: baglam,
                                    butun: e.yontem == "sira_disi", cikis: cikis) {
                    s["kesit"] = ["genislik": k.genislik, "yukseklik": k.yukseklik,
                                  "kutu": kutuDizisi(k.kutu), "donus": k.donus, "olcek": k.olcek]
                } else {
                    s["neden"] = "kesit çizilemedi"
                }
            }
        }
        sonuclar.append(s)
    }
}

let cikti = try JSONSerialization.data(withJSONObject: ["sonuclar": sonuclar], options: [.sortedKeys])
FileHandle.standardOutput.write(cikti)
FileHandle.standardOutput.write("\n".data(using: .utf8)!)
