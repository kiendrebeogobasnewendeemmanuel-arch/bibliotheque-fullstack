class Lecteur {
  final int id;
  final String nom;
  final String email;

  Lecteur({
    required this.id,
    required this.nom,
    required this.email,
  });

  factory Lecteur.fromJson(Map<String, dynamic> json) {
    return Lecteur(
      id: json['id'],
      nom: json['nom'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nom': nom,
      'email': email,
    };
  }
}