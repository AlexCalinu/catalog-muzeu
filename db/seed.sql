-- =====================================================================
-- Catalog digital pentru muzeu - date de test
-- Rulare (dupa schema.sql):  psql -U postgres -d catalog_muzeu -f db/seed.sql
-- Scriptul poate fi rulat de mai multe ori: goleste tabelele si reincarca.
-- =====================================================================

SET client_encoding = 'UTF8';

BEGIN;

TRUNCATE vizualizari, expozitii_exponate, expozitii, fisiere_media,
         exponate, epoci, categorii
RESTART IDENTITY CASCADE;

-- ---------------------------------------------------------------------
-- CATEGORII (8)
-- ---------------------------------------------------------------------
INSERT INTO categorii (denumire, descriere) VALUES
  ('Pictură',                'Picturi în ulei, tempera, icoane pe lemn și pe sticlă.'),
  ('Sculptură',              'Lucrări în piatră, marmură, bronz și lemn.'),
  ('Ceramică',               'Vase, cahle și obiecte din lut ars.'),
  ('Arheologie',             'Obiecte descoperite în situri arheologice.'),
  ('Numismatică',            'Monede, medalii și bancnote.'),
  ('Textile și port popular','Costume populare, covoare și țesături.'),
  ('Arme și armuri',         'Arme albe, arme de foc și piese de armură.'),
  ('Manuscrise și carte veche','Manuscrise, tipărituri vechi și hărți.');

-- ---------------------------------------------------------------------
-- EPOCI (8)  - anii negativi = î.Hr.
-- ---------------------------------------------------------------------
INSERT INTO epoci (denumire, an_inceput, an_sfarsit, descriere) VALUES
  ('Neolitic',                -6500, -2500, 'Primele comunități agricole și culturile ceramicii pictate.'),
  ('Epoca bronzului',         -2500,  -800, 'Apariția metalurgiei bronzului.'),
  ('Antichitate dacică',       -800,   106, 'Civilizația geto-dacă până la cucerirea romană.'),
  ('Perioada romană',           106,   275, 'Provincia romană Dacia.'),
  ('Evul mediu',                500,  1500, 'Formarea și consolidarea statelor medievale românești.'),
  ('Epoca modernă timpurie',   1500,  1800, 'Secolele XVI–XVIII.'),
  ('Secolul al XIX-lea',       1800,  1899, 'Modernizarea și formarea statului român modern.'),
  ('Secolul al XX-lea',        1900,  1999, 'Arta și cultura secolului trecut.');

-- ---------------------------------------------------------------------
-- EXPONATE (42) - categoria si epoca sunt legate prin denumire
-- ---------------------------------------------------------------------
INSERT INTO exponate (cod_inventar, titlu, descriere, autor, an_creare, material,
                      dimensiuni, id_categorie, id_epoca)
SELECT v.cod, v.titlu, v.descriere, v.autor, v.an, v.material, v.dim,
       c.id_categorie, e.id_epoca
