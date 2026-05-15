package com.bibliotheque.service;


import com.bibliotheque.model.Reservation;
import com.bibliotheque.exception.LivreDejaReserveException;
import com.bibliotheque.exception.ResourceNotFoundException;
import lombok.RequiredArgsConstructor;
import com.bibliotheque.model.Lecteur;
import com.bibliotheque.model.Livre;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.bibliotheque.repository.LecteurRepository;
import com.bibliotheque.repository.LivreRepository;
import com.bibliotheque.repository.ReservationRepository;

import java.util.List;

@Service
@RequiredArgsConstructor
public class ReservationService {

    private final ReservationRepository reservationRepository;
    private final LivreRepository livreRepository;
    private final LecteurRepository lecteurRepository;

    // Retourne toutes les réservations
    public List<Reservation> getToutesLesReservations() {
        return reservationRepository.findAll();
    }

    // Retourne les réservations d'un lecteur
    public List<Reservation> getReservationsParLecteur(Long lecteurId) {
        return reservationRepository.findByLecteurId(lecteurId);
    }

    // ============================================
    // MÉTHODE CORRIGÉE — Bug race condition
    // ============================================
    // @Transactional garantit que toutes les opérations
    // se font en UNE SEULE transaction atomique
    // Si une étape échoue → tout est annulé (rollback)
    @Transactional
    public Reservation reserverLivre(Long livreId, Long lecteurId) {

        // findByIdWithLock → SELECT ... FOR UPDATE
        // Verrouille la ligne du livre en base
        // Si une 2ème requête arrive en même temps
        // elle ATTEND que ce verrou soit libéré
        // C'est ici que le bug est corrigé !
        Livre livre = livreRepository.findByIdWithLock(livreId)
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Livre non trouvé avec l'id : " + livreId
                ));

        // Vérifie la disponibilité APRES avoir posé le verrou
        // Maintenant une seule requête à la fois peut passer ici
        if (!livre.getDisponible()) {
            throw new LivreDejaReserveException(
                    "Ce livre est déjà réservé"
            );
        }

        // Vérifie que le lecteur existe
        Lecteur lecteur = lecteurRepository.findById(lecteurId)
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Lecteur non trouvé avec l'id : " + lecteurId
                ));

        // Marque le livre comme non disponible
        livre.setDisponible(false);
        livreRepository.save(livre);

        // Crée la réservation
        Reservation reservation = new Reservation();
        reservation.setLivre(livre);
        reservation.setLecteur(lecteur);
        return reservationRepository.save(reservation);
    }

    // Annule une réservation
    @Transactional
    public void annulerReservation(Long reservationId) {
        Reservation reservation = reservationRepository
                .findById(reservationId)
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Réservation non trouvée avec l'id : " + reservationId
                ));

        // Remet le livre disponible
        Livre livre = reservation.getLivre();
        livre.setDisponible(true);
        livreRepository.save(livre);

        // Supprime la réservation
        reservationRepository.delete(reservation);
    }
}
