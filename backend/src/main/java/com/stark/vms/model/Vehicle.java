package com.stark.vms.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.*;

@Entity
@Table(name = "vehicles",
       uniqueConstraints = @UniqueConstraint(name = "uk_vehicle_number", columnNames = "vehicle_number"))
public class Vehicle {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotBlank(message = "Vehicle number is required")
    @Size(max = 30, message = "Vehicle number must be 30 characters or fewer")
    @Column(name = "vehicle_number", nullable = false, length = 30)
    private String vehicleNumber;

    @NotBlank(message = "Type is required")
    @Column(name = "vehicle_type", nullable = false, length = 30)
    private String type;

    @NotBlank(message = "Brand is required")
    @Column(nullable = false, length = 60)
    private String brand;

    @NotBlank(message = "Model is required")
    @Column(name = "vehicle_model", nullable = false, length = 60)
    private String model;

    @NotNull(message = "Year is required")
    @Min(value = 1950, message = "Year must be 1950 or later")
    @Max(value = 2100, message = "Year is not valid")
    @Column(name = "manufacture_year", nullable = false)
    private Integer year;

    @NotBlank(message = "Status is required")
    @Column(nullable = false, length = 20)
    private String status;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getVehicleNumber() { return vehicleNumber; }
    public void setVehicleNumber(String vehicleNumber) { this.vehicleNumber = vehicleNumber; }
    public String getType() { return type; }
    public void setType(String type) { this.type = type; }
    public String getBrand() { return brand; }
    public void setBrand(String brand) { this.brand = brand; }
    public String getModel() { return model; }
    public void setModel(String model) { this.model = model; }
    public Integer getYear() { return year; }
    public void setYear(Integer year) { this.year = year; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
}
