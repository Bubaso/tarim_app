import re

files_to_fix = [
    "/Users/BURHAN/Desktop/tarim_app/lib/features/home/presentation/screens/category_articles_screen.dart",
]

for file_path in files_to_fix:
    with open(file_path, 'r') as f:
        content = f.read()

    # Find and remove Text(dateStr...
    # There are variations like:
    # Text(dateStr.toUpperCase(),
    #     style: GoogleFonts.robotoMono(...)),
    
    # regex to match Text(dateStr.toUpperCase(), ... ) 
    pattern = r'\s*Text\(dateStr\.toUpperCase\(\),\s*style:\s*GoogleFonts\.[a-zA-Z]+\([^)]*\)\s*\),'
    
    new_content = re.sub(pattern, '', content)
    
    with open(file_path, 'w') as f:
        f.write(new_content)
    
    print(f"Fixed {file_path}")
