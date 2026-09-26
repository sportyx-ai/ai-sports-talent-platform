package com.sportyx.backend.config;

import com.sportyx.backend.DTO.AdminUserCreateDTO;
import com.sportyx.backend.Repositories.AdminUserRepository;
import com.sportyx.backend.Services.AdminUserService;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.jdbc.core.JdbcTemplate;

@Configuration
@RequiredArgsConstructor
public class DataSeeder {

    private final AdminUserRepository adminUserRepository;
    private final AdminUserService adminUserService;
    private final JdbcTemplate jdbcTemplate;

    @Bean
    CommandLineRunner seedDefaultAdmin() {
        return args -> {
            try {
                jdbcTemplate.execute("""
                    CREATE TABLE IF NOT EXISTS assessments (
                        id UUID PRIMARY KEY,
                        athlete_id UUID NOT NULL REFERENCES athletes(id) ON DELETE CASCADE,
                        video_id UUID NOT NULL REFERENCES video_uploads(id) ON DELETE CASCADE,
                        assessed_by UUID NOT NULL REFERENCES admin_users(id),
                        overall_score NUMERIC(4, 2),
                        skill_scores JSON,
                        performance_level VARCHAR(50),
                        strengths TEXT,
                        areas_to_improve TEXT,
                        recommendations TEXT,
                        assessed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                    );
                    """);
            } catch (Exception ignored) {
            }
            String email = "admin@sportyx.com";
            if (!adminUserRepository.existsByEmail(email)) {
                AdminUserCreateDTO dto = new AdminUserCreateDTO();
                dto.setFullName("Test Admin");
                dto.setEmail(email);
                dto.setPasswordHash("admin123");
                dto.setRole("SUPER_ADMIN");
                adminUserService.createAdmin(dto);
            }
        };
    }
}
