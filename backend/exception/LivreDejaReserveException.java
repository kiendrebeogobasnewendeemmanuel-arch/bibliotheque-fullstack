package com.bibliotheque.exception;



// 409 = "Conflit"
// Parfait pour signaler qu'un livre
// est déjà réservé par quelqu'un d'autre
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ResponseStatus;

@ResponseStatus(HttpStatus.CONFLICT)
public class LivreDejaReserveException extends RuntimeException {

    public LivreDejaReserveException(String message) {
        super(message);
    }
}
