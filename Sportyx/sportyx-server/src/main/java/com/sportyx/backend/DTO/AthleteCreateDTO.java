package com.sportyx.backend.DTO;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;
import java.time.LocalDate;
import java.util.Map;

@Data
public class AthleteCreateDTO {
    @Schema(example = "John Smith")
    private String fullName;
    
    @Schema(example = "2010-01-15")
    private LocalDate dateOfBirth;
    
    @Schema(example = "Male")
    private String gender;
    
    @Schema(example = "https://example.com/photo.jpg")
    private String profilePhotoUrl;
    
    @Schema(example = "Football")
    private String sportCategory;
    
    @Schema(example = "BEGINNER", allowableValues = {"BEGINNER", "INTERMEDIATE", "ADVANCED"})
    private String skillLevel;
    
    @Schema(example = "High School")
    private String schoolInstitution;
    
    @Schema(example = "{\"parent_name\": \"Parent Name\", \"phone\": \"1234567890\"}")
    private Map<String, Object> contactInfo;
}
