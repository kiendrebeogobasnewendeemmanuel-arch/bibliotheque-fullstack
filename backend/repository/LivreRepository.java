package com.bibliotheque.repository;

import com.bibliotheque.model.Livre;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import jakarta.persistence.LockModeType;
import java.util.List;
import java.util.Optional;

// @Repository dit à Spring Boot :
// "Cette interface gère l'accès à la base de données"
@Repository

// JpaRepository<Livre, Long> donne automatiquement accès à :
// save(), findAll(), findById(), deleteById()... etc
// Livre = le modèle concerné
// Long = le type de l'id
public interface LivreRepository extends JpaRepository<Livre, Long> {

    // Spring JPA comprend le nom de la méthode et génère le SQL !
    // findBy + Titre + ContainingIgnoreCase
    // → SELECT * FROM livre WHERE LOWER(titre) LIKE LOWER('%mot%')
    List<Livre> findByTitreContainingIgnoreCase(String titre);

    // SELECT * FROM livre WHERE LOWER(auteur) LIKE LOWER('%mot%')
    List<Livre> findByAuteurContainingIgnoreCase(String auteur);

    // Recherche par année de publication
    // SELECT * FROM livre WHERE annee_publication = ?
    List<Livre> findByAnneePublication(Integer anneePublication);

    // SELECT * FROM livre WHERE disponible = ?
    List<Livre> findByDisponible(Boolean disponible);

    // C'est la méthode CLÉ pour corriger le bug !
    // @Lock(PESSIMISTIC_WRITE) → SELECT ... FOR UPDATE
    // Verrouille la ligne pendant la transaction
    // pour éviter les doubles réservations simultanées
    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("SELECT l FROM Livre l WHERE l.id = :id")
    Optional<Livre> findByIdWithLock(@Param("id") Long id);
}
