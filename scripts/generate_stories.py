import sys
import os
import json
from datetime import datetime, timedelta

# tarim_ai_pipeline bağımlılıkları ve config için yolu ekle
sys.path.append("/Users/BURHAN/tarim_ai_pipeline")
from src.config import supabase_client, GEMINI_API_KEY
import google.generativeai as genai

# Gemini Ayarları
genai.configure(api_key=GEMINI_API_KEY)
model = genai.GenerativeModel('gemini-2.5-flash')

def generate_story_for_article(article):
    """
    Haber metnini Gemini'ye gönderip, içinden istatistik/veri varsa story formatına çevirir.
    Eğer hikaye olmaya değecek bir veri yoksa None döner.
    """
    content = article.get("content", "")
    title = article.get("title", "")
    
    if len(content) < 200:
        return None
        
    prompt = f"""
    Sen Tarım Portalı için profesyonel bir sosyal medya içerik yöneticisisin. 
    Aşağıdaki haberi oku. Haberde eğer sayısal bir veri, yüzdelik bir artış/düşüş, net bir fiyat, 
    veya çok çarpıcı bir gelişme varsa bundan bir "Instagram Story" veri kartı çıkarmanı istiyorum. 
    Eğer haber sadece yorum, siyasi söylem veya genel bir bilgi içeriyorsa boş döndür.
    
    ÖNEMLİ: Uygulamamızın hem Türkçe hem İngilizce versiyonu var. Bu yüzden ürettiğin her metnin
    mutlaka İngilizce çevirisini de ("_en" uzantılı anahtarlarda) sağlamalısın. İngilizce çeviriler
    profesyonel ve gazetecilik diline uygun olmalı.
    
    Lütfen ÇIKTIYI SADECE AŞAĞIDAKİ JSON FORMATINDA VER. Başka hiçbir açıklama yazma.
    
    İstenilen JSON yapısı:
    {{
        "is_story_worthy": true veya false,
        "group_title": "Kısa Kategori Adı (Örn: Piyasa Özeti, TMO Alımları vs. Max 15 harf)",
        "group_title_en": "Kategori Adının İngilizcesi (Örn: Market Summary, TMO Purchases. Max 15 chars)",
        "super_title": "KISA ETİKET (Örn: GÜNLÜK PİYASA, HASAT 2024. Max 20 harf)",
        "super_title_en": "KISA ETİKET İNGİLİZCE (Örn: DAILY MARKET. Max 20 chars)",
        "headline": "Haberi anlatan 1 veya 2 cümlelik çarpıcı başlık (Max 60 harf)",
        "headline_en": "Haberi anlatan İngilizce başlık (Max 60 chars)",
        "big_stat_value": "Vurucu sayısal değer (Örn: +%4.2, 9.25₺, 12%)",
        "big_stat_value_en": "Vurucu sayısal değer İngilizce formda (Örn: +4.2%, 9.25 TRY, 12%)",
        "stat_label": "Bu sayının ne olduğunu açıklayan kısa etiket (Örn: Chicago Borsası Artış)",
        "stat_label_en": "İngilizce etiket (Örn: Chicago Exchange Increase)"
    }}
    
    Haber Başlığı: {title}
    Haber Metni: {content[:1500]}
    """
    
    try:
        response = model.generate_content(prompt)
        text = response.text.strip()
        
        # Markdown kod bloklarını temizle
        if text.startswith("```json"):
            text = text[7:-3]
        elif text.startswith("```"):
            text = text[3:-3]
            
        data = json.loads(text.strip())
        
        if data.get("is_story_worthy") == True:
            return data
    except Exception as e:
        print(f"Gemini hatası veya ayrıştırma hatası: {e}")
        
    return None

def run_story_pipeline():
    print("=== TARIM HİKAYELERİ BOTO (STORY PIPELINE) BAŞLATILDI ===")
    
    # 1. Şu an yayında olan (süresi dolmamış) story sayısına bak.
    # Limiti 7 belirledik, çok dolmasını engelle.
    now_utc = datetime.utcnow().isoformat()
    active_stories = supabase_client.from_("portal_stories") \
        .select("id") \
        .gt("expires_at", now_utc) \
        .execute()
        
    active_count = len(active_stories.data)
    print(f"Şu an yayında olan hikaye sayısı: {active_count} (Limit: 7)")
    
    if active_count >= 10:
        print("Hikaye kapasitesi dolu. İşlem sonlandırılıyor.")
        return
        
    # 2. Her zaman hikaye olması için son 36 saatteki güncel haberleri çek
    thirty_six_hours_ago = (datetime.utcnow() - timedelta(hours=36)).isoformat()
    articles_resp = supabase_client.from_("articles") \
        .select("id, title, content, image_url, is_breaking") \
        .eq("status", "published") \
        .not_.is_("image_url", "null") \
        .gt("created_at", thirty_six_hours_ago) \
        .order("is_breaking", desc=True) \
        .order("created_at", desc=True) \
        .limit(100) \
        .execute()
        
    articles = articles_resp.data
    
    # 3. Zaten story'si yapılmış olanları tespit et
    existing_story_article_ids = set()
    all_stories = supabase_client.from_("portal_stories").select("article_id").execute()
    for s in all_stories.data:
        existing_story_article_ids.add(s["article_id"])
    # 4. Haberleri sırayla değerlendir
    added_count = 0
    
    for article in articles:
        if added_count + active_count >= 10:
            print("Limit 10'a ulaşıldı.")
            break
            
        image_url = article.get("image_url", "")
        if not image_url or len(image_url.strip()) < 5 or "unsplash" in image_url.lower():
            continue
            
        if article["id"] in existing_story_article_ids:
            continue
            
        print(f"\nDeğerlendiriliyor: {article['title']}")
        story_data = generate_story_for_article(article)
        
        if story_data:
            print(f" -> Harika! Veri bulundu: {story_data['big_stat_value']} - {story_data['stat_label']}")
            
            # Veritabanına kaydet (24 saat ömürlü)
            expires = (datetime.utcnow() + timedelta(hours=24)).isoformat()
            
            # Items JSONB yapısı (İleride birden çok slide olursa diye liste)
            items_list = [{
                "super_title": story_data.get("super_title", ""),
                "super_title_en": story_data.get("super_title_en", ""),
                "headline": story_data.get("headline", ""),
                "headline_en": story_data.get("headline_en", ""),
                "big_stat_value": story_data.get("big_stat_value", ""),
                "big_stat_value_en": story_data.get("big_stat_value_en", ""),
                "stat_label": story_data.get("stat_label", ""),
                "stat_label_en": story_data.get("stat_label_en", ""),
                "group_title_en": story_data.get("group_title_en", "") # Avatar başlığı için buraya saklıyoruz
            }]
            
            supabase_client.from_("portal_stories").insert({
                "article_id": article["id"],
                "group_title": story_data.get("group_title", ""),
                "is_breaking": article.get("is_breaking", False),
                "items": items_list,
                "expires_at": expires
            }).execute()
            
            print(" -> Veritabanına kaydedildi.")
            added_count += 1
        else:
            print(" -> Yeterli veri bulunamadı, story üretilmedi.")

    print(f"\n=== İŞLEM TAMAMLANDI. Üretilen Yeni Hikaye Sayısı: {added_count} ===")

if __name__ == "__main__":
    run_story_pipeline()
