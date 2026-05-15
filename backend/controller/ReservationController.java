package com.bibliotheque.controller;

import com.bibliotheque.model.Reservation;
import com.bibliotheque.service.ReservationService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;


import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/reservations")
@CrossOrigin(origins = "*")
@RequiredArgsConstructor
public class ReservationController {

    private final ReservationService reservationService;

    // GET /api/reservations
    @GetMapping
    public ResponseEntity<List<Reservation>> getReservations() {
        return ResponseEntity.ok(
                reservationService.getToutesLesReservations()
        );
    }

    // GET /api/reservations/lecteur/1
    // Toutes les réservations d'un lecteur
    @GetMapping("/lecteur/{lecteurId}")
    public ResponseEntity<List<Reservation>> getReservationsParLecteur(
            @PathVariable Long lecteurId) {
        return ResponseEntity.ok(
                reservationService.getReservationsParLecteur(lecteurId)
        );
    }

    // POST /api/reservations
    // Flutter envoie : { "livreId": 1, "lecteurId": 2 }
    // @RequestBody Map<String, Long> :
    // récupère ces deux valeurs depuis le JSON
    @PostMapping
    public ResponseEntity<Reservation> reserverLivre(
            @RequestBody Map<String, Long> body) {

        Long livreId   = body.get("livreId");
        Long lecteurId = body.get("lecteurId");

        Reservation reservation = reservationService
                .reserverLivre(livreId, lecteurId);

        return ResponseEntity.status(HttpStatus.CREATED)
                .body(reservation);
    }

    // DELETE /api/reservations/1
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> annulerReservation(
            @PathVariable Long id) {
        reservationService.annulerReservation(id);
        return ResponseEntity.noContent().build();
    }
}
