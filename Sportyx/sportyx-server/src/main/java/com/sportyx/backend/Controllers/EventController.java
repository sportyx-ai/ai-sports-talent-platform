package com.sportyx.backend.Controllers;


import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import com.sportyx.backend.Entities.AthleteEvent;
import com.sportyx.backend.Entities.Event;
import com.sportyx.backend.Enums.EventStatus;
import com.sportyx.backend.Enums.RegistrationStatus;
import com.sportyx.backend.Services.EventService;

import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api")
@RequiredArgsConstructor
public class EventController {

    private final EventService eventService;

    // GET /api/events
    @GetMapping("/events")
    public ResponseEntity<List<Event>> getAllEvents() {
        return ResponseEntity.ok(eventService.getAllEvents());
    }

    // GET /api/events/upcoming
    @GetMapping("/events/upcoming")
    public ResponseEntity<List<Event>> getUpcomingEvents() {
        return ResponseEntity.ok(eventService.getUpcomingEvents());
    }

    // GET /api/events/{id}
    @GetMapping("/events/{id}")
    public ResponseEntity<Event> getEventById(@PathVariable UUID id) {
        return ResponseEntity.ok(eventService.getEventById(id));
    }

    // GET /api/athletes/{athleteId}/events  (personalised dashboard events)
    @GetMapping("/athletes/{athleteId}/events")
    public ResponseEntity<List<Event>> getEventsForAthlete(@PathVariable UUID athleteId) {
        return ResponseEntity.ok(eventService.getEventsForAthlete(athleteId));
    }

    // POST /api/admin/{adminId}/events  (admin panel)
    @PostMapping("/admin/{adminId}/events")
    public ResponseEntity<Event> createEvent(@PathVariable UUID adminId,
                                              @RequestBody com.sportyx.backend.DTO.EventCreateDTO dto) {
        return ResponseEntity.status(HttpStatus.CREATED)
            .body(eventService.createEvent(adminId, dto));
    }

    // PATCH /api/events/{id}/status
    @PatchMapping("/events/{id}/status")
    public ResponseEntity<Event> updateEventStatus(@PathVariable UUID id,
                                                    @RequestBody com.sportyx.backend.DTO.EventStatusDTO dto) {
        EventStatus status = EventStatus.valueOf(dto.getStatus());
        return ResponseEntity.ok(eventService.updateEventStatus(id, status));
    }

    // POST /api/athletes/{athleteId}/events/{eventId}/register
    @PostMapping("/athletes/{athleteId}/events/{eventId}/register")
    public ResponseEntity<AthleteEvent> registerAthlete(@PathVariable UUID athleteId,
                                                         @PathVariable UUID eventId) {
        return ResponseEntity.status(HttpStatus.CREATED)
            .body(eventService.registerAthleteForEvent(athleteId, eventId));
    }

    // PATCH /api/athletes/{athleteId}/events/{eventId}/status
    @PatchMapping("/athletes/{athleteId}/events/{eventId}/status")
    public ResponseEntity<AthleteEvent> updateRegistrationStatus(@PathVariable UUID athleteId,
                                                                   @PathVariable UUID eventId,
                                                                   @RequestBody Map<String, String> body) {
        RegistrationStatus status = RegistrationStatus.valueOf(body.get("status"));
        return ResponseEntity.ok(eventService.updateRegistrationStatus(athleteId, eventId, status));
    }

    // GET /api/events/{eventId}/registrations  (admin panel)
    @GetMapping("/events/{eventId}/registrations")
    public ResponseEntity<List<AthleteEvent>> getRegistrations(@PathVariable UUID eventId) {
        return ResponseEntity.ok(eventService.getRegistrationsByEvent(eventId));
    }
}