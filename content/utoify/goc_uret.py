#!/usr/bin/env python3
"""veri.json → supabase/migrations/20261112190000_sergi.sql

Göç ELLE yazılmıyor: 114 satırı elle yazmak, bir fotoğrafçı adını sessizce
yanlış yazmanın en kolay yolu. Veri değişirse bu betik yeniden koşturulur.
"""
from __future__ import annotations

import json
import pathlib
import sys

KOK = pathlib.Path(__file__).resolve().parent
DEPO = KOK.parent.parent
CIKIS = DEPO / "supabase/migrations/20261112190000_sergi.sql"


def t(s) -> str:
    if s is None or s == "":
        return "null"
    return "'" + str(s).replace("'", "''") + "'"


BAS = """-- Fotoğraf sergisi — anasayfanın altındaki galeri bandı ve kendi sayfası
--
-- İLK İÇERİK: 16. Uluslararası Tarım Orman ve İnsan Fotoğraf Yarışması
-- (UTOİFY 2026). T.C. Tarım ve Orman Bakanlığı Eğitim ve Yayın Dairesi
-- Başkanlığı düzenliyor, DenizBank destekliyor. 114 kare: 14 ödül,
-- 100 sergileme.
--
-- NEDEN İKİ TABLO. Yarışma üst verisi (tema, düzenleyen, kaynak adresleri)
-- yıl başına BİR kez geçerli; 114 satırın her birine kopyalamak, temayı
-- değiştirmek gerektiğinde 114 satırı güncellemek demekti. Sitenin kendi
-- arşivi 2009'a kadar gidiyor (on beş albüm) — bu yapı o yılların da
-- eklenebilmesi için kuruldu.
--
-- KÜNYE ZORUNLU. `fotografci` ve `eser` boş geçilemiyor, `kaynak_adres`
-- yarışma satırında zorunlu. Bir kare künyesiz yayına çıkamıyor; kısıt
-- veritabanında çünkü bir gün paneli kullanan kişi çizicinin varsayımını
-- bilemez.
--
-- SIRA ÖNEMLİ — YARIŞMA `yayinda = false` İLE GİRİYOR.
--
-- Kareler hosting'de (`web/sergi/utoify-16/`). Bu göç önce uygulanıp dağıtım
-- sonra yapılırsa anasayfanın altında 114 KIRIK GÖRSEL çıkar — üstelik
-- hiçbir şey hata vermeden, ki bu portalın en sık yaşadığı arıza biçimi.
--
-- Doğru sıra:
--   1) göç uygulanır        → veri girer, sayfa HÂLÂ görünmez
--   2) derle + dağıt        → kareler hosting'e çıkar
--   3) canlıda doğrulanır   → bir kare açılıyor mu
--   4) yayına alınır:
--        update public.sergi_yarismalari set yayinda = true, guncellendi = now()
--         where kod = 'utoify-16';
--
-- Dördüncü adım AYRI ve bilinçli: yayına alma kararı tek satırda duruyor,
-- geri alması da tek satır.
--
-- TELİF. Kareler fotoğrafçılarının telifinde. Yarışmanın katılım şartları
-- sayfası boş dönüyor ve kamuya açık bir kullanım lisansı bulunamadı.
-- Yayım kararı 12 Kasım 2026'da kullanıcıya ait: sonuçlar kamuya açık bir
-- ilan ve sergi, her kare fotoğrafçı adı, eser adı ve kaynağa bağlantıyla
-- yayımlanıyor. `yayinda` bayrağı tam bu yüzden var: itiraz gelirse tek
-- satırlık bir güncellemeyle kare de, yarışma da sayfadan kalkıyor.

create table if not exists public.sergi_yarismalari (
  kod               text primary key,
  sira              integer not null,
  yil               integer not null,
  ad_tr             text not null,
  ad_en             text not null,
  kisa              text,
  tema_tr           text,
  tema_en           text,
  duzenleyen_tr     text not null,
  duzenleyen_en     text not null,
  destekci          text,
  kaynak_adres      text not null,
  odul_listesi      text,
  sergileme_listesi text,
  yayinda           boolean not null default false,
  guncellendi       timestamptz not null default now()
);

create table if not exists public.sergi_eserleri (
  kod          text primary key,
  yarisma_kod  text not null references public.sergi_yarismalari(kod) on delete cascade,
  tur          text not null,
  kategori     text not null,
  sira         integer not null,
  odul_tr      text not null,
  odul_en      text not null,
  fotografci   text not null,
  eser         text not null,
  il           text,
  ulke_tr      text not null,
  ulke_en      text not null,
  adres        text not null,
  en           integer,
  boy          integer,
  en_boy       numeric(6,4),
  yayinda      boolean not null default true
);

alter table public.sergi_eserleri drop constraint if exists sergi_eserleri_tur;
alter table public.sergi_eserleri add constraint sergi_eserleri_tur
  check (tur in ('odul', 'sergileme'));

-- Künye boş geçilemez. Trim edilmiş hâli de boş olmamalı: " " künye değil.
alter table public.sergi_eserleri drop constraint if exists sergi_eserleri_kunye;
alter table public.sergi_eserleri add constraint sergi_eserleri_kunye
  check (length(btrim(fotografci)) > 0 and length(btrim(eser)) > 0
         and length(btrim(adres)) > 0);

create index if not exists sergi_eserleri_yarisma_sira
  on public.sergi_eserleri (yarisma_kod, sira);
create index if not exists sergi_eserleri_il
  on public.sergi_eserleri (il) where il is not null;

alter table public.sergi_yarismalari enable row level security;
alter table public.sergi_eserleri enable row level security;

drop policy if exists "anon yayindaki yarismalari okur" on public.sergi_yarismalari;
create policy "anon yayindaki yarismalari okur"
  on public.sergi_yarismalari for select to anon using (yayinda);

drop policy if exists "authenticated tum yarismalari okur" on public.sergi_yarismalari;
create policy "authenticated tum yarismalari okur"
  on public.sergi_yarismalari for select to authenticated using (true);

-- Eser, yarışması yayında DEĞİLSE görünmüyor. İki bayrağı ayrı tutup yalnız
-- esere bakmak, yayından kaldırılan bir yarışmanın karelerinin ortada
-- kalmasına yol açardı — hem de sessizce.
drop policy if exists "anon yayindaki eserleri okur" on public.sergi_eserleri;
create policy "anon yayindaki eserleri okur"
  on public.sergi_eserleri for select to anon using (
    yayinda and exists (
      select 1 from public.sergi_yarismalari y
       where y.kod = sergi_eserleri.yarisma_kod and y.yayinda));

drop policy if exists "authenticated tum eserleri okur" on public.sergi_eserleri;
create policy "authenticated tum eserleri okur"
  on public.sergi_eserleri for select to authenticated using (true);

comment on table public.sergi_yarismalari is
  'Fotoğraf yarışmaları. Bir satır = bir yıl. Kareler sergi_eserleri''nde.';
comment on column public.sergi_eserleri.yayinda is
  'Tek kareyi sayfadan kaldırmak için. Telif itirazının cevabı bu bayrak.';
"""


