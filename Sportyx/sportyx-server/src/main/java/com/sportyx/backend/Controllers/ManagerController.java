package com.sportyx.backend.Controllers;


import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import com.sportyx.backend.Entities.Manager;
import com.sportyx.backend.Services.ManagerService;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/managers")
@RequiredArgsConstructor
public class ManagerController {

    private final ManagerService managerService;

    // GET /api/managers
    @GetMapping
    public ResponseEntity<List<Manager>> getAllManagers() {
        return ResponseEntity.ok(managerService.getAllManagers());
    }

    // GET /api/managers/{id}
    @GetMapping("/{id}")
    public ResponseEntity<Manager> getManagerById(@PathVariable UUID id) {
        return ResponseEntity.ok(managerService.getManagerById(id));
    }

    // POST /api/managers/register
    @PostMapping("/register")
    public ResponseEntity<Manager> register(@RequestBody com.sportyx.backend.DTO.ManagerRegistrationDTO dto) {
        Manager manager = Manager.builder()
            .fullName(dto.getFullName())
            .email(dto.getEmail())
            .passwordHash(dto.getPasswordHash())
            .phone(dto.getPhone())
            .organization(dto.getOrganization())
            .role(dto.getRole() != null ? dto.getRole() : "PT_TEACHER")
            .build();
        
        if (dto.getAthletes() != null) {
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
                    .manager(manager)
                    .build();
                manager.getAthletes().add(athlete);
            });
        }
        
        return ResponseEntity.status(HttpStatus.CREATED)
            .body(managerService.createManager(manager));
    }

    // PUT /api/managers/{id}
    @PutMapping("/{id}")
    public ResponseEntity<Manager> updateManager(@PathVariable UUID id,
                                                  @RequestBody com.sportyx.backend.DTO.ManagerUpdateDTO dto) {
        return ResponseEntity.ok(managerService.updateManager(id, dto));
    }

    // DELETE /api/managers/{id}  (soft delete)
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deactivate(@PathVariable UUID id) {
        managerService.deactivateManager(id);
        return ResponseEntity.noContent().build();
    }
}