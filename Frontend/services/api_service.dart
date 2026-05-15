import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/livre.dart';
import '../models/lecteur.dart';
import '../models/reservation.dart';

class ApiService {
  // L'adresse de ton API Spring Boot
  // C'est le port qu'on a configuré ensemble
  static const String baseUrl = 'http://localhost:8081/api';

  // =============================================
  // LIVRES
  // =============================================

  // Récupère tous les livres
  // GET /api/livres
  static Future<List<Livre>> getLivres() async {
    // Envoie la requête à Spring Boot
    final response = await http.get(
      Uri.parse('$baseUrl/livres'),
    );

    // 200 = succès
    if (response.statusCode == 200) {
      // Décode le JSON reçu
      List<dynamic> data = jsonDecode(response.body);
      // Convertit chaque élément en objet Livre
      return data.map((json) => Livre.fromJson(json)).toList();
    } else {
      throw Exception('Erreur lors du chargement des livres');
    }
  }

  // Recherche des livres par titre ou auteur
  // GET /api/livres?search=mot
  static Future<List<Livre>> rechercherLivres(String mot) async {
    final response = await http.get(
      Uri.parse('$baseUrl/livres?search=$mot'),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Livre.fromJson(json)).toList();
    } else {
      throw Exception('Erreur lors de la recherche');
    }
  }

  // Crée un nouveau livre
  // POST /api/livres
  static Future<Livre> creerLivre(Map<String, dynamic> livreData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/livres'),
      // Précise qu'on envoie du JSON
      headers: {'Content-Type': 'application/json'},
      // Convertit les données en JSON
      body: jsonEncode(livreData),
    );

    if (response.statusCode == 201) {
      return Livre.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Erreur lors de la création du livre');
    }
  }

  // Modifie un livre
  // PUT /api/livres/{id}
  static Future<Livre> modifierLivre(int id, Map<String, dynamic> livreData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/livres/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(livreData),
    );

    if (response.statusCode == 200) {
      return Livre.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Erreur lors de la modification du livre');
    }
  }

  // Supprime un livre
  // DELETE /api/livres/{id}
  static Future<void> supprimerLivre(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/livres/$id'),
    );

    if (response.statusCode != 204) {
      throw Exception('Erreur lors de la suppression du livre');
    }
  }

  // =============================================
  // LECTEURS
  // =============================================

  // Récupère tous les lecteurs
  // GET /api/lecteurs
  static Future<List<Lecteur>> getLecteurs() async {
    final response = await http.get(
      Uri.parse('$baseUrl/lecteurs'),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Lecteur.fromJson(json)).toList();
    } else {
      throw Exception('Erreur lors du chargement des lecteurs');
    }
  }

  // Crée un nouveau lecteur
  // POST /api/lecteurs
  static Future<Lecteur> creerLecteur(Map<String, dynamic> lecteurData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/lecteurs'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(lecteurData),
    );

    if (response.statusCode == 201) {
      return Lecteur.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Erreur lors de la création du lecteur');
    }
  }

  // Supprime un lecteur
  // DELETE /api/lecteurs/{id}
  static Future<void> supprimerLecteur(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/lecteurs/$id'),
    );

    if (response.statusCode != 204) {
      throw Exception('Erreur lors de la suppression du lecteur');
    }
  }

  // =============================================
  // RESERVATIONS
  // =============================================

  // Récupère toutes les réservations
  // GET /api/reservations
  static Future<List<Reservation>> getReservations() async {
    final response = await http.get(
      Uri.parse('$baseUrl/reservations'),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Reservation.fromJson(json)).toList();
    } else {
      throw Exception('Erreur lors du chargement des réservations');
    }
  }

  // Réserve un livre
  // POST /api/reservations
  static Future<Reservation> reserverLivre(
      int livreId, int lecteurId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/reservations'),
      headers: {'Content-Type': 'application/json'},
      // Spring Boot attend livreId et lecteurId
      body: jsonEncode({
        'livreId': livreId,
        'lecteurId': lecteurId,
      }),
    );

    if (response.statusCode == 201) {
      return Reservation.fromJson(jsonDecode(response.body));
    } else {
      // Récupère le message d'erreur de Spring Boot
      // ex: "Ce livre est déjà réservé"
      final error = jsonDecode(response.body);
      throw Exception(error['message']);
    }
  }

  // Annule une réservation
  // DELETE /api/reservations/{id}
  static Future<void> annulerReservation(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/reservations/$id'),
    );

    if (response.statusCode != 204) {
      throw Exception('Erreur lors de l\'annulation');
    }
  }

  // =============================================
  // DASHBOARD
  // =============================================

  // Récupère les statistiques
  // GET /api/dashboard
  static Future<Map<String, dynamic>> getDashboard() async {
    final response = await http.get(
      Uri.parse('$baseUrl/dashboard'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erreur lors du chargement du dashboard');
    }
  }
}