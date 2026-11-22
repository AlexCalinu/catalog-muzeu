import { mesajEroareDb } from '@/lib/db';
import { listeazaCategorii, listeazaEpoci } from '@/lib/exponate';
import FormularExponat from './FormularExponat';

export const dynamic = 'force-dynamic';

export default async function PaginaExponatNou() {
  let categorii = [];
  let epoci = [];
  let eroare = null;
  try {
    [categorii, epoci] = await Promise.all([listeazaCategorii(), listeazaEpoci()]);
  } catch (err) {
    console.error(err);
    eroare = mesajEroareDb(err);
  }

  return (
    <>
      <h1>Adaugă exponat</h1>
      {eroare
        ? <div className="alerta eroare">{eroare}</div>
        : <FormularExponat categorii={categorii} epoci={epoci} />}
    </>
  );
}
