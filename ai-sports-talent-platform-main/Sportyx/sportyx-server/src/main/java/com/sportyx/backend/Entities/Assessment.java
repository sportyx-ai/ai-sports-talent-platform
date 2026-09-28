package com.sportyx.backend.Entities;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.Map;
import java.util.UUID;

@Entity
@Table(name = "assessments")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class Assessment {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "athlete_id", nullable = false)
    @JsonIgnoreProperties({"videoUploads", "assessments", "athleteEvents", "notifications"})
    private Athlete athlete;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "video_id", nullable = false)
    @JsonIgnoreProperties({"assessment"})
    private VideoUpload video;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "assessed_by", nullable = false)
    @JsonIgnoreProperties({"passwordHash"})
    private AdminUser assessedBy;

    // Score between 0.00 and 10.00
    @Column(name = "overall_score", precision = 4, scale = 2)
    private BigDecimal overallScore;

    // Sport-agnostic skill breakdown e.g. {"speed": 8.5, "agility": 7.2, "stamina": 6.0}
    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "skill_scores", columnDefinition = "json")
    private Map<String, Object> skillScores;

    // e.g. "TALENT", "PROMISING", "AVERAGE"
    @Column(name = "performance_level", length = 50)
    private String performanceLevel;

    @Column(columnDefinition = "text")
    private String strengths;

    @Column(name = "areas_to_improve", columnDefinition = "text")
    private String areasToImprove;

    @Column(columnDefinition = "text")
    private String recommendations;

    @CreationTimestamp
    @Column(name = "assessed_at", updatable = false)
    private LocalDateTime assessedAt;
}