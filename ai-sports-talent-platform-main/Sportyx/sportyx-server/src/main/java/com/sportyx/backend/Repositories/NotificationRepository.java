package com.sportyx.backend.Repositories;


import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import com.sportyx.backend.Entities.Notification;

import java.util.List;
import java.util.UUID;

@Repository
public interface NotificationRepository extends JpaRepository<Notification, UUID> {
    List<Notification> findByManagerIdOrderByCreatedAtDesc(UUID managerId);
    List<Notification> findByManagerIdAndIsReadFalse(UUID managerId);
    long countByManagerIdAndIsReadFalse(UUID managerId);

    @Modifying
    @Transactional
    @Query("UPDATE Notification n SET n.isRead = true WHERE n.manager.id = :managerId")
    void markAllAsReadByManagerId(UUID managerId);
}