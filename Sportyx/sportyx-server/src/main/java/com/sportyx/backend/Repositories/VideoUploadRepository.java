package com.sportyx.backend.Repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.sportyx.backend.Entities.VideoUpload;
import com.sportyx.backend.Enums.ReviewStatus;

import java.util.List;
import java.util.UUID;

@Repository
public interface VideoUploadRepository extends JpaRepository<VideoUpload, UUID> {
    List<VideoUpload> findByAthleteId(UUID athleteId);
    List<VideoUpload> findByManagerId(UUID managerId);
    List<VideoUpload> findByAdminReviewStatus(ReviewStatus status);
    List<VideoUpload> findByAthleteIdAndAdminReviewStatus(UUID athleteId, ReviewStatus status);
}