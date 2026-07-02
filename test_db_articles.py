import requests

url = "https://xkwcyavcltrweunvooeu.supabase.co/rest/v1/articles?select=id,title,status,source_name,region,topic,content_type,image_url,is_hero&limit=20"
headers = {
    "apikey": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inhrd2N5YXZjbHRyd2V1bnZvb2V1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODEzNDk4NTIsImV4cCI6MjA5NjkyNTg1Mn0.j6miEKZCNQ2XJ_jx8eRLKMs-g_KSBBbigHsrWAgjxS4",
    "Authorization": "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inhrd2N5YXZjbHRyd2V1bnZvb2V1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODEzNDk4NTIsImV4cCI6MjA5NjkyNTg1Mn0.j6miEKZCNQ2XJ_jx8eRLKMs-g_KSBBbigHsrWAgjxS4"
}

response = requests.get(url, headers=headers)
articles = response.json()

for a in articles:
    print(f"[{a['status']}] {a['title'][:30]}... | source: {a['source_name']} | region: {a['region']} | topic: {a['topic']} | type: {a['content_type']} | img: {bool(a['image_url'])}")
