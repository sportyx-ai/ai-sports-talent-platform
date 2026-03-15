package com.sportyx.backend.DTO;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

@Data
public class EventStatusDTO {
    @Schema(example = "ONGOING", allowableValues = {"UPCOMING", "ONGOING", "CLOSED"})
    private String status;
}
