package com.sportyx.backend.Services;


import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.sportyx.backend.Entities.AdminUser;
import com.sportyx.backend.Repositories.AdminUserRepository;

import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class AdminUserService {

    private final AdminUserRepository adminUserRepository;

    public List<AdminUser> getAllAdmins() {
        return adminUserRepository.findAll();
    }

    public AdminUser getAdminById(UUID id) {
        return adminUserRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Admin not found with id: " + id));
    }

    public AdminUser getAdminByEmail(String email) {
        return adminUserRepository.findByEmail(email)
            .orElseThrow(() -> new RuntimeException("Admin not found with email: " + email));
    }

    @Transactional
    public AdminUser createAdmin(com.sportyx.backend.DTO.AdminUserCreateDTO dto) {
        if (adminUserRepository.existsByEmail(dto.getEmail())) {
            throw new RuntimeException("Email already registered: " + dto.getEmail());
        }
        
        AdminUser admin = AdminUser.builder()
            .fullName(dto.getFullName())
            .email(dto.getEmail())
            .passwordHash(dto.getPasswordHash())
            .role(dto.getRole() != null ? dto.getRole() : "REVIEWER")
            .build();
            
        return adminUserRepository.save(admin);
    }

    @Transactional
    public void deactivateAdmin(UUID id) {
        AdminUser admin = getAdminById(id);
        admin.setIsActive(false);
        adminUserRepository.save(admin);
    }
}