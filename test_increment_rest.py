import os
import requests
import json

url = "https://xkwcyavcltrweunvooeu.supabase.co/rest/v1"
key = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inhrd2N5YXZjbHRyd2V1bnZvb2V1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODEzNDk4NTIsImV4cCI6MjA5NjkyNTg1Mn0.j6miEKZCNQ2XJ_jx8eRLKMs-g_KSBBbigHsrWAgjxS4"

headers = {
    "apikey": key,
    "Authorization": f"Bearer {key}",
    "Content-Type": "application/json",
    "Prefer": "return=representation"
}

res = requests.get(f"{url}/articles?select=id,view_count&limit=1", headers=headers)
article_id = res.json()[0]['id']
current_count = res.json()[0].get('view_count', 0)
print(f"Current count: {current_count}")

update_res = requests.patch(
    f"{url}/articles?id=eq.{article_id}",
    headers=headers,
    json={"view_count": current_count + 1}
)
print("UPDATE status code:", update_res.status_code)
print("UPDATE response:", update_res.text)

res_after = requests.get(f"{url}/articles?id=eq.{article_id}&select=id,view_count", headers=headers)
print("Count after:", res_after.json()[0].get('view_count'))

