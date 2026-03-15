package com.sportyx.backend.DTO;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;
import java.time.LocalDate;

@Data
public class EventCreateDTO {
    @Schema(example = "Regional Football Championship")
    private String title;
    
    @Schema(example = "Annual regional football championship for young athletes.")
    private String description;
    
    @Schema(example = "Football")
    private String sportCategory;
    
    @Schema(example = "INTERMEDIATE", allowableValues = {"BEGINNER", "INTERMEDIATE", "ADVANCED"})
    private String skillLevelRequired;
    
    @Schema(example = "Sports Complex, Chennai")
    private String location;
    
    @Schema(example = "2026-04-15")
    private LocalDate eventDate;
    
    @Schema(example = "2026-04-01")
    private LocalDate registrationDeadline;
}
