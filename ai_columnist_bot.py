import os
import json
import uuid
from dotenv import load_dotenv
from supabase import create_client, Client
import google.generativeai as genai

# =========================================================================
# TARIM PORTALI — AI EDİTÖRYEL MOTOR
# 
# İki modül:
#   1. generate_news_article()  → Ham haber URL/metnini alır, profesyonel
#      bir haber makalesi olarak veritabanına yazar.
#   2. generate_ai_articles()   → 5 AI yazarımıza köşe yazısı yazdırır.
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

# ─────────────────────────────────────────────────────────────────────────────
# BÖLÜM 1: HABERİ PORTALA DÖNÜŞTÜR (Ana Haber Makalesi)
# ─────────────────────────────────────────────────────────────────────────────

NEWS_ARTICLE_SYSTEM_PROMPT = """
Sen "Tarım Portalı"nın baş editörüsün. Görevin, sana verilen ham haber metnini (kaynak: RSS feed, scrape, ajans metni vb.)
portalın standartlarında, zengin ve profesyonel bir haber makalesine dönüştürmek.

=== TEMEL KURALLAR ===
1.  ASLA ÖZETLEME (ANTI-SUMMARIZATION): Sen bir özetleyici değilsin. Görevin orijinal metni kısaltmak değil, eksiksiz bir şekilde profesyonel portal diline çevirmektir.
2.  BİREBİR DETAY KORUMASI: Haberdeki hiçbir önemli bilgiyi kaçırma. Bütün yer, tarih, rakam, yüzde, kurum adı, kişi adı, miktar ve karşılaştırmalar korunmalıdır.
3.  LİSTE VE MADDELERİ ZORUNLU KORUMA: Eğer orijinal metinde alt başlıklar, maddeler (örn: 7 Hata), listeler veya Soru-Cevap (SSS) bölümleri varsa; üreteceğin metinde de BİREBİR AYNI SAYIDA madde, alt başlık ve liste olmak ZORUNDADIR. Tek bir madde bile atlanamaz veya birleştirilemez.
4.  HTML ZENGİNLİĞİ: Maddeleri ve listeleri mutlaka <ul>, <li>, <strong> etiketleriyle zenginleştir. Mantıklı ara başlıklar (<h2>) kullan.
5.  BAĞLAMLI RAKAMLAR: Rakamlar bağlam ile verilmeli: "5 milyon ton" değil, "geçen yılın aynı dönemine göre %8 artışla 5 milyon ton".
6.  ZİHİNSEL KONTROL: Yazıya başlamadan önce orijinal metindeki tüm rakamları ve maddeleri zihninde tara. Çıktıyı üretirken hiçbirini atlamadığından emin ol.

=== CHART_DATA KURALLARI (ÇOK ÖNEMLİ) ===
AI olarak kendin bir data visualization uzmanısın. Haberde karşılaştırılabilir, görselleştirilebilir veri 
varsa chart_data oluştur. Yoksa null bırak — her habere zorla grafik koyma.

chart_data türleri ve ne zaman kullanılacağı:
- "bar"          → Tek serili karşılaştırma (örn: ülke bazında üretim miktarları)
- "horizontal_bar" → Uzun etiketli karşılaştırma (örn: bölge/şehir bazlı istatistikler)  
- "line"         → Zaman serisi verisi (örn: aylık/yıllık fiyat değişimi, üretim trendi)
- "donut"        → Oransal dağılım (örn: pazar payları, segment yüzdeleri)
- "pie"          → Yüzdesel bütün (3-5 kategori arası en iyi çalışır)
- "stat"         → Birden fazla ayrı KPI/metrik kutusu (örn: "Üretim: 5M ton | İhracat: 2.3M ton | Fiyat: 8.50 TL/kg")
- "table"        → Çoklu sütunlu karşılaştırmalı veri

TASARIM PRENSİBİ: Grafik bilgi taşımalı. Sadece süs değil, okuyucuya ek değer katmalı.
Grafik başlığı kısa ve açıklayıcı olmalı, subtitle bağlam eklemeli.

=== JSON ÇIKTI FORMATI ===
{
  "title": "Vurucu Türkçe Haber Başlığı",
  "title_en": "Impactful English Headline",
  "spot": "2-3 cümlelik özet manşet. Haberin özünü, en önemli rakam veya gelişmeyi içermeli.",
  "spot_en": "2-3 sentence lead summary in English.",
  "content": "<h2>Ara Başlık</h2><p>Haber gövdesi...</p>",
  "content_en": "<h2>Section Header</h2><p>Article body in English...</p>",
  "summary": "Tek cümle özet (SEO için)",
  "summary_en": "Single sentence summary in English.",
  "key_takeaways": [
    "Önemli çıkarım 1 (rakam içermeli)",
    "Önemli çıkarım 2",
    "Önemli çıkarım 3"
  ],
  "key_takeaways_en": [
    "Key takeaway 1",
    "Key takeaway 2",
    "Key takeaway 3"
  ],
  "expert_insight": "Haberin ekonomik/tarımsal/sosyal önemine dair 2-4 cümlelik uzman değerlendirmesi. Gerçekçi ve otoritatif ton.",
  "expert_insight_en": "Expert insight in English.",
  "chart_data": {
    "type": "bar|line|donut|pie|stat|table|horizontal_bar",
    "title": "Grafik başlığı",
    "subtitle": "Veri kaynağı veya tarih aralığı",
    "unit": " ton | $ | % | TL/kg (değer birimini gir, boş bırakma)",
    "data": [
      {"label": "Etiket", "value": 123.4, "change": "+5.2%" }
    ]
  },
  "seo_keywords": ["anahtar kelime 1", "anahtar kelime 2", "anahtar kelime 3"],
  "image_url": "https://images.unsplash.com/photo-XXXXX?w=1200&auto=format&fit=crop&q=80"
}

NOT: chart_data yoksa "chart_data": null döndür. image_url için konuya uygun Unsplash fotoğrafı seç.
SADECE GEÇERLİ JSON DÖNDÜR. Markdown kod bloğu kullanma.
"""

