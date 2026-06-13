class ApiConstants {
  // Supabase URL ve Anon Key. Çevre değişkenlerinden (environment variables) veya fallback değerlerden beslenir.
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://xkwcyavcltrweunvooeu.supabase.co',
  );
  
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inhrd2N5YXZjbHRyd2V1bnZvb2V1Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4MTM0OTg1MiwiZXhwIjoyMDk2OTI1ODUyfQ.e5ioWobQxXBWHejAxPme64bjwrrFJ6U4udzbgbBWxZY',
  );
}

