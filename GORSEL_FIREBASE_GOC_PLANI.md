# Görselleri Supabase Storage'dan Firebase'e Taşıma Planı

**Durum:** Kısıtlama kalkınca uygulanacak. Yazıldığı tarih: 10 Kasım 2026.
**Amaç:** Supabase kotasını patlatan şeyi kaynağından çıkarmak. Veritabanı
Postgres'te kalıyor; RLS kuralları, tetikleyiciler, panel girişi ve 17 tablonun
hiçbirine dokunulmuyor.

---

## 0. Ölçülen mevcut durum

| Ne | Değer |
|---|---|
| Firebase projesi | `tarim-app-2026` (zaten Blaze — fonksiyonlar orada çalışıyor) |
| Supabase kovaları | `article-images` (public, asıl yük), `article-audios` (public, m4a sesler) |
| Mevcut adres kalıbı | `https://xkwcyavcltrweunvooeu.supabase.co/storage/v1/object/public/article-images/<dosya>` |
| Dosya adları | Kaynağın karmasını taşıyor → **içerik adresli, değişmez** |
| Python yükleme noktası | `image_storage.upload_bytes()` (tek boğaz), + `thumbnail_generator.py` 2 yer, + `yazar_sesi.py` 1 yer |
| Dart yükleme noktası | `storage_service.dart` → `editor_uploads/` (panelden elle görsel), tek çağıran |
| SSR fonksiyonları | `safeImageUrl()` yalnızca protokol bakıyor, **alan adı beyaz listesi yok** → kod değişikliği gerekmiyor |

### Taşımayı kolaylaştıran tek gerçek
Dosya adları içerik karması olduğu için **yol aynı kalabilir**. Yani veritabanı
onarımı dosya-dosya eşleme tablosu değil, tek bir önek değişimi:

```
.../storage/v1/object/public/article-images/ABC.jpg
→ https://storage.googleapis.com/tarim-app-2026-gorsel/ABC.jpg
```

Bu, göçü idempotent (iki kez çalışsa zarar vermez) ve geri alınabilir yapıyor.

---

## 1. Senden gereken (konsol işleri — 10 dakika)

1. **Firebase konsolu → `tarim-app-2026` → Build → Storage → Get started.**
   Bu, varsayılan kovayı açar. Yeni proje açma, aynı projeyi kullanıyoruz.
2. Görseller için **ayrı bir kova** aç: `tarim-app-2026-gorsel`, konum
   `europe-west1` (fonksiyonlarla aynı bölge — gereksiz bölge arası trafik olmasın).
   Varsayılan kovayı özel bırakıyoruz; herkese açık olan sadece bu olacak.
3. Python hattı için **servis hesabı anahtarı**: Google Cloud konsolu →
   IAM → Service Accounts → yeni hesap → rol **Storage Object Admin** (yalnızca
   bu kovada) → JSON anahtar indir.
   Dosyayı **depo dışına** koy, örn. `~/.gizli/tarim-gcs.json`. Depoya girmesin.
4. Bana ver: proje kimliğini doğrula (`tarim-app-2026`), kova adını ve
   JSON anahtarın yolunu. Anahtarın içeriğini sohbete yazma, yol yeter.

Gerisini ben yapıyorum.

---

## 2. Aşama 0 — CORS kapısı (bu geçmeden hiçbir şeye başlanmaz)

Bu projede görselleri bir kez CORS yüzünden kaybettik. O yüzden ilk iş tek bir
deneme dosyası yükleyip başlıkları gözle görmek.

```bash
# kovayı herkese okunur yap (listelemeye izin VERMEYEN rol)
gcloud storage buckets add-iam-policy-binding gs://tarim-app-2026-gorsel \
  --member=allUsers --role=roles/storage.legacyObjectReader

# CORS: açık görsel olduğu için "*" güvenlik kaybı değil, CanvasKit şartı
printf '[{"origin":["*"],"method":["GET","HEAD"],"responseHeader":["Content-Type","Cache-Control"],"maxAgeSeconds":3600}]' > /tmp/cors.json
gcloud storage buckets update gs://tarim-app-2026-gorsel --cors-file=/tmp/cors.json
```

**Kapı şartı** — şu çıktı görünmeden Aşama 1'e geçilmez:

