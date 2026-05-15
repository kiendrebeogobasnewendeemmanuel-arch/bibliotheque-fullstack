# bibliotheque-fullstack
Application web de gestion de bibliothèque développée avec Flutter Web, Spring Boot et PostgreSQL. Le projet permet la gestion des livres, lecteurs et réservations avec API REST, tests d’intégration et gestion des conflits de réservation.

# Stack technique
| Couche          | Technologie              |
| Backend         | Spring Boot 3 (Java 17)  |
| Base de données | PostgreSQL 15        |
| Frontend        | Flutter 3                |
| API             | REST (JSON)              |

# Justification
*Spring Boot offre une gestion robuste des transactions (@Transactional)
et des verrous pessimistes, indispensables pour éviter les doubles
réservations en concurrence. 

*PostgreSQL garantit l'intégrité des données
via des contraintes (UNIQUE, FK). 

*Flutter permet une interface mobile
cross-platform connectée à l'API REST.

## Endpoints API

| Méthode | URL                        | Description                  |
|---------|----------------------------|------------------------------|
| GET     | `/api/livres`              | Liste des livres              |
| GET     | `/api/livres?search=clean` | Recherche par titre/auteur    |
| POST    | `/api/livres`              | Créer un livre                |
| PUT     | `/api/livres/{id}`         | Modifier un livre             |
| DELETE  | `/api/livres/{id}`         | Supprimer un livre            |
| GET     | `/api/lecteurs`            | Liste des lecteurs            |
| POST    | `/api/lecteurs`            | Créer un lecteur              |
| POST    | `/api/reservations`        | Réserver un livre             |
| DELETE  | `/api/reservations/{id}`   | Annuler une réservation       |
| GET     | `/api/dashboard`           | Statistiques générales        |

## Les codes sql pour creer les tables dans postgre a travers pgadmin 4 ##
-- =============================================
-- BIBLIOTHEQUE DB - Script de création
-- =============================================

-- Table Livre
CREATE TABLE livre (
    id                 BIGSERIAL PRIMARY KEY,
    titre              VARCHAR(255)    NOT NULL,
    auteur             VARCHAR(255)    NOT NULL,
    annee_publication  INTEGER         NOT NULL CHECK (annee_publication > 0),
    disponible         BOOLEAN         NOT NULL DEFAULT TRUE,
    created_at         TIMESTAMP       NOT NULL DEFAULT NOW()
);

-- Table Lecteur
CREATE TABLE lecteur (
    id          BIGSERIAL PRIMARY KEY,
    nom         VARCHAR(255)    NOT NULL,
    email       VARCHAR(255)    NOT NULL UNIQUE,
    created_at  TIMESTAMP       NOT NULL DEFAULT NOW()
);

-- Table Reservation
CREATE TABLE reservation (
    id               BIGSERIAL PRIMARY KEY,
    livre_id         BIGINT      NOT NULL REFERENCES livre(id)   ON DELETE RESTRICT,
    lecteur_id       BIGINT      NOT NULL REFERENCES lecteur(id) ON DELETE RESTRICT,
    date_reservation DATE        NOT NULL DEFAULT CURRENT_DATE,
    created_at       TIMESTAMP   NOT NULL DEFAULT NOW(),

    -- Un livre ne peut avoir qu'une seule réservation active à la fois
    CONSTRAINT uq_livre_reservation UNIQUE (livre_id)
);

-- Index pour accélérer les recherches fréquentes
CREATE INDEX idx_livre_titre       ON livre(titre);
CREATE INDEX idx_livre_auteur      ON livre(auteur);
CREATE INDEX idx_livre_disponible  ON livre(disponible);
CREATE INDEX idx_reservation_lecteur ON reservation(lecteur_id);

## Bug corrigé — Race condition
### Problème identifié
Dans la fonction `reserverLivre`, si deux requêtes arrivent simultanément,
les deux lisent `disponible = true` en même temps et créent chacune
une réservation — le livre se retrouve réservé deux fois.

### Correction appliquée
Utilisation de `@Transactional` + verrou pessimiste (`PESSIMISTIC_WRITE`)
sur la lecture du livre, couplé à une contrainte `UNIQUE(livre_id)`
en base de données.

### Test de non-régression
`ReservationServiceTest.deuxReservationsSimultanees_uneSeuleDoitReussir()`

**le code du test se trouve dans le fichier ReservationServiceTest.java**
## les resultats du test
[root]
annulerReservation_doitRendreLivreDisponible()
reserverLivre_dejaReserve_doitEchouer()
reserverLivre_deuxRequetesSimultanees_uneSeuleDoitReussir()
reserverLivre_disponible_doitReussir()
**Tests passed: 4 of 4 Tests**
