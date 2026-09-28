package com.sportyx.backend.Controllers;


import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import com.sportyx.backend.Entities.Athlete;
import com.sportyx.backend.Services.AthleteService;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api")
@RequiredArgsConstructor
public class AthleteController {

    private final AthleteService athleteService;

    // GET /api/managers/{managerId}/athletes
    @GetMapping("/managers/{managerId}/athletes")
    public ResponseEntity<List<Athlete>> getAthletesByManager(@PathVariable UUID managerId) {
        return ResponseEntity.ok(athleteService.getAthletesByManager(managerId));
    }

    // GET /api/athletes/{id}
    @GetMapping("/athletes/{id}")
    public ResponseEntity<Athlete> getAthleteById(@PathVariable UUID id) {
        return ResponseEntity.ok(athleteService.getAthleteById(id));
    }

    // POST /api/managers/{managerId}/athletes
    @PostMapping("/managers/{managerId}/athletes")
    public ResponseEntity<Athlete> createAthlete(@PathVariable UUID managerId,
                                                  @RequestBody com.sportyx.backend.DTO.AthleteCreateDTO dto) {
        return ResponseEntity.status(HttpStatus.CREATED)
            .body(athleteService.createAthlete(managerId, dto));
    }

    // PUT /api/athletes/{id}
    @PutMapping("/athletes/{id}")
    public ResponseEntity<Athlete> updateAthlete(@PathVariable UUID id,
                                                  @RequestBody com.sportyx.backend.DTO.AthleteUpdateDTO dto) {
        return ResponseEntity.ok(athleteService.updateAthlete(id, dto));
    }

    // DELETE /api/athletes/{id}  (soft delete)
    @DeleteMapping("/athletes/{id}")
    public ResponseEntity<Void> deleteAthlete(@PathVariable UUID id) {
        athleteService.deleteAthlete(id);
        return ResponseEntity.noContent().build();
    }

    // GET /api/managers/{managerId}/athletes/count
    @GetMapping("/managers/{managerId}/athletes/count")
    public ResponseEntity<Long> countAthletes(@PathVariable UUID managerId) {
        return ResponseEntity.ok(athleteService.countAthletesByManager(managerId));
    }
}