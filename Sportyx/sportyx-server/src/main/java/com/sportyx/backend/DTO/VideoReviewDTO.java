package com.sportyx.backend.DTO;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

@Data
public class VideoReviewDTO {
    @Schema(example = "Great performance! Shows excellent technique.", description = "Admin feedback on the video")
    private String feedback;
    
    @Schema(example = "REVIEWED", allowableValues = {"PENDING", "REVIEWED", "REJECTED"}, description = "Review status")
    private String status;
}