FROM (VALUES
  ('MN-0001','Vas pictat de tip Cucuteni','Vas ceramic cu decor spiralat pictat în roșu, alb și negru.',NULL,-4200,'Lut ars, pigmenți minerali','h 38 cm','Ceramică','Neolitic'),
  ('MN-0002','Statuetă feminină','Figurină antropomorfă stilizată, cu decor incizat.',NULL,-4800,'Lut ars','h 12 cm','Arheologie','Neolitic'),
  ('MN-0003','Topor de piatră șlefuită','Unealtă cu orificiu de înmănușare, foarte bine conservată.',NULL,-5000,'Piatră','14 × 6 cm','Arheologie','Neolitic'),
  ('MN-0004','Castron cu decor incizat','Castron cu motive geometrice umplute cu pastă albă.',NULL,-5200,'Lut ars','Ø 24 cm','Ceramică','Neolitic'),
  ('MN-0005','Sabie de bronz','Sabie cu mâner plin, descoperită într-un depozit de bronzuri.',NULL,-1300,'Bronz','l 62 cm','Arme și armuri','Epoca bronzului'),
  ('MN-0006','Brățară spiralică','Podoabă din sârmă de bronz răsucită în spirală.',NULL,-1500,'Bronz','Ø 7 cm','Arheologie','Epoca bronzului'),
  ('MN-0007','Urnă funerară','Vas folosit pentru depunerea cenușii defunctului.',NULL,-1100,'Lut ars','h 31 cm','Ceramică','Epoca bronzului'),
  ('MN-0008','Tezaur de monede KOSON','Lot de monede de aur cu legenda KOSON.',NULL,-44,'Aur','Ø 2 cm / buc.','Numismatică','Antichitate dacică'),
  ('MN-0009','Sică dacică','Pumnal curbat cu decor ștanțat pe lamă.',NULL,-100,'Fier','l 34 cm','Arme și armuri','Antichitate dacică'),
  ('MN-0010','Brățară dacică spiralată','Brățară cu capete în formă de protome de șarpe.',NULL,-50,'Argint','Ø 8 cm','Arheologie','Antichitate dacică'),
  ('MN-0011','Cană dacică','Cană lucrată cu mâna, cu toartă înaltă.',NULL,-150,'Lut ars','h 18 cm','Ceramică','Antichitate dacică'),
  ('MN-0012','Denar emis de Traian','Monedă de argint cu efigia împăratului.',NULL,112,'Argint','Ø 1,9 cm','Numismatică','Perioada romană'),
  ('MN-0013','Opaiț roman','Lampă cu ulei decorată cu o mască de teatru.',NULL,150,'Lut ars','l 11 cm','Ceramică','Perioada romană'),
  ('MN-0014','Altar votiv','Altar dedicat lui Jupiter de un veteran al legiunii.',NULL,180,'Calcar','h 95 cm','Sculptură','Perioada romană'),
  ('MN-0015','Fibulă romană','Agrafă pentru prinderea mantiei.',NULL,200,'Bronz aurit','l 6 cm','Arheologie','Perioada romană'),
  ('MN-0016','Diplomă militară','Fragment de diplomă acordată unui soldat la lăsarea la vatră.',NULL,123,'Bronz','15 × 12 cm','Arheologie','Perioada romană'),
  ('MN-0017','Bust de magistrat','Portret în marmură al unui magistrat municipal.',NULL,160,'Marmură','h 52 cm','Sculptură','Perioada romană'),
  ('MN-0018','Icoana Maicii Domnului','Icoană pe lemn cu fond aurit.',NULL,1450,'Tempera pe lemn, foiță de aur','64 × 48 cm','Pictură','Evul mediu'),
  ('MN-0019','Ducat de argint','Monedă emisă în Țara Românească.',NULL,1400,'Argint','Ø 1,7 cm','Numismatică','Evul mediu'),
  ('MN-0020','Spadă medievală','Spadă cu gardă dreaptă și mâner pentru o mână.',NULL,1350,'Oțel','l 98 cm','Arme și armuri','Evul mediu'),
  ('MN-0021','Tetraevanghel','Manuscris pe pergament cu miniaturi și inițiale ornate.',NULL,1480,'Pergament, cerneală','32 × 23 cm','Manuscrise și carte veche','Evul mediu'),
  ('MN-0022','Cahlă cu cavaler','Cahlă de sobă cu reprezentarea unui cavaler călare.',NULL,1490,'Lut ars smălțuit','20 × 20 cm','Ceramică','Evul mediu'),
  ('MN-0023','Coif medieval','Coif conic din fier forjat.',NULL,1420,'Fier','h 26 cm','Arme și armuri','Evul mediu'),
  ('MN-0024','Carte de învățătură','Tipăritură în limba română cu xilogravuri.',NULL,1643,'Hârtie, piele','30 × 20 cm','Manuscrise și carte veche','Epoca modernă timpurie'),
  ('MN-0025','Icoană pe sticlă','Icoană țărănească pictată pe sticlă, Transilvania.',NULL,1780,'Pictură pe sticlă','42 × 33 cm','Pictură','Epoca modernă timpurie'),
  ('MN-0026','Pistol cu cremene','Pistol de cavalerie cu patul încrustat cu os.',NULL,1760,'Oțel, lemn, os','l 48 cm','Arme și armuri','Epoca modernă timpurie'),
  ('MN-0027','Taler cu leu','Monedă de argint olandeză, larg circulată în Principate.',NULL,1650,'Argint','Ø 4 cm','Numismatică','Epoca modernă timpurie'),
  ('MN-0028','Scoarță oltenească','Covor țesut în război cu motivul pomului vieții.',NULL,1790,'Lână','210 × 140 cm','Textile și port popular','Epoca modernă timpurie'),
  ('MN-0029','Car cu boi','Scenă rurală pictată în plein-air.','Nicolae Grigorescu',1899,'Ulei pe pânză','48 × 72 cm','Pictură','Secolul al XIX-lea'),
  ('MN-0030','Portret de țărancă','Portret în costum popular.','Theodor Aman',1870,'Ulei pe pânză','60 × 45 cm','Pictură','Secolul al XIX-lea'),
  ('MN-0031','Ie cu altiță','Cămașă femeiască brodată cu fir negru și roșu.',NULL,1880,'Pânză de in, bumbac','l 75 cm','Textile și port popular','Secolul al XIX-lea'),
  ('MN-0032','Ulcior de Horezu','Ulcior smălțuit cu motivul cocoșului.',NULL,1890,'Lut ars smălțuit','h 28 cm','Ceramică','Secolul al XIX-lea'),
  ('MN-0033','Monedă de 5 lei Carol I','Monedă de argint din primele emisiuni ale Regatului.',NULL,1881,'Argint','Ø 3,7 cm','Numismatică','Secolul al XIX-lea'),
  ('MN-0034','Harta Principatelor','Hartă litografiată a Moldovei și Țării Românești.',NULL,1856,'Hârtie, litografie','58 × 80 cm','Manuscrise și carte veche','Secolul al XIX-lea'),
  ('MN-0035','Anemone','Natură statică cu flori într-o vază.','Ștefan Luchian',1908,'Ulei pe carton','55 × 45 cm','Pictură','Secolul al XX-lea'),
  ('MN-0036','Cap de copil','Portret sculptat cu suprafață finisată.',NULL,1925,'Bronz','h 30 cm','Sculptură','Secolul al XX-lea'),
  ('MN-0037','Peisaj de iarnă','Sat de munte acoperit de zăpadă.',NULL,1935,'Ulei pe pânză','70 × 90 cm','Pictură','Secolul al XX-lea'),
  ('MN-0038','Costum popular din Maramureș','Costum bărbătesc complet de sărbătoare.',NULL,1930,'Lână, in, piele','—','Textile și port popular','Secolul al XX-lea'),
  ('MN-0039','Vază modernistă','Vază cu forme geometrice și glazură mată.',NULL,1965,'Gresie ceramică','h 40 cm','Ceramică','Secolul al XX-lea'),
  ('MN-0040','Abecedar ilustrat','Manual școlar cu ilustrații color.',NULL,1920,'Hârtie','24 × 17 cm','Manuscrise și carte veche','Secolul al XX-lea'),
  ('MN-0041','Bustul unui poet','Bust comemorativ realizat pentru o expoziție.',NULL,1950,'Bronz','h 65 cm','Sculptură','Secolul al XX-lea'),
  ('MN-0042','Bancnotă de 100 de lei','Bancnotă emisă după reforma monetară.',NULL,1947,'Hârtie','15 × 7 cm','Numismatică','Secolul al XX-lea')
) AS v (cod, titlu, descriere, autor, an, material, dim, categorie, epoca)
JOIN categorii c ON c.denumire = v.categorie
JOIN epoci     e ON e.denumire = v.epoca
ORDER BY v.cod;

