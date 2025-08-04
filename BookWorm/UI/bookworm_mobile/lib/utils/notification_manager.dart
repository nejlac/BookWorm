import 'package:flutter/material.dart';
import 'dart:async';

class NotificationManager {
  static final NotificationManager _instance = NotificationManager._internal();
  factory NotificationManager() => _instance;
  NotificationManager._internal();

  VoidCallback? _refreshCallback;
  bool _isRefreshing = false;
  Timer? _debounceTimer;

  void setRefreshCallback(VoidCallback callback) {
    _refreshCallback = callback;
  }

  void refreshNotifications() {
    if (_isRefreshing) return;
    
    _debounceTimer?.cancel();
    
    _debounceTimer = Timer(const Duration(milliseconds: 100), () {
      if (_isRefreshing) return;
      
      _isRefreshing = true;
      try {
        _refreshCallback?.call();
      } finally {
        _isRefreshing = false;
      }
    });
  }
} 