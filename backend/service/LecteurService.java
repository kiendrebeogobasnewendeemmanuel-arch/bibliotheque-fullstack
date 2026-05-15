package com.bibliotheque.service;


import com.bibliotheque.exception.ResourceNotFoundException;
import lombok.RequiredArgsConstructor;
import com.bibliotheque.model.Lecteur;
import org.springframework.stereotype.Service;
import com.bibliotheque.repository.LecteurRepository;

import java.util.List;

@Service
@RequiredArgsConstructor
public class LecteurService {

    private final LecteurRepository lecteurRepository;

    // Retourne tous les lecteurs
    public List<Lecteur> getTousLesLecteurs() {
        return lecteurRepository.findAll();
    }

    // Retourne un lecteur par son id
    public Lecteur getLecteurParId(Long id) {
        return lecteurRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Lecteur non trouvé avec l'id : " + id
                ));
    }

    // Crée un nouveau lecteur
    public Lecteur creerLecteur(Lecteur lecteur) {
        // Vérifie si l'email existe déjà
        lecteurRepository.findByEmail(lecteur.getEmail())
                .ifPresent(l -> {
                    throw new IllegalArgumentException(
                            "Un lecteur avec cet email existe déjà"
                    );
                });
        return lecteurRepository.save(lecteur);
    }

    // Modifie un lecteur existant
    public Lecteur modifierLecteur(Long id, Lecteur lecteurModifie) {
        Lecteur lecteur = getLecteurParId(id);
        lecteur.setNom(lecteurModifie.getNom());
        lecteur.setEmail(lecteurModifie.getEmail());
        return lecteurRepository.save(lecteur);
    }

    // Supprime un lecteur
    public void supprimerLecteur(Long id) {
        Lecteur lecteur = getLecteurParId(id);
        lecteurRepository.delete(lecteur);
    }
}
