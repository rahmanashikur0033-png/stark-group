package com.stark.vms.repository;

import com.stark.vms.model.Vehicle;
import org.springframework.data.jpa.repository.JpaRepository;

public interface VehicleRepository extends JpaRepository<Vehicle, Long> {

    boolean existsByVehicleNumberIgnoreCase(String vehicleNumber);

    boolean existsByVehicleNumberIgnoreCaseAndIdNot(String vehicleNumber, Long id);
}
