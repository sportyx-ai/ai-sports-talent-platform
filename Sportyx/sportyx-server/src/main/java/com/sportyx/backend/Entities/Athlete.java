package com.sportyx.backend.Entities;


import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.annotations.UpdateTimestamp;
import org.hibernate.type.SqlTypes;

import com.fasterxml.jackson.annotation.JsonIdentityInfo;
import com.fasterxml.jackson.annotation.ObjectIdGenerators;
import com.sportyx.backend.Enums.SkillLevel;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Entity
@Table(name = "athletes")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
@JsonIdentityInfo(generator = ObjectIdGenerators.PropertyGenerator.class, property = "id")
public class Athlete {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "manager_id", nullable = false)
    private Manager manager;

    @Column(name = "full_name", nullable = false, length = 150)
    private String fullName;

    @Column(name = "date_of_birth")
    private LocalDate dateOfBirth;

    @Column(length = 20)
    private String gender;

    @Column(name = "profile_photo_url")
    private String profilePhotoUrl;

    @Column(name = "sport_category", length = 100)
    private String sportCategory;

    @Enumerated(EnumType.STRING)
    @Column(name = "skill_level", length = 50)
    private SkillLevel skillLevel;

    @Column(name = "school_institution", length = 200)
    private String schoolInstitution;

    // Stores parent contact details as JSON: {"parent_name":"...", "phone":"..."}
    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "contact_info", columnDefinition = "json")
    private Map<String, Object> contactInfo;

    @Column(name = "is_active")
    @Builder.Default
    private Boolean isActive = true;

    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    // Relationships
    @OneToMany(mappedBy = "athlete", cascade = CascadeType.ALL)
    @Builder.Default
    private List<VideoUpload> videoUploads = new ArrayList<>();

    @OneToMany(mappedBy = "athlete", cascade = CascadeType.ALL)
    @Builder.Default
    private List<Assessment> assessments = new ArrayList<>();

    @OneToMany(mappedBy = "athlete", cascade = CascadeType.ALL)
    @Builder.Default
    private List<AthleteEvent> athleteEvents = new ArrayList<>();

    @OneToMany(mappedBy = "athlete", cascade = CascadeType.ALL)
    @Builder.Default
    private List<Notification> notifications = new ArrayList<>();
}