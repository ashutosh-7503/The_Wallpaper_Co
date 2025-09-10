import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:shimmer/shimmer.dart';
import 'package:provider/provider.dart';
import 'package:the_wallpaper_company/features/favorite/provider/favorite_provider.dart';
import '../../models/wallpaper_model.dart';

class WallpaperScreen extends StatefulWidget {
  final List<Wallpaper> wallpapers;
  final int initialIndex;
  const WallpaperScreen({
    super.key,
    required this.wallpapers,
    required this.initialIndex,
  });

  @override
  State<WallpaperScreen> createState() => _WallpaperScreenState();
}

class _WallpaperScreenState extends State<WallpaperScreen>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late int _currentIndex;
  bool _showHeart = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onDoubleTap() {
    setState(() => _showHeart = true);
    final favProvider = Provider.of<FavoriteProvider>(context, listen: false);
    final wallpaperId = widget.wallpapers[_currentIndex].id;
    if (favProvider.isFavorite(wallpaperId)) {
      favProvider.removeFavorite(wallpaperId);
    } else {
      favProvider.addFavorite(wallpaperId);
    }
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) setState(() => _showHeart = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.wallpapers.length,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
            },
            itemBuilder: (context, index) {
              final wallpaper = widget.wallpapers[index];
              return GestureDetector(
                onDoubleTap: _onDoubleTap,
                child: Stack(
                  children: [
                    SizedBox.expand(
                      child: CachedNetworkImage(
                        cacheManager: CacheManager(
                          Config(
                            'wallpaperCache',
                            stalePeriod: const Duration(days: 7),
                            maxNrOfCacheObjects: 300,
                          ),
                        ),
                        imageUrl: wallpaper.imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Shimmer.fromColors(
                          baseColor: Colors.grey[900]!,
                          highlightColor: Colors.grey[700]!,
                          child: Container(color: Colors.grey[900]),
                        ),
                        errorWidget: (context, url, error) => const Center(
                          child: Icon(Icons.error, color: Colors.red, size: 48),
                        ),
                      ),
                    ),
                    if (_showHeart && index == _currentIndex)
                      Center(
                        child: HeartBeat(
                          duration: const Duration(milliseconds: 700),
                          child: Icon(
                            Icons.favorite,
                            color: Colors.pinkAccent.withAlpha(180),
                            size: 120,
                          ),
                        ),
                      ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 24,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withOpacity(0.8),
                              Colors.transparent,
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    wallpaper.title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black54,
                                          blurRadius: 8,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 6,
                                    ),
                                    child: Text(
                                      wallpaper.category,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white.withOpacity(0.18),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 12,
                                ),
                              ),
                              onPressed: () {
                                // TODO: Implement download logic
                              },
                              icon: const Icon(Icons.download, size: 22),
                              label: const Text(
                                'Download',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          Positioned(
            top: 36,
            left: 16,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 28,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}
