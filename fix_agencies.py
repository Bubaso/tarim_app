import re

file_path = "../tarim_ai_pipeline/src/utils/agency_fetcher.py"

with open(file_path, "r", encoding="utf-8") as f:
    content = f.read()

# Remove Food Safety News block
content = re.sub(r'\{\s*"name": "Food Safety News".*?\},', '', content, flags=re.DOTALL)
# Remove Food Chemistry Journal block
content = re.sub(r'\{\s*"name": "Food Chemistry Journal".*?\},', '', content, flags=re.DOTALL)
# Remove Nature Food block
content = re.sub(r'\{\s*"name": "Nature Food".*?\},', '', content, flags=re.DOTALL)

with open(file_path, "w", encoding="utf-8") as f:
    f.write(content)

print("Sources removed successfully.")
