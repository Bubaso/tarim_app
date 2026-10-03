import sys
sys.path.append("/Users/BURHAN/Desktop/tarim_ai_pipeline")
from src.config import supabase_client as supabase

def get_content():
    res = supabase.table("articles").select("title, content").eq("id", "aa33516b-cd8e-4b8c-bbb6-bf2890eaa301").execute()
    print(res.data[0])

if __name__ == "__main__":
    get_content()
