import sys
sys.path.append("/Users/BURHAN/Desktop/tarim_ai_pipeline")
from src.config import supabase_client as supabase
import requests
import json
import base64
import struct
import math
import wave
import io
import os

GEMINI_API_KEY = ""

def generate_speech(text, voice_name, tone_prompt):
    url = f"https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-preview-tts:generateContent?key={GEMINI_API_KEY}"
    payload = {
        "contents": [
            {
                "parts": [
                    {"text": tone_prompt + "\n\n\"" + text + "\""}
                ]
            }
        ],
        "generationConfig": {
            "responseModalities": ["AUDIO"],
            "speechConfig": {
                "voiceConfig": {
                    "prebuiltVoiceConfig": {"voiceName": voice_name}
                }
            }
        }
    }
    print(f"Calling Gemini TTS for voice {voice_name}...")
    res = requests.post(url, headers={"Content-Type": "application/json"}, json=payload)
    if res.status_code != 200:
        raise Exception(f"TTS API Error: {res.status_code} - {res.text}")
    
    data = res.json()
    candidates = data.get("candidates", [])
    if not candidates:
        raise Exception("No candidates in response")
    
    parts = candidates[0].get("content", {}).get("parts", [])
    base64_audio = None
    for part in parts:
        if "inlineData" in part:
            base64_audio = part["inlineData"]["data"]
            break
            
    if not base64_audio:
        raise Exception("No inlineData in response")
        
    raw_pcm = base64.b64decode(base64_audio)
    return raw_pcm

def normalize_pcm(raw_pcm, sample_rate=24000):
    num_samples = len(raw_pcm) // 2
    if num_samples == 0:
        return raw_pcm
        
    samples = list(struct.unpack(f"<{num_samples}h", raw_pcm))
    sum_squares = sum(s * s for s in samples)
    peak = max(abs(s) for s in samples)
    
    rms = math.sqrt(sum_squares / num_samples)
    gain = 1.0
    if rms > 0:
        target_rms = 32767.0 * 0.158489
        gain = target_rms / rms
        
    max_allowed_peak = 32767.0 * 0.89125
    if peak * gain > max_allowed_peak and peak > 0:
        gain = max_allowed_peak / peak
        
    normalized_samples = []
    for s in samples:
        v = s * gain
        if v > 32767: v = 32767
        elif v < -32768: v = -32768
        normalized_samples.append(int(v))
        
    normalized_pcm = struct.pack(f"<{num_samples}h", *normalized_samples)
    
    wav_io = io.BytesIO()
    with wave.open(wav_io, 'wb') as wav_file:
        wav_file.setnchannels(1)
        wav_file.setsampwidth(2)
        wav_file.setframerate(sample_rate)
        wav_file.writeframes(normalized_pcm)
        
    return wav_io.getvalue()

def process_article(article_id):
    print(f"Processing article {article_id}...")
    res = supabase.table("articles").select("*").eq("id", article_id).execute()
    if not res.data:
        print("Article not found!")
        return
    article = res.data[0]
    author = article.get("source_name", "") or ""
    
    is_female = "Tuba" in author or "Yörük" in author or "Günebak" in author
    voice = "Erinome" if is_female else "Charon"
    tone = (
        'Doğayı, toprağı ve suyu seven bir yazarın kendi yazısını anlattığı gibi; samimi, sıcak, Anadolu sevgisiyle dolu, akıcı ve etkileyici bir kadın tonu ile oku. Tüm metin boyunca ses rengini ve sıcaklığını koru:'
        if is_female else
        'Kendi makalesini seslendiren bir araştırmacı köşe yazarı gibi; samimi, sorgulayıcı, hafif hicivli, dinleyiciyle dertleşen, akıcı ve entelektüel bir sohbet tonu ile oku. Tüm metin boyunca ses rengini, anlatım hızını ve perdeni koru, akışı hiç bozma:'
    )
    
    import re
    body = article.get("content", "")
    body = re.sub(r'<[^>]+>', ' ', body)
    body = body.replace('&nbsp;', ' ').replace('&quot;', '"').replace('&amp;', '&')
    body = re.sub(r'\s+', ' ', body).strip()
    
    title = article.get("title", "")
    full_text = f"{title}. {body}"
    
    if len(full_text) > 7000:
        full_text = full_text[:7000]
        last_dot = full_text.rfind('.')
        if last_dot > 100:
            full_text = full_text[:last_dot + 1]
            
    try:
        raw_pcm = generate_speech(full_text, voice, tone)
        wav_bytes = normalize_pcm(raw_pcm)
        
        # Save to temp file and convert
        import subprocess, os
        with open("temp_gen.wav", "wb") as f:
            f.write(wav_bytes)
        subprocess.run(["afconvert", "-f", "m4af", "-d", "aac", "temp_gen.wav", "temp_gen.m4a"], check=True)
        with open("temp_gen.m4a", "rb") as f:
            m4a_bytes = f.read()
        os.remove("temp_gen.wav")
        os.remove("temp_gen.m4a")
        
        clean_slug = re.sub(r'[^a-zA-Z0-9]', '_', author.lower())
        file_path = f"columnists/{clean_slug}_{article_id}.m4a"
        
        print(f"Uploading {file_path} to Supabase...")
        supabase.storage.from_("article-audios").upload(
            file=m4a_bytes,
            path=file_path,
            file_options={"content-type": "audio/x-m4a", "upsert": "true"}
        )
        
        public_url = supabase.storage.from_("article-audios").get_public_url(file_path)
        print(f"Updating db with audio URL: {public_url}")
        supabase.table("articles").update({"audio_url": public_url}).eq("id", article_id).execute()
        print(f"Successfully processed {article_id}")
    except Exception as e:
        print(f"Error processing {article_id}: {e}")

if __name__ == "__main__":
    process_article("fdc8e812-a032-4a4e-85eb-9e15b0e0aaf2")
    process_article("b5a6d65f-1d66-48ca-9c04-eb0124217991")
    process_article("e7498eba-7ee0-41c2-ab30-ee068be855ca")
