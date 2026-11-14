#!/usr/bin/env python3
"""Ax-3'ün 13 deneyi → ax3.json

KAYNAK: TÜBA · "Türk Astronot Alper Gezeravcı'nın Uzayda Yapacağı 13
Bilimsel Deney" (.docx, tuba.gov.tr). BİRİNCİL — resmî deney listesi.
Misyon adları, kurumlar ve proje yöneticileri belgenin kendi yazımıyla.

SINIFLANDIRMA ELLE YAPILDI, ANAHTAR KELİMEYLE DEĞİL. İlk deneme otomatik
eşleştirmeydi ve GÜVENİLMEZ çıktı: alaşım (UYNA) ile akışkan dinamiği
(gMETAL) deneylerini "biyolojik" işaretledi, PRANET'i ise biçimi farklı
olduğu için hiç görmedi. Her deneyin sınıfı aşağıda GEREKÇESİYLE yazılı;
sınır durumlar ayrıca işaretli.
"""
from __future__ import annotations
import json, pathlib, datetime

KOK = pathlib.Path(__file__).parent

D = [
 (1,"UYNA","Uzay İçin Yeni Nesil Alaşımlar","TÜBİTAK MAM","Ömür Can Odabaş",
  "malzeme","Yüksek entropili alaşımların ergime ve katılaşması."),
 (2,"gMETAL","Katı Fazdaki Parçacıkların Bir Akışkan İçindeki Dinamiğine Yerçekimsiz Ortam Etkisi",
  "TÜBİTAK MAM","Prof. Dr. İskender Gökalp / Prof. Dr. Ahmet Yozgatlıgil",
  "fizik","İtki sistemleri için katı-akışkan karışımı."),
 (3,"UzMAn","Uzay Görevleri için Mikroalgal Yaşam Destek Üniteleri",
  "Boğaziçi Üniversitesi","Dr. Öğr. Üyesi Berat Haznedaroğlu","BİTKİ_ALG",
  "Mikroalglerin yerçekimsiz ortamda büyümesi, CO₂ yakalama ve O₂ üretim "
  "kabiliyeti; TÜBİTAK MAM ile yaşam destek sistemi."),
 (4,"EXTREMOPHYTE","Ekstrem Halofit olan Schrenkiella Parvula'nın Tuz Stresine Verdiği Yanıtların Uzay Ortamında Araştırılması",
  "Ege Üniversitesi","Prof. Dr. İsmail Türkan","BİTKİ",
  "A. thaliana ve S. parvula'da RNA-seq ile transkriptom; glikofit ile "
  "halofitin tuz stresi yanıtlarının mikroyerçekiminde karşılaştırılması."),
 (5,"METABOLOM","Astronotların Metabolom/Transkriptomlarındaki Değişimlerin Analizi",
  "Ankara Üniversitesi","Prof. Dr. Emel Emregül","insan","İnsan omik verisi."),
 (6,"MİYELOİD","Radyasyonun Miyeloid-Kökenli Baskılayıcı Hücrelere Etkisi",
  "Hacettepe Üniversitesi","Prof. Dr. Güneş Esendağlı","insan","İnsan bağışıklık hücreleri."),
 (7,"MESSAGE","Mikroyerçekimi İlişkili Genetik Bilim Misyonu",
  "Üsküdar Üniversitesi","Dr. Öğr. Üyesi Cihan Taştan","insan",
  "Bağışıklık hücrelerinde CRISPR ile gen taraması. CRISPR geçiyor ama "
  "konu İNSAN hücresi, bitki değil."),
 (8,"ALGALSPACE","Uzay Koşullarında Antarktika ve Ilıman Mikroalg Yetiştiriciliğinin Karşılaştırmalı Bir Çalışması",
  "Yıldız Teknik Üniversitesi","Prof. Dr. Didem Özçimen","BİTKİ_ALG",
  "Kutup ve ılıman bölge mikroalglerinin uzayda büyüme karşılaştırması; "
  "CO₂'den O₂ rejenerasyonu, ek gıda, su iyileştirme. Belgeye göre "
  "literatürde İLK KEZ kutup alglerinin uzayda kullanımı."),
 (9,"CRISPR-GEM","Mikro Yerçekimi Altında Bitkilerde CRISPR Gen Düzenleme Verimliliğinin Araştırılması",
  "Yıldız Teknik Üniversitesi","Tuğçe Celayir","BİTKİ",
  "Biyorejeneratif yaşam destek sistemlerinin iskeleti olan bitkilerde "
  "CRISPR etkinliği."),
 (10,"PRANET","Propolisin Antibakteriyel Etkisi","Muş Bilim ve Sanat Merkezi",
  "Birsen Geçer","SINIR_TARIMSAL_URUN",
  "Propolisin mikroyerçekiminde bakteriler üzerindeki etkisi. Propolis arı "
  "ürünü — tarımsal ürün sayılır ama deney BİTKİ YETİŞTİRME değil, "
  "antibakteriyel etki. Bitki/alg sayısına KATILMADI."),
 (11,"VOKALKORD","Vokal Kord Kaynaklı Değişimlerle Hayati Tepkimelerin Tespiti",
  "Haliç Üniversitesi","Prof. Dr. Gökhan Aydemir","insan","İnsan sesi."),
 (12,"OKSİJEN SATURASYONU","Verilen Havanın Oksijen Seviyesiyle Rahatsızlıkların Tanımlanması",
  "Nişantaşı Üniversitesi","Oğuzhan Aydemir","insan","İnsan solunumu."),
 (13,"MİYOKA","Mikro Yerçekimi Ortamında Kurşunsuz Lehimleme Araştırması",
  "TÜBİTAK UZAY","Hakan Asan","mühendislik","Elektronik kart montajı."),
]

