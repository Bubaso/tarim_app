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

  static const String geminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: 'AIzaSyCbxJQ2JUUTY4PjOh_RVaAIzYI0hYvL8_g',
  );
}

