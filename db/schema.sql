-- =====================================================================
-- Catalog digital pentru muzeu - schema bazei de date (PostgreSQL)
-- Rulare:  psql -U postgres -d catalog_muzeu -f db/schema.sql
-- Scriptul poate fi rulat de mai multe ori: sterge si recreeaza totul.
-- =====================================================================

DROP VIEW  IF EXISTS v_expozitii_active;
DROP TABLE IF EXISTS vizualizari         CASCADE;
DROP TABLE IF EXISTS expozitii_exponate  CASCADE;
DROP TABLE IF EXISTS expozitii           CASCADE;
DROP TABLE IF EXISTS fisiere_media       CASCADE;
DROP TABLE IF EXISTS exponate            CASCADE;
DROP TABLE IF EXISTS epoci               CASCADE;
DROP TABLE IF EXISTS categorii           CASCADE;

-- ---------------------------------------------------------------------
-- 1. CATEGORII (pictura, sculptura, ceramica, ...)
-- ---------------------------------------------------------------------
CREATE TABLE categorii (
    id_categorie  SERIAL        PRIMARY KEY,
    denumire      VARCHAR(100)  NOT NULL,
    descriere     TEXT,
    CONSTRAINT uq_categorii_denumire UNIQUE (denumire),
    CONSTRAINT ck_categorii_denumire CHECK (length(trim(denumire)) > 0)
);

-- ---------------------------------------------------------------------
-- 2. EPOCI (anii negativi = inainte de Hristos)
-- ---------------------------------------------------------------------
CREATE TABLE epoci (
    id_epoca      SERIAL        PRIMARY KEY,
    denumire      VARCHAR(100)  NOT NULL,
    an_inceput    INTEGER       NOT NULL,
    an_sfarsit    INTEGER       NOT NULL,
    descriere     TEXT,
    CONSTRAINT uq_epoci_denumire UNIQUE (denumire),
    CONSTRAINT ck_epoci_interval CHECK (an_inceput <= an_sfarsit)
);

