import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fladder/models/seerr/seerr_dashboard_model.dart';
import 'package:fladder/seerr/seerr_models.dart';
import 'package:fladder/util/localization_helper.dart';
import 'package:fladder/providers/transmission_provider.dart';

class DownloadStatusLabel extends ConsumerWidget {
  final SeerrDashboardPosterModel poster;
  final List<int>? filterSeasons;

  const DownloadStatusLabel({
    required this.poster,
    this.filterSeasons,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final standardDownloads = poster.mediaInfo?.downloadStatus ?? [];
    final fourKDownloads = poster.mediaInfo?.downloadStatus4k ?? [];
    final allDownloads = [...standardDownloads, ...fourKDownloads];

    final relevantDownloads = filterSeasons != null && filterSeasons!.isNotEmpty
        ? allDownloads.where((d) => filterSeasons!.contains(d.episode?.seasonNumber)).toList()
        : allDownloads;

    num totalSize = 0;
    num totalRemaining = 0;

    for (final download in relevantDownloads) {
      if (download.size != null) {
        totalSize += download.size!;
        totalRemaining += download.sizeLeft ?? 0;
      }
    }

    final hasDownloads = totalSize > 0;
    final percentage = hasDownloads ? ((totalSize - totalRemaining) / totalSize) * 100 : 0.0;

    if (hasDownloads) {
      String downloadLabel = context.localized.processing;
      double displayPercentage = percentage / 100;
      
      final transmissionTorrents = ref.watch(transmissionProvider);
      Map<String, dynamic>? activeTorrent;
      
      for (final download in relevantDownloads) {
          if (download.downloadId != null && download.downloadId!.isNotEmpty) {
              for (final t in transmissionTorrents) {
                  if (t['hashString']?.toString().toLowerCase() == download.downloadId?.toLowerCase()) {
                      activeTorrent = t as Map<String, dynamic>?;
                      break;
                  }
              }
          }
          if (activeTorrent == null && download.title != null) {
              for (final t in transmissionTorrents) {
                  if (t['name']?.toString().toLowerCase() == download.title?.toLowerCase()) {
                      activeTorrent = t as Map<String, dynamic>?;
                      break;
                  }
              }
          }
          if (activeTorrent != null) break;
      }

      if (activeTorrent != null) {
          final pct = activeTorrent['percentDone'] as num? ?? 0.0;
          displayPercentage = pct / 100;
          final speed = activeTorrent['rateDownload_mb'] as num? ?? 0;
          final eta = activeTorrent['eta_str'] ?? '';
          
          if (speed > 0) {
              downloadLabel = '${pct.toStringAsFixed(1)}% • ${speed.toStringAsFixed(1)} MB/s • $eta';
          } else {
              downloadLabel = '${pct.toStringAsFixed(1)}% • Parado';
          }
      } else {
          if (poster.type == SeerrMediaType.tvshow && relevantDownloads.isNotEmpty) {
            final firstDownload = relevantDownloads.first;
            final seasonNum = firstDownload.episode?.seasonNumber;
            final episodeNum = firstDownload.episode?.episodeNumber;

            if (seasonNum != null && episodeNum != null) {
              downloadLabel = '${context.localized.processing} S${seasonNum}E$episodeNum';
            }
          }
      }

      return Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 6,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                value: displayPercentage,
                strokeWidth: 2,
                backgroundColor: theme.colorScheme.onPrimaryContainer.withAlpha(50),
                valueColor: AlwaysStoppedAnimation(
                  theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            Text(
              downloadLabel,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: poster.displayStatusColor,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Text(
        poster.displayStatusLabel(context),
        style: theme.textTheme.bodyMedium?.copyWith(
          color: Colors.white,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
      ),
    );
  }
}
