import 'package:flutter/material.dart';
import '../models/lecteur.dart';
import '../services/api_service.dart';

class LecteursScreen extends StatefulWidget {
  const LecteursScreen({super.key});

  @override
  State<LecteursScreen> createState() => _LecteursScreenState();
}

class _LecteursScreenState extends State<LecteursScreen> {

  List<Lecteur> lecteurs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    chargerLecteurs();
  }

  Future<void> chargerLecteurs() async {
    setState(() => isLoading = true);
    try {
      final data = await ApiService.getLecteurs();
      setState(() {
        lecteurs = data;
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

  // Dialogue pour ajouter ou modifier un lecteur
  void afficherDialogueLecteur({Lecteur? lecteur}) {
    final nomController = TextEditingController(
        text: lecteur?.nom ?? '');
    final emailController = TextEditingController(
        text: lecteur?.email ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          lecteur == null ? 'Ajouter un lecteur' : 'Modifier le lecteur'
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Champ nom
            TextField(
              controller: nomController,
              decoration: const InputDecoration(
                labelText: 'Nom complet',
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 8),
            // Champ email
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
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
              final data = {
                'nom': nomController.text,
                'email': emailController.text,
              };
              try {
                if (lecteur == null) {
                  await ApiService.creerLecteur(data);
                  afficherSucces('Lecteur ajouté avec succès !');
                } else {
                  // Modification — à ajouter dans ApiService
                  afficherSucces('Lecteur modifié avec succès !');
                }
                Navigator.pop(context);
                chargerLecteurs();
              } catch (e) {
                afficherErreur('Erreur : $e');
              }
            },
            child: const Text('Sauvegarder'),
          ),
        ],
      ),
    );
  }

  // Supprime un lecteur
  Future<void> supprimerLecteur(int id) async {
    // Demande confirmation avant suppression
    final confirmer = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text(
            'Voulez-vous vraiment supprimer ce lecteur ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Non'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Oui, supprimer',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmer == true) {
      try {
        await ApiService.supprimerLecteur(id);
        afficherSucces('Lecteur supprimé !');
        chargerLecteurs();
      } catch (e) {
        afficherErreur('Erreur : $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('👥 Lecteurs'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : lecteurs.isEmpty
              ? const Center(
                  child: Text('Aucun lecteur enregistré'),
                )
              : ListView.builder(
                  itemCount: lecteurs.length,
                  itemBuilder: (context, index) {
                    final lecteur = lecteurs[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      child: ListTile(
                        // Avatar avec initiale du nom
                        leading: CircleAvatar(
                          backgroundColor: Colors.purple,
                          child: Text(
                            lecteur.nom[0].toUpperCase(),
                            style: const TextStyle(
                                color: Colors.white),
                          ),
                        ),
                        title: Text(lecteur.nom),
                        subtitle: Text(lecteur.email),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Bouton modifier
                            IconButton(
                              icon: const Icon(Icons.edit,
                                  color: Colors.orange),
                              onPressed: () =>
                                  afficherDialogueLecteur(
                                      lecteur: lecteur),
                            ),
                            // Bouton supprimer
                            IconButton(
                              icon: const Icon(Icons.delete,
                                  color: Colors.red),
                              onPressed: () =>
                                  supprimerLecteur(lecteur.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

      // Bouton pour ajouter un lecteur
      floatingActionButton: FloatingActionButton(
        onPressed: () => afficherDialogueLecteur(),
        backgroundColor: Colors.purple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}