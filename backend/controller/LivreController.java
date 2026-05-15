package com.bibliotheque.controller;

import com.bibliotheque.model.Livre;
import com.bibliotheque.service.LivreService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;


import java.util.List;

// @RestController dit à Spring Boot :
// "Cette classe reçoit les requêtes HTTP
// et retourne du JSON automatiquement"
@RestController

// @RequestMapping : toutes les routes
// de ce controller commencent par /api/livres
@RequestMapping("/api/livres")

// @CrossOrigin : autorise Flutter à appeler
// cette API depuis n'importe quelle adresse
@CrossOrigin(origins = "*")

@RequiredArgsConstructor
public class LivreController {

    private final LivreService livreService;

    // GET /api/livres
    // GET /api/livres?search=clean
    // GET /api/livres?annee=2022
    // @RequestParam : paramètre optionnel dans l'URL
    // required = false → pas obligatoire
    @GetMapping
    public ResponseEntity<List<Livre>> getLivres(
            @RequestParam(required = false) String search,
            @RequestParam(required = false) Integer annee) {

        List<Livre> livres;

        if (search != null && !search.isEmpty()) {
            // Recherche par titre ou auteur
            livres = livreService.rechercherLivres(search);
        } else if (annee != null) {
            // Filtre par année
            livres = livreService.getLivresParAnnee(annee);
        } else {
            // Retourne tous les livres
            livres = livreService.getTousLesLivres();
        }

        // ResponseEntity.ok() → code HTTP 200
        return ResponseEntity.ok(livres);
    }

    // GET /api/livres/1
    // @PathVariable : récupère l'id dans l'URL
    @GetMapping("/{id}")
    public ResponseEntity<Livre> getLivreParId(
            @PathVariable Long id) {
        return ResponseEntity.ok(livreService.getLivreParId(id));
    }

    // POST /api/livres
    // @RequestBody : récupère le JSON envoyé par Flutter
    // et le convertit en objet Livre automatiquement
    @PostMapping
    public ResponseEntity<Livre> creerLivre(
            @RequestBody Livre livre) {
        Livre nouveauLivre = livreService.creerLivre(livre);
        // 201 CREATED → code HTTP pour une création réussie
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(nouveauLivre);
    }

    // PUT /api/livres/1
    @PutMapping("/{id}")
    public ResponseEntity<Livre> modifierLivre(
            @PathVariable Long id,
            @RequestBody Livre livre) {
        return ResponseEntity.ok(
                livreService.modifierLivre(id, livre)
        );
    }

    // DELETE /api/livres/1
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> supprimerLivre(
            @PathVariable Long id) {
        livreService.supprimerLivre(id);
        // 204 NO CONTENT → suppression réussie, pas de contenu retourné
        return ResponseEntity.noContent().build();
    }
}
