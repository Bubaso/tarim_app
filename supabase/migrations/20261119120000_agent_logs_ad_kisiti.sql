-- agent_logs.agent_name kısıtı — 19 Kasım 2026
--
-- SORUN
-- Hat, her haberi yazdıktan sonra işletme kaydını `agent_logs`'a "hat" adıyla
-- yazıyor. `agent_logs_agent_name_check` bu adı kabul etmiyordu ve her kayıt
-- şu hatayla düşüyordu:
--
--   new row for relation "agent_logs" violates check constraint
--   "agent_logs_agent_name_check"  (code 23514)
--
-- Hata hattın kendi try bloğunda yakalanıp "(günlük yazılamadı: ...)" diye
-- basılıyor, haberi etkilemiyor. Bu yüzden aylarca fark edilmedi: tabloda
-- yalnızca eski `analyst` ve `chief` kayıtları var, hattın kendi koşuları
-- hakkında TEK SATIR yok.
--
-- 19 Kasım 2026'da ağ kesintisi hattı sakat haber üretmeye düşürdü ve sebebi
-- aramak için bakılacak ilk yer bu tabloydu. Tablo boştu; teşhis ancak kaynak
-- sayfaları elle yeniden ölçerek çıkarıldı.
--
-- KARAR: liste değil, boş olmama denetimi.
-- Kısıtı yeni adlarla GENİŞLETMEK aynı tuzağı kurar — bir sonraki ajan
-- eklendiğinde kaydı yine sessizce düşer. `agent_logs` bir teşhis tablosu;
-- uygulama onu hiç okumuyor, hiçbir karar ona bağlı değil. Burada kaybedilen
-- kayıt, yazım hatasından pahalı. O yüzden denetim yalnız "boş olmasın"
-- diyor; adların doğruluğu koddan geliyor (src/main.py, src/agents/chief.py).
alter table public.agent_logs
  drop constraint if exists agent_logs_agent_name_check;

alter table public.agent_logs
  add constraint agent_logs_agent_name_check
  check (agent_name is not null and length(btrim(agent_name)) > 0);

comment on column public.agent_logs.agent_name is
  'Kaydı yazan ajan/bileşen adı. Sabit liste YOK — bkz. 20261119120000.';
