// Yapay Zeka ve Dijital Tarım — PDF'in bir sayfasını PNG'ye çizer (karar 58).
//
//     swift pdf_sayfa.swift <pdf> <sayfa (1'den)> <genişlik px> <çıkış.png>
//
// Makale PDF'lerinin içindeki şekiller (ayrı görsel dosyası olmayanlar)
// gorsel_kirp.py ile bu çizimden kırpılıyor. macOS PDFKit'i kullanır; PDF
// yalnız çizilir, içindeki hiçbir şey çalıştırılmaz.
import AppKit
import Foundation
import PDFKit

let a = CommandLine.arguments
guard a.count == 5, let sayfaNo = Int(a[2]), let genislik = Double(a[3]) else {
    FileHandle.standardError.write("kullanım: swift pdf_sayfa.swift <pdf> <sayfa> <genişlik> <çıkış.png>\n".data(using: .utf8)!)
    exit(2)
}
guard let belge = PDFDocument(url: URL(fileURLWithPath: a[1])), let sayfa = belge.page(at: sayfaNo - 1) else {
    FileHandle.standardError.write("PDF ya da sayfa açılamadı\n".data(using: .utf8)!)
    exit(1)
}
let kutu = sayfa.bounds(for: .mediaBox)
let donuk = sayfa.rotation % 180 != 0
let (gw, gy) = donuk ? (kutu.height, kutu.width) : (kutu.width, kutu.height)
let olcek = genislik / gw
let w = Int(genislik.rounded()), h = Int((gy * olcek).rounded())
guard let ctx = CGContext(data: nil, width: w, height: h, bitsPerComponent: 8, bytesPerRow: 0,
                          space: CGColorSpaceCreateDeviceRGB(),
                          bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { exit(1) }
ctx.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 1))
ctx.fill(CGRect(x: 0, y: 0, width: w, height: h))
ctx.scaleBy(x: olcek, y: olcek)
sayfa.draw(with: .mediaBox, to: ctx)
guard let resim = ctx.makeImage(),
      let png = NSBitmapImageRep(cgImage: resim).representation(using: .png, properties: [:]) else { exit(1) }
try png.write(to: URL(fileURLWithPath: a[4]))
print("\(w)×\(h)")
