package com.sportyx.backend.Services;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.sportyx.backend.Entities.AdminUser;
import com.sportyx.backend.Entities.Assessment;
import com.sportyx.backend.Entities.VideoUpload;
import com.sportyx.backend.Enums.NotificationType;
import com.sportyx.backend.Enums.ReviewStatus;
import com.sportyx.backend.Repositories.AssessmentRepository;

import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class AssessmentService {

    private final AssessmentRepository assessmentRepository;
    private final VideoUploadService videoUploadService;
    private final AdminUserService adminUserService;
    private final NotificationService notificationService;

    public List<Assessment> getAssessmentsByAthlete(UUID athleteId) {
        return assessmentRepository.findByAthleteId(athleteId);
    }

    public Assessment getAssessmentById(UUID id) {
        return assessmentRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Assessment not found with id: " + id));
    }

    public Assessment getAssessmentByVideo(UUID videoId) {
        return assessmentRepository.findByVideoId(videoId)
            .orElseThrow(() -> new RuntimeException("No assessment found for video: " + videoId));
    }

    @Transactional
    public Assessment createAssessment(UUID adminId, UUID videoId, com.sportyx.backend.DTO.AssessmentCreateDTO dto) {
        AdminUser admin = adminUserService.getAdminById(adminId);
        VideoUpload video = videoUploadService.getVideoById(videoId);

        if (assessmentRepository.findByVideoId(videoId).isPresent()) {
            throw new RuntimeException("Assessment already exists for this video");
        }

        Assessment assessment = Assessment.builder()
            .video(video)
            .athlete(video.getAthlete())
            .assessedBy(admin)
            .overallScore(dto.getOverallScore())
            .skillScores(dto.getSkillScores())
            .performanceLevel(dto.getPerformanceLevel())
            .strengths(dto.getStrengths())
            .areasToImprove(dto.getAreasToImprove())
            .recommendations(dto.getRecommendations())
            .build();

        Assessment saved = assessmentRepository.save(assessment);

        // Mark video as reviewed
        videoUploadService.submitAdminFeedback(videoId, assessment.getRecommendations(), ReviewStatus.REVIEWED);

        // Notify the manager
        notificationService.createNotification(
            video.getManager(),
            video.getAthlete(),
            NotificationType.ASSESSMENT_READY,
            "Assessment Ready",
            "Assessment for " + video.getAthlete().getFullName() + " is now available."
        );

        return saved;
    }

    @Transactional
    public Assessment updateAssessment(UUID assessmentId, com.sportyx.backend.DTO.AssessmentUpdateDTO dto) {
        Assessment existing = getAssessmentById(assessmentId);
        existing.setOverallScore(dto.getOverallScore());
        existing.setSkillScores(dto.getSkillScores());
        existing.setPerformanceLevel(dto.getPerformanceLevel());
        existing.setStrengths(dto.getStrengths());
        existing.setAreasToImprove(dto.getAreasToImprove());
        existing.setRecommendations(dto.getRecommendations());
        return assessmentRepository.save(existing);
    }
}