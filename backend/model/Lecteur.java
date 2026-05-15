package com.bibliotheque.model;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.time.LocalDateTime;
// Cette import est nouvelle ! Elle permet de dire
// qu'un Lecteur peut avoir PLUSIEURS réservations
import java.util.List;

@Entity
@Table(name = "lecteur")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Lecteur {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "nom", nullable = false)
    private String nom;

    // unique = true → correspond à notre UNIQUE
    // dans PostgreSQL, un email ne peut pas être en double
    @Column(name = "email", nullable = false, unique = true)
    private String email;

    // @OneToMany : un Lecteur peut avoir PLUSIEURS réservations
    // "mappedBy = lecteur" dit à JPA :
    // "va chercher la relation du côté de Reservation.java
    //  dans le champ qui s'appelle 'lecteur' "
    // cascade : si on supprime un lecteur,
    // ses réservations sont supprimées aussi
    // fetch LAZY : les réservations ne sont chargées
    // que quand on en a besoin (économise la mémoire)
    @JsonIgnore
    @OneToMany(mappedBy = "lecteur",
            cascade = CascadeType.ALL,
            fetch = FetchType.LAZY)
    private List<Reservation> reservations;

    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
    }
}
