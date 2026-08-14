-- Türkşeker kaynak bağlantısını duyurular listesine çeviriyor.
--
-- Detay sayfasındaki "Resmî ilan" düğmesi okuyucuyu fiyatın geldiği belgeye
-- götürmeli. turkseker.gov.tr kök adresi kurumsal ana sayfa: oraya düşen
-- okuyucu fiyat ilanını kendi bulmak zorunda kalıyordu. ModulID=9&MenuID=52
-- ise ayrıştırıcının PDF'leri okuduğu listenin ta kendisi — gösterilen rakamın
-- kaynağı o sayfadaki bir belge.

update public.commodity_sources
set url = 'https://www.turkseker.gov.tr/?ModulID=9&MenuID=52'
where key = 'turkseker';
