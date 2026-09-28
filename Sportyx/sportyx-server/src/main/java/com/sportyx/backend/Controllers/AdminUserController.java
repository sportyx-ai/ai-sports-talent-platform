package com.sportyx.backend.Controllers;


import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import com.sportyx.backend.Entities.AdminUser;
import com.sportyx.backend.Services.AdminUserService;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/admin/users")
@RequiredArgsConstructor
public class AdminUserController {

    private final AdminUserService adminUserService;

    // GET /api/admin/users
    @GetMapping
    public ResponseEntity<List<AdminUser>> getAllAdmins() {
        return ResponseEntity.ok(adminUserService.getAllAdmins());
    }

    // GET /api/admin/users/{id}
    @GetMapping("/{id}")
    public ResponseEntity<AdminUser> getAdminById(@PathVariable UUID id) {
        return ResponseEntity.ok(adminUserService.getAdminById(id));
    }

    // POST /api/admin/users
    @PostMapping
    public ResponseEntity<AdminUser> createAdmin(@RequestBody com.sportyx.backend.DTO.AdminUserCreateDTO dto) {
        return ResponseEntity.status(HttpStatus.CREATED)
            .body(adminUserService.createAdmin(dto));
    }

    // DELETE /api/admin/users/{id}
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deactivateAdmin(@PathVariable UUID id) {
        adminUserService.deactivateAdmin(id);
        return ResponseEntity.noContent().build();
    }
}