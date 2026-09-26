package com.sportyx.backend.Controllers;


import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.support.ServletUriComponentsBuilder;

import com.sportyx.backend.Entities.Manager;
import com.sportyx.backend.Services.ManagerService;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/managers")
@RequiredArgsConstructor
public class ManagerController {

    private final ManagerService managerService;
    private final com.sportyx.backend.Repositories.ManagerRepository managerRepository;

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
    public ResponseEntity<?> register(@RequestBody com.sportyx.backend.DTO.ManagerRegistrationDTO dto) {
        if (dto.getEmail() == null || dto.getEmail().trim().isEmpty()) {
            return ResponseEntity.badRequest().body(Map.of("message", "Email is required"));
        }
        if (dto.getFullName() == null || dto.getFullName().trim().isEmpty()) {
            return ResponseEntity.badRequest().body(Map.of("message", "Full name is required"));
        }
        if (dto.getPasswordHash() == null || dto.getPasswordHash().trim().isEmpty()) {
            return ResponseEntity.badRequest().body(Map.of("message", "Password is required"));
        }
        try {
            java.util.Optional<Manager> existing = managerRepository.findByEmail(dto.getEmail().trim().toLowerCase());
            if (existing.isPresent()) {
                Manager mgr = existing.get();
                mgr.setFullName(dto.getFullName().trim());
                mgr.setPasswordHash(dto.getPasswordHash().trim());
                if (dto.getPhone() != null && !dto.getPhone().trim().isEmpty()) {
                    mgr.setPhone(dto.getPhone().trim());
                }
                if (dto.getOrganization() != null && !dto.getOrganization().trim().isEmpty()) {
                    mgr.setOrganization(dto.getOrganization().trim());
                }
                if (dto.getAge() != null) mgr.setAge(dto.getAge());
                if (dto.getGender() != null) mgr.setGender(dto.getGender());
                if (dto.getIdNumber() != null) mgr.setIdNumber(dto.getIdNumber());
                if (dto.getIdProofUrl() != null) mgr.setIdProofUrl(dto.getIdProofUrl());
                mgr.setIsActive(true);
                return ResponseEntity.ok(managerRepository.save(mgr));
            }

            Manager manager = Manager.builder()
                .fullName(dto.getFullName().trim())
                .email(dto.getEmail().trim().toLowerCase())
                .passwordHash(dto.getPasswordHash().trim())
                .phone(dto.getPhone() != null ? dto.getPhone().trim() : null)
                .organization(dto.getOrganization() != null ? dto.getOrganization().trim() : null)
                .age(dto.getAge())
                .gender(dto.getGender())
                .idNumber(dto.getIdNumber())
                .idProofUrl(dto.getIdProofUrl())
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
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.CONFLICT)
                .body(Map.of("message", e.getMessage()));
        }
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

    // POST /api/managers/upload-id-proof
    @PostMapping(
        value = "/upload-id-proof",
        consumes = {"multipart/form-data"}
    )
    public ResponseEntity<Map<String, Object>> uploadIdProof(
        @RequestPart("file") MultipartFile file
    ) {
        try {
            String uploadDir = "uploads/id_proofs";
            Files.createDirectories(Paths.get(uploadDir));

            String originalFileName = file.getOriginalFilename() != null ? file.getOriginalFilename() : "id_proof.jpg";
            String filename = System.currentTimeMillis() + "_" + originalFileName.replaceAll("[^a-zA-Z0-9._-]", "_");
            Path filepath = Paths.get(uploadDir, filename);

            Files.copy(file.getInputStream(), filepath, StandardCopyOption.REPLACE_EXISTING);

            String baseUrl = ServletUriComponentsBuilder.fromCurrentContextPath().build().toUriString();
            String fileUrl = baseUrl + "/uploads/id_proofs/" + filename;

            return ResponseEntity.status(HttpStatus.CREATED).body(Map.of(
                "fileUrl", fileUrl,
                "fileName", filename,
                "message", "ID Proof uploaded successfully"
            ));
        } catch (IOException e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(Map.of("error", "Failed to upload ID proof: " + e.getMessage()));
        }
    }

    // POST /api/managers/{managerId}/athletes/upload-photo
    @PostMapping(
        value = "/{managerId}/athletes/upload-photo",
        consumes = {"multipart/form-data"}
    )
    public ResponseEntity<Map<String, Object>> uploadAthletePhoto(
        @PathVariable UUID managerId,
        @RequestPart("file") MultipartFile file,
        @RequestPart(value = "fileName", required = false) String fileName
    ) {
        try {
            String uploadDir = "uploads/athletes";
            Files.createDirectories(Paths.get(uploadDir));

            String originalFileName = fileName != null ? fileName : file.getOriginalFilename();
            String filename = System.currentTimeMillis() + "_" + originalFileName;
            Path filepath = Paths.get(uploadDir, filename);

            Files.copy(file.getInputStream(), filepath, StandardCopyOption.REPLACE_EXISTING);

            String baseUrl = ServletUriComponentsBuilder.fromCurrentContextPath().build().toUriString();
            String fileUrl = baseUrl + "/uploads/athletes/" + filename;

            return ResponseEntity.status(HttpStatus.CREATED).body(Map.of(
                "fileUrl", fileUrl,
                "fileName", filename,
                "message", "Photo uploaded successfully"
            ));
        } catch (IOException e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(Map.of("error", "Failed to upload photo: " + e.getMessage()));
        }
    }
}