-- ---------------------------------------------------------------------
-- FISIERE_MEDIA - doar metadate si calea pe disc
-- ---------------------------------------------------------------------
-- imaginea principala pentru fiecare exponat
INSERT INTO fisiere_media (id_exponat, tip, nume_fisier, cale_fisier, tip_mime,
                           dimensiune_bytes, este_principal)
SELECT id_exponat, 'imagine',
       cod_inventar || '.jpg',
       'uploads/imagini/' || cod_inventar || '.jpg',
       'image/jpeg',
       150000 + id_exponat * 7919,
       TRUE
FROM exponate;

-- o imagine suplimentara (detaliu) pentru o treime din exponate
INSERT INTO fisiere_media (id_exponat, tip, nume_fisier, cale_fisier, tip_mime,
                           dimensiune_bytes, este_principal)
SELECT id_exponat, 'imagine',
       cod_inventar || '_detaliu.jpg',
       'uploads/imagini/' || cod_inventar || '_detaliu.jpg',
       'image/jpeg',
       90000 + id_exponat * 3571,
       FALSE
FROM exponate
WHERE id_exponat % 3 = 0;

-- audio-ghid in limba romana pentru primele 34 de exponate
INSERT INTO fisiere_media (id_exponat, tip, nume_fisier, cale_fisier, tip_mime,
                           dimensiune_bytes, durata_secunde, limba)
