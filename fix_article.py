import os
import json
import requests
from bs4 import BeautifulSoup
from dotenv import load_dotenv
from supabase import create_client
import google.generativeai as genai
import ai_columnist_bot

load_dotenv()
supabase = create_client(os.environ.get('SUPABASE_URL'), os.environ.get('SUPABASE_SERVICE_ROLE_KEY') or os.environ.get('SUPABASE_ANON_KEY'))
genai.configure(api_key=os.environ.get('GEMINI_API_KEY'))

article_id = "1086231c-bd3c-4aab-998b-77df821776d4"

# 1. Fetch raw HTML
url = "https://www.aa.com.tr/tr/ekonomi/kuresel-gida-fiyatlari-3-5-yilin-zirvesinde/4020976"
try:
    headers = {"User-Agent": "Mozilla/5.0"}
    res = requests.get(url, headers=headers)
    soup = BeautifulSoup(res.text, 'html.parser')
    
    # Extract text from AA
    body = soup.find('div', class_='haber-metni') or soup.find('div', class_='article-body') or soup.find('body')
    raw_text = body.get_text(separator='\n', strip=True) if body else soup.get_text()
    
    print("Orijinal metin çekildi, uzunluk:", len(raw_text))
    
    # 2. Run new prompt
    print("Yeni (Agresif) Prompt ile AI çalıştırılıyor...")
    new_data = ai_columnist_bot.generate_news_article(raw_text, "AA Tarım & Ekonomi")
    
    if new_data:
        # Update DB
        payload = {
            "title": new_data.get("title", ""),
            "title_en": new_data.get("title_en", ""),
            "spot": new_data.get("spot", ""),
            "spot_en": new_data.get("spot_en", ""),
            "content": new_data.get("content", ""),
            "content_en": new_data.get("content_en", ""),
            "summary": new_data.get("summary", ""),
            "summary_en": new_data.get("summary_en", ""),
            "key_takeaways": new_data.get("key_takeaways", []),
            "key_takeaways_en": new_data.get("key_takeaways_en", []),
            "expert_insight": new_data.get("expert_insight", ""),
            "expert_insight_en": new_data.get("expert_insight_en", ""),
            "chart_data": new_data.get("chart_data")
        }
        
        supabase.table('articles').update(payload).eq('id', article_id).execute()
        print("Veritabanı başarıyla GÜNCELLENDİ!")
    else:
        print("AI veri üretemedi.")
        
except Exception as e:
    print("HATA:", e)

