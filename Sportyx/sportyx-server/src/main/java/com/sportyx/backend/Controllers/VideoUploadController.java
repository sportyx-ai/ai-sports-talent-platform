package com.sportyx.backend.Controllers;


import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import com.sportyx.backend.Entities.VideoUpload;
import com.sportyx.backend.Enums.ReviewStatus;
import com.sportyx.backend.Services.VideoUploadService;

import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api")
@RequiredArgsConstructor
public class VideoUploadController {

    private final VideoUploadService videoUploadService;

    // GET /api/athletes/{athleteId}/videos
    @GetMapping("/athletes/{athleteId}/videos")
    public ResponseEntity<List<VideoUpload>> getVideosByAthlete(@PathVariable UUID athleteId) {
        return ResponseEntity.ok(videoUploadService.getVideosByAthlete(athleteId));
    }

    // GET /api/managers/{managerId}/videos
    @GetMapping("/managers/{managerId}/videos")
    public ResponseEntity<List<VideoUpload>> getVideosByManager(@PathVariable UUID managerId) {
        return ResponseEntity.ok(videoUploadService.getVideosByManager(managerId));
    }

    // GET /api/videos/{id}
    @GetMapping("/videos/{id}")
    public ResponseEntity<VideoUpload> getVideoById(@PathVariable UUID id) {
        return ResponseEntity.ok(videoUploadService.getVideoById(id));
    }

    // GET /api/admin/videos/pending  (admin panel)
    @GetMapping("/admin/videos/pending")
    public ResponseEntity<List<VideoUpload>> getPendingVideos() {
        return ResponseEntity.ok(videoUploadService.getPendingReviewVideos());
    }

    // POST /api/managers/{managerId}/athletes/{athleteId}/videos
    @PostMapping("/managers/{managerId}/athletes/{athleteId}/videos")
    public ResponseEntity<VideoUpload> uploadVideo(@PathVariable UUID managerId,
                                                    @PathVariable UUID athleteId,
                                                    @RequestBody com.sportyx.backend.DTO.VideoUploadDTO dto) {
        return ResponseEntity.status(HttpStatus.CREATED)
            .body(videoUploadService.uploadVideo(managerId, athleteId, dto));
    }

    // PATCH /api/admin/videos/{videoId}/review  (admin panel only)
    @PatchMapping("/admin/videos/{videoId}/review")
    public ResponseEntity<VideoUpload> reviewVideo(@PathVariable UUID videoId,
                                                    @RequestBody com.sportyx.backend.DTO.VideoReviewDTO dto) {
        ReviewStatus status = ReviewStatus.valueOf(dto.getStatus());
        return ResponseEntity.ok(videoUploadService.submitAdminFeedback(videoId, dto.getFeedback(), status));
    }
}