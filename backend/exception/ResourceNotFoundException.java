package com.bibliotheque.exception;


// @ResponseStatus dit à Spring Boot :
// "Quand cette erreur est lancée, retourne
// automatiquement le code HTTP 404 à Flutter"
// 404 = "Ressource non trouvée"
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ResponseStatus;

@ResponseStatus(HttpStatus.NOT_FOUND)

// extends RuntimeException :
// cette classe EST une exception Java
// On étend RuntimeException pour ne pas
// être obligé de la déclarer partout avec "throws"
public class ResourceNotFoundException extends RuntimeException {

    // super(message) transmet le message
    // à la classe parent RuntimeException
    // Ce message sera retourné à Flutter
    public ResourceNotFoundException(String message) {
        super(message);
    }
}