deneyler = [{"no": n, "kisa_ad": k, "misyon_adi": m, "kurum": ku,
             "proje_yoneticisi": py, "sinif": s, "gerekce": g}
            for n, k, m, ku, py, s, g in D]
bitki = [d for d in deneyler if d["sinif"].startswith("BİTKİ")]
sinir = [d for d in deneyler if d["sinif"].startswith("SINIR")]

d = {
    "_kaynak": ("TÜBA · 'Türk Astronot Alper Gezeravcı'nın Uzayda Yapacağı 13 "
                "Bilimsel Deney' · tuba.gov.tr"),
    "_nitelik": "BİRİNCİL — resmî deney listesi",
    "_belge": "kaynak_dosyalari/tuba_13deney.docx",
    "_gorev": {"ad": "Axiom Mission 3 (Ax-3)", "firlatis": "19 Ocak 2024",
               "sure_gun": 14, "yer": "Uluslararası Uzay İstasyonu",
               "astronot": "Alper Gezeravcı"},
    "_secim_sureci": ("Deneyler için çağrı yayımlandı; gelen başvurular TUA "
                      "ve TÜBİTAK UZAY uzmanlarından oluşan bir komisyonca "
                      "değerlendirildi."),
    "_SINIFLANDIRMA_NOTU": (
        "ELLE yapıldı. Otomatik anahtar kelime eşleştirmesi denendi ve "
        "güvenilmez çıktı: alaşım ve akışkan dinamiği deneylerini "
        "'biyolojik' işaretledi, PRANET'i biçimi farklı olduğu için hiç "
        "görmedi. Her sınıf gerekçesiyle yazılı."),
    "toplam": len(deneyler),
    "bitki_alg_sayisi": len(bitki),
    "sinir_durum": [s["kisa_ad"] for s in sinir],
    "_ORAN": (f"On üç deneyin {len(bitki)}'ü bitki ya da mikroalg. "
              f"Propolis (PRANET) tarımsal bir ürün ama deney yetiştirme "
              f"değil antibakteriyel etki ölçümü; sayıya KATILMADI. "
              f"Katılırsa {len(bitki)+len(sinir)} olur."),
    "_IKI_ALG_NOTU": ("Dördün İKİSİ mikroalg ve ikisi de YAŞAM DESTEK "
                      "amaçlı — CO₂'den O₂ üretimi, su iyileştirme, ek gıda. "
                      "Bu, ESA'nın MELiSSA'sı ve Çin'in Lunar Palace'ı ile "
                      "aynı soruna çalışıyor: kapalı döngü."),
    "deneyler": deneyler,
}
(KOK / "ax3.json").write_text(json.dumps(d, ensure_ascii=False, indent=1) + "\n",
                              encoding="utf-8")
print(f"✓ ax3.json · {len(deneyler)} deney · bitki/alg {len(bitki)} · sınır {len(sinir)}")
for b in bitki:
    print(f"   {b['no']:>2}. {b['kisa_ad']:14s} {b['kurum']}")
