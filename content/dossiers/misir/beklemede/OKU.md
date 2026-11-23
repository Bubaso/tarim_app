# Mısır devri — BEKLİYOR

Kullanıcı onayı alındı (23 Kasım 2026): *"önizleme uygun, sıradaki ülke
Hindistan olsun. bizim ülke sıralaması listesinden de teyit et doğruluğunu.
yayına almak için gerekli işlemleri yap."*

Liste karşılaştırıldı — **§2.11'de Hindistan yok** ve yedinci sıra döngü
gereği bir Model olmak zorunda (Mısır altıncı, rol Rakip). Kullanıcı aynı
gün listeye sadık kalmayı seçti: **"Yakında" kartı Danimarka'ya dönüyor.**

Devir göçü `migrations/` altına KONMADI, burada bekliyor: ilgisiz bir
sebeple atılan tek bir `supabase db push` dosyayı onaysız yayına sokardı.

## Sıra — ikisi sizde, hizmet anahtarı hiçbir yerde durmuyor

| # | adım | kim |
|---|---|---|
| 1 | `supabase/seed/dossier_misir.sql` uygulanır — içerik **draft** iner, anon anahtarıyla görünmez | **siz** |
| 2 | `ls supabase/migrations/ \| tail` — damga kontrolü | siz |
| 3 | Devir göçü `migrations/` altına taşınır, `supabase db push` | **siz** |
| 4 | `yayin.json` durumları veritabanıyla eşitlenir (misir→published, irak→archived) | ben |
| 5 | `./deploy.sh --hosting` — og kabuğu ve şerit | onayınızla |
| 6 | `scripts/dosya_hikayeleri.py` — ana sayfa hikâyesi | ben |

```bash
ls supabase/migrations/ | tail
```

```bash
mv content/dossiers/misir/beklemede/20261123120000_dosya_devri_misir.sql supabase/migrations/ && supabase db push
```

## Dört tuzak — dördü de önceki devirlerde yaşandı

**1 · Göç damgası uygulanmış son göçten SONRA olmalı.** CLI eski damgalı bir
göçü **sessizce atlıyor** ve *"Remote database is up to date"* diyor — hata
vermiyor. 23 Kasım'da son göç `20261120090000`; bu damga `20261123120000`.
Taşımadan hemen önce yine bakın.

**2 · Adım 4 atlanamaz.** `deploy.sh` içindeki durum bekçisi depo ile
veritabanını karşılaştırıyor: `yayin.json` "draft" derken veritabanı
"published" diyorsa **dağıtımı durduruyor**. Irak bu yüzden on gün og
etiketlerini kaybetmişti.

**3 · Dağıtım kirli ağaçta durur.** Çalışma ağacındaki her şey Mısır işi
olsa bile `deploy.sh` `git status --porcelain` boş değilse duruyor (19 Kasım,
`b62d524`). Mısır işi adım 0'da commit edildi; dağıtımdan önce ağacın temiz
olduğunu doğrulayın, başka bir oturumun işi varsa **kimin olduğunu sorun,
onun adına commit etmeyin.**

**4 · Görseller izleniyor, stash onlara dokunmuyor.** `web/dosya/misir`
altındaki 18 kare git'te kayıtlı. `git stash -u` yalnız izlenmeyenleri
alıyor, yani dağıtım görselleri silmiyor. (İzlenmeselerdi silerdi.)

## Geri alma

Devir tek işlemde koşuyor; sağlamalardan biri tutmazsa tümden geri alınıyor.
Uygulandıktan sonra geri almak gerekirse: Mısır `draft`'a, Irak `published`'a
ve takvim satırı Mısır'a döner — ama `yayin.json` da aynı turda geri
alınmalı, yoksa bekçi bir sonraki dağıtımı durdurur.
