import 'package:flutter/material.dart';
import '../models/reservation.dart';
import '../models/livre.dart';
import '../models/lecteur.dart';
import '../services/api_service.dart';

class ReservationsScreen extends StatefulWidget {
  const ReservationsScreen({super.key});

  @override
  State<ReservationsScreen> createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends State<ReservationsScreen> {

  List<Reservation> reservations = [];
  List<Livre> livresDisponibles = [];
  List<Lecteur> lecteurs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    chargerDonnees();
  }

  // Charge tout en même temps
  Future<void> chargerDonnees() async {
    setState(() => isLoading = true);
    try {
      // Appels simultanés pour aller plus vite
      final results = await Future.wait([
        ApiService.getReservations(),
        ApiService.getLivres(),
        ApiService.getLecteurs(),
      ]);

      setState(() {
        reservations = results[0] as List<Reservation>;

        // Garde seulement les livres disponibles
        // pour la liste de réservation
        livresDisponibles = (results[1] as List<Livre>)
            .where((l) => l.disponible)
            .toList();

        lecteurs = results[2] as List<Lecteur>;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      afficherErreur('Erreur : $e');
    }
  }

  void afficherErreur(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        // Durée plus longue pour les erreurs
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void afficherSucces(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  // Dialogue pour créer une réservation
  void afficherDialogueReservation() {
    // Livre sélectionné dans le menu déroulant
    Livre? livreSelectionne;
    // Lecteur sélectionné dans le menu déroulant
    Lecteur? lecteurSelectionne;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        // StatefulBuilder permet de mettre à jour
        // le dialogue sans reconstruire tout l'écran
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('📚 Nouvelle réservation'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              // Menu déroulant — choix du livre
              DropdownButtonFormField<Livre>(
                decoration: const InputDecoration(
                  labelText: 'Choisir un livre disponible',
                  prefixIcon: Icon(Icons.book),
                ),
                items: livresDisponibles.map((livre) {
                  return DropdownMenuItem(
                    value: livre,
                    child: Text(
                      livre.titre,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setDialogState(() {
                    livreSelectionne = value;
                  });
                },
              ),

              const SizedBox(height: 16),

              // Menu déroulant — choix du lecteur
              DropdownButtonFormField<Lecteur>(
                decoration: const InputDecoration(
                  labelText: 'Choisir un lecteur',
                  prefixIcon: Icon(Icons.person),
                ),
                items: lecteurs.map((lecteur) {
                  return DropdownMenuItem(
                    value: lecteur,
                    child: Text(lecteur.nom),
                  );
                }).toList(),
                onChanged: (value) {
                  setDialogState(() {
                    lecteurSelectionne = value;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Vérifie que les deux sont sélectionnés
                if (livreSelectionne == null ||
                    lecteurSelectionne == null) {
                  afficherErreur(
                      'Veuillez sélectionner un livre et un lecteur');
                  return;
                }

                try {
                  await ApiService.reserverLivre(
                    livreSelectionne!.id,
                    lecteurSelectionne!.id,
                  );
                  Navigator.pop(context);
                  afficherSucces('Réservation créée avec succès !');
                  // Recharge tout
                  chargerDonnees();
                } catch (e) {
                  // Affiche le message d'erreur de Spring Boot
                  // ex: "Ce livre est déjà réservé"
                  afficherErreur(e.toString());
                }
              },
              child: const Text('Réserver'),
            ),
          ],
        ),
      ),
    );
  }

  // Annule une réservation
  Future<void> annulerReservation(int id) async {
    final confirmer = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Annuler la réservation'),
        content: const Text(
            'Voulez-vous vraiment annuler cette réservation ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Non'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Oui, annuler',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmer == true) {
      try {
        await ApiService.annulerReservation(id);
        afficherSucces('Réservation annulée !');
        chargerDonnees();
      } catch (e) {
        afficherErreur('Erreur : $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📋 Réservations'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : reservations.isEmpty
              ? const Center(
                  child: Text('Aucune réservation en cours'),
                )
              : ListView.builder(
                  itemCount: reservations.length,
                  itemBuilder: (context, index) {
                    final reservation = reservations[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Colors.orange,
                          child: Icon(Icons.bookmark,
                              color: Colors.white),
                        ),
                        title: Text(
                          reservation.livre.titre,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            // Nom du lecteur
                            Text(
                              '👤 ${reservation.lecteur.nom}',
                            ),
                            // Date de réservation
                            Text(
                              '📅 ${reservation.dateReservation}',
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey),
                            ),
                          ],
                        ),
                        // Bouton annuler
                        trailing: IconButton(
                          icon: const Icon(Icons.cancel,
                              color: Colors.red),
                          onPressed: () =>
                              annulerReservation(reservation.id),
                        ),
                      ),
                    );
                  },
                ),

      // Bouton pour créer une réservation
      floatingActionButton: FloatingActionButton.extended(
        onPressed: afficherDialogueReservation,
        backgroundColor: Colors.orange,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Réserver',
            style: TextStyle(color: Colors.white)),
      ),
    );
  }
}