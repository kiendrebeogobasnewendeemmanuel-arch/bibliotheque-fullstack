package com.bibliotheque.repository;

import com.bibliotheque.model.Lecteur;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface LecteurRepository extends JpaRepository<Lecteur, Long> {

    // Vérifie si un email existe déjà
    // utile pour éviter les doublons
    // SELECT * FROM lecteur WHERE email = ?
    Optional<Lecteur> findByEmail(String email);

    // Recherche par nom
    // SELECT * FROM lecteur WHERE LOWER(nom) LIKE LOWER('%mot%')
    java.util.List<Lecteur> findByNomContainingIgnoreCase(String nom);
}
