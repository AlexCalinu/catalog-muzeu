import Link from 'next/link';
import { mesajEroareDb } from '@/lib/db';
import { statisticiGenerale } from '@/lib/exponate';

export const dynamic = 'force-dynamic';

export default async function Acasa() {
  let stat = null;
  let eroare = null;
  try {
    stat = await statisticiGenerale();
  } catch (err) {
    console.error(err);
    eroare = mesajEroareDb(err);
  }

  return (
    <>
      <h1>Catalog digital al muzeului</h1>
      <p className="subtitlu">
        Exponate cu imagini și audio-ghid, organizate pe categorii, epoci și expoziții.
      </p>

      {eroare && <div className="alerta eroare">{eroare}</div>}

      {stat && (
        <div className="cifre">
          <div><strong>{stat.exponate}</strong><span>exponate</span></div>
          <div><strong>{stat.categorii}</strong><span>categorii</span></div>
          <div><strong>{stat.audio_ghiduri}</strong><span>audio-ghiduri</span></div>
          <div><strong>{stat.expozitii_active}</strong><span>expoziții active</span></div>
        </div>
      )}

      <div className="actiuni">
        <Link href="/exponate" className="buton">Vezi exponatele</Link>
        <Link href="/exponate/nou" className="buton secundar">Adaugă exponat</Link>
      </div>
    </>
  );
}
