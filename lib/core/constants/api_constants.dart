class ApiConstants {
  // Supabase URL ve Anon Key.
  // Production build için --dart-define ile override edilebilir:
  //   flutter build apk \
  //     --dart-define=SUPABASE_URL=https://xxx.supabase.co \
  //     --dart-define=SUPABASE_ANON_KEY=eyJ...
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://xkwcyavcltrweunvooeu.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inhrd2N5YXZjbHRyd2V1bnZvb2V1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODEzNDk4NTIsImV4cCI6MjA5NjkyNTg1Mn0.j6miEKZCNQ2XJ_jx8eRLKMs-g_KSBBbigHsrWAgjxS4',
  );

  // GEMINI ANAHTARI BURADAN KALDIRILDI (15 Kasım 2026).
  //
  // Anahtar `defaultValue` olarak duruyordu ve Flutter web bütün uygulamayı
  // tek dosyada derlediği için `tarimportali.net/main.dart.js` içinde,
  // giriş yapmayan herkese açık geliyordu. Kullanıcı anahtarı Google
  // tarafında iptal etti; tek kullanıcısı olan "Yayın Kurulu Önerileri"
  // özelliği de kaldırıldı.
  //
  // Uygulamanın içinden yapay zekâ çağrısı gerekirse anahtar BURAYA DEĞİL
  // bir Cloud Function'a konur: tarayıcıya giden her şey okunabilir.

  static const String unsplashApiKey = String.fromEnvironment(
    'UNSPLASH_API_KEY',
    defaultValue: 'YOUR_UNSPLASH_ACCESS_KEY',
  );
}

