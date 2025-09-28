import 'dart:io';

enum StatusType { image, video }

class WhatsAppStatus {
  final String id;
  final String name;
  final String filePath;
  final StatusType type;
  final DateTime dateModified;
  final int fileSize;
  final String? thumbnailPath;

  const WhatsAppStatus({
    required this.id,
    required this.name,
    required this.filePath,
    required this.type,
    required this.dateModified,
    required this.fileSize,
    this.thumbnailPath,
  });

  File get file => File(filePath);

  String get formattedSize {
    if (fileSize < 1024) return '${fileSize}B';
    if (fileSize < 1024 * 1024)
      return '${(fileSize / 1024).toStringAsFixed(1)}KB';
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(dateModified);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  static StatusType getTypeFromExtension(String extension) {
    final imageExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp'];
    final videoExtensions = ['.mp4', '.avi', '.mkv', '.mov', '.wmv', '.3gp'];

    if (imageExtensions.contains(extension.toLowerCase())) {
      return StatusType.image;
    } else if (videoExtensions.contains(extension.toLowerCase())) {
      return StatusType.video;
    }
    return StatusType.image; // Default fallback
  }

  WhatsAppStatus copyWith({
    String? id,
    String? name,
    String? filePath,
    StatusType? type,
    DateTime? dateModified,
    int? fileSize,
    String? thumbnailPath,
  }) {
    return WhatsAppStatus(
      id: id ?? this.id,
      name: name ?? this.name,
      filePath: filePath ?? this.filePath,
      type: type ?? this.type,
      dateModified: dateModified ?? this.dateModified,
      fileSize: fileSize ?? this.fileSize,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
    );
  }
}
