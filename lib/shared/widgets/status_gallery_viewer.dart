import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_text_styles.dart';
import '../../data/models/whatsapp_status.dart';

class StatusGalleryViewer extends StatefulWidget {
  final WhatsAppStatus status;
  final List<WhatsAppStatus> allStatuses;
  final int currentIndex;

  const StatusGalleryViewer({
    super.key,
    required this.status,
    required this.allStatuses,
    required this.currentIndex,
  });

  @override
  State<StatusGalleryViewer> createState() => _StatusGalleryViewerState();
}

class _StatusGalleryViewerState extends State<StatusGalleryViewer> {
  late PageController _pageController;
  late int _currentIndex;
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.currentIndex;
    _pageController = PageController(initialPage: _currentIndex);
    _initializeCurrentStatus();
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _initializeCurrentStatus() {
    final currentStatus = widget.allStatuses[_currentIndex];
    if (currentStatus.type == StatusType.video) {
      _initializeVideo(currentStatus);
    }
  }

  void _initializeVideo(WhatsAppStatus status) {
    _videoController?.dispose();
    _videoController = VideoPlayerController.file(File(status.filePath));
    _videoController!.initialize().then((_) {
      setState(() {
        _isVideoInitialized = true;
      });
    });
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
      _isVideoInitialized = false;
    });
    _initializeCurrentStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.7),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '${_currentIndex + 1} of ${widget.allStatuses.length}',
          style: AppTextStyles.titleMedium.copyWith(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: _shareCurrentStatus,
          ),
          IconButton(
            icon: _isDownloading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.download, color: Colors.white),
            onPressed: _isDownloading ? null : _downloadCurrentStatus,
          ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        itemCount: widget.allStatuses.length,
        itemBuilder: (context, index) {
          final status = widget.allStatuses[index];
          return _buildStatusView(status, index == _currentIndex);
        },
      ),
      bottomNavigationBar: Container(
        color: Colors.black.withOpacity(0.7),
        padding: const EdgeInsets.all(AppDimensions.spacing16),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.allStatuses[_currentIndex].name,
                style: AppTextStyles.titleSmall.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 4),
              Text(
                widget.allStatuses[_currentIndex].formattedDate,
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.grey[300],
                ),
              ),
              Text(
                widget.allStatuses[_currentIndex].formattedSize,
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.grey[300],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusView(WhatsAppStatus status, bool isCurrent) {
    if (status.type == StatusType.video) {
      return _buildVideoView(status, isCurrent);
    } else {
      return _buildImageView(status);
    }
  }

  Widget _buildImageView(WhatsAppStatus status) {
    return InteractiveViewer(
      minScale: 0.5,
      maxScale: 4.0,
      child: Center(
        child: Image.file(
          File(status.filePath),
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, color: Colors.white, size: 48),
                  SizedBox(height: 8),
                  Text(
                    'Failed to load image',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildVideoView(WhatsAppStatus status, bool isCurrent) {
    if (!isCurrent || !_isVideoInitialized || _videoController == null) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    return Center(
      child: AspectRatio(
        aspectRatio: _videoController!.value.aspectRatio,
        child: Stack(
          children: [
            VideoPlayer(_videoController!),
            Center(
              child: IconButton(
                icon: Icon(
                  _videoController!.value.isPlaying
                      ? Icons.pause
                      : Icons.play_arrow,
                  size: 64,
                  color: Colors.white.withOpacity(0.8),
                ),
                onPressed: () {
                  setState(() {
                    if (_videoController!.value.isPlaying) {
                      _videoController!.pause();
                    } else {
                      _videoController!.play();
                    }
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _shareCurrentStatus() async {
    try {
      final status = widget.allStatuses[_currentIndex];
      await Share.shareXFiles([XFile(status.filePath)]);
    } catch (e) {
      _showSnackBar('Failed to share: $e', Colors.red);
    }
  }

  Future<void> _downloadCurrentStatus() async {
    setState(() {
      _isDownloading = true;
    });

    try {
      final status = widget.allStatuses[_currentIndex];

      // Request storage permission
      final permission = await Permission.storage.request();
      if (!permission.isGranted) {
        _showSnackBar('Storage permission denied', Colors.red);
        return;
      }

      // Get the downloads directory
      Directory? downloadsDirectory;
      if (Platform.isAndroid) {
        downloadsDirectory = Directory(
          '/storage/emulated/0/Download/just_status_saver',
        );
      } else {
        final appDir = await getApplicationDocumentsDirectory();
        downloadsDirectory = Directory('${appDir.path}/just_status_saver');
      }

      // Create directory if it doesn't exist
      if (!await downloadsDirectory.exists()) {
        await downloadsDirectory.create(recursive: true);
      }

      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = status.name.split('.').last;
      final fileName = 'status_${timestamp}.$extension';
      final destinationPath = '${downloadsDirectory.path}/$fileName';

      // Copy file
      final sourceFile = File(status.filePath);
      await sourceFile.copy(destinationPath);

      _showSnackBar('Downloaded to just_status_saver folder', Colors.green);
    } catch (e) {
      _showSnackBar('Download failed: $e', Colors.red);
    } finally {
      setState(() {
        _isDownloading = false;
      });
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
