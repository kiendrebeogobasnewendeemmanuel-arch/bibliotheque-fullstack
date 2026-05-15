package com.bibliotheque.repository;

import com.bibliotheque.model.Reservation;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ReservationRepository extends JpaRepository<Reservation, Long> {

    // Toutes les réservations d'un lecteur
    // SELECT * FROM reservation WHERE lecteur_id = ?
    List<Reservation> findByLecteurId(Long lecteurId);

    // Toutes les réservations d'un livre
    // SELECT * FROM reservation WHERE livre_id = ?
    List<Reservation> findByLivreId(Long livreId);

    // Vérifie si un livre est déjà réservé
    // SELECT * FROM reservation WHERE livre_id = ?
    Optional<Reservation> findFirstByLivreId(Long livreId);
}