def generate_news_article(raw_news_text: str, source_name: str = "Tarım Portalı") -> dict | None:
    """
    Ham haber metnini alır, AI ile zenginleştirip profesyonel makaleye dönüştürür.
    
    Args:
        raw_news_text: Kaynak haber metni (RSS, scrape, ajans vb.)
        source_name: Kaynak adı (örn: "Reuters", "TARSİM", "Gıda Tarım Bakanlığı")
    
    Returns:
        dict: İşlenmiş makale verisi (Supabase'e insert için hazır)
    """
    user_prompt = f"""
Kaynak: {source_name}

HAM HABER METNİ:
{raw_news_text}

Yukarıdaki haberi portal standartlarında işle ve JSON formatında döndür.
"""
    try:
        model = genai.GenerativeModel(
            model_name="gemini-1.5-pro",
            system_instruction=NEWS_ARTICLE_SYSTEM_PROMPT,
            generation_config=genai.GenerationConfig(response_mime_type="application/json"),
        )
        response = model.generate_content(user_prompt)
        return json.loads(response.text)
    except Exception as e:
        print(f"HATA (generate_news_article): {e}")
        return None


def save_news_article(article_data: dict, source_name: str, source_url: str = "", category_id: str | None = None) -> bool:
    """İşlenmiş makaleyi Supabase'e kaydeder."""
    if not article_data:
        return False

    payload = {
        "id": str(uuid.uuid4()),
        "slug": str(uuid.uuid4()),
        "status": "published",
        "content_type": "news",
        "source_name": source_name,
        "source_url": source_url or None,
        "is_hero": False,
        "title": article_data.get("title", ""),
        "title_en": article_data.get("title_en", ""),
        "content": article_data.get("content", ""),
        "content_en": article_data.get("content_en", ""),
        "summary": article_data.get("summary", ""),
        "summary_en": article_data.get("summary_en", ""),
        "spot": article_data.get("spot", ""),
        "spot_en": article_data.get("spot_en", ""),
        "key_takeaways": article_data.get("key_takeaways", []),
        "key_takeaways_en": article_data.get("key_takeaways_en", []),
        "expert_insight": article_data.get("expert_insight", ""),
        "expert_insight_en": article_data.get("expert_insight_en", ""),
        "chart_data": article_data.get("chart_data"),
        "seo_keywords": article_data.get("seo_keywords", []),
        "image_url": article_data.get("image_url", ""),
        "category_id": category_id,
    }

    try:
        supabase.table("articles").insert(payload).execute()
        print(f"✅ Kaydedildi: {payload['title']}")
        return True
    except Exception as e:
        print(f"❌ Kaydedilemedi: {e}")
        return False


# ─────────────────────────────────────────────────────────────────────────────
# BÖLÜM 2: KÖŞE YAZARLARI BOT (5 Uzman AI Yazar)
# ─────────────────────────────────────────────────────────────────────────────

COLUMNIST_SYSTEM_PROMPT = """
Sen "Tarım Portalı"nın yayın yönetmenisin. Emrinde 5 uzman köşe yazarı var:
1. Dr. Tarık Yılmaz (Tarım Ekonomisti)
2. Zeynep Aksoy (İklim & Teknoloji Analisti)
3. Prof. Dr. Kemal Şahin (Gıda Politikaları Uzmanı)
4. Doç. Dr. Ayşe Gündüz (Kırsal Kalkınma & Sosyoloji)
5. Caner Ekinci (Tarımsal Emtia & Piyasa Analisti)

Günün önemli tarım haberleri sana verilecek. Görevin:
- Her yazara kendi uzmanlık alanına uygun, derin ve analitik bir köşe yazısı (op-ed) yazdırmak.
- Yazılar profesyonel, "insan eseri" sıcaklığında, siyasi polemikten uzak olmalı.
- Eğer haberde çarpıcı rakamsal veri varsa, yazar bunu yazısında kullanmalı ve gerekirse chart_data oluşturmalı.
- İçerik en az 4 paragraf olmalı — giriş, analiz, sonuç ve öneriler.

JSON ÇIKTI:
{
  "suggestions_for_dashboard": ["Öneri 1", "Öneri 2"],
  "articles": [
    {
      "source_name": "Dr. Tarık Yılmaz",
      "title": "Makale Başlığı",
      "title_en": "Article Title",
      "content": "<p>HTML içerik...</p>",
      "content_en": "<p>English HTML content...</p>",
      "summary": "Tek cümle özet",
      "summary_en": "Single sentence summary",
      "spot": "2 cümle öne çıkarma",
      "spot_en": "2 sentence lead",
      "key_takeaways": ["Çıkarım 1", "Çıkarım 2", "Çıkarım 3"],
      "key_takeaways_en": ["Takeaway 1", "Takeaway 2", "Takeaway 3"],
      "expert_insight": "Yazarın özel analizi",
      "expert_insight_en": "Author's expert analysis in English",
      "chart_data": null,
      "image_url": "https://images.unsplash.com/photo-XXXXX?w=1200&auto=format&fit=crop&q=80"
    }
  ]
}

SADECE GEÇERLİ JSON DÖNDÜR. Markdown kullanma.
"""

