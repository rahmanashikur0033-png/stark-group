package com.stark.vms;

import com.stark.vms.model.AppUser;
import com.stark.vms.model.Vehicle;
import com.stark.vms.repository.AppUserRepository;
import com.stark.vms.repository.VehicleRepository;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;

@SpringBootApplication
public class VmsApplication {

    public static void main(String[] args) {
        SpringApplication.run(VmsApplication.class, args);
    }

    @Bean
    PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    /** Adds a default login and a few sample vehicles the first time the tables are empty. */
    @Bean
    CommandLineRunner seedData(VehicleRepository repo, AppUserRepository users, PasswordEncoder encoder) {
        return args -> {
            if (users.count() == 0) {
                AppUser admin = new AppUser();
                admin.setUsername("admin");
                admin.setPasswordHash(encoder.encode("admin123"));
                users.save(admin);
            }
            if (repo.count() > 0) return;
            repo.save(make("DHA-METRO-11-2045", "Car", "Toyota", "Corolla", 2021, "Active"));
            repo.save(make("DHA-METRO-14-7788", "Truck", "Tata", "Prima", 2019, "Maintenance"));
            repo.save(make("CTG-METRO-13-3021", "Van", "Nissan", "Caravan", 2018, "Inactive"));
        };
    }

    private Vehicle make(String number, String type, String brand, String model, int year, String status) {
        Vehicle v = new Vehicle();
        v.setVehicleNumber(number);
        v.setType(type);
        v.setBrand(brand);
        v.setModel(model);
        v.setYear(year);
        v.setStatus(status);
        return v;
    }
}
