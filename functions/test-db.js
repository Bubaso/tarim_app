import { SUPABASE_URL, SUPABASE_ANON_KEY } from './config.js';

async function check() {
  const res = await fetch(`${SUPABASE_URL}/rest/v1/articles?status=eq.published&is_breaking=is.true&select=id,title,created_at&order=created_at.desc&limit=5`, {
    headers: {
      apikey: SUPABASE_ANON_KEY,
      Authorization: `Bearer ${SUPABASE_ANON_KEY}`,
      Accept: 'application/json',
    },
  });
  console.log(await res.json());
}
check();
