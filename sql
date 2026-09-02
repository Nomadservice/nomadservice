NomadService — Database SQL

Versione: 0.1
Stato: Proposta tecnica
Progetto: NomadService

1. Obiettivo

Questa è la prima traduzione concreta del modello descritto in "docs/Database.md".

Il database deve permettere di:

- identificare un luogo;
- identificare i servizi presenti in quel luogo;
- classificare ogni servizio;
- descrivere in modo strutturato disponibilità, accesso, costi, limitazioni e orari;
- raccogliere informazioni aggiuntive dagli utenti;
- distinguere tra informazione sconosciuta e informazione negativa;
- permettere contributi anonimi molto brevi;
- permettere agli utenti registrati di fornire informazioni più complete.

Il modello deve inoltre poter crescere senza dover essere riprogettato da zero.

---

2. Entità principali

Il modello iniziale utilizza queste entità:

places
   │
   └── services
          │
          ├── service_categories
          │       └── categories
          │
          ├── service_information
          │
          └── contributions
                    │
                    └── users

---

3. "places"

Rappresenta il luogo fisico.

Un luogo può contenere uno o più servizi.

CREATE TABLE places (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    address TEXT,
    city TEXT,
    region TEXT,
    country TEXT,
    latitude REAL,
    longitude REAL,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL
);

Principio

Il luogo non è il protagonista dell'applicazione.

È il contenitore fisico nel quale possono essere presenti diversi servizi.

Esempio:

Area di sosta X
 ├── Acqua
 ├── Scarico
 ├── Elettricità
 └── Servizi igienici

---

4. "services"

Rappresenta il singolo servizio utilizzabile dall'utente.

CREATE TABLE services (
    id INTEGER PRIMARY KEY,
    place_id INTEGER NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    status TEXT NOT NULL DEFAULT 'unknown',
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL,

    FOREIGN KEY (place_id)
        REFERENCES places(id)
);

"status"

Valori previsti:

active
inactive
unknown

"unknown" significa che non abbiamo informazioni sufficienti per stabilire lo stato.

Non deve essere interpretato come "inactive".

---

5. "categories"

Le categorie permettono di classificare i servizi.

CREATE TABLE categories (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    description TEXT,
    active INTEGER NOT NULL DEFAULT 1
);

Esempi iniziali:

Acqua
Elettricità
Lavanderia
Docce
Servizi igienici
Parcheggio
Rifornimento
Smaltimento
Internet
Riparazioni
Alimentari
Trasporti
Altro

L'elenco non è definitivo.

---

6. "service_categories"

Un servizio può appartenere a più categorie.

CREATE TABLE service_categories (
    service_id INTEGER NOT NULL,
    category_id INTEGER NOT NULL,

    PRIMARY KEY (service_id, category_id),

    FOREIGN KEY (service_id)
        REFERENCES services(id),

    FOREIGN KEY (category_id)
        REFERENCES categories(id)
);

Esempio:

Servizio:
"Area camper comunale"

Categorie:
- Parcheggio
- Acqua
- Scarico
- Elettricità

---

7. "service_information"

Questa è una delle parti centrali del database.

Serve a rappresentare le informazioni operative del servizio.

CREATE TABLE service_information (
    id INTEGER PRIMARY KEY,
    service_id INTEGER NOT NULL,

    existence TEXT NOT NULL DEFAULT 'unknown',
    access TEXT NOT NULL DEFAULT 'unknown',
    cost TEXT NOT NULL DEFAULT 'unknown',

    opening_hours TEXT,
    limitations TEXT,

    updated_at TIMESTAMP NOT NULL,

    FOREIGN KEY (service_id)
        REFERENCES services(id)
);

7.1 Esistenza

Possibili valori concettuali:

available
unavailable
unknown

È fondamentale distinguere:

unavailable

da:

unknown

Esempio:

«"Qui non c'è acqua."»

→ "unavailable"

Esempio:

«"Non so se c'è l'acqua."»

→ "unknown"

---

7.2 Accesso

Il database deve poter distinguere, almeno concettualmente:

public
customers
residents
authorization_required
unknown

In futuro potranno essere aggiunte altre condizi
