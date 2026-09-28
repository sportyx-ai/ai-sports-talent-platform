package com.sportyx.backend.Services;

import com.sportyx.backend.DTO.MlAnalysisResponseDTO;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.FileSystemResource;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.client.RestTemplate;

import java.io.File;

@Service
public class MlService {

    private static final Logger logger = LoggerFactory.getLogger(MlService.class);

    @Value("${app.ml.service.url:http://localhost:8000}")
    private String mlServiceUrl;

    private final RestTemplate restTemplate = new RestTemplate();

    /**
     * Send video to ML FastAPI model service at /analyze
     */
    public MlAnalysisResponseDTO analyzeVideo(File videoFile, String exerciseHint) {
        if (videoFile == null || !videoFile.exists()) {
            logger.warn("Video file does not exist, skipping ML analysis");
            return null;
        }

        try {
            logger.info("Sending video file {} to ML service at {}/analyze", videoFile.getName(), mlServiceUrl);

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.MULTIPART_FORM_DATA);

            MultiValueMap<String, Object> body = new LinkedMultiValueMap<>();

            // Use FileSystemResource with guaranteed .mp4 filename extension for FastAPI regex check
            FileSystemResource videoResource = new FileSystemResource(videoFile) {
                @Override
                public String getFilename() {
                    String name = super.getFilename();
                    if (name == null || name.isBlank()) {
                        return "video.mp4";
                    }
                    String lower = name.toLowerCase();
                    if (!lower.endsWith(".mp4") && !lower.endsWith(".mov") && !lower.endsWith(".avi") && !lower.endsWith(".mkv") && !lower.endsWith(".webm")) {
                        return name + ".mp4";
                    }
                    return name;
                }
            };

            body.add("video", videoResource);

            String exercise = mapExerciseHint(exerciseHint);
            if (exercise != null) {
                body.add("exercise", exercise);
            }

            HttpEntity<MultiValueMap<String, Object>> requestEntity = new HttpEntity<>(body, headers);

            ResponseEntity<MlAnalysisResponseDTO> response = restTemplate.postForEntity(
                mlServiceUrl + "/analyze",
                requestEntity,
                MlAnalysisResponseDTO.class
            );

            if (response.getStatusCode().is2xxSuccessful() && response.getBody() != null) {
                logger.info("Successfully received ML analysis result: score={}, exercise={}",
                    response.getBody().getOverallScore(), response.getBody().getExercise());
                return response.getBody();
            } else {
                logger.error("ML service returned non-success code: {}", response.getStatusCode());
            }

        } catch (Exception e) {
            logger.error("Failed to connect or analyze video with ML model service: {}", e.getMessage(), e);
        }

        return null;
    }

    private String mapExerciseHint(String hint) {
        if (hint == null) return null;
        String lower = hint.toLowerCase();
        if (lower.contains("squat")) return "squat";
        if (lower.contains("push")) return "push_up";
        if (lower.contains("sit")) return "sit_up";
        if (lower.contains("broad")) return "standing_broad_jump";
        if (lower.contains("jump")) return "vertical_jump";
        return null;
    }
}
