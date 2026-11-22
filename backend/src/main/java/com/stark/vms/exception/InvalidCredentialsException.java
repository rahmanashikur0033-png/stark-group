package com.stark.vms.exception;

public class InvalidCredentialsException extends RuntimeException {
    public InvalidCredentialsException() {
        super("Incorrect username or password.");
    }
}
