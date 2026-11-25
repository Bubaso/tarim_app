# SALT'tan 91 dosyayı indirme — tarayıcı yöntemi

Ben indiremiyorum: `archives.saltresearch.org` Cloudflare arkasında ve
komut satırından gelen istekler 403 alıyor. **Sizin tarayıcınız o kapıyı
zaten geçmiş durumda**, çünkü siteyi normal şekilde açıyorsunuz. Aşağıdaki
betik tam olarak bunu kullanıyor: sayfanın kendi oturumuyla dosyaları
çekiyor.

> **Önce şunu bilin:** indirmek SALT'ın "bireysel araştırma" kapsamına
> giriyor, sorun değil. **Yayımlamak** için izin mektubu beklenecek
> (bkz. `salt_izin_mektubu_TASLAK.md`). Yani dosyaları şimdi indirip
> izin gelince kullanabiliriz.

---

## Adımlar

**1.** Şu sayfayı açın (hangi SALT sayfası olursa olsun, önemli olan adresin
`archives.saltresearch.org` olması):

```
https://archives.saltresearch.org/handle/123456789/195731
```

**2.** Konsolu açın:
- Mac'te Chrome/Edge: **⌥⌘J**
- Mac'te Safari: önce Ayarlar → Gelişmiş → "Geliştir menüsünü göster", sonra **⌥⌘C**
- Firefox: **⌥⌘K**

**3.** Aşağıdaki betiğin tamamını kopyalayıp konsola yapıştırın ve Enter'a basın.

**4.** Tarayıcı "Bu site birden çok dosya indirmek istiyor" diye soracak —
**İzin ver** deyin. (Chrome bunu bir kez sorar.)

**5.** Dosyalar normal İndirilenler klasörünüze inecek. Bitince konsol
`BİTTİ — 91 dosya` yazacak.

**6.** Hepsini tek bir klasöre koyup bana o klasörün yolunu söyleyin.

---

## Betik

```javascript
(async () => {
  const kayitlar = {
    "195731": "alpullu_albumu",
    "215423": "etimesgut_kompleksi",
    "97324":  "usak_albumu",
    "117021": "usak_sosyal_tesisler",
    "196846": "pancar_hasadi",
    "196977": "usak_vagondan_aktarma",
    "196978": "usak_makine_dairesi_calisanlar",
    "196979": "usak_makine_dairesi",
    "196860": "etimesgut_fabrika",
    "105027": "turhal_fabrika",
    "116005": "usak_fabrika_1",
    "103306": "usak_fabrika_2",
    "208326": "alpullu_fabrika",
    "236467": "eskisehir_cizim"
  };
  const bekle = ms => new Promise(r => setTimeout(r, ms));
  let n = 0, hata = 0;

  for (const [id, ad] of Object.entries(kayitlar)) {
    const r = await fetch(`/handle/123456789/${id}`, {credentials: 'same-origin'});
    const doc = new DOMParser().parseFromString(await r.text(), 'text/html');
    const yollar = [...new Set(
      Array.from(doc.querySelectorAll('a[href*="/bitstream/"]'))
        .map(a => a.getAttribute('href'))
        .filter(h => !h.includes('?dl='))
    )];
    console.log(`${ad}: ${yollar.length} dosya`);

    for (let i = 0; i < yollar.length; i++) {
      try {
        const res = await fetch(yollar[i], {credentials: 'same-origin'});
        if (!res.ok) throw new Error(res.status);
        const blob = await res.blob();
        const url = URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = `salt_${ad}_${String(i + 1).padStart(3, '0')}.jpg`;
        document.body.appendChild(a);
        a.click();
        a.remove();
        URL.revokeObjectURL(url);
        n++;
      } catch (e) {
        hata++;
        console.warn('atlandı:', yollar[i], String(e));
      }
      await bekle(500);          // siteyi yormamak için
    }
  }
  console.log(`BİTTİ — ${n} dosya` + (hata ? ` · ${hata} atlandı` : ''));
})();
```

Dosya adları `salt_alpullu_albumu_001.jpg` gibi olacak; hangi karenin
hangi kayıttan geldiği adından okunuyor. Künyeleri ben kayıt kodlarından
yazacağım.

---

## Betik çalışmazsa

**Firefox + DownThemAll** eklentisi aynı işi yapar: kayıt sayfasını açın,
sağ tık → DownThemAll → `.jpg` süzgeci. On dört sayfa için on dört kez.

**Ya da elle:** her kayıt sayfasında dosya adlarının yanındaki indirme
bağlantısına tıklayarak. 91 dosya için uzun sürer; en kalabalık ikisi
Alpullu albümü (45) ve Etimesgut dizisi (16).

---

## İndirilecek kayıtlar

| kayıt | kod | dosya |
|---|---|---|
| İstanbul ve Trakya Şeker Fabrikaları T.A.Ş. Alpullu Şeker ve İspirto Fabrikaları (1928-29) | AHTURAL013 | 45 |
| Türkiye Şeker Fabrikası Etimesgut Kompleksi (Ali Mukbil Gökdoğan) | TMGH007 | 16 |
| Uşak Şeker Fabrikası albümü | AHUSA004 | 8 |
| Uşak Şeker Fabrikası Sosyal Tesisleri | AHUSA002 | 4 |
| Şeker pancarı tarlasında hasat yapılırken | AFDIVH215 | 2 |
| Uşak Şeker Fabrikası'nın makine dairesi ve çalışanları | AHUSA007 | 2 |
| Uşak Şeker Fabrikası'nın makine dairesi | AHUSA008 | 2 |
| Etimesgut Şeker Fabrikası | AHANKA191 | 2 |
| Turhal Şeker Fabrikası | AHTOK001 | 2 |
| Uşak Şeker Fabrikası | AHUSA001 | 2 |
| Uşak Şeker Fabrikası | AHUSA003 | 2 |
| Alpullu Şeker Fabrikası | AHKIR008 | 2 |
| Uşak'a gelen şeker pancarları vagonlardan aktarılırken | AHUSA006 | 1 |
| Eskişehir Şeker Fabrikası çizimi | AHESK033 | 1 |
| **toplam** | | **91** |
