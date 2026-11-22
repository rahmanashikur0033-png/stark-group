package com.stark.vms.service;

import com.stark.vms.exception.DuplicateVehicleException;
import com.stark.vms.exception.VehicleNotFoundException;
import com.stark.vms.model.Vehicle;
import com.stark.vms.repository.VehicleRepository;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class VehicleService {

    private final VehicleRepository repository;

    public VehicleService(VehicleRepository repository) {
        this.repository = repository;
    }

    public List<Vehicle> findAll() {
        return repository.findAll(Sort.by(Sort.Direction.DESC, "id"));
    }

    public Vehicle findById(Long id) {
        return repository.findById(id).orElseThrow(() -> new VehicleNotFoundException(id));
    }

    public Vehicle create(Vehicle input) {
        normalize(input);
        if (repository.existsByVehicleNumberIgnoreCase(input.getVehicleNumber())) {
            throw new DuplicateVehicleException(input.getVehicleNumber());
        }
        input.setId(null);
        return repository.save(input);
    }

    public Vehicle update(Long id, Vehicle input) {
        Vehicle existing = findById(id);
        normalize(input);
        if (repository.existsByVehicleNumberIgnoreCaseAndIdNot(input.getVehicleNumber(), id)) {
            throw new DuplicateVehicleException(input.getVehicleNumber());
        }
        existing.setVehicleNumber(input.getVehicleNumber());
        existing.setType(input.getType());
        existing.setBrand(input.getBrand());
        existing.setModel(input.getModel());
        existing.setYear(input.getYear());
        existing.setStatus(input.getStatus());
        return repository.save(existing);
    }

    public void delete(Long id) {
        if (!repository.existsById(id)) {
            throw new VehicleNotFoundException(id);
        }
        repository.deleteById(id);
    }

    /** Trim text and store vehicle numbers in upper case so "abc-1" and "ABC-1" count as duplicates. */
    private void normalize(Vehicle v) {
        v.setVehicleNumber(v.getVehicleNumber().trim().toUpperCase());
        v.setType(v.getType().trim());
        v.setBrand(v.getBrand().trim());
        v.setModel(v.getModel().trim());
        v.setStatus(v.getStatus().trim());
    }
}
