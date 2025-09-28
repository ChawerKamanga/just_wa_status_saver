import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class DebugScreen extends StatefulWidget {
  const DebugScreen({super.key});

  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  List<String> _debugLogs = [];

  void _addLog(String message) {
    setState(() {
      _debugLogs.add(
        '${DateTime.now().toString().split(' ')[1].substring(0, 8)}: $message',
      );
    });
    print('🐛 $message');
  }

  Future<void> _checkPermissions() async {
    _addLog('=== CHECKING PERMISSIONS ===');

    final storageStatus = await Permission.storage.status;
    _addLog('Storage permission: $storageStatus');

    final manageStorageStatus = await Permission.manageExternalStorage.status;
    _addLog('Manage external storage: $manageStorageStatus');

    final photosStatus = await Permission.photos.status;
    _addLog('Photos permission: $photosStatus');

    final videosStatus = await Permission.videos.status;
    _addLog('Videos permission: $videosStatus');
  }

  Future<void> _requestAllPermissions() async {
    _addLog('=== REQUESTING PERMISSIONS ===');

    try {
      final permissions = [
        Permission.storage,
        Permission.manageExternalStorage,
        Permission.photos,
        Permission.videos,
      ];

      final statuses = await permissions.request();

      for (final entry in statuses.entries) {
        _addLog('${entry.key}: ${entry.value}');
      }
    } catch (e) {
      _addLog('Error requesting permissions: $e');
    }
  }

  Future<void> _checkDirectories() async {
    _addLog('=== CHECKING DIRECTORIES ===');

    final paths = [
      '/storage/emulated/0',
      '/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Media/.Statuses',
      '/storage/emulated/0/Android/media/com.whatsapp.w4b/WhatsApp Business/Media/.Statuses',
      '/sdcard',
      '/sdcard/Android/media/com.whatsapp/WhatsApp/Media/.Statuses',
    ];

    for (final path in paths) {
      final dir = Directory(path);
      final exists = await dir.exists();
      _addLog('$path: ${exists ? "EXISTS" : "NOT FOUND"}');

      if (exists) {
        try {
          final entities = await dir.list().toList();
          _addLog('  - Contains ${entities.length} items');

          if (path.contains('.Statuses')) {
            final files = entities.whereType<File>().toList();
            _addLog('  - ${files.length} files in status folder');

            for (final file in files.take(5)) {
              // Show first 5 files
              final stat = await file.stat();
              _addLog(
                '  - ${file.path.split('/').last} (${stat.size} bytes, ${stat.modified})',
              );
            }
          }
        } catch (e) {
          _addLog('  - Error reading directory: $e');
        }
      }
    }
  }

  Future<void> _testDownload() async {
    _addLog('=== TESTING DOWNLOAD ===');

    try {
      final downloadsDir = Directory(
        '/storage/emulated/0/Download/just_status_saver',
      );
      _addLog('Creating download directory: ${downloadsDir.path}');

      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
        _addLog('Directory created successfully');
      } else {
        _addLog('Directory already exists');
      }

      // Test file creation
      final testFile = File(
        '${downloadsDir.path}/test_${DateTime.now().millisecondsSinceEpoch}.txt',
      );
      await testFile.writeAsString('Test file content');
      _addLog('Test file created: ${testFile.path}');

      // Clean up
      await testFile.delete();
      _addLog('Test file deleted');
    } catch (e) {
      _addLog('Download test failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug WhatsApp Status'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Wrap(
              spacing: 8,
              children: [
                ElevatedButton(
                  onPressed: _checkPermissions,
                  child: const Text('Check Permissions'),
                ),
                ElevatedButton(
                  onPressed: _requestAllPermissions,
                  child: const Text('Request Permissions'),
                ),
                ElevatedButton(
                  onPressed: _checkDirectories,
                  child: const Text('Check Directories'),
                ),
                ElevatedButton(
                  onPressed: _testDownload,
                  child: const Text('Test Download'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _debugLogs.clear();
                    });
                  },
                  child: const Text('Clear'),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView.builder(
                itemCount: _debugLogs.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      _debugLogs[index],
                      style: const TextStyle(
                        color: Colors.green,
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
