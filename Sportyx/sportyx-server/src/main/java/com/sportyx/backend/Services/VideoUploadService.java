package com.sportyx.backend.Services;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.sportyx.backend.Entities.Athlete;
import com.sportyx.backend.Entities.Manager;
import com.sportyx.backend.Entities.VideoUpload;
import com.sportyx.backend.Enums.ReviewStatus;
import com.sportyx.backend.Enums.UploadStatus;
import com.sportyx.backend.Repositories.VideoUploadRepository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class VideoUploadService {

    private final VideoUploadRepository videoUploadRepository;
    private final AthleteService athleteService;
    private final ManagerService managerService;

    public List<VideoUpload> getVideosByAthlete(UUID athleteId) {
        return videoUploadRepository.findByAthleteId(athleteId);
    }

    public List<VideoUpload> getVideosByManager(UUID managerId) {
        return videoUploadRepository.findByManagerId(managerId);
    }

    public List<VideoUpload> getPendingReviewVideos() {
        return videoUploadRepository.findByAdminReviewStatus(ReviewStatus.PENDING);
    }

    public VideoUpload getVideoById(UUID id) {
        return videoUploadRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Video not found with id: " + id));
    }

    @Transactional
    public VideoUpload uploadVideo(UUID managerId, UUID athleteId, com.sportyx.backend.DTO.VideoUploadDTO dto) {
        Manager manager = managerService.getManagerById(managerId);
        Athlete athlete = athleteService.getAthleteById(athleteId);

        // Ensure manager owns this athlete
        if (!athlete.getManager().getId().equals(managerId)) {
            throw new RuntimeException("Manager does not manage this athlete");
        }

        VideoUpload video = VideoUpload.builder()
            .title(dto.getTitle())
            .videoUrl(dto.getVideoUrl())
            .thumbnailUrl(dto.getThumbnailUrl())
            .sportCategory(dto.getSportCategory())
            .skillType(dto.getSkillType())
            .durationSeconds(dto.getDurationSeconds())
            .manager(manager)
            .athlete(athlete)
            .uploadStatus(UploadStatus.UPLOADED)
            .adminReviewStatus(ReviewStatus.PENDING)
            .build();
            
        // If eventId is provided, link to event (you'll need EventService for this)
        // if (dto.getEventId() != null) {
        //     Event event = eventService.getEventById(dto.getEventId());
        //     video.setEvent(event);
        // }
        
        return videoUploadRepository.save(video);
    }

    @Transactional
    public VideoUpload submitAdminFeedback(UUID videoId, String feedback, ReviewStatus status) {
        VideoUpload video = getVideoById(videoId);
        video.setAdminFeedback(feedback);
        video.setAdminReviewStatus(status);
        video.setReviewedAt(LocalDateTime.now());
        return videoUploadRepository.save(video);
    }
}