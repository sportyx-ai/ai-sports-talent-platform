package com.sportyx.backend.Entities;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import com.fasterxml.jackson.annotation.JsonIdentityInfo;
import com.fasterxml.jackson.annotation.ObjectIdGenerators;
import com.sportyx.backend.Enums.EventStatus;
import com.sportyx.backend.Enums.SkillLevel;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Entity
@Table(name = "events")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
@JsonIdentityInfo(generator = ObjectIdGenerators.PropertyGenerator.class, property = "id")
public class Event {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "created_by", nullable = false)
    private AdminUser createdBy;

    @Column(nullable = false, length = 200)
    private String title;

    @Column(columnDefinition = "text")
    private String description;

    @Column(name = "sport_category", length = 100)
    private String sportCategory;

    @Enumerated(EnumType.STRING)
    @Column(name = "skill_level_required", length = 50)
    private SkillLevel skillLevelRequired;

    @Column(length = 200)
    private String location;

    @Column(name = "event_date")
    private LocalDate eventDate;

    @Column(name = "registration_deadline")
    private LocalDate registrationDeadline;

    @Enumerated(EnumType.STRING)
    @Column(length = 30)
    @Builder.Default
    private EventStatus status = EventStatus.UPCOMING;

    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    // Relationships
    @OneToMany(mappedBy = "event", cascade = CascadeType.ALL)
    @Builder.Default
    private List<AthleteEvent> athleteEvents = new ArrayList<>();

    @OneToMany(mappedBy = "event")
    @Builder.Default
    private List<VideoUpload> videoUploads = new ArrayList<>();
}