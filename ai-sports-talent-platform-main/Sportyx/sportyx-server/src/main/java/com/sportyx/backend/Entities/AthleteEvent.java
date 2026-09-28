package com.sportyx.backend.Entities;


import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import com.fasterxml.jackson.annotation.JsonBackReference;
import com.sportyx.backend.Enums.RegistrationStatus;

import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(
    name = "athlete_events",
    uniqueConstraints = @UniqueConstraint(columnNames = {"athlete_id", "event_id"})
)
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class AthleteEvent {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "athlete_id", nullable = false)
    @JsonBackReference("athlete-events")
    private Athlete athlete;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "event_id", nullable = false)
    @JsonBackReference("event-athletes")
    private Event event;

    @Enumerated(EnumType.STRING)
    @Column(name = "registration_status", length = 30)
    @Builder.Default
    private RegistrationStatus registrationStatus = RegistrationStatus.REGISTERED;

    @CreationTimestamp
    @Column(name = "registered_at", updatable = false)
    private LocalDateTime registeredAt;
}