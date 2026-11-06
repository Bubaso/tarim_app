"""Tarım Portalı hikaye üretici.

Yayındaki haberlerden "Instagram story" biçiminde veri kartları çıkarır ve
`portal_stories` tablosuna yazar. Uygulama bu satırları konu başlığına göre
gruplayıp anasayfadaki şeritte gösterir.

Çalıştırma
----------
Ortam değişkenleriyle (CI / sunucu):

    SUPABASE_URL=... SUPABASE_SERVICE_ROLE_KEY=... GEMINI_API_KEY=... \
        python scripts/generate_stories.py

Değişkenler yoksa yerel `tarim_ai_pipeline` kurulumuna düşer (geliştirici
makinesi). Eskiden yalnızca bu ikinci yol vardı; hikayeler ancak geliştiricinin
bilgisayarı çalıştırdığında üretiliyordu — bkz. .github/workflows/generate_stories.yml
"""

import io
import json
import os
import re
import struct
import sys
import urllib.request
from datetime import datetime, timedelta, timezone


# ── Kurallar ─────────────────────────────────────────────────────────────────
# İstemci tarafındaki karşılıkları lib/features/stories/data/story_constants.dart
# içindeki StoryRules sınıfındadır; ikisini birlikte güncelleyin.

class StoryRules:
    #: Aynı anda yayında olabilecek en fazla hikaye satırı.
    MAX_ACTIVE = 50

    #: Haberlerin taranacağı zaman penceresi.
    ARTICLE_WINDOW_HOURS = 36

    #: Tek çalıştırmada değerlendirilen en fazla haber.
    ARTICLE_SCAN_LIMIT = 100

    #: Hikâye ömrü KADEMELİ (6 Kasım 2026 denetimi, T3).
    #:
    #: Eskiden herkese sabit 24 saat veriliyordu. Hat her sabah tek seferde
    #: çalıştığı için bütün hikâyeler aynı dakikada doğuyor ve aynı dakikada
    #: ölüyordu: ölçümde 30 aktif hikâyenin 27'si aynı saniyede sona eriyordu.
    #: Şerit 10 konudan 3 konuya bir anda düşüp ertesi sabaha kadar öyle
    #: kalıyordu.
    #:
    #: Artık aynı konudaki her ek hikâye bir öncekinden TTL_ADIM saat kısa
    #: yaşıyor. Üretim anı değişmiyor, şerit gün boyunca incelerek değişiyor.
    TTL_TABAN = 30
    TTL_ADIM = 3
    TTL_EN_AZ = 18

    #: Son dakika daha kısa yaşıyor: 24 saat sonra "son dakika" olan bir şey
    #: yok. Sıralamadaki bonusun kendi penceresi zaten 12 saat.
    BREAKING_TTL_HOURS = 20

    #: Kart gücü eşiği (model 1-10 veriyor).
    #:
    #: Ölçüm: son 36 saatte yayınlanan 48 haberin 29'u hikâyeye çevrilmişti —
    #: %60. "Çarpıcı sayısal veri" ölçütü bu kadar geçirgense ölçüt değil;
    #: şeridin değeri seçiciliğinden geliyor.
    GUC_ESIGI = 7

    #: Tek çalıştırmada ve tek günde eklenebilecek en fazla hikâye.
    #:
    #: Hat saatlik çalışıyor; tavan olmadan sabahki yığın tek seferde
    #: içeri giriyordu. Günlük tavan şeridi 12 güçlü karta sabitliyor.
    CALISMA_BASINA = 6
    GUNLUK_EN_FAZLA = 12

    #: Aynı haberden ikinci kez hikaye üretmemek için bakılan geçmiş. Eskiden
    #: tablonun tamamı çekiliyordu; hikayeler en fazla 36 saat yaşadığı için
    #: bir haftalık pencere yeterli ve sorgu sabit maliyetli kalıyor.
    DEDUPE_WINDOW_DAYS = 7

    #: Modele verilen haber metninin uzunluğu. 1500 karakter, tabloların ve
    #: rakamların metnin ortasında kaldığı haberlerde veriyi kaçırıyordu.
    CONTENT_CHARS = 4000

    #: Tam ekran gösterim için kabul edilen en küçük görsel genişliği.
    #: Bunun altındaki görsel telefonda kaçınılmaz olarak bulanık çıkıyor.
    MIN_IMAGE_WIDTH = 1200


