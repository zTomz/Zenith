import 'dart:io';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:zenith/services/ai_model_service.dart';

class DownloadAiTile extends StatefulWidget with FTileMixin {
  const DownloadAiTile({super.key});

  @override
  State<DownloadAiTile> createState() => _DownloadAiTileState();
}

class _DownloadAiTileState extends State<DownloadAiTile> {
  // Access the global service
  final _aiService = AIModelService.instance;

  static const String _modelUrl =
      'https://huggingface.co/Qwen/Qwen2.5-1.5B-Instruct-GGUF/resolve/main/qwen2.5-1.5b-instruct-q4_k_m.gguf?download=true';

  // Local state for download progress (doesn't need to be global)
  double _downloadProgress = -1;
  CancelToken? _cancelToken;

  @override
  void dispose() {
    // Cancel download if user leaves the screen to save data
    if (_cancelToken != null && !_cancelToken!.isCancelled) {
      _cancelToken!.cancel("Screen closed");
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ListenableBuilder rebuilds this widget automatically when AIModelService changes
    return ListenableBuilder(
      listenable: _aiService,
      builder: (context, child) {
        final isDownloaded = _aiService.isDownloaded;

        return FTile(
          prefix: const Icon(FIcons.brainCog),
          title: const Text('AI Model'),
          details: isDownloaded
              ? const Text(
                  "Model installed",
                  style: TextStyle(color: Colors.green),
                )
              : _downloadProgress == -1
              ? const Text('Download Zenith AI (1.1 GB)')
              : ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 200),
                  child: Row(
                    children: [
                      Text('${(_downloadProgress * 100).toStringAsFixed(0)}%'),
                      const SizedBox(width: 8),
                      Expanded(
                        child: FDeterminateProgress(value: _downloadProgress),
                      ),
                    ],
                  ),
                ),
          onPress: () async {
            if (isDownloaded) {
              _showDeleteDialog(context);
            } else if (_downloadProgress != -1) {
              _cancelDownload();
            } else {
              await _startDownload();
            }
          },
        );
      },
    );
  }

  Future<void> _startDownload() async {
    _cancelToken = CancelToken();
    final dio = Dio();

    try {
      // 1. Get target path from service
      final filePath = await _aiService.getTargetFilePath();

      setState(() {
        _downloadProgress = 0;
      });

      // 2. Start Download
      await dio.download(
        _modelUrl,
        filePath,
        cancelToken: _cancelToken,
        onReceiveProgress: (received, total) {
          if (total != -1 && mounted) {
            setState(() {
              _downloadProgress = received / total;
            });
          }
        },
      );

      // 3. Success
      if (mounted) {
        setState(() {
          _downloadProgress = -1;
        });
        // Update global state
        _aiService.setDownloadComplete();
      }
    } catch (e) {
      // 4. Handle Error or Cancel
      if (CancelToken.isCancel(e as DioException)) {
        debugPrint("Download canceled by user");
      } else {
        debugPrint("Download error: $e");
      }

      // Cleanup: Delete corrupted file
      await _deleteFileLocally(updateService: false);

      if (mounted) {
        setState(() {
          _downloadProgress = -1;
        });
      }
    }
  }

  void _cancelDownload() {
    _cancelToken?.cancel("Canceled by user");
  }

  Future<void> _showDeleteDialog(BuildContext context) async {
    showFDialog(
      routeStyle: context.theme.dialogRouteStyle
          .copyWith(
            barrierFilter: (animation) => ImageFilter.compose(
              outer: ImageFilter.blur(
                sigmaX: animation * 5,
                sigmaY: animation * 5,
              ),
              inner: ColorFilter.mode(
                context.theme.colors.barrier,
                BlendMode.srcOver,
              ),
            ),
          )
          .call,
      context: context,
      builder: (context, style, animation) => FDialog(
        animation: animation,
        title: const Text('Are you absolutely sure?'),
        body: const Text(
          'Are you sure you want to delete the AI model? This action cannot be undone.',
        ),
        actions: [
          FButton(
            style: FButtonStyle.destructive(),
            onPress: () async {
              await _deleteFileLocally(updateService: true);
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
            child: const Text('Delete'),
          ),
          FButton(
            style: FButtonStyle.outline(),
            onPress: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  /// Helper to delete the file physically
  Future<void> _deleteFileLocally({required bool updateService}) async {
    try {
      final path = await _aiService.getTargetFilePath();
      final file = File(path);

      if (await file.exists()) {
        await file.delete();
      }

      if (updateService) {
        _aiService.setDeleted();
      }
    } catch (e) {
      debugPrint("Error deleting file: $e");
    }
  }
}
