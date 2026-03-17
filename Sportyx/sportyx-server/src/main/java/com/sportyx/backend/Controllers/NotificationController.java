package com.sportyx.backend.Controllers;


import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import com.sportyx.backend.Entities.Notification;
import com.sportyx.backend.Services.NotificationService;

import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api")
@RequiredArgsConstructor
public class NotificationController {

    private final NotificationService notificationService;

    // GET /api/managers/{managerId}/notifications
    @GetMapping("/managers/{managerId}/notifications")
    public ResponseEntity<List<Notification>> getNotifications(@PathVariable UUID managerId) {
        return ResponseEntity.ok(notificationService.getNotificationsForManager(managerId));
    }

    // GET /api/managers/{managerId}/notifications/unread
    @GetMapping("/managers/{managerId}/notifications/unread")
    public ResponseEntity<List<Notification>> getUnread(@PathVariable UUID managerId) {
        return ResponseEntity.ok(notificationService.getUnreadNotifications(managerId));
    }

    // GET /api/managers/{managerId}/notifications/count
    @GetMapping("/managers/{managerId}/notifications/count")
    public ResponseEntity<Map<String, Long>> getUnreadCount(@PathVariable UUID managerId) {
        return ResponseEntity.ok(Map.of("unread", notificationService.getUnreadCount(managerId)));
    }

    // PATCH /api/notifications/{id}/read
    @PatchMapping("/notifications/{id}/read")
    public ResponseEntity<Void> markAsRead(@PathVariable UUID id) {
        notificationService.markAsRead(id);
        return ResponseEntity.noContent().build();
    }

    // PATCH /api/managers/{managerId}/notifications/read-all
    @PatchMapping("/managers/{managerId}/notifications/read-all")
    public ResponseEntity<Void> markAllAsRead(@PathVariable UUID managerId) {
        notificationService.markAllAsRead(managerId);
        return ResponseEntity.noContent().build();
    }
}