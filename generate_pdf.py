import os
from fpdf import FPDF

class CustomPDF(FPDF):
    def header(self):
        self.set_font("helvetica", "B", 18)
        self.cell(0, 10, "Tarim App - Aylik Maliyet Raporu", ln=True, align="C")
        self.ln(5)
        
    def footer(self):
        self.set_y(-15)
        self.set_font("helvetica", "I", 8)
        self.cell(0, 10, f"Sayfa {self.page_no()}", align="C")

def create_pdf():
    pdf = CustomPDF()
    pdf.add_page()
    
    # Due to fpdf2 default core fonts not fully supporting Turkish characters, we'll use ASCII replacements 
    # for simplicity, or just plain English/Turkish characters that helvetica supports.
    pdf.set_font("helvetica", size=12)
    
    content = [
        ("1. Sunucu ve Veritabani Altyapisi", [
            "- Supabase (PostgreSQL, Storage, Auth): Pro Plan (Onerilen) - $25 / Ay",
            "- Firebase (Hosting, Push Notifications): Blaze Plan - ~ $0 - $5 / Ay"
        ]),
        ("2. Yapay Zeka Maliyetleri (Google Gemini 2.5 Flash)", [
            "- Haber cekme, ceviri, analiz ve kose yazari uretimi:",
            "  * Gunluk ortalama 100 haber x 3 ajan cagirisi = 300 cagiri/gun",
            "  * Aylik ~9.000 - 10.000 istek.",
            "  * Gemini 2.5 Flash 1 Milyon token basina $0.075.",
            "- Aylik Tahmini Maliyet: $1 - $3 / Ay"
        ]),
        ("3. Veri Kaynaklari ve Gorsel API'ler", [
            "- Hava Durumu (Open-Meteo): Ucretsiz Katman - $0 / Ay",
            "- Finans / Emtia (Yahoo Finance v8): Acik Kaynak Proxy - $0 / Ay",
            "- Otomatik Makale Gorselleri (Unsplash): Ucretsiz Katman - $0 / Ay"
        ]),
        ("4. Bot Barindirma (AI Pipeline Cron Job)", [
            "- Python AI botunu barindirmak icin (DigitalOcean Droplet / AWS EC2): ~ $5 - $10 / Ay"
        ]),
        ("5. Apple ve Google Uygulama Magazasi (Yillik / Tek Seferlik)", [
            "- Apple Developer Hesabi: $99 / Yil (Aylik ~$8.25)",
            "- Google Play Developer: $25 (Tek seferlik)"
        ])
    ]
    
    for title, items in content:
        pdf.set_font("helvetica", "B", 14)
        pdf.cell(0, 10, title, ln=True)
        pdf.set_font("helvetica", "", 12)
        for item in items:
            pdf.multi_cell(0, 8, item)
        pdf.ln(5)
        
    pdf.ln(10)
    pdf.set_font("helvetica", "B", 16)
    pdf.set_fill_color(240, 240, 240)
    pdf.cell(0, 15, "Toplam Aylik Duzenli Maliyet: $31 - $45 / Ay", ln=True, fill=True)
    
    output_path = "/Users/BURHAN/Desktop/Maliyet_Raporu.pdf"
    pdf.output(output_path)
    print(f"PDF basariyla olusturuldu: {output_path}")

if __name__ == "__main__":
    create_pdf()
