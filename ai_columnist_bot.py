import os
import json
import uuid
from dotenv import load_dotenv
from supabase import create_client, Client
import google.generativeai as genai

# =========================================================================
# AI YAZAR OTOMASYON BOTU (GEMINI)
# Bu script, günlük taze haberleri aldıktan sonra 5 AI yazarımızın 
# bu haberleri yorumlayıp köşe yazısı üretmesini sağlar.
# =========================================================================

load_dotenv()

SUPABASE_URL = os.environ.get('SUPABASE_URL')
SUPABASE_KEY = os.environ.get('SUPABASE_SERVICE_ROLE_KEY') or os.environ.get('SUPABASE_ANON_KEY')
GEMINI_API_KEY = os.environ.get('GEMINI_API_KEY')

if not SUPABASE_URL or not SUPABASE_KEY:
    print("HATA: Supabase kimlik bilgileri eksik.")
    exit(1)

if not GEMINI_API_KEY:
    print("HATA: GEMINI_API_KEY eksik. Lütfen .env dosyasına ekleyin.")
    exit(1)

supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)
genai.configure(api_key=GEMINI_API_KEY)

def generate_ai_articles(todays_news_text: str):
    system_prompt = """Sen saygın bir ekonomi, tarım ve sosyoloji haber portalının yayın yönetmenisin. Emrinde 5 uzman köşe yazarı var:
1. Dr. Tarık Yılmaz (Tarım Ekonomisti)
2. Zeynep Aksoy (İklim & Teknoloji Analisti)
3. Prof. Dr. Kemal Şahin (Gıda Politikaları Uzmanı)
4. Doç. Dr. Ayşe Gündüz (Kırsal Kalkınma & Sosyoloji)
5. Caner Ekinci (Tarımsal Emtia Uzmanı)

Sana günün önemli tarım haberleri verilecek. Senden beklenen:
1. Bu haberleri analiz edip, her bir yazara kendi uzmanlık alanına uygun, vurucu ve analitik BİRER KÖŞE YAZISI (op-ed) yazdırman.
2. Yazıların dili çok profesyonel, "insan eseri" sıcaklığında ve kesinlikle siyasi polemiklerden uzak olmalı.
3. Çıktıyı SADECE geçerli bir JSON formatında döndür. Markdown (```json) kullanma.

JSON formatı şu şekilde olmalı:
{
  "suggestions_for_dashboard": [ "Konu Önerisi 1", "Konu Önerisi 2" ],
  "articles": [
    {
      "source_name": "Dr. Tarık Yılmaz",
      "title": "Makale Başlığı",
      "title_en": "Article Title",
      "content": "<p>Makale HTML içeriği (paragraflar halinde)</p>",
      "content_en": "<p>Article HTML content in English</p>",
      "summary": "1 Cümlelik özet",
      "summary_en": "1 Sentence summary",
      "image_url": "https://images.unsplash.com/... (Konuya uygun unsplash resmi, yoksa tarım temalı bir resim URL'si)"
    }
  ]
}
"""
    
    user_prompt = f"Günün Haberleri:\n{todays_news_text}\n\nLütfen JSON çıktısını üret."

    print("Gemini API'sine istek gönderiliyor...")
    
    try:
        model = genai.GenerativeModel(
            model_name="gemini-1.5-flash",
            system_instruction=system_prompt,
            generation_config=genai.GenerationConfig(
                response_mime_type="application/json",
            )
        )
        response = model.generate_content(user_prompt)
        result_text = response.text
        
        data = json.loads(result_text)
        return data.get('articles', [])
    except Exception as e:
        print(f"HATA: AI veya JSON çözme hatası: {e}")
        return []

def save_articles_to_supabase(articles):
    if not articles:
        print("Kaydedilecek makale bulunamadı.")
        return
    
    # 1. 'Köşe Yazısı' kategorisinin ID'sini bul
    cat_res = supabase.table('categories').select('id, name').execute()
    category_id = None
    for cat in cat_res.data:
        if 'analiz' in cat['name'].lower() or 'köşe' in cat['name'].lower() or 'yazar' in cat['name'].lower():
            category_id = cat['id']
            break
    if not category_id and len(cat_res.data) > 0:
        category_id = cat_res.data[0]['id']

    # 2. Makaleleri DB'ye bas
    for article in articles:
        article['slug'] = str(uuid.uuid4())
        article['status'] = 'published'
        article['content_type'] = 'text'
        article['category_id'] = category_id
        article['is_hero'] = False
        
        try:
            res = supabase.table('articles').insert(article).execute()
            print(f"✅ Eklendi: {article['title']} (Yazar: {article['source_name']})")
        except Exception as e:
            print(f"❌ Eklenemedi: {article['title']} | Hata: {e}")

if __name__ == "__main__":
    sample_news = "Bugün buğday fiyatları %5 arttı. İklim krizine bağlı kuraklık İç Anadolu'yu etkiliyor."
    
    print("1. Yapay Zekadan (Gemini) yazılar isteniyor...")
    new_articles = generate_ai_articles(sample_news)
    
    if new_articles:
        print(f"2. {len(new_articles)} yazı üretildi. Veritabanına kaydediliyor...")
        save_articles_to_supabase(new_articles)
    else:
        print("İşlem tamamlandı, yazı üretilmedi.")
