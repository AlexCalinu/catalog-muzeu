# Catalog digital pentru muzeu

Aplicație web pentru catalogul unui muzeu, cu imagini și audio-ghid pentru fiecare exponat.
Proiect pentru disciplina **Baze de date**.

- **SGBD:** PostgreSQL
- **Aplicație:** Next.js (App Router) + `pg` (node-postgres), fără ORM. Toate interogările sunt scrise în SQL și sunt parametrizate.

> **Stadiu: etapa 1 (prima corectură).** Momentan există baza de date completă (schemă și date de test) și aplicația de bază, cu listarea și adăugarea exponatelor. Restul funcționalităților vin în etapele următoare (vezi [Plan](#plan)).

---

## Structura proiectului

```
catalog-muzeu/
├── db/
│   ├── schema.sql            # tabele, constrângeri, indecși, view
│   └── seed.sql              # date de test
├── public/uploads/
│   ├── imagini/              # aici se salvează imaginile (pe disc)
│   └── audio/                # aici se salvează audio-ghidurile (pe disc)
├── src/
│   ├── lib/
│   │   ├── db.js             # conexiunea la PostgreSQL și mesajele de eroare
│   │   └── exponate.js       # interogările SQL și validarea datelor
│   └── app/
│       ├── page.js                       # pagina principală
│       ├── exponate/page.js              # lista exponatelor
│       ├── exponate/nou/                 # formularul de adăugare
│       └── api/exponate/route.js         # API: GET (listă), POST (adăugare)
├── .env.example              # model pentru fișierul .env
└── package.json
```

## Baza de date

| Tabel | Rol |
|---|---|
| `categorii` | categoriile exponatelor (pictură, ceramică, numismatică, …) |
| `epoci` | perioadele istorice, cu an de început și de sfârșit (anii negativi înseamnă î.Hr.) |
| `exponate` | exponatele; FK către `categorii` și `epoci` |
| `fisiere_media` | imagini și audio-ghiduri. **Fișierul stă pe disc**; în DB se salvează doar metadatele și calea |
| `expozitii` | expozițiile, fiecare cu o perioadă de desfășurare |
| `expozitii_exponate` | legătura N:M dintre expoziții și exponate, cu ordinea de afișare |
| `vizualizari` | vizualizările exponatelor, folosite pentru statistici |

**Constrângeri folosite:** `PRIMARY KEY` (inclusiv cheie compusă), `FOREIGN KEY` (cu `ON DELETE RESTRICT` / `CASCADE`), `NOT NULL`, `UNIQUE` (inclusiv indecși unici parțiali, de ex. un singur audio-ghid per exponat și limbă) și `CHECK` (de ex. perioada unei expoziții, tipul fișierului media, sursa unei vizualizări).

**View:** `v_expozitii_active` conține expozițiile active la data curentă, cu numărul de exponate și zilele rămase.

**Date de test:** 8 categorii, 8 epoci, 42 de exponate, 100 de fișiere media, 7 expoziții, 40 de legături expoziție–exponat și ~700 de vizualizări. Datele expozițiilor sunt calculate relativ la ziua curentă, așa că view-ul returnează mereu rezultate.

> În datele de test, înregistrările din `fisiere_media` conțin doar metadate. Fișierele propriu-zise vor fi adăugate odată cu funcția de upload.

---

## Instalare și rulare (Windows)

### 1. Instalează PostgreSQL

1. Descarcă installerul de pe <https://www.postgresql.org/download/windows/> (installerul EDB).
2. Rulează installerul cu opțiunile implicite: port `5432`, utilizator `postgres`. **Notează parola** aleasă pentru utilizatorul `postgres`.
3. Adaugă folderul `bin` în variabila de sistem `PATH`, de exemplu `C:\Program Files\PostgreSQL\18\bin` (înlocuiește `18` cu versiunea instalată).
4. Deschide un terminal nou și verifică instalarea:

   ```powershell
   psql --version
   ```

### 2. Instalează Node.js

Ai nevoie de Node.js 20.9 sau mai nou: <https://nodejs.org>. Verifică instalarea cu `node --version`.

### 3. Clonează proiectul

```powershell
git clone https://github.com/AlexCalinu/catalog-muzeu.git
cd catalog-muzeu
```

### 4. Creează baza de date

```powershell
psql -U postgres -c "CREATE DATABASE catalog_muzeu ENCODING 'UTF8' TEMPLATE template0;"
```

### 5. Rulează schema și datele de test

```powershell
psql -U postgres -d catalog_muzeu -f db/schema.sql
psql -U postgres -d catalog_muzeu -f db/seed.sql
```

La final, `seed.sql` afișează numărul de înregistrări din fiecare tabel. Ambele scripturi pot fi rulate din nou oricând: `schema.sql` recreează tabelele, iar `seed.sql` golește tabelele și reîncarcă datele.

Verificare rapidă a view-ului:

```powershell
psql -U postgres -d catalog_muzeu -c "SELECT titlu, sala, nr_exponate FROM v_expozitii_active;"
```

### 6. Configurează fișierul `.env`

```powershell
copy .env.example .env
```

Deschide `.env` și completează parola utilizatorului `postgres`:

```env
PGHOST=localhost
PGPORT=5432
PGDATABASE=catalog_muzeu
PGUSER=postgres
PGPASSWORD=parola_ta
```

Fișierul `.env` este în `.gitignore`, deci nu ajunge pe GitHub.

### 7. Pornește aplicația

```powershell
npm install
npm run dev
```

Aplicația pornește la <http://localhost:3000>.

Pentru varianta de producție: `npm run build`, apoi `npm start`.

---

## Funcționalități

### Etapa 1 (implementat)

- Listarea exponatelor (`/exponate`), cu interogare JOIN pe categorii și epoci și agregare pe numărul de imagini și audio-ghiduri
- Adăugarea unui exponat (`/exponate/nou`), cu validare în aplicație și în baza de date
- Pagina principală, cu cifre generale (inclusiv numărul de expoziții active, calculat din view)
- API REST: `GET /api/exponate`, `POST /api/exponate`
- Interogări parametrizate (`$1, $2, …`) și tratarea erorilor: codurile PostgreSQL (`23505` valoare duplicată, `23503` FK, `23514` CHECK, eroare de conexiune) sunt afișate ca mesaje clare

### Plan

- [ ] CRUD complet pentru exponate (editare, ștergere), categorii, epoci și expoziții
- [ ] Upload de imagini și audio-ghiduri (salvate pe disc, cu metadatele în `fisiere_media`)
- [ ] Căutare după categorie, epocă și cuvânt cheie
- [ ] Expoziții cu perioadă de desfășurare; pagina expozițiilor active (din `v_expozitii_active`)
- [ ] Mod vizitator, cu redarea audio-ghidului și înregistrarea vizualizărilor
- [ ] Statistici: cele mai vizualizate exponate, vizualizări pe categorii și pe epoci

## Probleme frecvente

| Problemă | Soluție |
|---|---|
| `psql` nu este recunoscut | Folderul `bin` al PostgreSQL nu este în `PATH` (pasul 1.3). Deschide un terminal nou după ce îl adaugi. |
| `password authentication failed` | Parola din `.env` (sau cea introdusă la `psql`) nu este corectă. |
| `database "catalog_muzeu" does not exist` | Rulează pasul 4. |
| Aplicația afișează „Nu se poate realiza conexiunea la baza de date” | Verifică dacă serviciul `postgresql-x64-…` rulează (din `services.msc`) și dacă valorile din `.env` sunt corecte. |
