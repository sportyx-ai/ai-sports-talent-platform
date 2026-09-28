package com.sportyx.backend.DTO;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;
import java.time.LocalDate;
import java.util.List;

@Data
public class ManagerRegistrationDTO {
    @Schema(example = "John Doe")
    private String fullName;
    
    @Schema(example = "john@example.com")
    private String email;
    
    @Schema(example = "hashedpassword123")
    private String passwordHash;
    
    @Schema(example = "1234567890")
    private String phone;
    
    @Schema(example = "Sports Academy")
    private String organization;
    
    @Schema(example = "21")
    private Integer age;

    @Schema(example = "Male")
    private String gender;

    @Schema(example = "998374741399")
    private String idNumber;

    @Schema(example = "http://localhost:8080/uploads/id_proofs/proof.jpg")
    private String idProofUrl;

    @Schema(example = "PT_TEACHER")
    private String role;
    
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
