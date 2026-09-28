package com.sportyx.backend.DTO;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;
import java.time.LocalDate;
import java.util.List;

@Data
public class ManagerUpdateDTO {
    @Schema(example = "John Doe")
    private String fullName;
    
    @Schema(example = "1234567890")
    private String phone;
    
    @Schema(example = "Sports Academy")
    private String organization;
    
    private List<AthleteDTO> athletes;

    @Data
    public static class AthleteDTO {
        @Schema(example = "Athlete Name")
        private String fullName;
        
        @Schema(example = "2005-01-15")
        private LocalDate dateOfBirth;
        
        @Schema(example = "Male")
        private String gender;
        
        @Schema(example = "https://example.com/photo.jpg")
        private String profilePhotoUrl;
        
        @Schema(example = "Football")
        private String sportCategory;
        
        @Schema(example = "INTERMEDIATE", allowableValues = {"BEGINNER", "INTERMEDIATE", "ADVANCED"})
        private String skillLevel;
        
        @Schema(example = "High School")
        private String schoolInstitution;
    }
}
