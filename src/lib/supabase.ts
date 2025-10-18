import { createClient } from '@supabase/supabase-js';

// Environment-Variablen für Supabase
const supabaseUrl = import.meta.env.PUBLIC_SUPABASE_URL;
const supabaseKey = import.meta.env.PUBLIC_SUPABASE_ANON_KEY;

if (!supabaseUrl || !supabaseKey) {
  throw new Error('Supabase URL und Anon Key müssen in .env gesetzt sein');
}

export const supabase = createClient(supabaseUrl, supabaseKey);
