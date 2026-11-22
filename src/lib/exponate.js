import { query } from './db';

/**
 * Lista exponatelor, cu denumirea categoriei si a epocii (JOIN)
 * si numarul de imagini / audio-ghiduri asociate (agregare).
 */
export async function listeazaExponate() {
  const { rows } = await query(`
    SELECT  e.id_exponat,
            e.cod_inventar,
            e.titlu,
            e.autor,
            e.an_creare,
            c.denumire AS categorie,
            ep.denumire AS epoca,
            COUNT(m.id_media) FILTER (WHERE m.tip = 'imagine') AS nr_imagini,
            COUNT(m.id_media) FILTER (WHERE m.tip = 'audio')   AS nr_audio
    FROM    exponate e
    JOIN    categorii c  ON c.id_categorie = e.id_categorie
    JOIN    epoci     ep ON ep.id_epoca    = e.id_epoca
    LEFT JOIN fisiere_media m ON m.id_exponat = e.id_exponat
    GROUP BY e.id_exponat, c.denumire, ep.denumire
    ORDER BY e.cod_inventar
  `);
  return rows;
}

export async function listeazaCategorii() {
  const { rows } = await query(
    'SELECT id_categorie, denumire FROM categorii ORDER BY denumire'
  );
  return rows;
}

export async function listeazaEpoci() {
  const { rows } = await query(
    'SELECT id_epoca, denumire, an_inceput, an_sfarsit FROM epoci ORDER BY an_inceput'
  );
  return rows;
}

/** Cifre pentru pagina principala; foloseste si view-ul v_expozitii_active. */
export async function statisticiGenerale() {
  const { rows } = await query(`
    SELECT (SELECT COUNT(*) FROM exponate)                               AS exponate,
           (SELECT COUNT(*) FROM categorii)                              AS categorii,
           (SELECT COUNT(*) FROM fisiere_media WHERE tip = 'audio')      AS audio_ghiduri,
           (SELECT COUNT(*) FROM v_expozitii_active)                     AS expozitii_active
  `);
  return rows[0];
}

/**
 * Valideaza datele primite din formular. Intoarce { date, erori }.
 * Constrangerile din baza de date raman ultima linie de aparare.
 */
export function valideazaExponat(input) {
  const erori = {};
  const text = (v) => (typeof v === 'string' ? v.trim() : '');
  const optional = (v) => text(v) || null;

  const date = {
    cod_inventar: text(input.cod_inventar).toUpperCase(),
    titlu: text(input.titlu),
    descriere: optional(input.descriere),
    autor: optional(input.autor),
    an_creare: text(String(input.an_creare ?? '')) === '' ? null : Number(input.an_creare),
    material: optional(input.material),
    dimensiuni: optional(input.dimensiuni),
    id_categorie: Number(input.id_categorie),
    id_epoca: Number(input.id_epoca),
  };

  if (!date.cod_inventar) erori.cod_inventar = 'Codul de inventar este obligatoriu.';
  else if (date.cod_inventar.length > 20) erori.cod_inventar = 'Maxim 20 de caractere.';

  if (!date.titlu) erori.titlu = 'Titlul este obligatoriu.';
  else if (date.titlu.length > 200) erori.titlu = 'Maxim 200 de caractere.';

  if (date.autor && date.autor.length > 150) erori.autor = 'Maxim 150 de caractere.';
  if (date.material && date.material.length > 150) erori.material = 'Maxim 150 de caractere.';
  if (date.dimensiuni && date.dimensiuni.length > 100) erori.dimensiuni = 'Maxim 100 de caractere.';

  if (date.an_creare !== null &&
      (!Number.isInteger(date.an_creare) || date.an_creare < -50000 || date.an_creare > 2100)) {
    erori.an_creare = 'Anul trebuie să fie un număr întreg între -50000 și 2100 (negativ = î.Hr.).';
  }

  if (!Number.isInteger(date.id_categorie) || date.id_categorie <= 0) erori.id_categorie = 'Alege o categorie.';
  if (!Number.isInteger(date.id_epoca) || date.id_epoca <= 0) erori.id_epoca = 'Alege o epocă.';

  return { date, erori };
}

/** Insereaza un exponat (interogare parametrizata) si intoarce randul creat. */
export async function adaugaExponat(d) {
  const { rows } = await query(
    `INSERT INTO exponate (cod_inventar, titlu, descriere, autor, an_creare,
                           material, dimensiuni, id_categorie, id_epoca)
     VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
     RETURNING id_exponat, cod_inventar, titlu`,
    [d.cod_inventar, d.titlu, d.descriere, d.autor, d.an_creare,
     d.material, d.dimensiuni, d.id_categorie, d.id_epoca]
  );
  return rows[0];
}
