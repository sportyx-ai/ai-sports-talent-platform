package com.sportyx.backend.Repositories;


import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.sportyx.backend.Entities.Assessment;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface AssessmentRepository extends JpaRepository<Assessment, UUID> {
    List<Assessment> findByAthleteId(UUID athleteId);
    Optional<Assessment> findByVideoId(UUID videoId);
    List<Assessment> findByAssessedById(UUID adminId);
}