#: Grup başlıkları sabit bir listeden seçiliyor. Serbest metin olduğunda her
#: haber kendi başlığını uyduruyor ve konuya göre gruplama imkânsızlaşıyordu.
CATEGORIES = [
    ("Piyasa", "Markets"),
    ("Hasat", "Harvest"),
    ("Destekleme", "Subsidies"),
    ("İhracat", "Exports"),
    ("Hayvancılık", "Livestock"),
    ("Su & İklim", "Water & Climate"),
    ("Gıda", "Food"),
    ("Teknoloji", "Technology"),
    ("Politika", "Policy"),
    ("Dünya", "World"),
]
FALLBACK_CATEGORY = ("Gündem", "Agenda")


# ── Bağlantılar ──────────────────────────────────────────────────────────────

def build_clients():
    """Supabase istemcisini ve Gemini modelini kurar.

    Önce ortam değişkenlerine bakar (sunucuda/CI'da böyle çalışır), yoksa
    geliştirici makinesindeki `tarim_ai_pipeline` kurulumuna düşer.
    """
    import google.generativeai as genai

    url = os.environ.get("SUPABASE_URL")
    key = os.environ.get("SUPABASE_SERVICE_ROLE_KEY") or os.environ.get("SUPABASE_KEY")
    gemini_key = os.environ.get("GEMINI_API_KEY")

    if url and key:
        from supabase import create_client

        supabase = create_client(url, key)
    else:
        local_pipeline = os.environ.get(
            "TARIM_PIPELINE_PATH", "/Users/BURHAN/tarim_ai_pipeline"
        )
        sys.path.append(local_pipeline)
        from src.config import supabase_client  # type: ignore
        from src.config import GEMINI_API_KEY  # type: ignore

        supabase = supabase_client
        gemini_key = gemini_key or GEMINI_API_KEY

    if not gemini_key:
        raise SystemExit("GEMINI_API_KEY tanımlı değil.")

    genai.configure(api_key=gemini_key)
    return supabase, genai.GenerativeModel("gemini-2.5-flash")


def utcnow():
    return datetime.now(timezone.utc)


# ── Görsel çözünürlüğü ───────────────────────────────────────────────────────

def read_image_width(url):
    """Görselin genişliğini başlığından okur; belirlenemezse None döner.

    Dosyanın tamamını indirmiyoruz — ilk 64 KB başlık için fazlasıyla yeter.
    """
    try:
        request = urllib.request.Request(
            url,
            headers={
                "Range": "bytes=0-65535",
                "User-Agent": "tarim-portal-story-bot/1.0",
            },
        )
        with urllib.request.urlopen(request, timeout=15) as response:
            data = response.read(65536)
    except Exception as error:  # ağ hatası hikayeyi engellemesin
        print(f"    ! görsel ölçülemedi ({error})")
        return None

    return _parse_width(data)


def _parse_width(data):
    if len(data) < 16:
        return None

    if data[:8] == b"\x89PNG\r\n\x1a\n" and len(data) >= 24:
        return struct.unpack(">I", data[16:20])[0]

    if data[:6] in (b"GIF87a", b"GIF89a"):
        return struct.unpack("<H", data[6:8])[0]

    if data[:4] == b"RIFF" and data[8:12] == b"WEBP":
        chunk = data[12:16]
        if chunk == b"VP8X" and len(data) >= 27:
            return int.from_bytes(data[24:27], "little") + 1
        if chunk == b"VP8 " and len(data) >= 28:
            return struct.unpack("<H", data[26:28])[0] & 0x3FFF
        if chunk == b"VP8L" and len(data) >= 25:
            bits = int.from_bytes(data[21:25], "little")
            return (bits & 0x3FFF) + 1
        return None

    if data[:2] == b"\xff\xd8":
        stream = io.BytesIO(data)
        stream.read(2)
        while True:
            head = stream.read(2)
            if len(head) < 2 or head[0] != 0xFF:
                return None
            marker = head[1]
            if marker in (0xD8, 0x01) or 0xD0 <= marker <= 0xD7:
                continue
            length_bytes = stream.read(2)
            if len(length_bytes) < 2:
                return None
            length = struct.unpack(">H", length_bytes)[0]
            # SOF0..SOF15 (DHT/DAC/RST hariç) çerçeve boyutunu taşır.
            if marker in (0xC0, 0xC1, 0xC2, 0xC3, 0xC5, 0xC6, 0xC7,
                          0xC9, 0xCA, 0xCB, 0xCD, 0xCE, 0xCF):
                # precision(1) + height(2) + width(2)
                body = stream.read(5)
                if len(body) < 5:
                    return None
                return struct.unpack(">H", body[3:5])[0]
            stream.seek(length - 2, io.SEEK_CUR)

    return None


