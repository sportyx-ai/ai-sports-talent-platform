package com.sportyx.backend.Services;

import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import com.sportyx.backend.DTO.MlAnalysisResponseDTO;
import com.sportyx.backend.Entities.AdminUser;
import com.sportyx.backend.Entities.Assessment;
import com.sportyx.backend.Entities.Athlete;
import com.sportyx.backend.Entities.Manager;
import com.sportyx.backend.Entities.VideoUpload;
import com.sportyx.backend.Enums.NotificationType;
import com.sportyx.backend.Enums.ReviewStatus;
import com.sportyx.backend.Enums.UploadStatus;
import com.sportyx.backend.Repositories.AdminUserRepository;
import com.sportyx.backend.Repositories.AssessmentRepository;
import com.sportyx.backend.Repositories.VideoUploadRepository;

import java.io.File;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class VideoUploadService {

    private static final Logger logger = LoggerFactory.getLogger(VideoUploadService.class);
    private static final long MAX_FILE_SIZE = 500L * 1024 * 1024; // 500MB

    private final VideoUploadRepository videoUploadRepository;
    private final AthleteService athleteService;
    private final ManagerService managerService;
    private final MlService mlService;
    private final AssessmentRepository assessmentRepository;
    private final AdminUserRepository adminUserRepository;
    private final NotificationService notificationService;

    @Value("${app.upload.dir:uploads}")
    private String uploadDir;

    public List<VideoUpload> getVideosByAthlete(UUID athleteId) {
        return videoUploadRepository.findByAthleteId(athleteId);
    }

    public List<VideoUpload> getVideosByManager(UUID managerId) {
        return videoUploadRepository.findByManagerId(managerId);
    }

    public List<VideoUpload> getPendingReviewVideos() {
        return videoUploadRepository.findByAdminReviewStatus(ReviewStatus.PENDING);
    }

    public List<VideoUpload> getAdminVideos() {
        // Exclude rejected videos from Admin dashboard (only passed/reviewed or pending)
        List<VideoUpload> all = videoUploadRepository.findAll();
        return all.stream()
            .filter(v -> v.getAdminReviewStatus() != ReviewStatus.REJECTED)
            .toList();
    }

    public VideoUpload getVideoById(UUID id) {
        return videoUploadRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Video not found with id: " + id));
    }

    @Transactional
    public VideoUpload uploadVideo(UUID managerId, UUID athleteId, com.sportyx.backend.DTO.VideoUploadDTO dto) {
        Manager manager = managerService.getManagerById(managerId);
        Athlete athlete = athleteService.getAthleteById(athleteId);

        // Ensure manager owns this athlete, or fallback to assigned manager
        if (athlete.getManager() != null && !athlete.getManager().getId().equals(managerId)) {
            manager = athlete.getManager();
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

        return videoUploadRepository.save(video);
    }

    @Transactional
    public VideoUpload uploadVideoFile(
        UUID managerId,
        UUID athleteId,
        MultipartFile file,
        String title,
        String sportCategory,
        String skillType,
        Integer durationSeconds,
        String publicBaseUrl
    ) {
        // Validation
        if (file == null || file.isEmpty()) {
            throw new RuntimeException("Video file is required");
        }

        long fileSize = file.getSize();
        logger.info("Uploading video: size={}MB, name={}", fileSize / (1024 * 1024), file.getOriginalFilename());

        if (fileSize > MAX_FILE_SIZE) {
            throw new RuntimeException("File size exceeds maximum limit of 500MB. Current size: " +
                (fileSize / (1024 * 1024)) + "MB");
        }

        String original = file.getOriginalFilename() == null ? "video.mp4" : file.getOriginalFilename();
        String ext = "";
        int dot = original.lastIndexOf('.');
        if (dot >= 0 && dot < original.length() - 1) {
            ext = original.substring(dot);
        }

        // Validate file extension
        if (!isValidVideoFile(ext)) {
            throw new RuntimeException("Invalid file type. Allowed: .mp4, .avi, .mkv, .mov, .webm, .flv");
        }

        String fileName = UUID.randomUUID() + ext;

        try {
            // Create upload directory
            Path uploadPath = Paths.get(uploadDir).toAbsolutePath().normalize();
            Files.createDirectories(uploadPath);

            // Save file to disk
            Path target = uploadPath.resolve(fileName);
            logger.info("Saving video to: {}", target.toString());
            Files.copy(file.getInputStream(), target, StandardCopyOption.REPLACE_EXISTING);

            logger.info("Video uploaded successfully to disk: {}", fileName);

            // Create initial DB record
            com.sportyx.backend.DTO.VideoUploadDTO dto = new com.sportyx.backend.DTO.VideoUploadDTO();
            dto.setTitle(title != null ? title : original);
            dto.setVideoUrl(publicBaseUrl + "/uploads/" + fileName);
            dto.setThumbnailUrl(null);
            dto.setSportCategory(sportCategory);
            dto.setSkillType(skillType);
            dto.setDurationSeconds(durationSeconds != null ? durationSeconds : 0);

            VideoUpload savedVideo = uploadVideo(managerId, athleteId, dto);

            // Trigger AI ML Analysis
            File savedFile = target.toFile();
            processMlAnalysis(savedVideo, savedFile, sportCategory);

            return savedVideo;

        } catch (Exception e) {
            logger.error("Failed to upload video file: {}", e.getMessage(), e);
            throw new RuntimeException("Failed to store video file: " + e.getMessage(), e);
        }
    }

    private void processMlAnalysis(VideoUpload video, File videoFile, String sportCategory) {
        try {
            logger.info("Initiating ML Analysis for video ID: {}", video.getId());
            MlAnalysisResponseDTO mlResult = mlService.analyzeVideo(videoFile, sportCategory);

            if (mlResult != null) {
                double score = mlResult.getOverallScore() != null ? mlResult.getOverallScore() : 0.0;
                String decision = (mlResult.getCheating() != null && mlResult.getCheating().getDecision() != null)
                    ? mlResult.getCheating().getDecision()
                    : "pass";

                // Assessment passes if decision is not 'reject' and overall score >= 50.0
                boolean isPassed = !"reject".equalsIgnoreCase(decision) && score >= 50.0;

                String strengthsStr = mlResult.getStrengths().isEmpty() ? "Good exercise execution" : String.join(", ", mlResult.getStrengths());
                String weaknessesStr = mlResult.getWeaknesses().isEmpty() ? "Form needs slight improvement" : String.join(", ", mlResult.getWeaknesses());

                if (isPassed) {
                    logger.info("ML Assessment PASSED for video ID: {} (Score: {})", video.getId(), score);
                    video.setAdminReviewStatus(ReviewStatus.REVIEWED);
                    String feedback = String.format("Score: %.1f/100 | Valid Reps: %d/%d\nStrengths: %s.",
                        score, mlResult.getValidReps(), mlResult.getTotalReps(), strengthsStr);
                    video.setAdminFeedback(feedback);
                    video.setReviewedAt(LocalDateTime.now());
                    videoUploadRepository.save(video);

                    // Create Assessment record so it appears on Admin Dashboard
                    AdminUser defaultAdmin = adminUserRepository.findAll().stream().findFirst().orElse(null);
                    if (defaultAdmin != null) {
                        BigDecimal scaledScore = BigDecimal.valueOf(score / 10.0).setScale(2, RoundingMode.HALF_UP);
                        String perfLevel = score >= 80.0 ? "TALENT" : (score >= 65.0 ? "PROMISING" : "AVERAGE");

                        Assessment assessment = Assessment.builder()
                            .video(video)
                            .athlete(video.getAthlete())
                            .assessedBy(defaultAdmin)
                            .overallScore(scaledScore)
                            .skillScores(mlResult.getSubscores())
                            .performanceLevel(perfLevel)
                            .strengths(strengthsStr)
                            .areasToImprove(weaknessesStr)
                            .recommendations(feedback)
                            .build();

                        assessmentRepository.save(assessment);
                    }

                    // Send notification
                    notificationService.createNotification(
                        video.getManager(),
                        video.getAthlete(),
                        NotificationType.ASSESSMENT_READY,
                        "AI Assessment Passed!",
                        "Assessment for " + video.getAthlete().getFullName() + " passed with score " + String.format("%.1f", score) + "/100 and has been sent to Admin."
                    );
                } else {
                    logger.info("ML Assessment FAILED / REJECTED for video ID: {} (Score: {})", video.getId(), score);
                    video.setAdminReviewStatus(ReviewStatus.REJECTED);
                    String feedback = String.format("Score: %.1f/100 | Valid Reps: %d/%d\nAreas to Improve: %s.\nPlease re-record and re-upload video.",
                        score, mlResult.getValidReps(), mlResult.getTotalReps(), weaknessesStr);
                    video.setAdminFeedback(feedback);
                    video.setReviewedAt(LocalDateTime.now());
                    videoUploadRepository.save(video);

                    // Send notification to user with feedback
                    notificationService.createNotification(
                        video.getManager(),
                        video.getAthlete(),
                        NotificationType.ASSESSMENT_READY,
                        "AI Assessment Feedback",
                        "Video form assessment needs improvement (Score: " + String.format("%.1f", score) + "/100). Please review AI feedback."
                    );
                }
            } else {
                logger.warn("ML Analysis returned null for video ID: {}. Leaving video as PENDING review.", video.getId());
                video.setAdminFeedback("Video uploaded. Pending AI model evaluation.");
                videoUploadRepository.save(video);
            }
        } catch (Exception e) {
            logger.error("Error during ML Analysis processing: {}", e.getMessage(), e);
            video.setAdminFeedback("Video uploaded. AI analysis encountered an error.");
            videoUploadRepository.save(video);
        }
    }

    @Transactional
    public VideoUpload submitAdminFeedback(UUID videoId, String feedback, ReviewStatus status) {
        VideoUpload video = getVideoById(videoId);
        video.setAdminFeedback(feedback);
        video.setAdminReviewStatus(status);
        video.setReviewedAt(LocalDateTime.now());
        return videoUploadRepository.save(video);
    }

    private boolean isValidVideoFile(String extension) {
        String ext = extension.toLowerCase();
        return ext.matches("\\.(mp4|avi|mkv|mov|webm|flv|m4v|3gp)$");
    }
}
