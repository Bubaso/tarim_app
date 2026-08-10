import { SUPABASE_URL, SUPABASE_ANON_KEY } from './config.js';

async function update() {
  const res = await fetch(`${SUPABASE_URL}/rest/v1/articles?id=eq.0abe3843-2229-47b0-8b6b-61fce6f69f85`, {
    method: 'PATCH',
    headers: {
      apikey: SUPABASE_ANON_KEY,
      Authorization: `Bearer ${SUPABASE_ANON_KEY}`,
      'Content-Type': 'application/json',
      Prefer: 'return=representation'
    },
    body: JSON.stringify({
      created_at: new Date().toISOString()
    })
  });
  console.log(await res.json());
}
update();