# ── Ömür ve tekrar denetimi ──────────────────────────────────────────────────

def _omur(kategori, sayac, son_dakika):
    """Hikâyenin kaç saat yaşayacağı — aynı konudaki kaçıncısı olduğuna göre.

    Son dakika bu kademeye GİRMİYOR: onun ömrü haberin niteliğinden geliyor,
    konudaki sırasından değil.
    """
    if son_dakika:
        return StoryRules.BREAKING_TTL_HOURS
    sira = sayac.get(kategori, 0)
    return max(
        StoryRules.TTL_EN_AZ,
        StoryRules.TTL_TABAN - sira * StoryRules.TTL_ADIM,
    )


#: Bir dizgedeki sayı öbekleri. Ayıraçlar dahil: "1.234,5" tek öbek.
_SAYI = re.compile(r"\d[\d.,]*")


def _sayilar(metin):
    """Metindeki sayıları karşılaştırılabilir biçimde döndürür.

    Ayıraçlar atılıyor: başlıkta "1.234", vurucu değerde "1234" yazıyorsa
    bu yine aynı sayıdır.
    """
    return {
        s.strip(".,").replace(".", "").replace(",", "")
        for s in _SAYI.findall(metin or "")
        if s.strip(".,")
    }


def baslik_rakami_tekrarliyor(baslik, vurucu):
    """Başlık, dev punto ile yazılan sayıyı AYNEN tekrar ediyor mu?

    6 Kasım 2026 denetimi (T4): üç alan birbirinden bağımsız dolduruluyor ve
    üçü de aynı bilgiyi taşıyordu. Okur dev bir rakam, onu tekrar eden bir
    etiket ve onu bir kez daha tekrar eden bir başlık okuyup tek bir şey
    öğreniyordu.

        big_stat_value : %30
        stat_label     : Yeni Pazar Kotası
        headline       : Hal Kanunu Taslağı ile Üreticiye %30 Pazar Kotası

    Kural: rakam "ne kadar"ı söylüyorsa başlık "ne olacak"ı söylemeli.
    """
    v = _sayilar(vurucu)
    if not v:
        return False
    return bool(v & _sayilar(baslik))


# ── Model çağrısı ────────────────────────────────────────────────────────────