def main() -> int:
    v = json.loads((KOK / "veri.json").read_text(encoding="utf-8"))
    y = v["yarisma"]
    s = [BAS, "\n-- ─── Yarışma ────────────────────────────────────────────────────────────\n"]
    s.append(
        "insert into public.sergi_yarismalari (kod, sira, yil, ad_tr, ad_en, kisa,\n"
        "  tema_tr, tema_en, duzenleyen_tr, duzenleyen_en, destekci,\n"
        "  kaynak_adres, odul_listesi, sergileme_listesi, yayinda)\n"
        "values (%s, %d, %d, %s, %s, %s,\n        %s, %s,\n        %s,\n        %s,\n"
        "        %s, %s,\n        %s,\n        %s, false)\n"
        "on conflict (kod) do update set\n"
        "  tema_tr = excluded.tema_tr, tema_en = excluded.tema_en,\n"
        "  kaynak_adres = excluded.kaynak_adres, guncellendi = now();\n"
        % (t(y["kod"]), y["sira"], y["yil"], t(y["ad_tr"]), t(y["ad_en"]),
           t(y["kisa"]), t(y["tema_tr"]), t(y["tema_en"]),
           t(y["duzenleyen_tr"]), t(y["duzenleyen_en"]), t(y["destekci"]),
           t(y["kaynak_adres"]), t(y["odul_listesi"]), t(y["sergileme_listesi"])))

    s.append("\n-- ─── 114 eser ───────────────────────────────────────────────────────────\n")
    s.append("insert into public.sergi_eserleri (kod, yarisma_kod, tur, kategori,\n"
             "  sira, odul_tr, odul_en, fotografci, eser, il, ulke_tr, ulke_en,\n"
             "  adres, en, boy, en_boy) values\n")
    satirlar = []
    for e in v["eserler"]:
        satirlar.append(
            "(%s, %s, %s, %s, %d, %s, %s, %s, %s, %s, %s, %s, %s, %d, %d, %s)"
            % (t(e["kod"]), t(y["kod"]), t(e["tur"]), t(e["kategori"]),
               e["sira"], t(e["odul_tr"]), t(e["odul_en"]),
               t(e["fotografci"]), t(e["eser"]), t(e["il"]),
               t(e["ulke_tr"]), t(e["ulke_en"]), t(e["adres"]),
               e["en"], e["boy"], e["en_boy"]))
    s.append(",\n".join(satirlar))
    s.append("\non conflict (kod) do update set\n"
             "  fotografci = excluded.fotografci, eser = excluded.eser,\n"
             "  il = excluded.il, adres = excluded.adres,\n"
             "  odul_tr = excluded.odul_tr, odul_en = excluded.odul_en;\n")

    s.append("""
-- ─── Anasayfa bandının günlük seçimi ─────────────────────────────────────
-- Band 114 kareyi gösteremez; on iki tane gösteriyor. Hangi on iki?
--
-- İlk akla gelen "ilk on iki" idi ve yanlış: band aylarca aynı kalır, geri
-- kalan 102 kare hiç görünmez. Rastgele seçim de yanlış: aynı gün sayfayı
-- iki kez açan okur iki farklı sergi görür, kaydırıp geri dönünce kare
-- kaybolur.
--
-- Seçim GÜNE göre belirlenimli: md5(kod || tarih). Aynı gün herkese aynı on
-- iki kare, ertesi gün başka on iki. Sunucuda, çünkü istemcide yapılsaydı
-- cihazın saat dilimi seçimi değiştirirdi.
create or replace function public.sergi_gunun_secimi(
  p_yarisma text default null, p_adet int default 12)
returns setof public.sergi_eserleri
language sql stable security definer set search_path = public as $$
  select e.* from public.sergi_eserleri e
    join public.sergi_yarismalari y on y.kod = e.yarisma_kod
   where e.yayinda and y.yayinda
     and (p_yarisma is null or e.yarisma_kod = p_yarisma)
   order by md5(e.kod || current_date::text)
   limit greatest(p_adet, 0);
$$;

comment on function public.sergi_gunun_secimi is
  'Anasayfa bandının günlük karesi. Gün başına belirlenimli: aynı gün herkese '
  'aynı seçim, ertesi gün başkası.';

grant execute on function public.sergi_gunun_secimi(text, int) to anon, authenticated;

-- ─── Kendi kendini sınama ────────────────────────────────────────────────
do $kontrol$
declare n int;
begin
  select count(*) into n from public.sergi_eserleri where yarisma_kod = 'utoify-16';
  if n <> 114 then
    raise exception '114 eser bekleniyordu, % bulundu', n;
  end if;
  select count(*) into n from public.sergi_eserleri
   where yarisma_kod = 'utoify-16' and tur = 'odul';
  if n <> 14 then
    raise exception '14 ödül bekleniyordu, % bulundu', n;
  end if;
  -- Künye kısıtı GERÇEKTEN reddediyor mu? Reddetmiyorsa künyesiz kare
  -- sızabilir ve bunu hiçbir şey hata vermeden yapar.
  begin
    insert into public.sergi_eserleri (kod, yarisma_kod, tur, kategori, sira,
      odul_tr, odul_en, fotografci, eser, ulke_tr, ulke_en, adres)
    values ('__deneme__', 'utoify-16', 'odul', 'genel', 999, 'x', 'x',
            '   ', 'x', 'Türkiye', 'Türkiye', 'x');
    raise exception 'künye kısıtı çalışmıyor — boş fotoğrafçı adı kabul edildi';
  exception when check_violation then null;
  end;
  if exists (select 1 from public.sergi_eserleri where kod = '__deneme__') then
    delete from public.sergi_eserleri where kod = '__deneme__';
    raise exception 'deneme satırı yazıldı';
  end if;
  -- Günlük seçim gerçekten on iki kare veriyor mu?
  --
  -- Fonksiyon `yayinda` süzüyor ve yarışma bilerek yayında DEĞİL (bkz.
  -- başlıktaki sıra notu). Sınama için geçici olarak açılıp kapatılıyor:
  -- "yayında değil, o yüzden sınamadım" demek, fonksiyonun bozuk olduğunu
  -- yayına alındığı gün öğrenmek demekti.
  update public.sergi_yarismalari set yayinda = true where kod = 'utoify-16';
  select count(*) into n from public.sergi_gunun_secimi('utoify-16', 12);
  update public.sergi_yarismalari set yayinda = false where kod = 'utoify-16';
  if n <> 12 then
    raise exception 'günlük seçim 12 kare vermedi: %', n;
  end if;

  -- Ve yayında DEĞİLKEN hiçbir şey dönmemeli: bayrak gerçekten kapatıyor mu?
  select count(*) into n from public.sergi_gunun_secimi('utoify-16', 12);
  if n <> 0 then
    raise exception 'yayinda=false iken % kare döndü — bayrak çalışmıyor', n;
  end if;
end
$kontrol$;
""")
    CIKIS.write_text("".join(s), encoding="utf-8")
    kb = CIKIS.stat().st_size / 1024
    print("✓ %s (%.1f KB, %d eser)" % (CIKIS.relative_to(DEPO), kb, len(v["eserler"])))
    return 0


if __name__ == "__main__":
    sys.exit(main())
