package com.stark.vms.controller;

import com.stark.vms.model.Vehicle;
import com.stark.vms.service.VehicleService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/vehicles")
public class VehicleController {

    private final VehicleService service;

    public VehicleController(VehicleService service) {
        this.service = service;
    }

    @GetMapping
    public List<Vehicle> list() {
        return service.findAll();
    }

    @GetMapping("/{id}")
    public Vehicle get(@PathVariable Long id) {
        return service.findById(id);
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public Vehicle create(@Valid @RequestBody Vehicle vehicle) {
        return service.create(vehicle);
    }

    @PutMapping("/{id}")
    public Vehicle update(@PathVariable Long id, @Valid @RequestBody Vehicle vehicle) {
        return service.update(id, vehicle);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void delete(@PathVariable Long id) {
        service.delete(id);
    }
}
