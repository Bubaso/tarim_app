import sys
import os
import subprocess
import requests
sys.path.append("/Users/BURHAN/Desktop/tarim_ai_pipeline")
from src.config import supabase_client as supabase

def compress_images():
    # Fetch all articles that have an image_url ending in .jpg or .png
    res = supabase.table("articles").select("id, image_url").not_.is_("image_url", "null").execute()
    articles = res.data
    
    jpg_articles = [a for a in articles if a['image_url'] and (a['image_url'].endswith(".jpg") or a['image_url'].endswith(".jpeg") or a['image_url'].endswith(".png"))]
    print(f"Found {len(jpg_articles)} articles with unoptimized images.")
    
    for idx, article in enumerate(jpg_articles):
        image_url = article['image_url']
        article_id = article['id']
        print(f"[{idx+1}/{len(jpg_articles)}] Processing {article_id}...")
        
        r = requests.get(image_url)
        if r.status_code != 200:
            print(f"Failed to download {image_url}")
            continue
            
        with open("temp.img", "wb") as f:
            f.write(r.content)
            
        webp_path = "temp.webp"
        
        # Convert to WebP using Pillow
        from PIL import Image
        try:
            with Image.open("temp.img") as img:
                # Resize if width or height is larger than 1000px
                if img.width > 1000 or img.height > 1000:
                    img.thumbnail((1000, 1000))
                
                # Convert to RGB if it's RGBA and we want a smaller webp
                if img.mode != 'RGB' and img.mode != 'RGBA':
                    img = img.convert('RGB')
                    
                img.save(webp_path, 'WEBP', quality=80)
        except Exception as e:
            print(f"Failed to convert image for {article_id}: {e}")
            continue
        
        parts = image_url.split("/article-images/")
        if len(parts) < 2:
            print("Invalid URL format")
            continue
            
        old_remote_path = parts[1]
        
        # Replace extension
        ext_idx = old_remote_path.rfind('.')
        if ext_idx != -1:
            new_remote_path = old_remote_path[:ext_idx] + ".webp"
        else:
            new_remote_path = old_remote_path + ".webp"
            
        with open(webp_path, "rb") as f:
            webp_bytes = f.read()
            
        print(f"Uploading {new_remote_path} ({len(webp_bytes)} bytes)...")
        supabase.storage.from_("article-images").upload(
            file=webp_bytes,
            path=new_remote_path,
            file_options={"content-type": "image/webp", "upsert": "true"}
        )
        
        new_public_url = supabase.storage.from_("article-images").get_public_url(new_remote_path)
        
        # Update DB
        supabase.table("articles").update({"image_url": new_public_url}).eq("id", article_id).execute()
        
        # Delete old image
        print(f"Deleting {old_remote_path} from storage...")
        supabase.storage.from_("article-images").remove([old_remote_path])
        
        print(f"Successfully migrated {article_id}")

    if os.path.exists("temp.img"):
        os.remove("temp.img")
    if os.path.exists("temp.webp"):
        os.remove("temp.webp")
        
if __name__ == "__main__":
    compress_images()
