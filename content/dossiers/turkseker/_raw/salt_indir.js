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
    const r = await fetch(`/handle/123456789/${id}`, { credentials: 'same-origin' });
    const doc = new DOMParser().parseFromString(await r.text(), 'text/html');
    const yollar = [...new Set(
      Array.from(doc.querySelectorAll('a[href*="/bitstream/"]'))
        .map(a => a.getAttribute('href'))
        .filter(h => !h.includes('?dl='))
    )];
    console.log(`${ad}: ${yollar.length} dosya`);

    for (let i = 0; i < yollar.length; i++) {
      try {
        const res = await fetch(yollar[i], { credentials: 'same-origin' });
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
      await bekle(500);
    }
  }
  console.log(`BİTTİ — ${n} dosya` + (hata ? ` · ${hata} atlandı` : ''));
})();
