import sys
sys.path.append("/Users/BURHAN/Desktop/tarim_ai_pipeline")
from src.config import supabase_client as supabase

def cleanup_storage():
    # 1. Fetch all audio_url and image_url from db
    res = supabase.table("articles").select("audio_url, image_url").execute()
    db_urls = set()
    for row in res.data:
        if row.get("audio_url"):
            db_urls.add(row["audio_url"].split("?")[0])
        if row.get("image_url"):
            db_urls.add(row["image_url"].split("?")[0])
            
    print(f"Total referenced files in DB: {len(db_urls)}")

    # 2. Cleanup article-audios
    def cleanup_bucket(bucket_name):
        print(f"Checking bucket: {bucket_name}")
        # Supabase list() only returns max 100 items by default unless you paginate, but let's assume we have < 1000 and we can list them recursively
        files_to_delete = []
        
        # Helper to list recursively
        def list_files(path=""):
            items = supabase.storage.from_(bucket_name).list(path)
            for item in items:
                # If it's a folder, it won't have an ID, or id is None
                if item.get("id") is None and item.get("name") != ".emptyFolderPlaceholder":
                    new_path = f"{path}/{item['name']}" if path else item['name']
                    list_files(new_path)
                else:
                    file_path = f"{path}/{item['name']}" if path else item['name']
                    if file_path == ".emptyFolderPlaceholder":
                        continue
                    public_url = supabase.storage.from_(bucket_name).get_public_url(file_path).split("?")[0]
                    if public_url not in db_urls:
                        print(f"Orphaned file found: {file_path}")
                        files_to_delete.append(file_path)
        
        list_files("")
        
        if files_to_delete:
            print(f"Deleting {len(files_to_delete)} orphaned files from {bucket_name}...")
            # Delete in chunks of 100
            for i in range(0, len(files_to_delete), 100):
                chunk = files_to_delete[i:i+100]
                supabase.storage.from_(bucket_name).remove(chunk)
            print(f"Cleanup for {bucket_name} complete.")
        else:
            print(f"No orphaned files found in {bucket_name}.")

    cleanup_bucket("article-audios")
    cleanup_bucket("article-images")
    
if __name__ == "__main__":
    cleanup_storage()
