package com.bibliotheque.model;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(
        name = "reservation",
        // Cette contrainte correspond à notre UNIQUE(livre_id)
        // dans PostgreSQL — un livre ne peut avoir
        // qu'une seule réservation active à la fois
        uniqueConstraints = {
                @UniqueConstraint(columnNames = "livre_id")
        }
)
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Reservation {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // @ManyToOne : plusieurs réservations peuvent concerner
    // le même livre (dans le temps)
    // mais UN livre n'a qu'UNE réservation ACTIVE à la fois
    // (c'est le UNIQUE qui gère ça)
    // @JoinColumn : c'est la clé étrangère vers la table livre
    // C'est notre livre_id REFERENCES livre(id) en SQL
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "livre_id", nullable = false)
    private Livre livre;

    // @ManyToOne : plusieurs réservations peuvent appartenir
    // au même lecteur
    // @JoinColumn : c'est la clé étrangère vers la table lecteur
    // C'est notre lecteur_id REFERENCES lecteur(id) en SQL
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "lecteur_id", nullable = false)
    private Lecteur lecteur;

    // La date du jour de la réservation
    // DEFAULT CURRENT_DATE en SQL
    @Column(name = "date_reservation", nullable = false)
    private LocalDate dateReservation;

    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    // Remplit automatiquement les dates
    // avant l'insertion dans PostgreSQL
    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
        // Si la date n'est pas fournie,
        // on met automatiquement la date du jour
        if (this.dateReservation == null) {
            this.dateReservation = LocalDate.now();
        }
    }
}