-- ---------------------------------------------------------------------
-- 3. EXPONATE
-- ---------------------------------------------------------------------
CREATE TABLE exponate (
    id_exponat     SERIAL        PRIMARY KEY,
    cod_inventar   VARCHAR(20)   NOT NULL,
    titlu          VARCHAR(200)  NOT NULL,
    descriere      TEXT,
    autor          VARCHAR(150),
    an_creare      INTEGER,
    material       VARCHAR(150),
    dimensiuni     VARCHAR(100),
    id_categorie   INTEGER       NOT NULL,
    id_epoca       INTEGER       NOT NULL,
    data_adaugare  TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_exponate_cod_inventar UNIQUE (cod_inventar),
    CONSTRAINT ck_exponate_titlu        CHECK (length(trim(titlu)) > 0),
    CONSTRAINT ck_exponate_an_creare    CHECK (an_creare IS NULL OR an_creare BETWEEN -50000 AND 2100),
    CONSTRAINT fk_exponate_categorie FOREIGN KEY (id_categorie)
        REFERENCES categorii (id_categorie) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_exponate_epoca FOREIGN KEY (id_epoca)
        REFERENCES epoci (id_epoca) ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE INDEX idx_exponate_categorie ON exponate (id_categorie);
CREATE INDEX idx_exponate_epoca     ON exponate (id_epoca);

-- ---------------------------------------------------------------------
-- 4. FISIERE_MEDIA (imagini si audio-ghiduri)
--    Fisierele sunt salvate pe disc; in baza de date pastram doar
--    metadatele si calea relativa (ex: uploads/audio/exp001_ro.mp3).
-- ---------------------------------------------------------------------
CREATE TABLE fisiere_media (
    id_media          SERIAL        PRIMARY KEY,
    id_exponat        INTEGER       NOT NULL,
    tip               VARCHAR(10)   NOT NULL,
    nume_fisier       VARCHAR(255)  NOT NULL,
    cale_fisier       VARCHAR(500)  NOT NULL,
    tip_mime          VARCHAR(100)  NOT NULL,
    dimensiune_bytes  BIGINT        NOT NULL,
    durata_secunde    INTEGER,
    limba             CHAR(2),
    este_principal    BOOLEAN       NOT NULL DEFAULT FALSE,
    data_incarcare    TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_media_cale       UNIQUE (cale_fisier),
    CONSTRAINT ck_media_tip        CHECK (tip IN ('imagine', 'audio')),
    CONSTRAINT ck_media_dimensiune CHECK (dimensiune_bytes > 0),
    CONSTRAINT ck_media_mime       CHECK (
        (tip = 'imagine' AND tip_mime LIKE 'image/%') OR
        (tip = 'audio'   AND tip_mime LIKE 'audio/%')
    ),
    -- durata si limba au sens doar pentru audio-ghiduri
    CONSTRAINT ck_media_audio CHECK (
        (tip = 'audio'   AND durata_secunde > 0 AND limba IS NOT NULL) OR
        (tip = 'imagine' AND durata_secunde IS NULL AND limba IS NULL)
    ),
    CONSTRAINT fk_media_exponat FOREIGN KEY (id_exponat)
        REFERENCES exponate (id_exponat) ON DELETE CASCADE
);

CREATE INDEX idx_media_exponat ON fisiere_media (id_exponat);

-- un singur audio-ghid per exponat si per limba
CREATE UNIQUE INDEX uq_media_audio_limba
    ON fisiere_media (id_exponat, limba) WHERE tip = 'audio';

-- o singura imagine principala per exponat
CREATE UNIQUE INDEX uq_media_imagine_principala
    ON fisiere_media (id_exponat) WHERE tip = 'imagine' AND este_principal;

-- ---------------------------------------------------------------------
-- 5. EXPOZITII (au o perioada de desfasurare)
-- ---------------------------------------------------------------------
CREATE TABLE expozitii (
    id_expozitie  SERIAL        PRIMARY KEY,
    titlu         VARCHAR(200)  NOT NULL,
    descriere     TEXT,
    sala          VARCHAR(50),
    data_inceput  DATE          NOT NULL,
    data_sfarsit  DATE          NOT NULL,
    CONSTRAINT uq_expozitii_titlu   UNIQUE (titlu),
    CONSTRAINT ck_expozitii_perioada CHECK (data_sfarsit >= data_inceput)
);

-- ---------------------------------------------------------------------
-- 6. EXPOZITII_EXPONATE (legatura N:M intre expozitii si exponate)
-- ---------------------------------------------------------------------
CREATE TABLE expozitii_exponate (
    id_expozitie    INTEGER  NOT NULL,
    id_exponat      INTEGER  NOT NULL,
    ordine_afisare  INTEGER  NOT NULL,
    CONSTRAINT pk_expozitii_exponate PRIMARY KEY (id_expozitie, id_exponat),
    CONSTRAINT uq_expozitii_ordine   UNIQUE (id_expozitie, ordine_afisare),
    CONSTRAINT ck_expozitii_ordine   CHECK (ordine_afisare > 0),
    CONSTRAINT fk_ee_expozitie FOREIGN KEY (id_expozitie)
        REFERENCES expozitii (id_expozitie) ON DELETE CASCADE,
    CONSTRAINT fk_ee_exponat FOREIGN KEY (id_exponat)
        REFERENCES exponate (id_exponat) ON DELETE CASCADE
);

CREATE INDEX idx_ee_exponat ON expozitii_exponate (id_exponat);

-- ---------------------------------------------------------------------
-- 7. VIZUALIZARI (folosite pentru statistici)
-- ---------------------------------------------------------------------
CREATE TABLE vizualizari (
    id_vizualizare        BIGSERIAL    PRIMARY KEY,
    id_exponat            INTEGER      NOT NULL,
    data_vizualizare      TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    sursa                 VARCHAR(10)  NOT NULL DEFAULT 'web',
    durata_ascultare_sec  INTEGER,
    CONSTRAINT ck_viz_sursa  CHECK (sursa IN ('web', 'qr', 'audio')),
    CONSTRAINT ck_viz_durata CHECK (durata_ascultare_sec IS NULL OR durata_ascultare_sec >= 0),
    CONSTRAINT fk_viz_exponat FOREIGN KEY (id_exponat)
        REFERENCES exponate (id_exponat) ON DELETE CASCADE
);

CREATE INDEX idx_viz_exponat ON vizualizari (id_exponat);
CREATE INDEX idx_viz_data    ON vizualizari (data_vizualizare);

-- ---------------------------------------------------------------------
-- VIEW: expozitiile active la data curenta, cu numarul de exponate
-- ---------------------------------------------------------------------
CREATE VIEW v_expozitii_active AS
SELECT  e.id_expozitie,
        e.titlu,
        e.descriere,
        e.sala,
        e.data_inceput,
        e.data_sfarsit,
        (e.data_sfarsit - CURRENT_DATE) AS zile_ramase,
        COUNT(ee.id_exponat)            AS nr_exponate
FROM    expozitii e
LEFT JOIN expozitii_exponate ee ON ee.id_expozitie = e.id_expozitie
WHERE   CURRENT_DATE BETWEEN e.data_inceput AND e.data_sfarsit
GROUP BY e.id_expozitie;
