import sys
import os
import re
from typing import List, Tuple, Optional
from urllib.parse import urljoin, urlparse

# Ayarlar
URL = sys.argv[1] if len(sys.argv) > 1 else "https://www.aa.com.tr/tr/gundem/nisasta-bazli-sekerden-uzak-durulmali-uyarisi/4030336"
SOURCE_NAME = sys.argv[2] if len(sys.argv) > 2 else None
HTML_FILE_OVERRIDE = sys.argv[3] if len(sys.argv) > 3 else None

if not SOURCE_NAME:
    if "aa.com.tr" in URL:
        SOURCE_NAME = "Anadolu Ajansı"
    elif "bbc.com" in URL:
        SOURCE_NAME = "BBC News"
    elif "cnn.com" in URL:
        SOURCE_NAME = "CNN International"
    elif "aljazeera.com" in URL:
        SOURCE_NAME = "Al Jazeera"
    elif "dw.com" in URL:
        SOURCE_NAME = "Deutsche Welle"
    elif "france24.com" in URL:
        SOURCE_NAME = "France 24"
    else:
        SOURCE_NAME = "Özel Haber"

# Dizin ekle
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from bs4 import BeautifulSoup
import trafilatura
from src.utils.agency_fetcher import scrape_og_image
from src.utils.article_images import extract_images_from_page, distribute_images_in_html, get_image_signature
from src.utils.fulltext import _session, fetch_body, MAX_CHARS, FULL_MIN_CHARS, yayin_tarihi
from src.utils.image_storage import upload_image_to_storage
from src.config import supabase_client
from src.main import run_pipeline


def get_image_signature(img_url: str) -> str:
    """Görsel URL sinden temel kimliği çıkarır; farklı ölçülerdeki aynı görseli eler."""
    clean_url = img_url.split("?")[0]
    filename = clean_url.split("/")[-1]
    base = re.sub(r"\.(jpg|jpeg|png|webp|gif)$", "", filename, flags=re.IGNORECASE)
    base = re.sub(r"thumbs?_[a-z0-9]+_", "", base)
    base = re.sub(r"[-_]\d{2,4}x\d{2,4}", "", base)
    base = re.sub(r"[-_]\d{2,4}$", "", base)
    return base.lower() if len(base) > 4 else filename.lower()


def extract_images_from_page(url: str, html_text: str, max_images: int = 3) -> List[str]:
    """Kaynak sayfadan en fazla max_images (varsayılan 3) görsel seçer.
    İlk görsel ana görsel, kalanlar gövde görselleridir."""
    if not html_text:
        return []

    soup = BeautifulSoup(html_text, "html.parser")
    og_tag = soup.find("meta", property="og:image") or soup.find("meta", attrs={"name": "twitter:image"})
    og_img = og_tag.get("content") if og_tag else None
    if og_img:
        og_img = urljoin(url, og_img.strip())

    selected = []
    seen_sigs = set()

    # 1. Ana görsel adayı: og:image
    if og_img and og_img.startswith(("http://", "https://")):
        sig = get_image_signature(og_img)
        seen_sigs.add(sig)
        selected.append(og_img)

    # 2. Sayfa içindeki diğer görselleri tara
    for tag in soup.find_all(["img", "figure", "a"]):
        src = None
        if tag.name == "img":
            src = (tag.get("src") or tag.get("data-src") or tag.get("data-original") or 
                   tag.get("data-hi-res-src"))
            if not src and tag.get("srcset"):
                raw_srcset = tag.get("srcset")
                # virgül ve boşlukla ayrılan srcset maddeleri
                parts = re.split(r",\s+(?=https?://|/[^/])", raw_srcset)
                if parts:
                    src = parts[-1].strip().split(" ")[0]
        elif tag.name == "figure":
            inner = tag.find("img")
            if inner:
                src = (inner.get("src") or inner.get("data-src") or inner.get("data-original") or
                       inner.get("data-hi-res-src"))
        elif tag.name == "a":
            href = tag.get("href", "")
            if any(href.lower().endswith(ext) for ext in [".jpg", ".jpeg", ".webp", ".png"]):
                src = href

        if not src:
            continue

        src = urljoin(url, src.strip())
        if not src.startswith(("http://", "https://")):
            continue

        clean_path = urlparse(src).path.lower()
        has_img_ext = any(clean_path.endswith(ext) for ext in [".jpg", ".jpeg", ".png", ".webp"])
        has_img_type = any(t in src.lower() for t in ["image", "photo", "picture", "upload", "media", "contents", "gallery", "cdn"])
        if not (has_img_ext or has_img_type):
            continue

        src_lower = src.lower()
        blacklist = [
            "logo", "icon", "avatar", "headshot", "author", "profile", "ad-", "advert",
            "tracker", "pixel", "banner", "placeholder", "spinner", ".svg", ".gif", "1x1",
            "share", "button", "next.png", "prev.png", "arrow", "badge", "close.png",
            "comments", "nav", "footer", "header", "aalogo", "thumbs_m_c_30375a8", "facebook", "twitter", "whatsapp", "linkedin", "instagram"
        ]
        if any(b in src_lower for b in blacklist):
            continue

        sig = get_image_signature(src)
        if sig in seen_sigs:
            continue

        seen_sigs.add(sig)
        selected.append(src)
        if len(selected) >= max_images:
            break

    return selected[:max_images]


