package com.sportyx.backend.Services;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.sportyx.backend.Entities.Athlete;
import com.sportyx.backend.Entities.Manager;
import com.sportyx.backend.Repositories.AthleteRepository;

import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class AthleteService {

    private final AthleteRepository athleteRepository;
    private final ManagerService managerService;

    public List<Athlete> getAthletesByManager(UUID managerId) {
        return athleteRepository.findByManagerIdAndIsActiveTrue(managerId);
    }

    public Athlete getAthleteById(UUID id) {
        return athleteRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Athlete not found with id: " + id));
    }

    public long countAthletesByManager(UUID managerId) {
        return athleteRepository.countByManagerId(managerId);
    }

    @Transactional
    public Athlete createAthlete(UUID managerId, com.sportyx.backend.DTO.AthleteCreateDTO dto) {
        Manager manager = managerService.getManagerById(managerId);
        
        Athlete athlete = Athlete.builder()
            .fullName(dto.getFullName())
            .dateOfBirth(dto.getDateOfBirth())
            .gender(dto.getGender())
            .profilePhotoUrl(dto.getProfilePhotoUrl())
            .sportCategory(dto.getSportCategory())
            .schoolInstitution(dto.getSchoolInstitution())
            .contactInfo(dto.getContactInfo())
            .manager(manager)
            .build();
            
        if (dto.getSkillLevel() != null && !dto.getSkillLevel().isEmpty() && 
            !dto.getSkillLevel().equalsIgnoreCase("string")) {
            athlete.setSkillLevel(com.sportyx.backend.Enums.SkillLevel.valueOf(dto.getSkillLevel().toUpperCase()));
        }
        
        return athleteRepository.save(athlete);
    }

    @Transactional
    public Athlete updateAthlete(UUID athleteId, com.sportyx.backend.DTO.AthleteUpdateDTO dto) {
        Athlete existing = getAthleteById(athleteId);
        existing.setFullName(dto.getFullName());
        existing.setDateOfBirth(dto.getDateOfBirth());
        existing.setGender(dto.getGender());
        existing.setProfilePhotoUrl(dto.getProfilePhotoUrl());
        existing.setSportCategory(dto.getSportCategory());
        
        if (dto.getSkillLevel() != null && !dto.getSkillLevel().isEmpty() && 
            !dto.getSkillLevel().equalsIgnoreCase("string")) {
            existing.setSkillLevel(com.sportyx.backend.Enums.SkillLevel.valueOf(dto.getSkillLevel().toUpperCase()));
        }
        
        existing.setSchoolInstitution(dto.getSchoolInstitution());
        existing.setContactInfo(dto.getContactInfo());
        return athleteRepository.save(existing);
    }

    @Transactional
    public void deleteAthlete(UUID athleteId) {
        // Soft delete — manager can restore if needed
        Athlete athlete = getAthleteById(athleteId);
        athlete.setIsActive(false);
        athleteRepository.save(athlete);
    }
}