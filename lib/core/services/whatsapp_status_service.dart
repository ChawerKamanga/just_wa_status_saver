import 'dart:io';
import 'package:external_path/external_path.dart';
import 'package:path_provider/path_provider.dart';
import '../../data/models/whatsapp_status.dart';

class WhatsAppStatusService {
  static const String _whatsappStatusPath =
      'Android/media/com.whatsapp/WhatsApp/Media/.Statuses';
  static const String _whatsappBusinessStatusPath =
      'Android/media/com.whatsapp.w4b/WhatsApp Business/Media/.Statuses';

  // Supported file extensions
  static const List<String> _imageExtensions = [
    '.jpg',
    '.jpeg',
    '.png',
    '.gif',
    '.webp',
  ];
  static const List<String> _videoExtensions = [
    '.mp4',
    '.avi',
    '.mkv',
    '.mov',
    '.wmv',
    '.3gp',
  ];

  /// Get all WhatsApp status files (images and videos)
  static Future<List<WhatsAppStatus>> getAllStatusFiles() async {
    try {
      final List<WhatsAppStatus> allStatuses = [];

      // Get status files from regular WhatsApp
      final whatsappStatuses = await _getStatusFilesFromPath(
        _whatsappStatusPath,
      );
      allStatuses.addAll(whatsappStatuses);

      // Get status files from WhatsApp Business
      final businessStatuses = await _getStatusFilesFromPath(
        _whatsappBusinessStatusPath,
      );
      allStatuses.addAll(businessStatuses);

      // Sort by date modified (newest first)
      allStatuses.sort((a, b) => b.dateModified.compareTo(a.dateModified));

      return allStatuses;
    } catch (e) {
      print('Error getting all status files: $e');
      return [];
    }
  }

  /// Get only image status files
  static Future<List<WhatsAppStatus>> getImageStatusFiles() async {
    try {
      final allStatuses = await getAllStatusFiles();
      return allStatuses
          .where((status) => status.type == StatusType.image)
          .toList();
    } catch (e) {
      print('Error getting image status files: $e');
      return [];
    }
  }

  /// Get only video status files
  static Future<List<WhatsAppStatus>> getVideoStatusFiles() async {
    try {
      final allStatuses = await getAllStatusFiles();
      return allStatuses
          .where((status) => status.type == StatusType.video)
          .toList();
    } catch (e) {
      print('Error getting video status files: $e');
      return [];
    }
  }

  /// Helper method to get status files from a specific path
  static Future<List<WhatsAppStatus>> _getStatusFilesFromPath(
    String relativePath,
  ) async {
    try {
      final List<WhatsAppStatus> statuses = [];

      // Try to get external storage paths
      final externalPaths = await _getExternalStoragePaths();

      for (final externalPath in externalPaths) {
        final statusDir = Directory('$externalPath/$relativePath');

        if (await statusDir.exists()) {
          final files = await statusDir.list().toList();

          for (final file in files) {
            if (file is File) {
              final status = await _createWhatsAppStatusFromFile(file);
              if (status != null) {
                statuses.add(status);
              }
            }
          }
        }
      }

      return statuses;
    } catch (e) {
      print('Error getting status files from path $relativePath: $e');
      return [];
    }
  }

  /// Get external storage paths
  static Future<List<String>> _getExternalStoragePaths() async {
    try {
      final List<String> paths = [];

      // Try to get external storage path using external_path package
      try {
        final externalPath =
            await ExternalPath.getExternalStoragePublicDirectory(
              ExternalPath.DIRECTORY_DOWNLOAD,
            );
        if (externalPath.isNotEmpty) {
          // Navigate up to get the root external storage
          final pathParts = externalPath.split('/');
          final rootIndex = pathParts.indexWhere(
            (part) => part == '0' || part == 'emulated',
          );
          if (rootIndex != -1 && rootIndex + 1 < pathParts.length) {
            final rootPath = pathParts.sublist(0, rootIndex + 2).join('/');
            paths.add(rootPath);
          }
        }
      } catch (e) {
        print('Error getting external path: $e');
      }

      // Fallback: try common Android external storage paths
      if (paths.isEmpty) {
        final commonPaths = [
          '/storage/emulated/0',
          '/sdcard',
          '/storage/sdcard0',
        ];

        for (final path in commonPaths) {
          final dir = Directory(path);
          if (await dir.exists()) {
            paths.add(path);
            break;
          }
        }
      }

      // Additional fallback using path_provider
      if (paths.isEmpty) {
        try {
          final directory = await getExternalStorageDirectory();
          if (directory != null) {
            // Navigate up to the root of external storage
            final pathParts = directory.path.split('/');
            final rootIndex = pathParts.indexWhere(
              (part) => part == '0' || part == 'emulated',
            );
            if (rootIndex != -1 && rootIndex + 1 < pathParts.length) {
              final rootPath = pathParts.sublist(0, rootIndex + 2).join('/');
              paths.add(rootPath);
            }
          }
        } catch (e) {
          print('Error using path_provider fallback: $e');
        }
      }

      return paths;
    } catch (e) {
      print('Error getting external storage paths: $e');
      return [];
    }
  }

  /// Create WhatsAppStatus object from file
  static Future<WhatsAppStatus?> _createWhatsAppStatusFromFile(
    File file,
  ) async {
    try {
      final fileName = file.uri.pathSegments.last;
      final extension = fileName.substring(fileName.lastIndexOf('.'));

      // Check if it's a supported file type
      if (!_isSupported(extension)) {
        return null;
      }

      final stat = await file.stat();
      final type = WhatsAppStatus.getTypeFromExtension(extension);

      return WhatsAppStatus(
        id: fileName,
        name: fileName,
        filePath: file.path,
        type: type,
        dateModified: stat.modified,
        fileSize: stat.size,
      );
    } catch (e) {
      print('Error creating WhatsAppStatus from file: $e');
      return null;
    }
  }

  /// Check if file extension is supported
  static bool _isSupported(String extension) {
    final lowercaseExt = extension.toLowerCase();
    return _imageExtensions.contains(lowercaseExt) ||
        _videoExtensions.contains(lowercaseExt);
  }

  /// Save status file to device gallery/downloads
  static Future<bool> saveStatusFile(WhatsAppStatus status) async {
    try {
      // Get downloads directory
      Directory? downloadsDir;

      try {
        downloadsDir = await getDownloadsDirectory();
      } catch (e) {
        // Fallback to external storage
        final externalDir = await getExternalStorageDirectory();
        if (externalDir != null) {
          downloadsDir = Directory(
            '${externalDir.parent.parent.parent.parent.path}/Download',
          );
        }
      }

      if (downloadsDir == null) {
        print('Could not access downloads directory');
        return false;
      }

      // Create destination directory if it doesn't exist
      final destDir = Directory('${downloadsDir.path}/WhatsApp Status');
      if (!await destDir.exists()) {
        await destDir.create(recursive: true);
      }

      // Copy file to destination
      final sourceFile = File(status.filePath);
      final destFile = File('${destDir.path}/${status.name}');

      await sourceFile.copy(destFile.path);
      print('File saved to: ${destFile.path}');

      return true;
    } catch (e) {
      print('Error saving status file: $e');
      return false;
    }
  }
}
