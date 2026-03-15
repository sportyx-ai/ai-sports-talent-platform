package com.sportyx.backend.Services;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.sportyx.backend.Entities.AdminUser;
import com.sportyx.backend.Entities.Athlete;
import com.sportyx.backend.Entities.AthleteEvent;
import com.sportyx.backend.Entities.Event;
import com.sportyx.backend.Enums.EventStatus;
import com.sportyx.backend.Enums.NotificationType;
import com.sportyx.backend.Enums.RegistrationStatus;
import com.sportyx.backend.Repositories.AthleteEventRepository;
import com.sportyx.backend.Repositories.EventRepository;

import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class EventService {

    private final EventRepository eventRepository;
    private final AthleteEventRepository athleteEventRepository;
    private final AthleteService athleteService;
    private final AdminUserService adminUserService;
    private final NotificationService notificationService;

    public List<Event> getAllEvents() {
        return eventRepository.findAll();
    }

    public List<Event> getUpcomingEvents() {
        return eventRepository.findByStatus(EventStatus.UPCOMING);
    }

    public Event getEventById(UUID id) {
        return eventRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Event not found with id: " + id));
    }

    // Personalised: fetch events matching this athlete's sport and skill level
    public List<Event> getEventsForAthlete(UUID athleteId) {
        Athlete athlete = athleteService.getAthleteById(athleteId);
        return eventRepository.findBySportCategoryAndSkillLevelRequiredAndStatus(
            athlete.getSportCategory(),
            athlete.getSkillLevel(),
            EventStatus.UPCOMING
        );
    }

    @Transactional
    public Event createEvent(UUID adminId, com.sportyx.backend.DTO.EventCreateDTO dto) {
        AdminUser admin = adminUserService.getAdminById(adminId);
        
        Event event = Event.builder()
            .title(dto.getTitle())
            .description(dto.getDescription())
            .sportCategory(dto.getSportCategory())
            .location(dto.getLocation())
            .eventDate(dto.getEventDate())
            .registrationDeadline(dto.getRegistrationDeadline())
            .createdBy(admin)
            .build();
            
        if (dto.getSkillLevelRequired() != null && !dto.getSkillLevelRequired().isEmpty()) {
            event.setSkillLevelRequired(com.sportyx.backend.Enums.SkillLevel.valueOf(dto.getSkillLevelRequired().toUpperCase()));
        }
        
        return eventRepository.save(event);
    }

    @Transactional
    public Event updateEventStatus(UUID eventId, EventStatus status) {
        Event event = getEventById(eventId);
        event.setStatus(status);
        return eventRepository.save(event);
    }

    @Transactional
    public AthleteEvent registerAthleteForEvent(UUID athleteId, UUID eventId) {
        if (athleteEventRepository.existsByAthleteIdAndEventId(athleteId, eventId)) {
            throw new RuntimeException("Athlete already registered for this event");
        }
        Athlete athlete = athleteService.getAthleteById(athleteId);
        Event event = getEventById(eventId);

        AthleteEvent registration = AthleteEvent.builder()
            .athlete(athlete)
            .event(event)
            .registrationStatus(RegistrationStatus.REGISTERED)
            .build();

        AthleteEvent saved = athleteEventRepository.save(registration);

        notificationService.createNotification(
            athlete.getManager(),
            athlete,
            NotificationType.EVENT_ADDED,
            "Event Registration",
            athlete.getFullName() + " has been registered for " + event.getTitle()
        );

        return saved;
    }

    @Transactional
    public AthleteEvent updateRegistrationStatus(UUID athleteId, UUID eventId, RegistrationStatus status) {
        AthleteEvent registration = athleteEventRepository
            .findByAthleteIdAndEventId(athleteId, eventId)
            .orElseThrow(() -> new RuntimeException("Registration not found"));
        registration.setRegistrationStatus(status);
        return athleteEventRepository.save(registration);
    }

    public List<AthleteEvent> getRegistrationsByEvent(UUID eventId) {
        return athleteEventRepository.findByEventId(eventId);
    }
}