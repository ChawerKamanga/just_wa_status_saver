import 'package:flutter/material.dart';
import '../../../../data/models/whatsapp_status.dart';
import '../../../../core/services/whatsapp_status_service.dart';
import '../../../../core/services/permission_service.dart';

class WhatsAppStatusViewModel extends ChangeNotifier {
  List<WhatsAppStatus> _allStatuses = [];
  List<WhatsAppStatus> _imageStatuses = [];
  List<WhatsAppStatus> _videoStatuses = [];
  bool _isLoading = false;
  bool _hasPermission = false;
  String? _errorMessage;
  int _selectedTabIndex = 0;

  // Getters
  List<WhatsAppStatus> get allStatuses => _allStatuses;
  List<WhatsAppStatus> get imageStatuses => _imageStatuses;
  List<WhatsAppStatus> get videoStatuses => _videoStatuses;
  bool get isLoading => _isLoading;
  bool get hasPermission => _hasPermission;
  String? get errorMessage => _errorMessage;
  int get selectedTabIndex => _selectedTabIndex;

  final List<String> tabs = ['Images', 'Videos'];

  WhatsAppStatusViewModel() {
    _initialize();
  }

  Future<void> _initialize() async {
    await checkPermission();
    if (_hasPermission) {
      await loadStatuses();
    }
  }

  Future<void> checkPermission() async {
    try {
      _hasPermission = await PermissionService.hasStoragePermission();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error checking permissions: $e';
      notifyListeners();
    }
  }

  Future<void> requestPermission() async {
    try {
      _hasPermission = await PermissionService.requestStoragePermission();
      notifyListeners();

      if (_hasPermission) {
        await loadStatuses();
      }
    } catch (e) {
      _errorMessage = 'Error requesting permissions: $e';
      notifyListeners();
    }
  }

  Future<void> loadStatuses() async {
    if (!_hasPermission) {
      _errorMessage = 'Storage permission not granted';
      notifyListeners();
      return;
    }

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Load all statuses
      _allStatuses = await WhatsAppStatusService.getAllStatusFiles();

      // Separate images and videos
      _imageStatuses = _allStatuses
          .where((status) => status.type == StatusType.image)
          .toList();
      _videoStatuses = _allStatuses
          .where((status) => status.type == StatusType.video)
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error loading status files: $e';
      notifyListeners();
    }
  }

  Future<void> refreshStatuses() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Clear existing data first
    _allStatuses.clear();
    _imageStatuses.clear();
    _videoStatuses.clear();

    await loadStatuses();
  }

  void selectTab(int index) {
    _selectedTabIndex = index;
    notifyListeners();
  }

  List<WhatsAppStatus> getStatusesForTab(int tabIndex) {
    switch (tabIndex) {
      case 0: // Images
        return _imageStatuses;
      case 1: // Videos
        return _videoStatuses;
      default:
        return _imageStatuses;
    }
  }

  Future<bool> saveStatus(WhatsAppStatus status) async {
    try {
      final success = await WhatsAppStatusService.saveStatusFile(status);
      if (success) {
        // You might want to show a success message to the user
        return true;
      } else {
        _errorMessage = 'Failed to save status file';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error saving status file: $e';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Get status count for display
  int get imageCount => _imageStatuses.length;
  int get videoCount => _videoStatuses.length;
  int get totalCount => _allStatuses.length;

  // Check if we have any statuses
  bool get hasStatuses => _allStatuses.isNotEmpty;
  bool get hasImages => _imageStatuses.isNotEmpty;
  bool get hasVideos => _videoStatuses.isNotEmpty;
}