def generate_ai_articles(todays_news_text: str) -> list:
    """5 AI yazarımıza günün haberlerine göre köşe yazısı yazdırır."""
    user_prompt = f"Günün Haberleri:\n{todays_news_text}\n\nLütfen JSON çıktısını üret."

    print("Gemini API'sine köşe yazısı isteği gönderiliyor...")
    try:
        model = genai.GenerativeModel(
            model_name="gemini-1.5-flash",
            system_instruction=COLUMNIST_SYSTEM_PROMPT,
            generation_config=genai.GenerationConfig(response_mime_type="application/json"),
        )
        response = model.generate_content(user_prompt)
        data = json.loads(response.text)
        return data.get("articles", [])
    except Exception as e:
        print(f"HATA: {e}")
        return []


def save_articles_to_supabase(articles: list):
    if not articles:
        print("Kaydedilecek makale bulunamadı.")
        return

    cat_res = supabase.table("categories").select("id, name").execute()
    category_id = None
    for cat in cat_res.data:
        name_lower = cat["name"].lower()
        if "analiz" in name_lower or "köşe" in name_lower or "yazar" in name_lower:
            category_id = cat["id"]
            break
    if not category_id and len(cat_res.data) > 0:
        category_id = cat_res.data[0]["id"]

    for article in articles:
        payload = {
            "id": str(uuid.uuid4()),
            "slug": str(uuid.uuid4()),
            "status": "published",
            "content_type": "text",
            "is_hero": False,
            "category_id": category_id,
            "title": article.get("title", ""),
            "title_en": article.get("title_en", ""),
            "content": article.get("content", ""),
            "content_en": article.get("content_en", ""),
            "summary": article.get("summary", ""),
            "summary_en": article.get("summary_en", ""),
            "spot": article.get("spot", ""),
            "spot_en": article.get("spot_en", ""),
            "key_takeaways": article.get("key_takeaways", []),
            "key_takeaways_en": article.get("key_takeaways_en", []),
            "expert_insight": article.get("expert_insight", ""),
            "expert_insight_en": article.get("expert_insight_en", ""),
            "chart_data": article.get("chart_data"),
            "source_name": article.get("source_name", ""),
            "image_url": article.get("image_url", ""),
        }
        try:
            supabase.table("articles").insert(payload).execute()
            print(f"✅ Eklendi: {payload['title']} (Yazar: {payload['source_name']})")
        except Exception as e:
            print(f"❌ Eklenemedi: {payload['title']} | Hata: {e}")


# ─────────────────────────────────────────────────────────────────────────────
# MAIN
# ─────────────────────────────────────────────────────────────────────────────
if __name__ == "__main__":
    import sys

    mode = sys.argv[1] if len(sys.argv) > 1 else "columnist"

    if mode == "news":
        # Kullanım: python ai_columnist_bot.py news "Ham haber metni buraya" "Kaynak Adı"
        raw_text = sys.argv[2] if len(sys.argv) > 2 else "Test haberi: Buğday fiyatları %5 arttı."
        source   = sys.argv[3] if len(sys.argv) > 3 else "Tarım Portalı"

        print(f"1. Haber işleniyor: {source}")
        result = generate_news_article(raw_text, source)
        if result:
            print(f"2. Makale üretildi. Supabase'e kaydediliyor...")
            save_news_article(result, source)
        else:
            print("Makale üretilemedi.")
    else:
        # Köşe yazarı modu (varsayılan)
        sample_news = "Bugün buğday fiyatları %5 arttı. İklim krizine bağlı kuraklık İç Anadolu'yu etkiliyor."
        print("1. Yapay Zekadan (Gemini) yazılar isteniyor...")
        new_articles = generate_ai_articles(sample_news)
        if new_articles:
            print(f"2. {len(new_articles)} yazı üretildi. Veritabanına kaydediliyor...")
            save_articles_to_supabase(new_articles)
        else:
            print("İşlem tamamlandı, yazı üretilmedi.")
