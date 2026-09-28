package com.sportyx.backend.Entities;



import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import com.fasterxml.jackson.annotation.JsonIdentityInfo;
import com.fasterxml.jackson.annotation.ObjectIdGenerators;
import com.sportyx.backend.Enums.ReviewStatus;
import com.sportyx.backend.Enums.UploadStatus;

import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "video_uploads")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
@JsonIdentityInfo(generator = ObjectIdGenerators.PropertyGenerator.class, property = "id")
public class VideoUpload {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "athlete_id", nullable = false)
    private Athlete athlete;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "manager_id", nullable = false)
    private Manager manager;

    // Nullable — video may or may not be linked to a specific event
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "event_id")
    private Event event;

    @Column(length = 200)
    private String title;

    @Column(name = "video_url", nullable = false, columnDefinition = "text")
    private String videoUrl;

    @Column(name = "thumbnail_url", columnDefinition = "text")
    private String thumbnailUrl;

    @Column(name = "sport_category", length = 100)
    private String sportCategory;

    @Column(name = "skill_type", length = 100)
    private String skillType;

    @Column(name = "duration_seconds")
    private Integer durationSeconds;

    @Enumerated(EnumType.STRING)
    @Column(name = "upload_status", length = 30)
    @Builder.Default
    private UploadStatus uploadStatus = UploadStatus.PENDING;

    @Enumerated(EnumType.STRING)
    @Column(name = "admin_review_status", length = 30)
    @Builder.Default
    private ReviewStatus adminReviewStatus = ReviewStatus.PENDING;

    @Column(name = "admin_feedback", columnDefinition = "text")
    private String adminFeedback;

    @CreationTimestamp
    @Column(name = "uploaded_at", updatable = false)
    private LocalDateTime uploadedAt;

    @Column(name = "reviewed_at")
    private LocalDateTime reviewedAt;

    // Relationship — one video can have one assessment
    @OneToOne(mappedBy = "video", cascade = CascadeType.ALL)
    private Assessment assessment;
}