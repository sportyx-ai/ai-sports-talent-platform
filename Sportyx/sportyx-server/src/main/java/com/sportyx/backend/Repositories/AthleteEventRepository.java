package com.sportyx.backend.Repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.sportyx.backend.Entities.AthleteEvent;
import com.sportyx.backend.Enums.RegistrationStatus;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface AthleteEventRepository extends JpaRepository<AthleteEvent, UUID> {
    List<AthleteEvent> findByAthleteId(UUID athleteId);
    List<AthleteEvent> findByEventId(UUID eventId);
    Optional<AthleteEvent> findByAthleteIdAndEventId(UUID athleteId, UUID eventId);
    boolean existsByAthleteIdAndEventId(UUID athleteId, UUID eventId);
    List<AthleteEvent> findByEventIdAndRegistrationStatus(UUID eventId, RegistrationStatus status);
}