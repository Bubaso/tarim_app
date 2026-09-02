/// Uygulama karanlık modu KALDIRILDI (kullanıcı kararı, P3).
///
/// `isDark` parametreleri ve `isDark ? koyu : açık` üçlüleri hâlâ kodun
/// içinde; kod olarak silinmeleri ayrı bir tura bırakıldı. O zamana kadar
/// hepsi buradan besleniyor ve **daima `false`** dönüyor — yani uygulama
/// her yerde açık modda.
///
/// Sabit (`const false`) yerine getter olması bilinçli: `const` olsaydı
/// analizör yüzlerce `isDark ? … : …` dalını "ölü kod" diye işaretlerdi.
/// Getter, o gürültüyü engelliyor; temizlik yapılınca bu dosya da silinecek.
bool get appIsDark => false;
