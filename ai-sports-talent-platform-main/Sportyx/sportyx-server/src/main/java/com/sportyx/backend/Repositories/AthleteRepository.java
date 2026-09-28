package com.sportyx.backend.Repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.sportyx.backend.Entities.Athlete;
import com.sportyx.backend.Enums.SkillLevel;

import java.util.List;
import java.util.UUID;

@Repository
public interface AthleteRepository extends JpaRepository<Athlete, UUID> {
    List<Athlete> findByManagerId(UUID managerId);
    List<Athlete> findByManagerIdAndIsActiveTrue(UUID managerId);
    List<Athlete> findBySportCategoryAndSkillLevel(String sportCategory, SkillLevel skillLevel);
    long countByManagerId(UUID managerId);
}