PROMPT = """Sen Tarım Portalı için profesyonel bir sosyal medya içerik yöneticisisin.
Aşağıdaki haberi oku. Haberde sayısal bir veri, yüzdelik bir artış/düşüş, net bir fiyat
veya çok çarpıcı bir gelişme varsa bundan bir "Instagram Story" veri kartı çıkar.
Haber sadece yorum, siyasi söylem veya genel bir bilgi içeriyorsa is_story_worthy false olsun.

ÖNEMLİ KURALLAR:
1. group_title MUTLAKA şu listeden BİRE BİR seçilecek: {categories}
   group_title_en de o kategorinin İngilizce karşılığı olacak: {categories_en}
2. big_stat_value MUTLAKA rakam içermeli ve en fazla 12 karakter olmalı (örn: +%4.2, 9.25₺, 12 bin ton).
   Rakam yoksa is_story_worthy false döndür.
3. Uygulamanın İngilizce sürümü de var; her alanın "_en" karşılığını gazetecilik diline uygun doldur.
4. headline, big_stat_value'daki SAYIYI TEKRAR ETMEYECEK. Dev punto ile yazılan
   rakam zaten ekranda duruyor; başlık aynı sayıyı bir daha yazarsa okur üç
   satır okuyup tek şey öğrenir. Rakam "ne kadar"ı söyler, başlık "ne olacak"ı:
   big_stat_value "%30" ise headline "Aracı payı yarıya iniyor" gibi olmalı,
   "Üreticiye %30 Pazar Kotası" gibi DEĞİL.
5. guc alanına 1-10 arası bir puan ver: bu kart bir haber şeridinde kendi
   başına durmayı ne kadar hak ediyor? 10 = okurun durup bakacağı çarpıcı
   bir rakam. 5 = doğru ama sıradan. Cömert davranma.
6. guc 8 veya üstüyse bir TAHMİN sorusu hazırla; değilse tahmin alanlarını boş
   bırak. Soru, okurun rakamı görmeden tahmin etmesini isteyen tek bir cümle
   olmalı (max 70 harf, örn: "Mazot maliyeti bu yıl ne kadar arttı?").
   tahmin_secenekler ÜÇ şık içerecek: biri big_stat_value'nun AYNISI, ikisi
   makul ama yanlış. Şıklar aynı biçimde yazılacak (hepsi yüzdeyse hepsi
   yüzde, hepsi tonsa hepsi ton) ve birbirine çok yakın OLMAYACAK — okur
   gerçekten seçim yapabilmeli. tahmin_dogru, doğru şıkkın 0 tabanlı sırası.

ÇIKTIYI SADECE JSON olarak ver, başka hiçbir açıklama yazma:
{{
    "is_story_worthy": true veya false,
    "guc": 1-10 arası tam sayı,
    "tahmin_soru": "Tahmin sorusu ya da boş dize",
    "tahmin_secenekler": ["şık 1", "şık 2", "şık 3"],
    "tahmin_dogru": 0,
    "group_title": "Listeden seçilen kategori",
    "group_title_en": "Kategorinin İngilizcesi",
    "super_title": "KISA ETİKET (Max 20 harf)",
    "super_title_en": "SHORT LABEL (Max 20 chars)",
    "headline": "Haberi anlatan çarpıcı başlık (Max 60 harf)",
    "headline_en": "English headline (Max 60 chars)",
    "big_stat_value": "Vurucu sayısal değer",
    "big_stat_value_en": "Numeric value in English form",
    "stat_label": "Bu sayının ne olduğunu açıklayan kısa etiket",
    "stat_label_en": "Short English label"
}}

Haber Başlığı: {title}
Haber Metni: {content}
"""


def generate_story_for_article(model, article):
    """Haberden story verisi üretir; uygun değilse None döner."""
    content = article.get("content", "") or ""
    title = article.get("title", "") or ""

    if len(content) < 200:
        return None

    prompt = PROMPT.format(
        categories=", ".join(tr for tr, _ in CATEGORIES),
        categories_en=", ".join(en for _, en in CATEGORIES),
        title=title,
        content=content[: StoryRules.CONTENT_CHARS],
    )

    try:
        response = model.generate_content(prompt)
        text = response.text.strip()
        if text.startswith("```json"):
            text = text[7:-3]
        elif text.startswith("```"):
            text = text[3:-3]
        data = json.loads(text.strip())
    except Exception as error:
        print(f"    ! Gemini hatası veya ayrıştırma hatası: {error}")
        return None

    if data.get("is_story_worthy") is not True:
        return None

    return validate(data)


