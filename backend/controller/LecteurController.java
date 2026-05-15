package com.bibliotheque.controller;

import com.bibliotheque.model.Lecteur;
import com.bibliotheque.service.LecteurService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;


import java.util.List;

@RestController
@RequestMapping("/api/lecteurs")
@CrossOrigin(origins = "*")
@RequiredArgsConstructor
public class LecteurController {

    private final LecteurService lecteurService;

    // GET /api/lecteurs
    @GetMapping
    public ResponseEntity<List<Lecteur>> getLecteurs() {
        return ResponseEntity.ok(
                lecteurService.getTousLesLecteurs()
        );
    }

    // GET /api/lecteurs/1
    @GetMapping("/{id}")
    public ResponseEntity<Lecteur> getLecteurParId(
            @PathVariable Long id) {
        return ResponseEntity.ok(
                lecteurService.getLecteurParId(id)
        );
    }

    // POST /api/lecteurs
    @PostMapping
    public ResponseEntity<Lecteur> creerLecteur(
            @RequestBody Lecteur lecteur) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(lecteurService.creerLecteur(lecteur));
    }

    // PUT /api/lecteurs/1
    @PutMapping("/{id}")
    public ResponseEntity<Lecteur> modifierLecteur(
            @PathVariable Long id,
            @RequestBody Lecteur lecteur) {
        return ResponseEntity.ok(
                lecteurService.modifierLecteur(id, lecteur)
        );
    }

    // DELETE /api/lecteurs/1
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> supprimerLecteur(
            @PathVariable Long id) {
        lecteurService.supprimerLecteur(id);
        return ResponseEntity.noContent().build();
    }
}
