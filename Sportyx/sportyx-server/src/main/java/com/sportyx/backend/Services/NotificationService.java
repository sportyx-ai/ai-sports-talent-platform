package com.sportyx.backend.Services;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.sportyx.backend.Entities.Athlete;
import com.sportyx.backend.Entities.Manager;
import com.sportyx.backend.Entities.Notification;
import com.sportyx.backend.Enums.NotificationType;
import com.sportyx.backend.Repositories.NotificationRepository;

import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class NotificationService {

    private final NotificationRepository notificationRepository;

    public List<Notification> getNotificationsForManager(UUID managerId) {
        return notificationRepository.findByManagerIdOrderByCreatedAtDesc(managerId);
    }

    public List<Notification> getUnreadNotifications(UUID managerId) {
        return notificationRepository.findByManagerIdAndIsReadFalse(managerId);
    }

    public long getUnreadCount(UUID managerId) {
        return notificationRepository.countByManagerIdAndIsReadFalse(managerId);
    }

    @Transactional
    public Notification createNotification(Manager manager, Athlete athlete,
                                           NotificationType type, String title, String message) {
        Notification notification = Notification.builder()
            .manager(manager)
            .athlete(athlete)
            .type(type)
            .title(title)
            .message(message)
            .isRead(false)
            .build();
        return notificationRepository.save(notification);
    }

    @Transactional
    public void markAsRead(UUID notificationId) {
        Notification n = notificationRepository.findById(notificationId)
            .orElseThrow(() -> new RuntimeException("Notification not found"));
        n.setIsRead(true);
        notificationRepository.save(n);
    }

    @Transactional
    public void markAllAsRead(UUID managerId) {
        notificationRepository.markAllAsReadByManagerId(managerId);
    }
}