```bash
curl -sI -H 'Origin: https://tarimportali.net' \
  https://storage.googleapis.com/tarim-app-2026-gorsel/deneme.jpg \
  | grep -iE 'access-control-allow-origin|cache-control|^HTTP'
```

`access-control-allow-origin` satırı yoksa CanvasKit görseli çizemez ve bütün
göç boşa gider. Flutter web'de de bir deneme kartıyla gözle doğrulanacak.

---

## 3. Aşama 1 — Dosyaları kopyala (kullanıcıya hiçbir etkisi yok)

Yeni betik: `~/tarim_ai_pipeline/gorselleri_firebaseye_tasi.py`

- Supabase deposunu **özyinelemeli** gezer — `depo_denetimi.py` içindeki klasör
  farkındalıklı listeleme mantığı aynen kullanılacak (`object/list` özyinelemeli
  değil; klasörler `metadata: null` satır olarak geliyor, bu tuzağa bir kez düştük).
- Her nesneyi indirip GCS'e **aynı yolla** yazar, üzerine şu üst bilgiyi koyar:
  `cache_control = "public, max-age=2592000, immutable"` (Supabase'de de
  `max-age=2592000` vardı, davranış birebir korunuyor).
- `--kuru` (dry-run) ve `--kaldigi-yerden` bayrakları olacak; kesinti olursa
  baştan başlamasın.
- Sonunda **sayım karşılaştırması** yazdırır: Supabase'deki nesne sayısı/bayt =
  GCS'deki. Eşit değilse göç devam etmez.

Bu aşamada iki depo da dolu. Canlıda hiçbir şey değişmiyor, geri dönüş bedeli yok.

---

## 4. Aşama 2 — Yazmaları çevir (yeni haberler Firebase'e gider)

Dokunulacak dosyalar, satırlarıyla:

| Dosya | Yer | İş |
|---|---|---|
| `src/utils/image_storage.py` | `BUCKET` (19), `_ensure_bucket()` (27), `upload_bytes()` (~425-441) | Tek boğaz. REST POST yerine `google-cloud-storage`; dönen adres GCS öneki |
| `src/utils/thumbnail_generator.py` | 85-88, 117-120 | Kendi başına yükleme yapıyor → `upload_bytes()`e yönlendir, kopya kod kalmasın |
| `src/yazar_sesi.py` | 173-176 | Ses `article-audios` → GCS `ses/` klasörü; `audio_url` sütunu |
| `src/scratch_migrate_unsplash.py` | 31-35 | Tek seferlik eski betik, sil |

`upload_bytes()` imzası **değişmiyor** — çağıranlar etkilenmiyor. Fallback uyarısı
(“GÖRSEL DEPOYA ALINAMADI… CORS yüzünden ÇİZİLEMEYEBİLİR”) aynen korunacak,
sessiz başarısızlığa geri dönmeyeceğiz.

Bu aşamadan sonra: **yeni** haberler Firebase'den gelir, **eski** haberler hâlâ
Supabase'den. İkisi birlikte çalışır. Burada durulabilir, acele yok.

---

## 5. Aşama 3 — Eski adresleri veritabanında çevir

Tek SQL göçü olarak: `supabase/migrations/<tarih>_gorseller_firebase.sql`.
Python'la satır satır değil, çünkü:

- `articles_kapak_turevleri` tetikleyicisi `image_url` gerçekten değişince
  `thumb_image_url` / `story_image_url` / `image_lqip`'i **siliyor**. Onarım
  betiklerinde bunu iki aşamalı yazmayla aşıyorduk; toplu göçte doğru yol
  tetikleyiciyi tek işlem boyunca kapatmak.
- `replace()` öneki bulamazsa hiçbir şey yapmaz → göç idempotent.

```sql
ALTER TABLE articles DISABLE TRIGGER articles_kapak_turevleri;

UPDATE articles SET
  image_url       = replace(image_url,       '<eski önek>', '<yeni önek>'),
  thumb_image_url = replace(thumb_image_url, '<eski önek>', '<yeni önek>'),
  story_image_url = replace(story_image_url, '<eski önek>', '<yeni önek>'),
  content         = replace(content,         '<eski önek>', '<yeni önek>'),
  content_en      = replace(content_en,      '<eski önek>', '<yeni önek>'),
  figures         = replace(figures::text,   '<eski önek>', '<yeni önek>')::jsonb,
  audio_url       = replace(audio_url, '<eski ses öneki>', '<yeni ses öneki>')
WHERE image_url LIKE '%<eski önek>%' OR content LIKE '%<eski önek>%' OR ...;

ALTER TABLE articles ENABLE TRIGGER articles_kapak_turevleri;
```

