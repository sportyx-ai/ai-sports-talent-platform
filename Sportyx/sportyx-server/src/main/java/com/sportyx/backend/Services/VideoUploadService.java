package com.sportyx.backend.Services;

import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import com.sportyx.backend.Entities.Athlete;
import com.sportyx.backend.Entities.Manager;
import com.sportyx.backend.Entities.VideoUpload;
import com.sportyx.backend.Enums.ReviewStatus;
import com.sportyx.backend.Enums.UploadStatus;
import com.sportyx.backend.Repositories.VideoUploadRepository;

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
    private static final int BUFFER_SIZE = 8192; // 8KB buffer

    private final VideoUploadRepository videoUploadRepository;
    private final AthleteService athleteService;
    private final ManagerService managerService;

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

            // Save file with streaming to handle large files
            Path target = uploadPath.resolve(fileName);
            logger.info("Saving video to: {}", target.toString());

            // Use streaming copy for large files
            Files.copy(file.getInputStream(), target, StandardCopyOption.REPLACE_EXISTING);

            logger.info("Video uploaded successfully: {}", fileName);

            // Create DTO and save to database
            com.sportyx.backend.DTO.VideoUploadDTO dto = new com.sportyx.backend.DTO.VideoUploadDTO();
            dto.setTitle(title != null ? title : original);
            dto.setVideoUrl(publicBaseUrl + "/uploads/" + fileName);
            dto.setThumbnailUrl(null);
            dto.setSportCategory(sportCategory);
            dto.setSkillType(skillType);
            dto.setDurationSeconds(durationSeconds != null ? durationSeconds : 0);

            return uploadVideo(managerId, athleteId, dto);

        } catch (Exception e) {
            logger.error("Failed to upload video file: {}", e.getMessage(), e);
            throw new RuntimeException("Failed to store video file: " + e.getMessage(), e);
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
