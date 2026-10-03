import sys
sys.path.append("/Users/BURHAN/Desktop/tarim_ai_pipeline")
from src.config import supabase_client as supabase
import json

def find_article():
    res = supabase.table("articles").select("id, title, image_url, status, source_name").ilike("title", "%kalkınma%").execute()
    for row in res.data:
        print(row)
        
if __name__ == "__main__":
    find_article()
