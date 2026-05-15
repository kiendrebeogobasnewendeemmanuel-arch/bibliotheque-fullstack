package com.bibliotheque.service;


import com.bibliotheque.exception.ResourceNotFoundException;
import lombok.RequiredArgsConstructor;
import com.bibliotheque.model.Livre;
import org.springframework.stereotype.Service;
import com.bibliotheque.repository.LivreRepository;

import java.util.List;

// @Service dit à Spring Boot :
// "Cette classe contient la logique métier"
// Spring va la gérer automatiquement en mémoire
@Service

// @RequiredArgsConstructor (Lombok) :
// génère automatiquement le constructeur
// pour injecter LivreRepository
@RequiredArgsConstructor

public class LivreService {

    // Spring Boot injecte automatiquement LivreRepository
    // grâce à @RequiredArgsConstructor
    // Tu n'as pas besoin de faire new LivreRepository()
    private final LivreRepository livreRepository;

    // Retourne tous les livres
    public List<Livre> getTousLesLivres() {
        return livreRepository.findAll();
    }

    // Retourne un livre par son id
    // Lance une erreur si le livre n'existe pas
    public Livre getLivreParId(Long id) {
        return livreRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Livre non trouvé avec l'id : " + id
                ));
    }

    // Recherche par titre OU auteur
    public List<Livre> rechercherLivres(String mot) {
        if (mot == null || mot.isEmpty()) {
            return livreRepository.findAll();
        }
        // Cherche dans le titre
        List<Livre> parTitre = livreRepository
                .findByTitreContainingIgnoreCase(mot);
        // Cherche dans l'auteur
        List<Livre> parAuteur = livreRepository
                .findByAuteurContainingIgnoreCase(mot);

        // Fusionne les deux listes sans doublons
        parTitre.addAll(parAuteur);
        return parTitre.stream().distinct().toList();
    }

    // Filtre par année de publication (bonus du kata)
    public List<Livre> getLivresParAnnee(Integer annee) {
        return livreRepository.findByAnneePublication(annee);
    }

    // Retourne uniquement les livres disponibles
    public List<Livre> getLivresDisponibles() {
        return livreRepository.findByDisponible(true);
    }

    // Crée un nouveau livre
    public Livre creerLivre(Livre livre) {
        // Par sécurité, un livre créé est toujours disponible
        livre.setDisponible(true);
        return livreRepository.save(livre);
    }

    // Modifie un livre existant
    public Livre modifierLivre(Long id, Livre livreModifie) {
        // Vérifie d'abord que le livre existe
        Livre livre = getLivreParId(id);

        // Met à jour les champs
        livre.setTitre(livreModifie.getTitre());
        livre.setAuteur(livreModifie.getAuteur());
        livre.setAnneePublication(livreModifie.getAnneePublication());

        // Sauvegarde les modifications
        return livreRepository.save(livre);
    }

    // Supprime un livre
    public void supprimerLivre(Long id) {
        // Vérifie d'abord que le livre existe
        Livre livre = getLivreParId(id);
        livreRepository.delete(livre);
    }
}
