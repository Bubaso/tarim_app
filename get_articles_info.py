import requests

headers = {
    "apikey": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inhrd2N5YXZjbHRyd2V1bnZvb2V1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODEzNDk4NTIsImV4cCI6MjA5NjkyNTg1Mn0.j6miEKZCNQ2XJ_jx8eRLKMs-g_KSBBbigHsrWAgjxS4",
    "Authorization": "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inhrd2N5YXZjbHRyd2V1bnZvb2V1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODEzNDk4NTIsImV4cCI6MjA5NjkyNTg1Mn0.j6miEKZCNQ2XJ_jx8eRLKMs-g_KSBBbigHsrWAgjxS4"
}

# Get the two Halil Etyemez articles
url_halil = "https://xkwcyavcltrweunvooeu.supabase.co/rest/v1/articles?source_name=ilike.*Halil*&order=created_at.desc&limit=2"
res_halil = requests.get(url_halil, headers=headers)
print("Halil Articles:", res_halil.json())

# Get Ezher's latest article
url_ezher = "https://xkwcyavcltrweunvooeu.supabase.co/rest/v1/articles?source_name=ilike.*Ezher*&order=created_at.desc&limit=1"
res_ezher = requests.get(url_ezher, headers=headers)
print("\nEzher Latest Article:", res_ezher.json())
