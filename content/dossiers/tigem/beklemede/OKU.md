# TİGEM devri — YAPILDI, 12 Kasım 2026

Bu klasör artık boş: devir göçü uygulandı ve
`supabase/migrations/20261112140000_dosya_devri_tigem.sql` altına taşındı.
Klasör, bir sonraki dosyanın devri için duruyor.

Kullanıcı onayı: *"TİGEM işin bittiği anda devrolabilir"*, ardından
*"TİGEM'i devredip canlıya almak için her şeyi yap bitir."*

## Uygulanan sıra

| # | adım | sonuç |
|---|---|---|
| 1 | `./deploy.sh --hosting` — görseller | 14/14 `200` + `image/jpeg` |
| 2 | İçerik göçü `20261111090000` (draft) | uygulandı |
| 3 | Devir göçü `20261112140000` | uygulandı, 14 sağlama geçti |
| 4 | `yayin.json` durumları veritabanıyla eşitlendi | tigem→published, dsi→archived |
| 5 | `./deploy.sh --hosting` — **ikinci kez**, og kabuğu için | aşağıya bak |
| 6 | `scripts/dosya_hikayeleri.py` | aşağıya bak |

## Sonraki devirde dikkat — üç tuzak, üçü de bu devirde yaşandı

**1. Göç damgası, uygulanmış son göçten SONRA olmalı.** Devir göçü önce
`20261112120000` damgalıydı; teaser kolonu `20261112130000` zaten
uygulanmıştı. CLI eski damgalı göçü **sessizce atladı** ve *"Remote database
is up to date"* dedi — hata vermedi. `20261112140000` yapılınca geçti.
Devir göçünün damgasını, taşımadan hemen önce `ls supabase/migrations/ | tail`
ile kontrol edin.

**2. Draft satır anon anahtarıyla GÖRÜNMEZ.** İçerik göçünden sonra
`country_dossiers?slug=eq.tigem` boş döndü ve bu bir hata sanıldı; RLS
draft'ı gizliyor. Doğrulamanın yolu devir göçünün kendi ön koşul sağlaması
("15 bölüm var mı") — o geçerse içerik yerindedir.

**3. İkinci dağıtım atlanamaz.** `statik_sayfa.mjs` yalnızca
published/archived için og kabuğu üretiyor; dosya devirden önce draft
olduğu için ilk dağıtımda kabuğu üretilmedi. Hosting dağıtımı genel dizini
değiştirdiğinden, devirden sonra dağıtılmazsa `/kurum/tigem` og
etiketlerini hiç almaz. Irak'ta bu on gün sürdü (§ `durum_bekcisi.mjs`).

## Geri alma

Uygulanmış göç düzenlenmez (§4.1); yeni göç yazılır:

```sql
update public.country_dossiers set status='draft'    where slug='tigem';
update public.country_dossiers set status='published',
       ends_at='2026-11-15T00:00:00Z'                where slug='dsi';
```

ve takvim satırı TİGEM'e döndürülür. `yayin.json` durumları da geri alınır,
yoksa `durum_bekcisi.mjs` sonraki dağıtımı durdurur.
