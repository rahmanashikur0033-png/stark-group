package com.stark.vms.controller;

import com.stark.vms.exception.InvalidCredentialsException;
import com.stark.vms.model.AppUser;
import com.stark.vms.repository.AppUserRepository;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final AppUserRepository users;
    private final PasswordEncoder encoder;

    public AuthController(AppUserRepository users, PasswordEncoder encoder) {
        this.users = users;
        this.encoder = encoder;
    }

    public record LoginRequest(
            @NotBlank(message = "Username is required.") String username,
            @NotBlank(message = "Password is required.") String password) {
    }

    @PostMapping("/login")
    public Map<String, String> login(@Valid @RequestBody LoginRequest request) {
        AppUser user = users.findByUsernameIgnoreCase(request.username().trim())
                .orElseThrow(InvalidCredentialsException::new);
        if (!encoder.matches(request.password(), user.getPasswordHash())) {
            throw new InvalidCredentialsException();
        }
        return Map.of("username", user.getUsername());
    }
}
