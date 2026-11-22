import Link from 'next/link';
import { mesajEroareDb } from '@/lib/db';
import { listeazaExponate } from '@/lib/exponate';

export const dynamic = 'force-dynamic';

function formateazaAn(an) {
  if (an === null || an === undefined) return '—';
  return an < 0 ? `${-an} î.Hr.` : String(an);
}

export default async function PaginaExponate({ searchParams }) {
  const { adaugat } = await searchParams;

  let exponate = [];
  let eroare = null;
  try {
    exponate = await listeazaExponate();
  } catch (err) {
    console.error(err);
    eroare = mesajEroareDb(err);
  }

  return (
    <>
      <div className="titlu-pagina">
        <h1>Exponate</h1>
        <Link href="/exponate/nou" className="buton">+ Adaugă exponat</Link>
      </div>

      {adaugat && <div className="alerta succes">Exponatul {adaugat} a fost adăugat.</div>}
      {eroare && <div className="alerta eroare">{eroare}</div>}

      {!eroare && (
        <>
          <p className="subtitlu">{exponate.length} exponate în catalog</p>
          <div className="tabel-scroll">
            <table>
              <thead>
                <tr>
                  <th>Cod</th>
                  <th>Titlu</th>
                  <th>Autor</th>
                  <th>An</th>
                  <th>Categorie</th>
                  <th>Epocă</th>
                  <th className="num">Imagini</th>
                  <th className="num">Audio</th>
                </tr>
              </thead>
              <tbody>
                {exponate.map((e) => (
                  <tr key={e.id_exponat} className={e.cod_inventar === adaugat ? 'nou' : undefined}>
                    <td className="cod">{e.cod_inventar}</td>
                    <td>{e.titlu}</td>
                    <td>{e.autor ?? '—'}</td>
                    <td>{formateazaAn(e.an_creare)}</td>
                    <td>{e.categorie}</td>
                    <td>{e.epoca}</td>
                    <td className="num">{e.nr_imagini}</td>
                    <td className="num">{e.nr_audio}</td>
                  </tr>
                ))}
                {exponate.length === 0 && (
                  <tr><td colSpan={8} className="gol">Nu există exponate.</td></tr>
                )}
              </tbody>
            </table>
          </div>
        </>
      )}
    </>
  );
}
