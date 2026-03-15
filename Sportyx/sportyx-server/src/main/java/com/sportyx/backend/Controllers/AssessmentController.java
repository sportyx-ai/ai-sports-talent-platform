package com.sportyx.backend.Controllers;


import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import com.sportyx.backend.Entities.Assessment;
import com.sportyx.backend.Services.AssessmentService;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api")
@RequiredArgsConstructor
public class AssessmentController {

    private final AssessmentService assessmentService;

    // GET /api/athletes/{athleteId}/assessments
    @GetMapping("/athletes/{athleteId}/assessments")
    public ResponseEntity<List<Assessment>> getAssessmentsByAthlete(@PathVariable UUID athleteId) {
        return ResponseEntity.ok(assessmentService.getAssessmentsByAthlete(athleteId));
    }

    // GET /api/assessments/{id}
    @GetMapping("/assessments/{id}")
    public ResponseEntity<Assessment> getAssessmentById(@PathVariable UUID id) {
        return ResponseEntity.ok(assessmentService.getAssessmentById(id));
    }

    // GET /api/videos/{videoId}/assessment
    @GetMapping("/videos/{videoId}/assessment")
    public ResponseEntity<Assessment> getAssessmentByVideo(@PathVariable UUID videoId) {
        return ResponseEntity.ok(assessmentService.getAssessmentByVideo(videoId));
    }

    // POST /api/admin/{adminId}/videos/{videoId}/assessment  (admin panel)
    @PostMapping("/admin/{adminId}/videos/{videoId}/assessment")
    public ResponseEntity<Assessment> createAssessment(@PathVariable UUID adminId,
                                                        @PathVariable UUID videoId,
                                                        @RequestBody com.sportyx.backend.DTO.AssessmentCreateDTO dto) {
        return ResponseEntity.status(HttpStatus.CREATED)
            .body(assessmentService.createAssessment(adminId, videoId, dto));
    }

    // PUT /api/assessments/{id}
    @PutMapping("/assessments/{id}")
    public ResponseEntity<Assessment> updateAssessment(@PathVariable UUID id,
                                                        @RequestBody com.sportyx.backend.DTO.AssessmentUpdateDTO dto) {
        return ResponseEntity.ok(assessmentService.updateAssessment(id, dto));
    }
}