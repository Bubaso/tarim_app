# Mısır devri — BEKLİYOR

Kullanıcı onayı alındı (23 Kasım 2026): *"önizleme uygun, sıradaki ülke
Hindistan olsun. bizim ülke sıralaması listesinden de teyit et doğruluğunu.
yayına almak için gerekli işlemleri yap."*

Liste karşılaştırıldı — **§2.11'de Hindistan yok** ve yedinci sıra döngü
gereği bir Model olmak zorunda (Mısır altıncı, rol Rakip). Kullanıcı aynı
gün listeye sadık kalmayı seçti: **"Yakında" kartı Danimarka'ya dönüyor.**

Devir göçü `migrations/` altına KONMADI, burada bekliyor: ilgisiz bir
sebeple atılan tek bir `supabase db push` dosyayı onaysız yayına sokardı.

## Sıra — DÜZELTİLDİ 23 Kasım 2026

İlk plan yanlıştı: seed'in elle uygulanacağı varsayılmıştı ve devir göçü
birinci sağlamasında durdu —

```
ERROR: Mısır bölüm sayısı 0, 18 olmalı — seed uygulanmamış olabilir (SQLSTATE P0001)
```

Bekçi doğru çalıştı, hiçbir şeye dokunulmadı. Sebep: `supabase db push`
yalnız `migrations/` altını uyguluyor, `seed/` klasörünü değil. Kurum
dosyalarında bu sorun yoktu çünkü TİGEM'in içeriği zaten bir göçtü.

**İçerik de göç oldu.** Damgası devirden önce:

| # | dosya | ne yapar |
|---|---|---|
| 1 | `20261123110000_misir_icerik_draft.sql` | içerik **draft** iner, anon anahtarıyla görünmez |
| 2 | `20261123120000_dosya_devri_misir.sql` | Mısır yayına, Irak arşive, kart Danimarka'ya |

CLI göçleri dosya adına göre sıralıyor, yani **tek komut ikisini sırayla**
uygular:

```bash
cd ~/Developer/tarim_app && supabase db push
```

Sonrası:

| # | adım | kim |
|---|---|---|
| 3 | `yayin.json` veritabanıyla eşitlenir (misir→published, irak→archived) | ben |
| 4 | `./deploy.sh --hosting` — og kabuğu ve şerit | onayınızla |
| 5 | `scripts/dosya_hikayeleri.py` — ana sayfa hikâyesi | ben |

### Seed'in dış işlem sınırı çıkarıldı

Seed dosyası tek başına çalıştırılmak için yazıldığından kendi `begin;` ve
`commit;`'ini taşıyor. Göç olarak koşarken CLI zaten her göçü tek işlemde
çalıştırıyor; içteki `commit` işlemi **erken kapatır** ve sonraki sağlamalar
başarısız olsa bile içerik yazılmış kalırdı. Göç kopyasından çıkarıldı,
özgün `supabase/seed/dossier_misir.sql` dokunulmadan duruyor.

**Sonraki ülke dosyasında:** `seed_dossier.mjs` çıktısı doğrudan göç olarak
kullanılamaz; dış `begin;`/`commit;` çıkarılmalı ve damga devir göçünden
önce olmalı.

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
