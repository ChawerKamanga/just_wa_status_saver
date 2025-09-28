import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../data/models/whatsapp_status.dart';

class WhatsAppStatusCard extends StatefulWidget {
  final WhatsAppStatus status;
  final VoidCallback? onTap;
  final VoidCallback? onSave;

  const WhatsAppStatusCard({
    super.key,
    required this.status,
    this.onTap,
    this.onSave,
  });

  @override
  State<WhatsAppStatusCard> createState() => _WhatsAppStatusCardState();
}

class _WhatsAppStatusCardState extends State<WhatsAppStatusCard> {
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    if (widget.status.type == StatusType.video) {
      _initializeVideoPlayer();
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _initializeVideoPlayer() async {
    try {
      _videoController = VideoPlayerController.file(widget.status.file);
      await _videoController!.initialize();
      setState(() {
        _isVideoInitialized = true;
      });
    } catch (e) {
      print('Error initializing video player: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withOpacity(0.1),
              blurRadius: AppDimensions.cardBlurRadius,
              spreadRadius: AppDimensions.cardSpreadRadius,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Media content
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppDimensions.radiusLarge),
                topRight: Radius.circular(AppDimensions.radiusLarge),
              ),
              child: _buildMediaWidget(),
            ),

            // File info and actions
            Padding(
              padding: const EdgeInsets.all(AppDimensions.spacing12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // File name
                  Text(
                    widget.status.name,
                    style: AppTextStyles.titleSmall.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: AppDimensions.spacing4),

                  // File info
                  Row(
                    children: [
                      Icon(
                        widget.status.type == StatusType.video
                            ? Icons.videocam
                            : Icons.image,
                        size: AppDimensions.iconSmall,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: AppDimensions.spacing4),
                      Text(
                        widget.status.formattedSize,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        widget.status.formattedDate,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppDimensions.spacing8),

                  // Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.status.type == StatusType.video
                            ? 'Video'
                            : 'Image',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      GestureDetector(
                        onTap: widget.onSave,
                        child: Container(
                          padding: const EdgeInsets.all(AppDimensions.spacing8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusSmall,
                            ),
                          ),
                          child: Icon(
                            Icons.download,
                            size: AppDimensions.iconSmall,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaWidget() {
    if (widget.status.type == StatusType.video) {
      return _buildVideoWidget();
    } else {
      return _buildImageWidget();
    }
  }

  Widget _buildImageWidget() {
    final theme = Theme.of(context);
    return AspectRatio(
      aspectRatio: 1.0,
      child: Image.file(
        widget.status.file,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: theme.colorScheme.surfaceVariant,
            child: Center(
              child: Icon(
                Icons.broken_image,
                color: theme.colorScheme.onSurfaceVariant,
                size: 40,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVideoWidget() {
    final theme = Theme.of(context);
    return AspectRatio(
      aspectRatio: 1.0,
      child: Stack(
        children: [
          if (_isVideoInitialized && _videoController != null)
            VideoPlayer(_videoController!)
          else
            Container(
              color: theme.colorScheme.onSurface.withOpacity(0.8),
              child: Center(
                child: CircularProgressIndicator(
                  color: theme.colorScheme.surface,
                ),
              ),
            ),

          // Video overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.3)],
              ),
            ),
          ),

          // Play button
          Center(
            child: Icon(
              Icons.play_circle_filled,
              color: theme.colorScheme.surface,
              size: 50,
            ),
          ),

          // Duration badge (if available)
          if (_isVideoInitialized && _videoController != null)
            Positioned(
              top: AppDimensions.spacing8,
              right: AppDimensions.spacing8,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacing8,
                  vertical: AppDimensions.spacing4,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusSmall,
                  ),
                ),
                child: Text(
                  _formatDuration(_videoController!.value.duration),
                  style: AppTextStyles.labelSmall.copyWith(
                    color: Theme.of(context).colorScheme.surface,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
