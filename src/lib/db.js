import { Pool } from 'pg';

// Datele de conectare vin din fisierul .env (vezi .env.example).
function creeazaPool() {
  return new Pool({
    host: process.env.PGHOST || 'localhost',
    port: Number(process.env.PGPORT || 5432),
    database: process.env.PGDATABASE || 'catalog_muzeu',
    user: process.env.PGUSER || 'postgres',
    password: process.env.PGPASSWORD,
    max: 10,
  });
}

// In modul dev, Next.js reincarca modulele la fiecare modificare;
// pastram pool-ul pe globalThis ca sa nu deschidem conexiuni noi de fiecare data.
const pool = globalThis.__pgPool ?? creeazaPool();
if (process.env.NODE_ENV !== 'production') globalThis.__pgPool = pool;

/**
 * Executa o interogare parametrizata.
 * Valorile se trimit separat ($1, $2, ...), niciodata concatenate in SQL.
 */
export async function query(text, params = []) {
  return pool.query(text, params);
}

/** Transforma erorile PostgreSQL in mesaje usor de inteles pentru utilizator. */
export function mesajEroareDb(err) {
  switch (err?.code) {
    case '23505':
      return 'Există deja o înregistrare cu aceeași valoare unică (ex: cod de inventar).';
    case '23503':
      return 'Categoria sau epoca selectată nu există.';
    case '23514':
      return 'Datele nu respectă o regulă de validare a bazei de date.';
    case '23502':
      return 'Lipsește un câmp obligatoriu.';
    case '22P02':
    case '22003':
      return 'Una dintre valorile numerice nu este validă.';
    case 'ECONNREFUSED':
    case 'ECONNRESET':
    case '28P01':
    case '3D000':
      return 'Nu se poate realiza conexiunea la baza de date. Verifică fișierul .env și dacă serverul PostgreSQL rulează.';
    default:
      return 'A apărut o eroare la accesarea bazei de date.';
  }
}
