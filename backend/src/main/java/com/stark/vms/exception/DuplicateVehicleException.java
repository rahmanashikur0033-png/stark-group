package com.stark.vms.exception;

public class DuplicateVehicleException extends RuntimeException {
    public DuplicateVehicleException(String vehicleNumber) {
        super("A vehicle with number " + vehicleNumber + " already exists.");
    }
}
