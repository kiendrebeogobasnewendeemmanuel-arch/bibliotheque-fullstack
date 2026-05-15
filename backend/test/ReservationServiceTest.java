package com.bibliotheque;

import com.bibliotheque.exception.LivreDejaReserveException;
import com.bibliotheque.model.Lecteur;
import com.bibliotheque.model.Livre;
import com.bibliotheque.model.Reservation;
import com.bibliotheque.repository.LecteurRepository;
import com.bibliotheque.repository.LivreRepository;
import com.bibliotheque.repository.ReservationRepository;
import com.bibliotheque.service.ReservationService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.transaction.annotation.Transactional;

import java.util.concurrent.atomic.AtomicInteger;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;

import static org.junit.jupiter.api.Assertions.*;

// @SpringBootTest charge tout le contexte Spring Boot
// pour les tests d'intégration
@SpringBootTest
class ReservationServiceTest {

    @Autowired
    private ReservationService reservationService;

    @Autowired
    private LivreRepository livreRepository;

    @Autowired
    private LecteurRepository lecteurRepository;

    @Autowired
    private ReservationRepository reservationRepository;

    // Variables réutilisées dans les tests
    private Livre livre;
    private Lecteur lecteur1;
    private Lecteur lecteur2;

    // @BeforeEach s'exécute avant chaque test
    // pour préparer des données fraîches
    @BeforeEach
    @Transactional
    void setUp() {
        // Nettoie la base avant chaque test
        reservationRepository.deleteAll();
        livreRepository.deleteAll();
        lecteurRepository.deleteAll();

        // Crée un livre disponible
        livre = new Livre();
        livre.setTitre("Clean Code");
        livre.setAuteur("Robert C. Martin");
        livre.setAnneePublication(2008);
        livre.setDisponible(true);
        livre = livreRepository.save(livre);

        // Crée deux lecteurs
        lecteur1 = new Lecteur();
        lecteur1.setNom("Alice");
        lecteur1.setEmail("alice@test.com");
        lecteur1 = lecteurRepository.save(lecteur1);

        lecteur2 = new Lecteur();
        lecteur2.setNom("Bob");
        lecteur2.setEmail("bob@test.com");
        lecteur2 = lecteurRepository.save(lecteur2);
    }

    // ============================================
    // TEST 1 — Réservation normale
    // ============================================
    @Test
    void reserverLivre_disponible_doitReussir() {
        // Action
        Reservation reservation = reservationService
                .reserverLivre(livre.getId(), lecteur1.getId());

        // Vérification
        assertNotNull(reservation);
        assertNotNull(reservation.getId());
        assertEquals(livre.getId(), reservation.getLivre().getId());
        assertEquals(lecteur1.getId(), reservation.getLecteur().getId());

        // Le livre doit être marqué non disponible
        Livre livreModifie = livreRepository
                .findById(livre.getId()).get();
        assertFalse(livreModifie.getDisponible());
    }

    // ============================================
    // TEST 2 — Livre déjà réservé
    // ============================================
    @Test
    void reserverLivre_dejaReserve_doitEchouer() {
        // Alice réserve le livre
        reservationService.reserverLivre(
                livre.getId(), lecteur1.getId());

        // Bob essaie de réserver le même livre
        // → doit lancer une exception
        assertThrows(
                LivreDejaReserveException.class,
                () -> reservationService.reserverLivre(
                        livre.getId(), lecteur2.getId()
                )
        );
    }

    // ============================================
    // TEST 3 — Le bug corrigé (race condition)
    // Deux requêtes simultanées sur le même livre
    // ============================================
    @Test
    void reserverLivre_deuxRequetesSimultanees_uneSeuleDoitReussir()
            throws InterruptedException {

        // Compteurs thread-safe
        AtomicInteger succes = new AtomicInteger(0);
        AtomicInteger echecs = new AtomicInteger(0);

        // Simule 2 requêtes simultanées
        ExecutorService executor = Executors.newFixedThreadPool(2);

        // Requête 1 — Alice
        executor.submit(() -> {
            try {
                reservationService.reserverLivre(
                        livre.getId(), lecteur1.getId());
                succes.incrementAndGet();
            } catch (Exception e) {
                echecs.incrementAndGet();
            }
        });

        // Requête 2 — Bob (en même temps)
        executor.submit(() -> {
            try {
                reservationService.reserverLivre(
                        livre.getId(), lecteur2.getId());
                succes.incrementAndGet();
            } catch (Exception e) {
                echecs.incrementAndGet();
            }
        });

        // Attend que les 2 threads se terminent
        executor.shutdown();
        executor.awaitTermination(10, TimeUnit.SECONDS);

        // ✅ UNE SEULE réservation doit avoir réussi
        assertEquals(1, succes.get(),
                "Une seule réservation doit réussir");

        // ✅ L'autre doit avoir échoué proprement
        assertEquals(1, echecs.get(),
                "Une réservation doit échouer");

        // ✅ Une seule réservation en base
        assertEquals(1, reservationRepository.count(),
                "Une seule réservation en base");
    }

    // ============================================
    // TEST 4 — Annulation de réservation
    // ============================================
    @Test
    void annulerReservation_doitRendreLivreDisponible() {
        // Alice réserve le livre
        Reservation reservation = reservationService
                .reserverLivre(livre.getId(), lecteur1.getId());

        // Alice annule sa réservation
        reservationService.annulerReservation(reservation.getId());

        // Le livre doit être à nouveau disponible
        Livre livreApres = livreRepository
                .findById(livre.getId()).get();
        assertTrue(livreApres.getDisponible());

        // La réservation doit être supprimée
        assertFalse(reservationRepository
                .findById(reservation.getId()).isPresent());
    }
}