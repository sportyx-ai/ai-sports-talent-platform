package com.sportyx.backend.Services;

import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import com.sportyx.backend.Entities.AdminUser;
import com.sportyx.backend.Entities.Athlete;
import com.sportyx.backend.Entities.AthleteEvent;
import com.sportyx.backend.Entities.Event;
import com.sportyx.backend.Enums.EventStatus;
import com.sportyx.backend.Enums.NotificationType;
import com.sportyx.backend.Enums.RegistrationStatus;
import com.sportyx.backend.Repositories.AthleteEventRepository;
import com.sportyx.backend.Repositories.EventRepository;

import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
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

    @Value("${app.upload.dir:uploads}")
    private String uploadDir;

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

    @Transactional
    public Event uploadEventPoster(UUID eventId, MultipartFile file, String publicBaseUrl) {
        if (file == null || file.isEmpty()) {
            throw new RuntimeException("Poster file is required");
        }

        Event event = getEventById(eventId);

        String original = file.getOriginalFilename() == null ? "poster.jpg" : file.getOriginalFilename();
        String ext = "";
        int dot = original.lastIndexOf('.');
        if (dot >= 0 && dot < original.length() - 1) {
            ext = original.substring(dot);
        }
        String fileName = UUID.randomUUID() + ext;

        try {
            Path uploadPath = Paths.get(uploadDir).toAbsolutePath().normalize();
            Files.createDirectories(uploadPath);
            Path target = uploadPath.resolve(fileName);
            Files.copy(file.getInputStream(), target, StandardCopyOption.REPLACE_EXISTING);
        } catch (Exception e) {
            throw new RuntimeException("Failed to store poster file", e);
        }

        String posterUrl = publicBaseUrl + "/uploads/" + fileName;
        event.setPosterUrl(posterUrl);
        return eventRepository.save(event);
    }
}