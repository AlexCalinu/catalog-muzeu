'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';

function formateazaAn(an) {
  return an < 0 ? `${-an} î.Hr.` : String(an);
}

export default function FormularExponat({ categorii, epoci }) {
  const router = useRouter();
  const [erori, setErori] = useState({});
  const [mesaj, setMesaj] = useState(null);
  const [seTrimite, setSeTrimite] = useState(false);

  async function trimite(ev) {
    ev.preventDefault();
    setSeTrimite(true);
    setMesaj(null);
    setErori({});

    const date = Object.fromEntries(new FormData(ev.currentTarget));
    try {
      const res = await fetch('/api/exponate', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(date),
      });
      const raspuns = await res.json();
      if (!res.ok) {
        setMesaj(raspuns.eroare || 'Exponatul nu a putut fi salvat.');
        setErori(raspuns.erori || {});
        return;
      }
      router.push(`/exponate?adaugat=${encodeURIComponent(raspuns.cod_inventar)}`);
      router.refresh();
    } catch {
      setMesaj('Serverul nu răspunde. Încearcă din nou.');
    } finally {
      setSeTrimite(false);
    }
  }

  const camp = (nume) => (erori[nume] ? <span className="eroare-camp">{erori[nume]}</span> : null);

  return (
    <form className="formular" onSubmit={trimite} noValidate>
      {mesaj && <div className="alerta eroare">{mesaj}</div>}

      <div className="rand">
        <label>
          Cod inventar *
          <input name="cod_inventar" maxLength={20} placeholder="MN-0043" required />
          {camp('cod_inventar')}
        </label>
        <label>
          An creare
          <input name="an_creare" type="number" min={-50000} max={2100} placeholder="ex: 1890 sau -200" />
          {camp('an_creare')}
        </label>
      </div>

      <label>
        Titlu *
        <input name="titlu" maxLength={200} required />
        {camp('titlu')}
      </label>

      <label>
        Descriere
        <textarea name="descriere" rows={4} />
      </label>

      <div className="rand">
        <label>
          Categorie *
          <select name="id_categorie" defaultValue="" required>
            <option value="" disabled>— alege —</option>
            {categorii.map((c) => (
              <option key={c.id_categorie} value={c.id_categorie}>{c.denumire}</option>
            ))}
          </select>
          {camp('id_categorie')}
        </label>
        <label>
          Epocă *
          <select name="id_epoca" defaultValue="" required>
            <option value="" disabled>— alege —</option>
            {epoci.map((e) => (
              <option key={e.id_epoca} value={e.id_epoca}>
                {e.denumire} ({formateazaAn(e.an_inceput)} – {formateazaAn(e.an_sfarsit)})
              </option>
            ))}
          </select>
          {camp('id_epoca')}
        </label>
      </div>

      <label>
        Autor
        <input name="autor" maxLength={150} />
        {camp('autor')}
      </label>

      <div className="rand">
        <label>
          Material
          <input name="material" maxLength={150} />
          {camp('material')}
        </label>
        <label>
          Dimensiuni
          <input name="dimensiuni" maxLength={100} placeholder="ex: 40 × 60 cm" />
          {camp('dimensiuni')}
        </label>
      </div>

      <div className="actiuni">
        <button type="submit" className="buton" disabled={seTrimite}>
          {seTrimite ? 'Se salvează…' : 'Salvează exponatul'}
        </button>
      </div>
    </form>
  );
}
