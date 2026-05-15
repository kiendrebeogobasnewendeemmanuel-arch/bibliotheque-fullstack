import 'package:flutter/material.dart';
import '../services/api_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {

  // Les statistiques reçues de Spring Boot
  Map<String, dynamic> stats = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    chargerStats();
  }

  Future<void> chargerStats() async {
    setState(() => isLoading = true);
    try {
      final data = await ApiService.getDashboard();
      setState(() {
        stats = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur : $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📊 Tableau de bord'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        // Bouton pour rafraîchir les stats
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: chargerStats,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              // Glisse vers le bas pour rafraîchir
              onRefresh: chargerStats,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // Titre de section
                    const Text(
                      '📚 Livres',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Ligne 1 — stats livres
                    Row(
                      children: [
                        // Total livres
                        Expanded(
                          child: _carteStatistique(
                            titre: 'Total livres',
                            valeur: '${stats['totalLivres'] ?? 0}',
                            icone: Icons.book,
                            couleur: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Livres disponibles
                        Expanded(
                          child: _carteStatistique(
                            titre: 'Disponibles',
                            valeur: '${stats['livresDisponibles'] ?? 0}',
                            icone: Icons.check_circle,
                            couleur: Colors.green,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Livres réservés
                        Expanded(
                          child: _carteStatistique(
                            titre: 'Réservés',
                            valeur: '${stats['livresReserves'] ?? 0}',
                            icone: Icons.bookmark,
                            couleur: Colors.red,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Titre de section
                    const Text(
                      '👥 Lecteurs & Réservations',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Ligne 2 — stats lecteurs
                    Row(
                      children: [
                        // Total lecteurs
                        Expanded(
                          child: _carteStatistique(
                            titre: 'Total lecteurs',
                            valeur: '${stats['totalLecteurs'] ?? 0}',
                            icone: Icons.people,
                            couleur: Colors.purple,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Total réservations
                        Expanded(
                          child: _carteStatistique(
                            titre: 'Réservations',
                            valeur: '${stats['totalReservations'] ?? 0}',
                            icone: Icons.list_alt,
                            couleur: Colors.orange,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Barre de progression disponibles vs réservés
                    const Text(
                      '📈 Taux de réservation',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Disponibles',
                                    style: TextStyle(
                                        color: Colors.green)),
                                const Text('Réservés',
                                    style:
                                        TextStyle(color: Colors.red)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Barre de progression
                            LinearProgressIndicator(
                              value: _calculerTaux(),
                              backgroundColor: Colors.green.shade200,
                              valueColor:
                                  const AlwaysStoppedAnimation<Color>(
                                      Colors.red),
                              minHeight: 16,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${(_calculerTaux() * 100).toStringAsFixed(1)}% des livres sont réservés',
                              style: const TextStyle(
                                  color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // Calcule le taux de réservation
  // pour la barre de progression
  double _calculerTaux() {
    final total = stats['totalLivres'] ?? 0;
    final reserves = stats['livresReserves'] ?? 0;
    if (total == 0) return 0;
    return reserves / total;
  }

  // Widget réutilisable pour afficher une statistique
  Widget _carteStatistique({
    required String titre,
    required String valeur,
    required IconData icone,
    required Color couleur,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Icône colorée
            Icon(icone, color: couleur, size: 32),
            const SizedBox(height: 8),
            // Valeur en grand
            Text(
              valeur,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: couleur,
              ),
            ),
            const SizedBox(height: 4),
            // Titre en petit
            Text(
              titre,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}