import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<bool> requestStoragePermission() async {
    try {
      // For Android 11+ (API 30+)
      if (Platform.isAndroid) {
        final androidVersion = await _getAndroidVersion();

        if (androidVersion >= 30) {
          // Request MANAGE_EXTERNAL_STORAGE for Android 11+
          final manageStorageStatus = await Permission.manageExternalStorage
              .request();
          if (manageStorageStatus.isGranted) {
            return true;
          }

          // Fallback to regular storage permissions
          final storageStatus = await Permission.storage.request();
          return storageStatus.isGranted;
        } else {
          // For older Android versions
          final storageStatus = await Permission.storage.request();
          return storageStatus.isGranted;
        }
      }

      return true; // For iOS or other platforms
    } catch (e) {
      print('Error requesting storage permission: $e');
      return false;
    }
  }

  static Future<bool> hasStoragePermission() async {
    try {
      if (Platform.isAndroid) {
        final androidVersion = await _getAndroidVersion();

        if (androidVersion >= 30) {
          final manageStorageStatus =
              await Permission.manageExternalStorage.status;
          if (manageStorageStatus.isGranted) {
            return true;
          }

          final storageStatus = await Permission.storage.status;
          return storageStatus.isGranted;
        } else {
          final storageStatus = await Permission.storage.status;
          return storageStatus.isGranted;
        }
      }

      return true;
    } catch (e) {
      print('Error checking storage permission: $e');
      return false;
    }
  }

  static Future<bool> shouldShowPermissionRationale() async {
    try {
      if (Platform.isAndroid) {
        return await Permission.storage.shouldShowRequestRationale;
      }
      return false;
    } catch (e) {
      print('Error checking permission rationale: $e');
      return false;
    }
  }

  static Future<void> openAppSettings() async {
    try {
      await openAppSettings();
    } catch (e) {
      print('Error opening app settings: $e');
    }
  }

  static Future<int> _getAndroidVersion() async {
    // This is a simple way to get Android version
    // In a real app, you might want to use a more robust method
    try {
      return 30; // Assume Android 11+ for now
    } catch (e) {
      return 23; // Fallback to older version
    }
  }
}
