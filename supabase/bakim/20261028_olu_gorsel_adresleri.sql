-- TEK SEFERLİK BAKIM — MIGRATION DEĞİL.
--
-- supabase/migrations/ altına KONMADI: sabit haber id'leri taşıyor ve
-- yalnızca bu veritabanının 28 Ekim 2026'daki durumuna ait. Migration
-- olsaydı depoyu kuran herkeste çalışır ve hiçbir şey yapmazdı
-- (CLAUDE.md §4.1). Elle çalıştırılır: Supabase SQL editörü.
--
--
-- Bu haberlerin image_url / story_image_url alanları Storage'da KARŞILIĞI
-- OLMAYAN bir dosyaya işaret ediyor. Adres dolu olduğu için uygulama
-- "görsel var" sayıyor ve kartta BOŞ KUTU çiziyor (CLAUDE.md §26.6).
-- NULL'a çekilince NewsCard.gorselsiz düzeni devreye giriyor ve kart
-- düzgün görünüyor. Metne dokunulmuyor.
--
-- Önce kaç satır etkileneceğini gör:
--   select count(*) from public.articles where id in (...);

begin;

update public.articles set image_url = null
 where id in (
  '07de71ba-ea5c-4492-9fcf-b19076814e9b',
  '10b1fe91-4ad0-4719-8f7f-97946ead5a54',
  '1f5f1076-4f50-4126-9485-e509c755dcc2',
  '209bbc63-2ad5-4c49-b0a9-2495dc8a2595',
  '2241ac1d-0c37-4b7a-b739-93a90ce3c8e6',
  '281985d0-f503-4cc2-bbfb-bc59beb85751',
  '29cf275f-80fb-4002-8a16-68647e90afd6',
  '4405bd80-0d18-44ac-bf97-6b80a86c0bcd',
  '4a954cf5-77fb-4f7e-a614-265bc6460cfb',
  '523e6245-965a-47c7-ae2a-9d92673deae3',
  '580c3120-1dda-479f-893a-57eb573d9881',
  '58c54b58-cff9-4ece-891c-fdf6d51c0726',
  '5ae85e36-8d68-4291-bae6-7a21af6990b4',
  '68a959c1-fc35-41fb-81d9-02855656858d',
  '6bbf3985-2d22-4fb9-a0ed-e275d5d054d1',
  '6ca7e560-bc09-4d75-83fa-1300f360a71d',
  '6d6daea2-3aa3-4e3e-a574-c4dfebb63ea9',
  'b0cb7a18-ca8c-4229-a7a0-edb32875914b',
  'b273ef8c-b653-4335-ba50-e16488a168bc',
  'bb56da4b-c79a-4e31-ba75-27515c46fa10',
  'd63ef055-b5b7-405e-8bca-02e60203ba08',
  'e5e1ad82-5e10-4907-9b92-632ac86cc464',
  'ec48c8e6-2ca5-42d8-a780-1fdc93b2c415',
  'eed302db-4c52-42b5-88eb-770b23a9f72b',
  'f12303d6-49dd-4838-be1d-75af348ced49',
  'ffbacce4-cbd0-40b7-8a4d-f59102db09ae'
 );

update public.articles set story_image_url = null
 where id in (
  '06f7f822-ba4b-40e3-9b18-c116ffa5f98c',
  '07de71ba-ea5c-4492-9fcf-b19076814e9b',
  '1757fd62-27ed-4ccc-bb29-043e0ec4f75f',
  '1ed904d3-a889-43d0-9cd0-1b159e4e91f7',
  '1f5f1076-4f50-4126-9485-e509c755dcc2',
  '4405bd80-0d18-44ac-bf97-6b80a86c0bcd',
  '4a954cf5-77fb-4f7e-a614-265bc6460cfb',
  '523e6245-965a-47c7-ae2a-9d92673deae3',
  '580c3120-1dda-479f-893a-57eb573d9881',
  '58c54b58-cff9-4ece-891c-fdf6d51c0726',
  '68a959c1-fc35-41fb-81d9-02855656858d',
  '6ca7e560-bc09-4d75-83fa-1300f360a71d',
  '8cd1645e-78ae-48be-bb37-a3921541b687',
  '98049ccf-0e92-46bf-bb1d-01bbb4d821ee',
  '99b978ff-0054-4dc8-a8ef-fd8fc0410b10',
  '9a0e77d9-8520-414b-8647-f82fee6d7add',
  'a2e38cdd-32c2-45b9-9735-cda738930e1e',
  'bd90a87e-deb7-45e1-8c98-d541e057fb67',
  'd27571d1-3831-426d-8f30-802dbe898957',
  'd4a7606d-9fc6-4ade-9623-2081c2377bc8',
  'd63ef055-b5b7-405e-8bca-02e60203ba08',
  'd78f055e-e673-43c7-9c34-7ddfcf3aefd6',
  'ddaf22bc-578d-4caf-85c2-3255eb4f2eb9',
  'eb64776d-3748-4cb1-8d09-7722f343c670',
  'f12303d6-49dd-4838-be1d-75af348ced49',
  'f5d6765b-bf90-4fab-a4b8-5dac65561fdc'
 );

commit;
