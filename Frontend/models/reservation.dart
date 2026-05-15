// On importe Livre et Lecteur
// car une Reservation contient les deux
import 'livre.dart';
import 'lecteur.dart';

class Reservation {
  final int id;
  final Livre livre;
  final Lecteur lecteur;
  final String dateReservation;

  Reservation({
    required this.id,
    required this.livre,
    required this.lecteur,
    required this.dateReservation,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'],
      // Le JSON contient un objet livre imbriqué
      // on utilise Livre.fromJson pour le convertir
      livre: Livre.fromJson(json['livre']),
      // Pareil pour le lecteur
      lecteur: Lecteur.fromJson(json['lecteur']),
      dateReservation: json['dateReservation'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'livreId': livre.id,
      'lecteurId': lecteur.id,
    };
  }
}