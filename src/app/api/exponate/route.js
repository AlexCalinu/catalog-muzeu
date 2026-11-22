import { NextResponse } from 'next/server';
import { mesajEroareDb } from '@/lib/db';
import { adaugaExponat, listeazaExponate, valideazaExponat } from '@/lib/exponate';

// GET /api/exponate - lista exponatelor in format JSON
export async function GET() {
  try {
    const exponate = await listeazaExponate();
    return NextResponse.json(exponate);
  } catch (err) {
    console.error('GET /api/exponate', err);
    return NextResponse.json({ eroare: mesajEroareDb(err) }, { status: 500 });
  }
}

// POST /api/exponate - adauga un exponat nou
export async function POST(request) {
  let body;
  try {
    body = await request.json();
  } catch {
    return NextResponse.json({ eroare: 'Cererea nu conține date JSON valide.' }, { status: 400 });
  }

  const { date, erori } = valideazaExponat(body ?? {});
  if (Object.keys(erori).length > 0) {
    return NextResponse.json({ eroare: 'Verifică datele introduse.', erori }, { status: 400 });
  }

  try {
    const exponat = await adaugaExponat(date);
    return NextResponse.json(exponat, { status: 201 });
  } catch (err) {
    console.error('POST /api/exponate', err);
    const status = err?.code?.startsWith?.('23') ? 409 : 500;
    const raspuns = { eroare: mesajEroareDb(err) };
    if (err?.code === '23505') raspuns.erori = { cod_inventar: 'Acest cod de inventar există deja.' };
    return NextResponse.json(raspuns, { status });
  }
}
