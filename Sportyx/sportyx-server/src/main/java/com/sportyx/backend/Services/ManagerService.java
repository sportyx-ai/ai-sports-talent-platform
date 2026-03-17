package com.sportyx.backend.Services;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.sportyx.backend.Entities.Manager;
import com.sportyx.backend.Repositories.ManagerRepository;

import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ManagerService {

    private final ManagerRepository managerRepository;

    public List<Manager> getAllManagers() {
        return managerRepository.findAll();
    }

    public Manager getManagerById(UUID id) {
        return managerRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Manager not found with id: " + id));
    }

    public Manager getManagerByEmail(String email) {
        return managerRepository.findByEmail(email)
            .orElseThrow(() -> new RuntimeException("Manager not found with email: " + email));
    }

    @Transactional
    public Manager createManager(Manager manager) {
        if (managerRepository.existsByEmail(manager.getEmail())) {
            throw new RuntimeException("Email already registered: " + manager.getEmail());
        }
        return managerRepository.save(manager);
    }

    @Transactional
    public Manager updateManager(UUID id, com.sportyx.backend.DTO.ManagerUpdateDTO dto) {
        Manager existing = getManagerById(id);
        existing.setFullName(dto.getFullName());
        existing.setPhone(dto.getPhone());
        existing.setOrganization(dto.getOrganization());
        
        // Add new athletes if provided
        if (dto.getAthletes() != null && !dto.getAthletes().isEmpty()) {
            dto.getAthletes().forEach(athleteDTO -> {
                com.sportyx.backend.Entities.Athlete athlete = com.sportyx.backend.Entities.Athlete.builder()
                    .fullName(athleteDTO.getFullName())
                    .dateOfBirth(athleteDTO.getDateOfBirth())
                    .gender(athleteDTO.getGender())
                    .profilePhotoUrl(athleteDTO.getProfilePhotoUrl())
                    .sportCategory(athleteDTO.getSportCategory())
                    .skillLevel(athleteDTO.getSkillLevel() != null && 
                        !athleteDTO.getSkillLevel().isEmpty() && 
                        !athleteDTO.getSkillLevel().equalsIgnoreCase("string") ? 
                        com.sportyx.backend.Enums.SkillLevel.valueOf(athleteDTO.getSkillLevel().toUpperCase()) : null)
                    .schoolInstitution(athleteDTO.getSchoolInstitution())
                    .manager(existing)
                    .build();
                existing.getAthletes().add(athlete);
            });
        }
        
        return managerRepository.save(existing);
    }

    @Transactional
    public void deactivateManager(UUID id) {
        Manager manager = getManagerById(id);
        manager.setIsActive(false);
        managerRepository.save(manager);
    }
}