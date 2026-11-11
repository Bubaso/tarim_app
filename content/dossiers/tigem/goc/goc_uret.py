#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""İçerik göçünü ÜRETİR — seed her değiştiğinde göç elle yamanmaz.

NEDEN VAR. Göç dosyası üç parçadan oluşuyor: başlık yorumu, üretilmiş seed,
sağlama bloğu. 11 Kasım'da bu üçü elle birleştirilmişti ve 12 Kasım'da seed
iki kez değişti (anahtar kelime çıkarıldı, on dört altyazı yeniden yazıldı).
Elle birleştirme her değişiklikte göçün seed'inin bayatlaması riskini
taşıyor — DSİ'de tam olarak bu oldu ve on bölüm başlığı canlıya ### ile gitti.

AYRICA BİR HATAYI DÜZELTİYOR. Elle birleştirilen sürümde seed'in kendi
`begin;`/`commit;` çifti duruyordu ve sağlama bloğu `commit;`ten SONRA
geliyordu. Yani "biri bile tutmazsa göç geri alınır" yazısı DOĞRU DEĞİLDİ:
içerik çoktan işlenmiş olurdu, sağlamanın patlaması hiçbir şeyi geri
almazdı. CLAUDE.md §4.1 zaten "seed migration'a taşınırken içteki
begin;/commit; çıkarılır" diyor; başlık yorumu bunu yaptığını söylüyordu ama
dosyada yapılmamıştı. Bu betik çıkarıyor — CLI her göçü tek işlemde
çalıştırdığı için sağlama artık aynı işlemin içinde ve geri alabiliyor.

Kullanım:  python3 content/dossiers/tigem/goc/goc_uret.py
"""
import io
import re
import sys
from pathlib import Path

BURADA = Path(__file__).resolve().parent
KOK = BURADA.parents[3]
HEDEF = KOK / "supabase/migrations/20261111090000_tigem_icerik_draft.sql"
SEED = KOK / "supabase/seed/dossier_tigem.sql"

baslik = io.open(BURADA / "baslik_icerik.sql", encoding="utf-8").read().rstrip()
seed = io.open(SEED, encoding="utf-8").read()
saglama = io.open(BURADA / "saglama_icerik.sql", encoding="utf-8").read().rstrip()

# İçteki işlem sınırlarını çıkar (§4.1). Satır başındakiler aranıyor: seed
# gövdesinde 'commit' sözcüğü başka bir bağlamda geçerse dokunulmasın.
once = len(re.findall(r"(?m)^(begin|commit);\s*$", seed))
seed = re.sub(r"(?m)^(begin|commit);\s*\n", "", seed)
if once != 2:
    print(f"✗ Seed'de beklenen 2 işlem satırı yerine {once} bulundu — "
          f"seed_dossier.mjs değişmiş olabilir, elle bakın.", file=sys.stderr)
    sys.exit(1)

cikti = f"{baslik}\n{seed.strip()}\n\n{saglama}\n"
io.open(HEDEF, "w", encoding="utf-8").write(cikti)

# Üretilen dosyada işlem satırı KALMAMALI.
kalan = re.findall(r"(?m)^(begin|commit);\s*$", cikti)
if kalan:
    print(f"✗ Üretilen göçte hâlâ işlem satırı var: {kalan}", file=sys.stderr)
    sys.exit(1)

sat = cikti.count("\n")
print(f"✓ göç yazıldı → {HEDEF.relative_to(KOK)}")
print(f"  {sat} satır · {len(cikti.encode()) / 1024:.1f} KB · içteki begin/commit çıkarıldı")
print(f"  sağlama bloğu göçün KENDİ işleminin içinde — biri tutmazsa her şey geri alınır")
