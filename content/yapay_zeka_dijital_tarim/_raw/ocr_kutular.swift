// Yapay Zeka ve Dijital Tarım — görseldeki yazıların yerini bulur (Türkçe görsel kopyaları).
//
//     swift ocr_kutular.swift <görsel> [--dondur saat|ters] [--kelime]
//
// macOS Vision (VNRecognizeTextRequest, .accurate, dil düzeltmesi kapalı) ile
// görseldeki her satırı okur ve piksel kutusunu yazar:
//
//     x0 y0 x1 y1  güven  "metin"
//
// Koordinatlar özgün görselin pikselleri, başlangıç sol üst köşe. Dikey
// yazılar için görsel önce döndürülür (`--dondur saat`: saat yönünde 90°,
// aşağıdan yukarı okunan eksen başlıkları için; `--dondur ters`: saatin
// tersine 90°), kutular yine özgün görselin koordinatlarına çevrilir.
// `--kelime` her satırın altına kelime kutularını da yazar. Görsel yalnız
// okunur; WebP'yi okuyamayan sistemde önce `sips -s format png` ile PNG'ye
// çevrilir. Çıktı gorsel_turkce.json'daki kutuların başlangıç noktası;
// son kutular gözle düzeltilir.
import AppKit
import CoreImage
import Foundation
import Vision

func hata(_ s: String) -> Never {
    FileHandle.standardError.write((s + "\n").data(using: .utf8)!)
    exit(2)
}

var argumanlar = Array(CommandLine.arguments.dropFirst())
var dondur = ""
var kelime = false
var yol = ""
while !argumanlar.isEmpty {
    let a = argumanlar.removeFirst()
    switch a {
    case "--dondur":
        guard !argumanlar.isEmpty else { hata("--dondur saat|ters") }
        dondur = argumanlar.removeFirst()
        guard dondur == "saat" || dondur == "ters" else { hata("--dondur saat|ters") }
    case "--kelime":
        kelime = true
    default:
        yol = a
    }
}
guard !yol.isEmpty else {
    hata("kullanım: swift ocr_kutular.swift <görsel> [--dondur saat|ters] [--kelime]")
}

let url = URL(fileURLWithPath: yol)
guard let kaynak = CGImageSourceCreateWithURL(url as CFURL, nil),
      let ozgun = CGImageSourceCreateImageAtIndex(kaynak, 0, nil) else {
    hata("görsel açılamadı: \(yol) (WebP okunamıyorsa: sips -s format png \(yol) --out x.png)")
}
let W = Double(ozgun.width), H = Double(ozgun.height)

// Döndürülmüş kopya: .right = saat yönünde 90°, .left = saatin tersine 90°.
var islenen = ozgun
if !dondur.isEmpty {
    let ci = CIImage(cgImage: ozgun).oriented(dondur == "saat" ? .right : .left)
    let baglam = CIContext(options: nil)
    guard let cg = baglam.createCGImage(ci, from: ci.extent) else { hata("döndürülemedi") }
    islenen = cg
}
let w2 = Double(islenen.width), h2 = Double(islenen.height)

// Döndürülmüş görseldeki (sol üst başlangıçlı) noktayı özgün görsele çevirir.
func geriCevir(_ x: Double, _ y: Double) -> (Double, Double) {
    switch dondur {
    case "saat": return (y, H - x)   // (x,y) -> (H-y, x) dönüşümünün tersi
    case "ters": return (W - y, x)   // (x,y) -> (y, W-x) dönüşümünün tersi
    default: return (x, y)
    }
}

// Vision'ın normalize kutusunu (sol alt başlangıç) özgün piksel kutusuna çevirir.
func kutu(_ r: CGRect) -> (Int, Int, Int, Int) {
    let xa = Double(r.minX) * w2, xb = Double(r.maxX) * w2
    let ya = (1 - Double(r.maxY)) * h2, yb = (1 - Double(r.minY)) * h2
    let koseler = [geriCevir(xa, ya), geriCevir(xb, ya), geriCevir(xa, yb), geriCevir(xb, yb)]
    let xs = koseler.map { $0.0 }, ys = koseler.map { $0.1 }
    return (Int(xs.min()!.rounded(.down)), Int(ys.min()!.rounded(.down)),
            Int(xs.max()!.rounded(.up)), Int(ys.max()!.rounded(.up)))
}

let istek = VNRecognizeTextRequest()
istek.recognitionLevel = .accurate
istek.usesLanguageCorrection = false
istek.recognitionLanguages = ["en-US"]
let isleyici = VNImageRequestHandler(cgImage: islenen, options: [:])
do { try isleyici.perform([istek]) } catch { hata("Vision hatası: \(error)") }

print("# \(yol)  \(Int(W))×\(Int(H))" + (dondur.isEmpty ? "" : "  döndürme: \(dondur)"))
let satirlar = (istek.results ?? []).compactMap { g -> (VNRecognizedText, (Int, Int, Int, Int))? in
    guard let aday = g.topCandidates(1).first else { return nil }
    return (aday, kutu(g.boundingBox))
}.sorted { ($0.1.1, $0.1.0) < ($1.1.1, $1.1.0) }

for (aday, k) in satirlar {
    print(String(format: "%5d %5d %5d %5d  %.2f  ", k.0, k.1, k.2, k.3, aday.confidence) + "\"\(aday.string)\"")
    guard kelime else { continue }
    let s = aday.string
    var bas = s.startIndex
    while bas < s.endIndex {
        while bas < s.endIndex && s[bas] == " " { bas = s.index(after: bas) }
        guard bas < s.endIndex else { break }
        var son = bas
        while son < s.endIndex && s[son] != " " { son = s.index(after: son) }
        if let kk = try? aday.boundingBox(for: bas..<son) {
            let kb = kutu(kk.boundingBox)
            print(String(format: "      %5d %5d %5d %5d        ", kb.0, kb.1, kb.2, kb.3) + "\"\(s[bas..<son])\"")
        }
        bas = son
    }
}
