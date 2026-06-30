import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:fladder/providers/tmdb_api_provider.dart';
import 'package:fladder/seerr/tmdb_models.dart';
import 'package:fladder/util/localization_helper.dart';

class TmdbImagesCarousel extends ConsumerStatefulWidget {
  final int tmdbId;
  final String mediaType;
  final EdgeInsetsGeometry padding;

  const TmdbImagesCarousel({
    super.key,
    required this.tmdbId,
    required this.mediaType,
    this.padding = EdgeInsets.zero,
  });

  @override
  ConsumerState<TmdbImagesCarousel> createState() => _TmdbImagesCarouselState();
}

class _TmdbImagesCarouselState extends ConsumerState<TmdbImagesCarousel> {
  final ScrollController _scrollController = ScrollController();
  bool _showLeftArrow = false;
  bool _showRightArrow = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    
    final leftVal = currentScroll > 10;
    final rightVal = currentScroll < maxScroll - 10;
    if (leftVal != _showLeftArrow || rightVal != _showRightArrow) {
      setState(() {
        _showLeftArrow = leftVal;
        _showRightArrow = rightVal;
      });
    }
  }

  void _scrollLeft() {
    _scrollController.animateTo(
      (_scrollController.offset - 400).clamp(0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _scrollRight() {
    _scrollController.animateTo(
      (_scrollController.offset + 400).clamp(0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    // TMDB requires 'movie' or 'tv'
    final String apiType = widget.mediaType == 'tvshow' ? 'tv' : 'movie';
    final asyncValue = ref.watch(tmdbImagesProvider((type: apiType, id: widget.tmdbId)));

    return asyncValue.when(
      data: (response) {
        if (response == null || response.backdrops == null || response.backdrops!.isEmpty) {
          return const SizedBox.shrink();
        }

        final backdrops = response.backdrops!.take(15).toList();
        final showRight = _showRightArrow && backdrops.length > 3;

        return Padding(
          padding: widget.padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [
              Text(
                'Scenes', // Fallback or localized
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: 180,
                    child: ListView.separated(
                      controller: _scrollController,
                      scrollDirection: Axis.horizontal,
                      itemCount: backdrops.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final backdrop = backdrops[index];
                        final url = backdrop.filePath != null
                            ? 'https://image.tmdb.org/t/p/w500${backdrop.filePath}'
                            : null;

                        if (url == null) return const SizedBox.shrink();

                        return AspectRatio(
                          aspectRatio: backdrop.aspectRatio ?? 1.778,
                          child: InkWell(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => _FullscreenGallery(
                                    backdrops: backdrops,
                                    initialIndex: index,
                                  ),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                              ),
                              clipBehavior: Clip.hardEdge,
                              child: CachedNetworkImage(
                                imageUrl: url,
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) => const Icon(Icons.broken_image),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  if (_showLeftArrow)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: FloatingActionButton.small(
                          heroTag: 'carousel_scroll_left',
                          backgroundColor: Colors.black.withOpacity(0.6),
                          foregroundColor: Colors.white,
                          onPressed: _scrollLeft,
                          child: const Icon(Icons.arrow_back_ios_new, size: 16),
                        ),
                      ),
                    ),
                  if (showRight)
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: FloatingActionButton.small(
                          heroTag: 'carousel_scroll_right',
                          backgroundColor: Colors.black.withOpacity(0.6),
                          foregroundColor: Colors.white,
                          onPressed: _scrollRight,
                          child: const Icon(Icons.arrow_forward_ios, size: 16),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (err, stack) => const SizedBox.shrink(),
    );
  }
}

class _FullscreenGallery extends StatefulWidget {
  final List<TmdbImage> backdrops;
  final int initialIndex;

  const _FullscreenGallery({
    required this.backdrops,
    required this.initialIndex,
  });

  @override
  State<_FullscreenGallery> createState() => _FullscreenGalleryState();
}

class _FullscreenGalleryState extends State<_FullscreenGallery> {
  late final PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentIndex < widget.backdrops.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prevPage() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.backdrops.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final backdrop = widget.backdrops[index];
              final url = backdrop.filePath != null
                  ? 'https://image.tmdb.org/t/p/original${backdrop.filePath}'
                  : null;

              if (url == null) return const SizedBox.shrink();

              return InteractiveViewer(
                minScale: 1.0,
                maxScale: 4.0,
                child: Center(
                  child: CachedNetworkImage(
                    imageUrl: url,
                    fit: BoxFit.contain,
                    progressIndicatorBuilder: (context, url, downloadProgress) => 
                        Center(child: CircularProgressIndicator(value: downloadProgress.progress)),
                    errorWidget: (context, url, error) => const Icon(Icons.broken_image, color: Colors.white),
                  ),
                ),
              );
            },
          ),
          if (_currentIndex > 0)
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: FloatingActionButton.small(
                  heroTag: 'gallery_prev',
                  backgroundColor: Colors.black.withOpacity(0.5),
                  foregroundColor: Colors.white,
                  onPressed: _prevPage,
                  child: const Icon(Icons.arrow_back_ios_new),
                ),
              ),
            ),
          if (_currentIndex < widget.backdrops.length - 1)
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: FloatingActionButton.small(
                  heroTag: 'gallery_next',
                  backgroundColor: Colors.black.withOpacity(0.5),
                  foregroundColor: Colors.white,
                  onPressed: _nextPage,
                  child: const Icon(Icons.arrow_forward_ios),
                ),
              ),
            ),
          Positioned(
            top: MediaQuery.paddingOf(context).top + 16,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FloatingActionButton.small(
                  heroTag: 'gallery_close_left',
                  backgroundColor: Colors.black.withOpacity(0.5),
                  foregroundColor: Colors.white,
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Icon(Icons.arrow_back),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_currentIndex + 1} / ${widget.backdrops.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                FloatingActionButton.small(
                  heroTag: 'gallery_close_right',
                  backgroundColor: Colors.black.withOpacity(0.5),
                  foregroundColor: Colors.white,
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Icon(Icons.close),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
