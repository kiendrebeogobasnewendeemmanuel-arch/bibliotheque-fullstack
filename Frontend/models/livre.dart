class Livre {
  // Les mêmes champs que ta table PostgreSQL
  final int id;
  final String titre;
  final String auteur;
  final int anneePublication;
  final bool disponible;

  // Constructeur
  Livre({
    required this.id,
    required this.titre,
    required this.auteur,
    required this.anneePublication,
    required this.disponible,
  });

  // fromJson : convertit le JSON de Spring Boot
  // en objet Dart utilisable dans Flutter
  // Exemple JSON reçu :
  // {"id":1,"titre":"Clean Code","auteur":"Martin",...}
  factory Livre.fromJson(Map<String, dynamic> json) {
    return Livre(
      id: json['id'],
      titre: json['titre'],
      auteur: json['auteur'],
      // Spring Boot envoie "anneePublication"
      // exactement comme dans ton modèle Java
      anneePublication: json['anneePublication'],
      disponible: json['disponible'],
    );
  }

  // toJson : convertit l'objet Dart en JSON
  // pour envoyer à Spring Boot
  Map<String, dynamic> toJson() {
    return {
      'titre': titre,
      'auteur': auteur,
      'anneePublication': anneePublication,
      'disponible': disponible,
    };
  }
}