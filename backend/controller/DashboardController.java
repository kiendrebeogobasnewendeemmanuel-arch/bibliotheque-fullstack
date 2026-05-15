package com.bibliotheque.controller;


import com.bibliotheque.repository.LecteurRepository;
import com.bibliotheque.repository.LivreRepository;
import com.bibliotheque.repository.ReservationRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/dashboard")
@CrossOrigin(origins = "*")
@RequiredArgsConstructor
public class DashboardController {

    private final LivreRepository livreRepository;
    private final ReservationRepository reservationRepository;
    private final LecteurRepository lecteurRepository;

    // GET /api/dashboard
    // Retourne les statistiques générales
    @GetMapping
    public ResponseEntity<Map<String, Object>> getDashboard() {

        Map<String, Object> stats = new HashMap<>();

        // Nombre total de livres
        stats.put("totalLivres",
                livreRepository.count());

        // Nombre de livres disponibles
        stats.put("livresDisponibles",
                livreRepository.findByDisponible(true).size());

        // Nombre de livres réservés
        stats.put("livresReserves",
                livreRepository.findByDisponible(false).size());

        // Nombre total de réservations
        stats.put("totalReservations",
                reservationRepository.count());

        // Nombre total de lecteurs
        stats.put("totalLecteurs",
                lecteurRepository.count());

        return ResponseEntity.ok(stats);
    }
}
