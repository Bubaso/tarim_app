import sys
sys.path.append("/Users/BURHAN/Desktop/tarim_ai_pipeline")
from src.config import supabase_client as supabase

def get_content():
    res = supabase.table("articles").select("id, title, content").ilike("title", "%Hakaretin%").ilike("source_name", "%Halil%").order("created_at", desc=True).limit(1).execute()
    if res.data:
        print(f"ID: {res.data[0]['id']}")
        print(f"Title: {res.data[0]['title']}")
        print(f"Content: {res.data[0]['content'][:1000]}...") # truncate for brevity
    else:
        print("Not found.")

if __name__ == "__main__":
    get_content()