def distribute_images_in_html(html_text: str, image_urls: List[str], alt_text: str = "") -> str:
    """Gövde görsellerini HTML içeriğindeki paragrafların arasına dengeli dağıtır."""
    if not html_text or not image_urls:
        return html_text

    paragraphs = re.split(r"(</p>)", html_text, flags=re.IGNORECASE)
    p_blocks = []
    i = 0
    while i < len(paragraphs):
        chunk = paragraphs[i]
        if i + 1 < len(paragraphs) and paragraphs[i+1].lower() == "</p>":
            p_blocks.append(chunk + paragraphs[i+1])
            i += 2
        else:
            if chunk.strip():
                p_blocks.append(chunk)
            i += 1

    if not p_blocks:
        img_tags = "".join([f'<p><img src="{img}" alt="{alt_text}" /></p>' for img in image_urls])
        return html_text + img_tags

    num_p = len(p_blocks)
    num_imgs = len(image_urls)

    if num_imgs == 1:
        insert_positions = [max(1, num_p // 2)]
    else:
        pos1 = max(1, num_p // 3)
        pos2 = max(pos1 + 1, (2 * num_p) // 3)
        insert_positions = [pos1, min(pos2, num_p)]

    result = []
    img_idx = 0
    for idx, block in enumerate(p_blocks, 1):
        result.append(block)
        if img_idx < num_imgs and idx == insert_positions[img_idx]:
            img_tag = f'<p><img src="{image_urls[img_idx]}" alt="{alt_text}" /></p>'
            result.append(img_tag)
            img_idx += 1

    while img_idx < num_imgs:
        result.append(f'<p><img src="{image_urls[img_idx]}" alt="{alt_text}" /></p>')
        img_idx += 1

    return "".join(result)


def main():
    print("\n" + "="*60)
    print(f"🎯 Hedef URL: {URL}")
    print(f"📰 Kaynak: {SOURCE_NAME}")

    sess = _session()
    raw_html = ""
    sayfa_tarihi = None
    method = "trafilatura"
    fetched_body = ""

    # 1. HTML ve Metin Çekme
    print("\n1. Sayfa içeriği ve metin çekiliyor...")
    if HTML_FILE_OVERRIDE and os.path.exists(HTML_FILE_OVERRIDE):
        print(f"   📂 Yerel HTML dosyasından okunuyor: {HTML_FILE_OVERRIDE}")
        with open(HTML_FILE_OVERRIDE, "r", encoding="utf-8", errors="ignore") as f:
            raw_html = f.read()
        fetched_body = trafilatura.extract(raw_html, include_comments=False, include_tables=True, include_formatting=True) or ""
        sayfa_tarihi = yayin_tarihi(raw_html)
    else:
        try:
            r = sess.get(URL, timeout=25)
            if r.status_code == 200:
                raw_html = r.text
                sayfa_tarihi = yayin_tarihi(raw_html)
                fetched_body = trafilatura.extract(raw_html, include_comments=False, include_tables=True, include_formatting=True) or ""
            else:
                print(f"   ⚠️ HTTP {r.status_code} döndü.")
        except Exception as net_err:
            print(f"   ⚠️ Ağ isteği hatası: {net_err}")

        if not fetched_body:
            fetched_body, method, sayfa_tarihi = fetch_body(URL, sess)

    if not fetched_body:
        print("   ❌ HATA: Metin çekilemedi. Lütfen URL'yi kontrol edin veya sitenin engeli olabilir.")
        sys.exit(1)

    body = fetched_body[:MAX_CHARS]
    source_chars = len(body)
    source_depth = "full" if source_chars >= FULL_MIN_CHARS else "brief"
    raw_source = body 

    print(f"   ✅ Metin çekildi ({source_chars} karakter, {method}). Tarih: {sayfa_tarihi}")

    # 2. Çoklu Görsel Ayıklama (Özel Haber Hattına Özel Kural: Max 3 görsel)
    print("\n2. Görseller taranıyor (En fazla 3 adet: 1 ana + gövde görselleri)...")
    all_images = extract_images_from_page(URL, raw_html, max_images=3)

    main_image = all_images[0] if all_images else scrape_og_image(URL)
    body_images = all_images[1:] if len(all_images) > 1 else []

    print(f"   🖼️  Ana Görsel: {main_image}")
    print(f"   🖼️  Gövde Görselleri ({len(body_images)} adet): {body_images}")

    # 3. AI Pipeline Başlatılıyor
    print("\n3. AI Pipeline Başlatılıyor...")
    try:
        final_article = run_pipeline(
            raw_source=raw_source,
            source_name=SOURCE_NAME,
            source_url=URL,
            image_url=main_image,
            mnt_featured=True,
            source_depth=source_depth,
            source_chars=source_chars,
            extraction_method=method,
            published_at=sayfa_tarihi,
        )

        if final_article.get("approved") is False:
            print("\n❌ [ELENDİ] Haber kriterlere uymayan olarak değerlendirildi.")
            return
        
        article_title = final_article.get("title")
        print(f"\n✅ [BAŞARILI] '{article_title}' başlığıyla veritabanına eklendi.")

        # 4. Gövde Görsellerini Supabase Storage'a yükleyip içeriğe dağıtma
        if body_images and supabase_client:
            print(f"\n4. Gövde görselleri ({len(body_images)} adet) Storage'a yüklenip metne dağıtılıyor...")
            uploaded_body_images = []
            for b_img in body_images:
                try:
                    stored_b = upload_image_to_storage(b_img)
                    if stored_b and "supabase.co" in stored_b:
                        uploaded_body_images.append(stored_b)
                        print(f"   📦 Gövde görseli yüklendi: {stored_b[:80]}...")
                    else:
                        print(f"   ⚠️ Gövde görseli Storage'a yüklenemedi: {b_img[:80]}")
                except Exception as up_err:
                    print(f"   ⚠️ Gövde görseli yükleme hatası: {up_err}")

            if uploaded_body_images:
                res = supabase_client.table("articles").select("id, content, content_en, title, title_en").eq("source_url", URL).order("created_at", desc=True).limit(1).execute()
                if res.data and len(res.data) > 0:
                    art = res.data[0]
                    art_id = art["id"]
                    cur_content = art.get("content") or ""
                    cur_content_en = art.get("content_en") or ""
                    
                    new_content = distribute_images_in_html(cur_content, uploaded_body_images, alt_text=art.get("title") or "")
                    new_content_en = distribute_images_in_html(cur_content_en, uploaded_body_images, alt_text=art.get("title_en") or "")

                    supabase_client.table("articles").update({
                        "content": new_content,
                        "content_en": new_content_en
                    }).eq("id", art_id).execute()
                    print(f"   🎉 {len(uploaded_body_images)} adet gövde görseli haber içeriğine ('content' ve 'content_en') başarıyla dağıtıldı!")
                else:
                    print("   ⚠️ DB'de eklenen makale bulunamadı, gövde görselleri güncellenemedi.")

    except Exception as e:
        print(f"\n💥 [HATA] {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    main()