SELECT id_exponat, 'audio',
       cod_inventar || '_ro.mp3',
       'uploads/audio/' || cod_inventar || '_ro.mp3',
       'audio/mpeg',
       (60 + (id_exponat * 17) % 120) * 16000,
       60 + (id_exponat * 17) % 120,
       'ro'
FROM exponate
WHERE id_exponat <= 34;

-- audio-ghid in limba engleza pentru o parte din exponate
INSERT INTO fisiere_media (id_exponat, tip, nume_fisier, cale_fisier, tip_mime,
                           dimensiune_bytes, durata_secunde, limba)
SELECT id_exponat, 'audio',
       cod_inventar || '_en.mp3',
       'uploads/audio/' || cod_inventar || '_en.mp3',
       'audio/mpeg',
       (55 + (id_exponat * 13) % 110) * 16000,
       55 + (id_exponat * 13) % 110,
       'en'
FROM exponate
WHERE id_exponat % 4 = 0;

-- ---------------------------------------------------------------------
-- EXPOZITII (7) - datele sunt relative la ziua curenta, astfel incat
-- view-ul v_expozitii_active sa returneze mereu rezultate.
-- ---------------------------------------------------------------------
INSERT INTO expozitii (titlu, descriere, sala, data_inceput, data_sfarsit) VALUES
  ('Comori ale Daciei',               'Tezaure, podoabe și arme ale geto-dacilor.',          'Sala A1', CURRENT_DATE - 30,  CURRENT_DATE + 60),
  ('Roma la Dunăre',                  'Viața de zi cu zi în provincia Dacia.',               'Sala B2', CURRENT_DATE - 10,  CURRENT_DATE + 90),
  ('Meșteșug și tradiție',            'Port popular și țesături tradiționale.',              'Sala C1', CURRENT_DATE - 100, CURRENT_DATE - 20),
  ('Arta românească modernă',         'Pictură și sculptură din secolele XIX–XX.',           'Sala D1', CURRENT_DATE - 5,   CURRENT_DATE + 120),
  ('Începuturile civilizației',       'Neoliticul și primele comunități agricole.',          'Sala A2', CURRENT_DATE + 15,  CURRENT_DATE + 150),
  ('Monede de-a lungul timpului',     'De la monedele dacice la bancnotele moderne.',        'Sala B1', CURRENT_DATE - 200, CURRENT_DATE - 150),
  ('Cavaleri și voievozi',            'Arme, manuscrise și icoane din Evul mediu românesc.', 'Sala A3', CURRENT_DATE - 60,  CURRENT_DATE + 10);

