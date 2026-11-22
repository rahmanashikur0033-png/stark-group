package com.stark.vms.exception;

public class VehicleNotFoundException extends RuntimeException {
    public VehicleNotFoundException(Long id) {
        super("Vehicle with id " + id + " was not found.");
    }
}
