import sys
sys.path.append('../tarim_ai_pipeline')
from src.config import supabase_client

print("Articles table columns:")
res = supabase_client.table('articles').select('*').limit(1).execute()
if res.data:
    print(list(res.data[0].keys()))

print("Portal_stories table columns:")
res = supabase_client.table('portal_stories').select('*').limit(1).execute()
if res.data:
    print(list(res.data[0].keys()))
