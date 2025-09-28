import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../data/models/whatsapp_status.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/status_gallery_viewer.dart';
import '../../../feed/presentation/widgets/whatsapp_status_card.dart';

class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  List<WhatsAppStatus> _savedFiles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedFiles();
  }

  Future<void> _loadSavedFiles() async {
    try {
      // Get the custom downloads directory
      Directory? downloadsDirectory;
      if (Platform.isAndroid) {
        downloadsDirectory = Directory(
          '/storage/emulated/0/Download/juststatus_saver',
        );
      } else {
        // For iOS, use Documents directory
        final appDir = await getApplicationDocumentsDirectory();
        downloadsDirectory = Directory(
          '${appDir.path}/Downloads/juststatus_saver',
        );
      }

      if (await downloadsDirectory.exists()) {
        final files = downloadsDirectory
            .listSync()
            .whereType<File>()
            .where(
              (file) =>
                  file.path.toLowerCase().endsWith('.jpg') ||
                  file.path.toLowerCase().endsWith('.jpeg') ||
                  file.path.toLowerCase().endsWith('.png') ||
                  file.path.toLowerCase().endsWith('.mp4') ||
                  file.path.toLowerCase().endsWith('.mov'),
            )
            .toList();

        final statusList = files.map((file) {
          final fileName = file.path.split('/').last;
          final isVideo =
              file.path.toLowerCase().endsWith('.mp4') ||
              file.path.toLowerCase().endsWith('.mov');
          final lastModified = file.lastModifiedSync();
          final fileSize = file.lengthSync();

          return WhatsAppStatus(
            id: fileName,
            name: fileName,
            filePath: file.path,
            type: isVideo ? StatusType.video : StatusType.image,
            dateModified: lastModified,
            fileSize: fileSize,
          );
        }).toList();

        // Sort by last modified (newest first)
        statusList.sort((a, b) => b.dateModified.compareTo(a.dateModified));

        setState(() {
          _savedFiles = statusList;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading saved files: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      selectedNavIndex: 1,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          AppStrings.navSaved,
          style: AppTextStyles.headlineSmall.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textPrimary),
            onPressed: () {
              setState(() {
                _isLoading = true;
              });
              _loadSavedFiles();
            },
          ),
          const SizedBox(width: AppDimensions.spacing8),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _savedFiles.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.folder_open,
                    size: 80,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(height: AppDimensions.spacing16),
                  Text('No Downloaded Status', style: AppTextStyles.titleLarge),
                  SizedBox(height: AppDimensions.spacing8),
                  Text(
                    'Your downloaded WhatsApp statuses will appear here',
                    style: AppTextStyles.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadSavedFiles,
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.spacing16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_savedFiles.length} Downloaded Files',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacing16),
                    Expanded(
                      child: MasonryGridView.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: AppDimensions.spacing8,
                        crossAxisSpacing: AppDimensions.spacing8,
                        itemCount: _savedFiles.length,
                        itemBuilder: (context, index) {
                          final status = _savedFiles[index];
                          return WhatsAppStatusCard(
                            status: status,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => StatusGalleryViewer(
                                    status: status,
                                    allStatuses: _savedFiles,
                                    currentIndex: index,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
