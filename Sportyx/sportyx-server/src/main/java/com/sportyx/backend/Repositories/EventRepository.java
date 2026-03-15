package com.sportyx.backend.Repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.sportyx.backend.Entities.Event;
import com.sportyx.backend.Enums.EventStatus;
import com.sportyx.backend.Enums.SkillLevel;

import java.util.List;
import java.util.UUID;

@Repository
public interface EventRepository extends JpaRepository<Event, UUID> {
    List<Event> findByStatus(EventStatus status);
    // Fetch events matching athlete's sport and skill level for personalised dashboard
    List<Event> findBySportCategoryAndSkillLevelRequiredAndStatus(
        String sportCategory, SkillLevel skillLevel, EventStatus status);
    List<Event> findByCreatedById(UUID adminId);
}