package com.bibliotheque.model;

// JPA : permet de lier cette classe à la table PostgreSQL
import jakarta.persistence.*;
// Lombok : génère automatiquement getters, setters, constructeurs
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.time.LocalDateTime;

// @Entity dit à Spring Boot :
// "Cette classe représente une table dans PostgreSQL"
@Entity

// @Table précise le nom exact de la table dans PostgreSQL
// C'est la table "livre" qu'on a créée dans pgAdmin
@Table(name = "livre")

// @Data (Lombok) génère automatiquement :
// - les getters (getId(), getTitre()...)
// - les setters (setId(), setTitre()...)
// - toString(), equals(), hashCode()
// Sans Lombok tu devrais écrire tout ça à la main !
@Data

// Génère un constructeur vide : new Livre()
// Obligatoire pour JPA
@NoArgsConstructor

// Génère un constructeur avec tous les champs :
// new Livre(titre, auteur, anneePublication, disponible)
@AllArgsConstructor

public class Livre {

    // @Id dit à JPA : "c'est la clé primaire de la table"
    @Id

    // @GeneratedValue dit à JPA : "laisse PostgreSQL
    // générer l'id automatiquement" (c'est notre BIGSERIAL)
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // @Column précise le nom de la colonne dans PostgreSQL
    // nullable = false → équivaut à NOT NULL dans SQL
    @Column(name = "titre", nullable = false)
    private String titre;

    @Column(name = "auteur", nullable = false)
    private String auteur;

    // Le champ anneePublication en Java
    // correspond à la colonne annee_publication en PostgreSQL
    @Column(name = "annee_publication", nullable = false)
    private Integer anneePublication;

    // Par défaut true : un livre créé est disponible
    // C'est notre DEFAULT TRUE dans PostgreSQL
    @Column(name = "disponible", nullable = false)
    private Boolean disponible = true;

    // Rempli automatiquement à la création
    // @Column(updatable = false) → cette valeur ne change jamais après création
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    // @PrePersist : cette méthode s'exécute automatiquement
    // juste AVANT que JPA insère l'enregistrement dans PostgreSQL
    // Tu n'as pas besoin de remplir createdAt manuellement
    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
    }
}
