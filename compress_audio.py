import sys
import os
import subprocess
import requests
sys.path.append("/Users/BURHAN/Desktop/tarim_ai_pipeline")
from src.config import supabase_client as supabase

def compress_audio():
    # Fetch all articles that have an audio_url ending in .wav
    res = supabase.table("articles").select("id, audio_url").not_.is_("audio_url", "null").ilike("audio_url", "%.wav").execute()
    articles = res.data
    print(f"Found {len(articles)} articles with .wav audio.")
    
    for idx, article in enumerate(articles):
        audio_url = article['audio_url']
        article_id = article['id']
        print(f"[{idx+1}/{len(articles)}] Processing {article_id}...")
        
        # Download WAV
        r = requests.get(audio_url)
        if r.status_code != 200:
            print(f"Failed to download {audio_url}")
            continue
            
        with open("temp.wav", "wb") as f:
            f.write(r.content)
            
        # Convert to M4A using macOS afconvert
        m4a_path = "temp.m4a"
        if os.path.exists(m4a_path):
            os.remove(m4a_path)
            
        subprocess.run(["afconvert", "-f", "m4af", "-d", "aac", "temp.wav", m4a_path], check=True)
        
        # Determine paths
        # URL format: .../object/public/article-audios/columnists/filename.wav
        parts = audio_url.split("/article-audios/")
        if len(parts) < 2:
            print("Invalid URL format")
            continue
        
        old_remote_path = parts[1]
        new_remote_path = old_remote_path.replace(".wav", ".m4a")
        
        # Upload M4A
        with open(m4a_path, "rb") as f:
            m4a_bytes = f.read()
            
        print(f"Uploading {new_remote_path} ({len(m4a_bytes)} bytes)...")
        supabase.storage.from_("article-audios").upload(
            file=m4a_bytes,
            path=new_remote_path,
            file_options={"content-type": "audio/x-m4a", "upsert": "true"}
        )
        
        # Get new public URL
        new_public_url = supabase.storage.from_("article-audios").get_public_url(new_remote_path)
        
        # Update DB
        supabase.table("articles").update({"audio_url": new_public_url}).eq("id", article_id).execute()
        
        # Delete old WAV
        print(f"Deleting {old_remote_path} from storage...")
        supabase.storage.from_("article-audios").remove([old_remote_path])
        
        print(f"Successfully migrated {article_id}")

    # Cleanup temp files
    if os.path.exists("temp.wav"):
        os.remove("temp.wav")
    if os.path.exists("temp.m4a"):
        os.remove("temp.m4a")
        
if __name__ == "__main__":
    compress_audio()
