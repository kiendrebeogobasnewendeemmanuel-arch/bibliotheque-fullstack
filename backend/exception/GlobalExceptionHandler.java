package com.bibliotheque.exception;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

// @RestControllerAdvice dit à Spring Boot :
// "Cette classe intercepte TOUTES les erreurs
// lancées dans l'application et les formate
// en JSON avant de les envoyer à Flutter"
@RestControllerAdvice
public class GlobalExceptionHandler {

    // Intercepte ResourceNotFoundException
    // et retourne une réponse JSON avec le code 404
    @ExceptionHandler(ResourceNotFoundException.class)
    public ResponseEntity<Map<String, Object>> handleNotFound(
            ResourceNotFoundException ex) {
        return buildResponse(HttpStatus.NOT_FOUND, ex.getMessage());
    }

    // Intercepte LivreDejaReserveException
    // et retourne une réponse JSON avec le code 409
    @ExceptionHandler(LivreDejaReserveException.class)
    public ResponseEntity<Map<String, Object>> handleDejaReserve(
            LivreDejaReserveException ex) {
        return buildResponse(HttpStatus.CONFLICT, ex.getMessage());
    }

    // Intercepte les erreurs générales
    // et retourne une réponse JSON avec le code 500
    @ExceptionHandler(Exception.class)
    public ResponseEntity<Map<String, Object>> handleGeneral(
            Exception ex) {
        return buildResponse(
                HttpStatus.INTERNAL_SERVER_ERROR,
                "Une erreur interne est survenue"
        );
    }

    // Méthode utilitaire qui construit
    // la réponse JSON envoyée à Flutter
    private ResponseEntity<Map<String, Object>> buildResponse(
            HttpStatus status, String message) {

        // Le JSON que Flutter recevra :
        // {
        //   "status": 404,
        //   "message": "Livre non trouvé avec l'id : 5",
        //   "timestamp": "2024-01-15T10:30:00"
        // }
        Map<String, Object> body = new HashMap<>();
        body.put("status", status.value());
        body.put("message", message);
        body.put("timestamp", LocalDateTime.now().toString());

        return new ResponseEntity<>(body, status);
    }
}
