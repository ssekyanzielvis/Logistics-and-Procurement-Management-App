import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();
  
  final List<AppNotification> _notifications = [];
  final List<VoidCallback> _listeners = [];
  
  List<AppNotification> get notifications => List.unmodifiable(_notifications);
  int get unreadCount => _notifications.where((n) => !n.isRead).length;
  
  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }
  
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }
  
  void _notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }
  
  void addNotification(AppNotification notification) {
    _notifications.insert(0, notification);
    _notifyListeners();
  }
  
  void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      _notifyListeners();
    }
  }
  
  void markAllAsRead() {
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    _notifyListeners();
  }
  
  void removeNotification(String notificationId) {
    _notifications.removeWhere((n) => n.id == notificationId);
    _notifyListeners();
  }
  
  void clearAll() {
    _notifications.clear();
    _notifyListeners();
  }
  
  // Predefined notification types
  void notifyLowBalance(String cardNumber, double balance) {
    addNotification(AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Low Balance Alert',
      message: 'Card ending in ${cardNumber.substring(cardNumber.length - 4)} has low balance: \$${balance.toStringAsFixed(2)}',
      type: NotificationType.warning,
      timestamp: DateTime.now(),
    ));
  }
  
  void notifyCardExpiring(String cardNumber, DateTime expiryDate) {
    addNotification(AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Card Expiring Soon',
      message: 'Card ending in ${cardNumber.substring(cardNumber.length - 4)} expires on ${expiryDate.day}/${expiryDate.month}/${expiryDate.year}',
      type: NotificationType.warning,
      timestamp: DateTime.now(),
    ));
  }
  
  void notifyTransactionComplete(double amount, String fuelType) {
    addNotification(AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Transaction Complete',
      message: 'Successfully purchased \$${amount.toStringAsFixed(2)} of ${fuelType.toUpperCase()}',
      type: NotificationType.success,
      timestamp: DateTime.now(),
    ));
  }
  
  void notifyCardAssigned(String cardNumber, String driverId) {
    addNotification(AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Card Assigned',
      message: 'Card ending in ${cardNumber.substring(cardNumber.length - 4)} has been assigned to driver $driverId',
      type: NotificationType.info,
      timestamp: DateTime.now(),
    ));
  }
  
  void notifySpendingLimitReached(String cardNumber) {
    addNotification(AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Spending Limit Reached',
      message: 'Card ending in ${cardNumber.substring(cardNumber.length - 4)} has reached its spending limit',
      type: NotificationType.error,
      timestamp: DateTime.now(),
    ));
  }
}

class AppNotification {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime timestamp;
  final bool isRead;
  final Map<String, dynamic>? data;
  
  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.data,
  });
  
  AppNotification copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    DateTime? timestamp,
    bool? isRead,
    Map<String, dynamic>? data,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      data: data ?? this.data,
    );
  }
}

enum NotificationType {
  info,
  success,
  warning,
  error,
}
