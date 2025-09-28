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

      print('🔍 Starting WhatsApp status file discovery...');

      // Get status files from regular WhatsApp
      final whatsappStatuses = await _getStatusFilesFromPath(
        _whatsappStatusPath,
      );
      print('📱 Regular WhatsApp found ${whatsappStatuses.length} files');
      allStatuses.addAll(whatsappStatuses);

      // Get status files from WhatsApp Business
      final businessStatuses = await _getStatusFilesFromPath(
        _whatsappBusinessStatusPath,
      );
      print('💼 WhatsApp Business found ${businessStatuses.length} files');
      allStatuses.addAll(businessStatuses);

      // Remove duplicates based on multiple criteria (file name, size, and path)
      final uniqueStatuses = <String, WhatsAppStatus>{};
      for (final status in allStatuses) {
        // Create a unique key based on file name, size, and modification date
        final uniqueKey =
            '${status.name}_${status.fileSize}_${status.dateModified.millisecondsSinceEpoch}';

        // Only add if not already present, or if this path is more canonical
        if (!uniqueStatuses.containsKey(uniqueKey)) {
          uniqueStatuses[uniqueKey] = status;
        } else {
          // Keep the one with the most canonical path (prefer /storage/emulated/0)
          final existing = uniqueStatuses[uniqueKey]!;
          if (status.filePath.contains('/storage/emulated/0') &&
              !existing.filePath.contains('/storage/emulated/0')) {
            uniqueStatuses[uniqueKey] = status;
          }
        }
      }

      // Convert back to list and sort by date modified (newest first)
      final finalStatuses = uniqueStatuses.values.toList();
      finalStatuses.sort((a, b) => b.dateModified.compareTo(a.dateModified));

      print(
        '✅ Total unique status files found: ${finalStatuses.length} (from ${allStatuses.length} total)',
      );
      return finalStatuses;
    } catch (e) {
      print('❌ Error getting all status files: $e');
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
      final Set<String> processedDirectories = {};

      // Try to get external storage paths
      final externalPaths = await _getExternalStoragePaths();
      print('🔍 Checking paths: $externalPaths');

      for (final externalPath in externalPaths) {
        final statusDir = Directory('$externalPath/$relativePath');
        final canonicalPath = statusDir.path;

        // Skip if we've already processed this directory
        if (processedDirectories.contains(canonicalPath)) {
          print('⏭️ Skipping already processed directory: $canonicalPath');
          continue;
        }

        processedDirectories.add(canonicalPath);
        print('📂 Checking directory: $canonicalPath');

        if (await statusDir.exists()) {
          print('✅ Directory exists, listing files...');
          try {
            final files = await statusDir
                .list(recursive: false, followLinks: false)
                .where((entity) => entity is File)
                .cast<File>()
                .toList();

            print('📄 Found ${files.length} files in directory');

            for (final file in files) {
              try {
                final status = await _createWhatsAppStatusFromFile(file);
                if (status != null) {
                  // Check for duplicates by file name and size before adding
                  final isDuplicate = statuses.any(
                    (existing) =>
                        existing.name == status.name &&
                        existing.fileSize == status.fileSize,
                  );

                  if (!isDuplicate) {
                    statuses.add(status);
                    print('✅ Added file: ${status.name}');
                  } else {
                    print('🔄 Skipped duplicate file: ${status.name}');
                  }
                } else {
                  print('❌ Skipped file: ${file.path}');
                }
              } catch (e) {
                print('❌ Error processing file ${file.path}: $e');
              }
            }
          } catch (e) {
            print('❌ Error listing files in $canonicalPath: $e');
          }
        } else {
          print('❌ Directory does not exist: $canonicalPath');
        }
      }

      print('📊 Total files found in $relativePath: ${statuses.length}');
      return statuses;
    } catch (e) {
      print('❌ Error getting status files from path $relativePath: $e');
      return [];
    }
  }

  /// Get external storage paths
  static Future<List<String>> _getExternalStoragePaths() async {
    try {
      final Set<String> paths = {};

      // Method 1: Try to get external storage path using external_path package
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
        print('❌ Error getting external path: $e');
      }

      // Method 2: Add common Android storage paths
      final commonPaths = [
        '/storage/emulated/0',
        '/storage/self/primary',
        '/sdcard',
      ];

      for (final path in commonPaths) {
        final dir = Directory(path);
        if (await dir.exists()) {
          paths.add(path);
        }
      }

      // Additional fallback using path_provider if no paths found
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
          print('❌ Error using path_provider fallback: $e');
        }
      }

      print('🗂️ Available storage paths: ${paths.toList()}');
      return paths.toList();
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

  /// Save status file to device Downloads folder
  static Future<bool> saveStatusFile(WhatsAppStatus status) async {
    try {
      // Get downloads directory - use direct path for Android
      Directory? downloadsDir;

      if (Platform.isAndroid) {
        // Direct path to Downloads folder (visible to user)
        downloadsDir = Directory('/storage/emulated/0/Download');
      } else {
        // For iOS, use Documents directory
        final appDir = await getApplicationDocumentsDirectory();
        downloadsDir = Directory('${appDir.path}/Downloads');
      }

      // Ensure directory exists
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }

      // Generate meaningful filename with timestamp
      final timestamp = DateTime.now();
      final dateStr =
          '${timestamp.year}${timestamp.month.toString().padLeft(2, '0')}${timestamp.day.toString().padLeft(2, '0')}';
      final timeStr =
          '${timestamp.hour.toString().padLeft(2, '0')}${timestamp.minute.toString().padLeft(2, '0')}${timestamp.second.toString().padLeft(2, '0')}';
      final extension = status.name.split('.').last;
      final fileName = 'WA_Status_${dateStr}_$timeStr.$extension';

      // Copy file to destination
      final sourceFile = File(status.filePath);
      final destFile = File('${downloadsDir.path}/$fileName');

      await sourceFile.copy(destFile.path);
      print('✅ File saved to Downloads: $fileName');

      return true;
    } catch (e) {
      print('❌ Error saving status file: $e');
      return false;
    }
  }
}
