package com.sportyx.backend.DTO;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

@Data
public class AdminUserCreateDTO {
    @Schema(example = "Admin User")
    private String fullName;
    
    @Schema(example = "admin@example.com")
    private String email;
    
    @Schema(example = "hashedpassword123")
    private String passwordHash;
    
    @Schema(example = "REVIEWER", allowableValues = {"SUPER_ADMIN", "REVIEWER"})
    private String role;
}
