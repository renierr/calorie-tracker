import 'dart:io';
import 'package:flutter/material.dart';
import '../../models/meal_model.dart';
import '../../theme/theme.dart';

class MealDetailFloatingButtons extends StatelessWidget {
  final Meal currentMeal;
  final bool isFavorite;
  final bool isExporting;
  final bool isSharing;
  final VoidCallback onClose;
  final VoidCallback onFavorite;
  final VoidCallback onDownload;
  final VoidCallback onShare;

  const MealDetailFloatingButtons({
    super.key,
    required this.currentMeal,
    required this.isFavorite,
    required this.isExporting,
    required this.isSharing,
    required this.onClose,
    required this.onFavorite,
    required this.onDownload,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final showShare = Platform.isAndroid || Platform.isIOS;

    return Positioned.fill(
      child: Stack(
        children: [
          Positioned(
            top: 12,
            right: 12,
            child: FloatingActionButton.small(
              heroTag: 'close_detail_${currentMeal.id}',
              backgroundColor: Colors.black54,
              onPressed: onClose,
              child: const Icon(Icons.close, color: Colors.white),
            ),
          ),
          Positioned(
            top: 12,
            right: 60,
            child: FloatingActionButton.small(
              heroTag: 'favorite_detail_${currentMeal.id}',
              backgroundColor: Colors.black54,
              onPressed: onFavorite,
              child: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? AppTheme.accentRed : Colors.white,
              ),
            ),
          ),
          Positioned(
            top: 12,
            left: 12,
            child: FloatingActionButton.small(
              heroTag: 'download_detail_${currentMeal.id}',
              backgroundColor: Colors.black54,
              onPressed: isExporting ? null : onDownload,
              child: isExporting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.download, color: Colors.white),
            ),
          ),
          if (showShare)
            Positioned(
              top: 12,
              left: 60,
              child: FloatingActionButton.small(
                heroTag: 'share_detail_${currentMeal.id}',
                backgroundColor: Colors.black54,
                onPressed: isSharing ? null : onShare,
                child: isSharing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.share, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
