package com.sportyx.backend.DTO;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;
import java.util.UUID;

@Data
public class VideoUploadDTO {
    @Schema(example = "Athlete Performance Video")
    private String title;
    
    @Schema(example = "https://example.com/video.mp4")
    private String videoUrl;
    
    @Schema(example = "https://example.com/thumbnail.jpg")
    private String thumbnailUrl;
    
    @Schema(example = "Football")
    private String sportCategory;
    
    @Schema(example = "Dribbling")
    private String skillType;
    
    @Schema(example = "120")
    private Integer durationSeconds;
    
    @Schema(example = "3fa85f64-5717-4562-b3fc-2c963f66afa6", description = "Optional event ID if video is for a specific event")
    private UUID eventId;
    //check
}