-- ---------------------------------------------------------------------
-- EXPOZITII_EXPONATE - exponatele sunt alese dupa epoca / categorie,
-- iar ordinea de afisare este data de ROW_NUMBER().
-- ---------------------------------------------------------------------
INSERT INTO expozitii_exponate (id_expozitie, id_exponat, ordine_afisare)
SELECT x.id_expozitie, s.id_exponat,
       ROW_NUMBER() OVER (PARTITION BY x.id_expozitie ORDER BY s.id_exponat)
FROM expozitii x
JOIN (
    SELECT ex.id_exponat, c.denumire AS categorie, ep.denumire AS epoca
    FROM exponate ex
    JOIN categorii c ON c.id_categorie = ex.id_categorie
    JOIN epoci    ep ON ep.id_epoca    = ex.id_epoca
) s ON
    (x.titlu = 'Comori ale Daciei'           AND s.epoca = 'Antichitate dacică')
 OR (x.titlu = 'Roma la Dunăre'              AND s.epoca = 'Perioada romană')
 OR (x.titlu = 'Meșteșug și tradiție'        AND s.categorie IN ('Textile și port popular', 'Ceramică')
                                             AND s.epoca IN ('Epoca modernă timpurie', 'Secolul al XIX-lea', 'Secolul al XX-lea'))
 OR (x.titlu = 'Arta românească modernă'     AND s.categorie IN ('Pictură', 'Sculptură')
                                             AND s.epoca IN ('Secolul al XIX-lea', 'Secolul al XX-lea'))
 OR (x.titlu = 'Începuturile civilizației'   AND s.epoca IN ('Neolitic', 'Epoca bronzului'))
 OR (x.titlu = 'Monede de-a lungul timpului' AND s.categorie = 'Numismatică')
 OR (x.titlu = 'Cavaleri și voievozi'        AND s.epoca = 'Evul mediu');

-- ---------------------------------------------------------------------
-- VIZUALIZARI - generate determinist (aceleasi date la fiecare rulare),
-- distribuite in ultimele 90 de zile, cu numar diferit per exponat.
-- ---------------------------------------------------------------------
INSERT INTO vizualizari (id_exponat, data_vizualizare, sursa, durata_ascultare_sec)
SELECT e.id_exponat,
       date_trunc('day', CURRENT_TIMESTAMP)
         - ((g * 7 + e.id_exponat * 3) % 90) * INTERVAL '1 day'
         + (9 + (g * 5 + e.id_exponat) % 9) * INTERVAL '1 hour'
         + ((g * 11) % 60) * INTERVAL '1 minute',
       CASE g % 3 WHEN 0 THEN 'web' WHEN 1 THEN 'qr' ELSE 'audio' END,
       CASE WHEN g % 3 = 2 THEN 20 + (g * 41 + e.id_exponat) % 160 END
FROM exponate e
CROSS JOIN LATERAL generate_series(1, 3 + (e.id_exponat * 37) % 29) AS g;

COMMIT;

-- Verificare rapida
SELECT 'categorii' AS tabel, COUNT(*) FROM categorii
UNION ALL SELECT 'epoci',              COUNT(*) FROM epoci
UNION ALL SELECT 'exponate',           COUNT(*) FROM exponate
UNION ALL SELECT 'fisiere_media',      COUNT(*) FROM fisiere_media
UNION ALL SELECT 'expozitii',          COUNT(*) FROM expozitii
UNION ALL SELECT 'expozitii_exponate', COUNT(*) FROM expozitii_exponate
UNION ALL SELECT 'vizualizari',        COUNT(*) FROM vizualizari;