def validate(data):
    """Modelin çıktısını kabul edilebilir hâle getirir; olmuyorsa None döner.

    Doğrulama olmadan şu kartlar ekrana çıkabiliyordu: dev punto ile yazılmış
    ama içinde hiç rakam olmayan bir "big_stat_value", ya da boş bir başlık.
    """
    headline = (data.get("headline") or "").strip()
    stat_label = (data.get("stat_label") or "").strip()
    big_stat = (data.get("big_stat_value") or "").strip()

    if not headline or not stat_label or not big_stat:
        print("    ! zorunlu alan boş, atlanıyor")
        return None

    if not any(ch.isdigit() for ch in big_stat):
        print(f"    ! vurucu değer rakam içermiyor ('{big_stat}'), atlanıyor")
        return None

    if len(big_stat) > 12:
        print(f"    ! vurucu değer çok uzun ('{big_stat}'), atlanıyor")
        return None

    # T4 — başlık dev rakamı tekrar edemez. İstemde yazılı ama model
    # kuralı her zaman tutmuyor; doğrulayıcı son söz.
    if baslik_rakami_tekrarliyor(headline, big_stat):
        print(f"    ! başlık vurucu rakamı tekrarlıyor ('{big_stat}'), atlanıyor")
        return None

    # T8 — güç eşiği. Model vermezse 0 sayılıyor: puansız kart geçemez,
    # yoksa eşik ilk model güncellemesinde sessizce devre dışı kalırdı.
    try:
        guc = int(data.get("guc") or 0)
    except (TypeError, ValueError):
        guc = 0
    if guc < StoryRules.GUC_ESIGI:
        print(f"    ! güç {guc} < {StoryRules.GUC_ESIGI}, atlanıyor")
        return None
    data["guc"] = guc

    # ── Tahmin slaytı (Ö5) ────────────────────────────────────────────────
    #
    # Geçersizse ATILIYOR, kart düşmüyor: tahmin bir süs, kartın kendisi
    # değil. Üç şık, doğru şık big_stat_value ile birebir, sıra 0-2 —
    # üçünden biri tutmazsa soru hiç sorulmuyor.
    soru = (data.get("tahmin_soru") or "").strip()
    sikler = data.get("tahmin_secenekler")
    try:
        dogru_sira = int(data.get("tahmin_dogru"))
    except (TypeError, ValueError):
        dogru_sira = -1

    gecerli = (
        bool(soru)
        and len(soru) <= 90
        and isinstance(sikler, list)
        and len(sikler) == 3
        and all(isinstance(s, str) and s.strip() for s in sikler)
        and 0 <= dogru_sira < 3
        and sikler[dogru_sira].strip() == big_stat
        # Şıklar birbirinden farklı olmalı; aynı iki şık soruyu anlamsız
        # kılıyor ve modelin arada yaptığı bir hata.
        and len({s.strip() for s in sikler}) == 3
    )
    if gecerli:
        data["tahmin_soru"] = soru
        data["tahmin_secenekler"] = [s.strip() for s in sikler]
        data["tahmin_dogru"] = dogru_sira
    else:
        if soru:
            print("    · tahmin şıkları geçersiz, soru atlandı")
        data["tahmin_soru"] = ""
        data["tahmin_secenekler"] = []
        data["tahmin_dogru"] = -1

    # Kategori listeye oturmuyorsa serbest metne izin vermek yerine yedeğe
    # düşüyoruz; gruplamanın çalışması buna bağlı.
    raw_category = (data.get("group_title") or "").strip().casefold()
    category = FALLBACK_CATEGORY
    for tr, en in CATEGORIES:
        if raw_category == tr.casefold():
            category = (tr, en)
            break
    data["group_title"], data["group_title_en"] = category

    return data


# ── Boru hattı ───────────────────────────────────────────────────────────────