Diğer tablolar aynı göçte: `columnists.avatar_url`, `video_haberleri.gorsel_url`
ve `kucuk_gorsel`, `portal_stories` görsel sütunları.

**Dokunulmayacak:**
- `image_lqip` — bu bir adres değil, gömülü data URI. Değiştirilirse bozulur.
- `country_dossiers`, `dossier_sections`, `dossier_takvim`, `active_country_dossier`
  — dosya tarafı başka bir oturumun alanı. O tablolardaki görsel sütunları
  listelenip **sana bildirilecek**, o oturum kendi göçünü yapsın. Ben dokunmuyorum.

Sonrasında doğrulama: rastgele 10 haberin kapak + kare + gövde görseli
`curl -I` ile 200 + `access-control-allow-origin`, sonra tarayıcıda gözle.

---

## 6. Aşama 4 — Supabase deposunu boşalt

En az **7 gün** bekledikten sonra (CDN önbellekleri ve paylaşılmış WhatsApp
önizlemeleri eski adresi tutuyor olabilir), Supabase'deki `article-images` ve
`article-audios` silinir. Kota o an düşer ve kısıtlama kalıcı olarak biter.

Silmeden önce `depo_denetimi.py --yetim` çalıştırılacak: hiçbir satırın hâlâ
eski adrese bakmadığından emin olmadan silme yok.

---

## 7. Aşama 5 (opsiyonel, sonraya bırakılabilir) — Panelden elle görsel yükleme

Burada gerçek bir pürüz var ve saklamıyorum: panel girişi **Supabase Auth**.
Firebase Storage kuralları Supabase'in kimlik biletini doğrulayamaz. Yani
`storage_service.dart`'ı doğrudan Firebase SDK'sına çevirmek, kovayı herkese
yazılır yapmak anlamına gelir — olmaz.

Doğru çözüm: küçük bir bulut fonksiyonu (`panelGorselYukle`) Supabase biletini
doğrular ve **imzalı yükleme adresi** döner; panel baytları doğrudan GCS'e yazar
(fonksiyondan bayt geçmez, maliyet doğmaz).

Ama bu yol şu an gereksiz: `editor_uploads/` tek çağrı noktasından besleniyor ve
birkaç MB. Aşama 1-4 kotayı zaten çözüyor. O yüzden **panel yüklemesi Supabase'de
kalıyor**; kova neredeyse boş durur. İşe yarar hale geldiğinde yaparız.

---

## 8. Geri dönüş

Her aşama tek başına geri alınabilir:

- Aşama 2 → `upload_bytes()` eski haline döner (git revert), yeni haberler yine Supabase'e.
- Aşama 3 → aynı SQL'in önekleri ters çevrilmiş hâli çalıştırılır. Dosyalar iki
  yerde de durduğu için veri kaybı yok.
- Aşama 4 geri alınamaz — o yüzden 7 gün bekleme ve yetim denetimi şart.

---

## 9. Maliyet

Blaze'in ücretsiz payı: 5 GB depolama, günlük 1 GB indirme, günlük 50 bin
indirme işlemi. Bizim ~1 GB görselimiz depolamada bedava.

Aşıldığında kabaca: depolama GB başına ~0,026 $/ay, indirme GB başına ~0,12 $.
Yani ayda 50 GB görsel trafiği ≈ 6 $. `max-age=2592000` sayesinde tekrar
ziyaretler hiç maliyet doğurmuyor. (Rakamlar uygulama anında güncel fiyat
sayfasından doğrulanacak.)

---

## 10. Kısıtlama hiç kalkmazsa — yedek yol

Aşama 1 Supabase'den **okuma** gerektiriyor. Okuma hiç açılmazsa dosyalar
kurtarılamaz, ama kaybedilmez de: her haberin `source_url`'ü elde ve hattın
görsel katmanı (`image_storage.upload_article_images`) kaynaktan yeniden
üretebiliyor. Kayıp, kaynağı ölmüş haberlerin görselleriyle sınırlı kalır.
Bu yol daha yavaş ve eksik — ilk tercih değil, ama çıkmaz sokak da değil.
