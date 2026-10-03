import sys
sys.path.append("/Users/BURHAN/Desktop/tarim_ai_pipeline")
from src.config import supabase_client as supabase
import json

def find_article():
    res = supabase.table("articles").select("id, title, status, source_name, source_type, created_at, audio_url").ilike("source_name", "%ezher%").order("created_at", desc=True).limit(5).execute()
    for row in res.data:
        print(row)
        
if __name__ == "__main__":
    find_article()
