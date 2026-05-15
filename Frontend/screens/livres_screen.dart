import 'package:flutter/material.dart';
import '../models/livre.dart';
import '../services/api_service.dart';

class LivresScreen extends StatefulWidget {
  const LivresScreen({super.key});

  @override
  State<LivresScreen> createState() => _LivresScreenState();
}

// StatefulWidget car l'écran change selon
// les actions de l'utilisateur
class _LivresScreenState extends State<LivresScreen> {

  // La liste des livres affichée
  List<Livre> livres = [];

  // Pour afficher un indicateur de chargement
  bool isLoading = true;

  // Contrôleur du champ de recherche
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Charge les livres au démarrage de l'écran
    chargerLivres();
  }

  // Charge tous les livres depuis Spring Boot
  Future<void> chargerLivres() async {
    setState(() => isLoading = true);
    try {
      final data = await ApiService.getLivres();
      setState(() {
        livres = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      afficherErreur('Erreur : $e');
    }
  }

  // Recherche des livres par titre ou auteur
  Future<void> rechercherLivres(String mot) async {
    if (mot.isEmpty) {
      chargerLivres();
      return;
    }
    setState(() => isLoading = true);
    try {
      final data = await ApiService.rechercherLivres(mot);
      setState(() {
        livres = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      afficherErreur('Erreur : $e');
    }
  }

  // Affiche un message d'erreur en bas de l'écran
  void afficherErreur(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  // Affiche un message de succès
  void afficherSucces(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  // Dialogue pour ajouter ou modifier un livre
  void afficherDialogueLivre({Livre? livre}) {
    final titreController = TextEditingController(
        text: livre?.titre ?? '');
    final auteurController = TextEditingController(
        text: livre?.auteur ?? '');
    final anneeController = TextEditingController(
        text: livre?.anneePublication.toString() ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(livre == null ? 'Ajouter un livre' : 'Modifier le livre'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Champ titre
            TextField(
              controller: titreController,
              decoration: const InputDecoration(labelText: 'Titre'),
            ),
            // Champ auteur
            TextField(
              controller: auteurController,
              decoration: const InputDecoration(labelText: 'Auteur'),
            ),
            // Champ année
            TextField(
              controller: anneeController,
              decoration: const InputDecoration(
                  labelText: 'Année de publication'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          // Bouton Annuler
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          // Bouton Sauvegarder
          ElevatedButton(
            onPressed: () async {
              final data = {
                'titre': titreController.text,
                'auteur': auteurController.text,
                'anneePublication': int.parse(anneeController.text),
              };
              try {
                if (livre == null) {
                  // Création
                  await ApiService.creerLivre(data);
                  afficherSucces('Livre ajouté avec succès !');
                } else {
                  // Modification
                  await ApiService.modifierLivre(livre.id, data);
                  afficherSucces('Livre modifié avec succès !');
                }
                Navigator.pop(context);
                // Recharge la liste
                chargerLivres();
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

  // Supprime un livre
  Future<void> supprimerLivre(int id) async {
    try {
      await ApiService.supprimerLivre(id);
      afficherSucces('Livre supprimé !');
      chargerLivres();
    } catch (e) {
      afficherErreur('Erreur : $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📚 Livres'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Barre de recherche
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher par titre ou auteur...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    searchController.clear();
                    chargerLivres();
                  },
                ),
              ),
              onChanged: rechercherLivres,
            ),
          ),

          // Liste des livres
          Expanded(
            child: isLoading
                // Indicateur de chargement
                ? const Center(child: CircularProgressIndicator())
                : livres.isEmpty
                    ? const Center(child: Text('Aucun livre trouvé'))
                    : ListView.builder(
                        itemCount: livres.length,
                        itemBuilder: (context, index) {
                          final livre = livres[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            child: ListTile(
                              // Icône selon disponibilité
                              leading: Icon(
                                livre.disponible
                                    ? Icons.book
                                    : Icons.book_outlined,
                                color: livre.disponible
                                    ? Colors.green
                                    : Colors.red,
                              ),
                              title: Text(livre.titre),
                              subtitle: Text(
                                  '${livre.auteur} · ${livre.anneePublication}'),
                              // Badge disponible/réservé
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: livre.disponible
                                          ? Colors.green
                                          : Colors.red,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      livre.disponible
                                          ? 'Disponible'
                                          : 'Réservé',
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 12),
                                    ),
                                  ),
                                  // Bouton modifier
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.orange),
                                    onPressed: () =>
                                        afficherDialogueLivre(livre: livre),
                                  ),
                                  // Bouton supprimer
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () => supprimerLivre(livre.id),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),

      // Bouton flottant pour ajouter un livre
      floatingActionButton: FloatingActionButton(
        onPressed: () => afficherDialogueLivre(),
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}