def run_story_pipeline():
    print("=== TARIM HİKAYELERİ (STORY PIPELINE) BAŞLATILDI ===")
    supabase, model = build_clients()

    now = utcnow()

    active = (
        supabase.from_("portal_stories")
        .select("id")
        .gt("expires_at", now.isoformat())
        .execute()
    )
    active_count = len(active.data or [])
    print(f"Yayındaki hikaye sayısı: {active_count} (Limit: {StoryRules.MAX_ACTIVE})")

    if active_count >= StoryRules.MAX_ACTIVE:
        print("Hikaye kapasitesi dolu. İşlem sonlandırılıyor.")
        return

    window_start = now - timedelta(hours=StoryRules.ARTICLE_WINDOW_HOURS)
    articles_resp = (
        supabase.from_("articles")
        .select("id, title, content, image_url, is_breaking")
        .eq("status", "published")
        .not_.is_("image_url", "null")
        .gt("created_at", window_start.isoformat())
        .order("is_breaking", desc=True)
        .order("created_at", desc=True)
        .limit(StoryRules.ARTICLE_SCAN_LIMIT)
        .execute()
    )
    articles = articles_resp.data or []

    dedupe_start = now - timedelta(days=StoryRules.DEDUPE_WINDOW_DAYS)
    recent_stories = (
        supabase.from_("portal_stories")
        .select("article_id")
        .gt("created_at", dedupe_start.isoformat())
        .execute()
    )
    already_used = {row["article_id"] for row in (recent_stories.data or [])}

    # Günlük tavan (T8). Gün sınırı Türkiye saatiyle: hat sabah 07:45'te
    # çalışıyor ve UTC gün sınırı o yığını ikiye bölerdi.
    gun_basi = (now + timedelta(hours=3)).replace(
        hour=0, minute=0, second=0, microsecond=0
    ) - timedelta(hours=3)
    bugunku = (
        supabase.from_("portal_stories")
        .select("id, group_title")
        .gt("created_at", gun_basi.isoformat())
        .execute()
    ).data or []
    print(
        f"Bugün eklenen: {len(bugunku)} "
        f"(günlük tavan: {StoryRules.GUNLUK_EN_FAZLA})"
    )
    if len(bugunku) >= StoryRules.GUNLUK_EN_FAZLA:
        print("Günlük tavana ulaşıldı. İşlem sonlandırılıyor.")
        return

    # Kademeli ömür, konudaki SIRAYA bakıyor; bugün o konudan kaç hikâye
    # çıktığını saymazsak her çalıştırma sayacı sıfırlar ve kademe oluşmaz.
    konu_sayaci = {}
    for satir in bugunku:
        ad = satir.get("group_title") or ""
        konu_sayaci[ad] = konu_sayaci.get(ad, 0) + 1

    added = 0
    for article in articles:
        if active_count + added >= StoryRules.MAX_ACTIVE:
            print(f"Limit {StoryRules.MAX_ACTIVE}'a ulaşıldı.")
            break
        if added >= StoryRules.CALISMA_BASINA:
            print(f"Çalıştırma tavanı ({StoryRules.CALISMA_BASINA}) doldu.")
            break
        if len(bugunku) + added >= StoryRules.GUNLUK_EN_FAZLA:
            print(f"Günlük tavan ({StoryRules.GUNLUK_EN_FAZLA}) doldu.")
            break

        image_url = (article.get("image_url") or "").strip()
        if len(image_url) < 6:
            continue
        if article["id"] in already_used:
            continue

        print(f"\nDeğerlendiriliyor: {article['title']}")

        width = read_image_width(image_url)
        if width is not None and width < StoryRules.MIN_IMAGE_WIDTH:
            print(f" -> görsel {width}px, tam ekranda bulanık kalır. Atlanıyor.")
            continue

        story = generate_story_for_article(model, article)
        if not story:
            print(" -> Yeterli veri bulunamadı, story üretilmedi.")
            continue

        is_breaking = bool(article.get("is_breaking"))
        kategori = story.get("group_title", "")
        ttl = _omur(kategori, konu_sayaci, is_breaking)
        konu_sayaci[kategori] = konu_sayaci.get(kategori, 0) + 1
        expires = now + timedelta(hours=ttl)

        items = [{
            "super_title": story.get("super_title", ""),
            "super_title_en": story.get("super_title_en", ""),
            "headline": story.get("headline", ""),
            "headline_en": story.get("headline_en", ""),
            "big_stat_value": story.get("big_stat_value", ""),
            "big_stat_value_en": story.get("big_stat_value_en", ""),
            "stat_label": story.get("stat_label", ""),
            "stat_label_en": story.get("stat_label_en", ""),
            # Avatar başlığının İngilizcesi burada saklanıyor.
            "group_title_en": story.get("group_title_en", ""),
            # Tahmin slaytı — boşsa istemci soruyu hiç çizmiyor.
            "tahmin_soru": story.get("tahmin_soru", ""),
            "tahmin_secenekler": story.get("tahmin_secenekler", []),
            "tahmin_dogru": story.get("tahmin_dogru", -1),
        }]

        supabase.from_("portal_stories").insert({
            "article_id": article["id"],
            "group_title": story.get("group_title", ""),
            "is_breaking": is_breaking,
            "items": items,
            "expires_at": expires.isoformat(),
        }).execute()

        print(
            f" -> [{story.get('group_title')}] {story.get('big_stat_value')}"
            f" — {story.get('stat_label')} (güç {story.get('guc')}, {ttl} saat)"
        )
        added += 1

    print(f"\n=== TAMAMLANDI. Üretilen yeni hikaye: {added} ===")


if __name__ == "__main__":
    run_story_pipeline()
