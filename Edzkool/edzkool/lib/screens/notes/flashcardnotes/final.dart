import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:edzkool/utils/app_log.dart';
import 'package:edzkool/screens/notes/logo.dart';
import 'package:edzkool/_env/env.dart';
import 'data.dart';

class FlashcardsScreenFour extends StatefulWidget {
  final String description;
  final String subSubjectName;
  final String subjectName;
  final String categoryName;
  const FlashcardsScreenFour({
    super.key,
    required this.description,
    required this.subSubjectName,
    required this.subjectName,
    required this.categoryName,
  });

  @override
  State<FlashcardsScreenFour> createState() => _FlashcardsScreenFourState();
}

class _FlashcardsScreenFourState extends State<FlashcardsScreenFour> {
  // All images available for this deck
  List<Map<String, String>> _allImages = [];
  // Windowed visible images currently in memory (lazy loaded in batches of 5)
  List<Map<String, String>> _visibleImages = [];
  static const int _batchSize = 5;

  final PageController _pageController = PageController();
  int _currentIndex = 0;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _controlsVisible = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    try {
      var data = await fetchFlashcards();
      AppLog.debug('DEBUG: FlashcardImages - API data received');

      if (data == null) {
        if (!mounted) return;
        setState(() {
          _errorMessage = 'NULL';
          _isLoading = false;
        });
        return;
      }

      List<dynamic> jsonData;
      if (data is Map && data.containsKey('results')) {
        jsonData = data['results'];
      } else if (data is List) {
        jsonData = data;
      } else {
        jsonData = [];
      }
      AppLog.debug('DEBUG: FlashcardImages - Total items: ${jsonData.length}');

      final filtered = jsonData.where(
        (item) =>
            item['category'] != null &&
            item['category']['name'] == widget.categoryName &&
            item['subject_name'] == widget.subjectName &&
            item['sub_subject_name'] == widget.subSubjectName &&
            (item['description']?.toString() ?? '') == widget.description,
      );

      final List<Map<String, String>> tempImages = [];

      for (var i in filtered) {
        if (i['images'] != null) {
          for (var img in i['images']) {
            tempImages.add({
              'image': img['image']?.toString() ?? '',
              'caption': img['caption']?.toString() ?? '',
            });
          }
        }
      }

      if (tempImages.isEmpty) {
        if (!mounted) return;
        setState(() {
          _errorMessage = 'NULL';
          _isLoading = false;
        });
        return;
      }

      if (!mounted) return;
      setState(() {
        _allImages = tempImages;
        // Lazy load: initially only load the first batch (1-5 pages)
        _visibleImages = tempImages.sublist(0, min(_batchSize, tempImages.length));
        _isLoading = false;
      });
      AppLog.debug('DEBUG: Initialized lazy flashcards: showing ${_visibleImages.length} of ${_allImages.length} images');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'NULL';
        _isLoading = false;
      });
    }
  }

  /// Dynamically load the next batch of 5 images when user scrolls near the end
  void _loadNextBatch() {
    if (_isLoadingMore || _visibleImages.length >= _allImages.length) return;

    setState(() {
      _isLoadingMore = true;
    });

    // Append next batch
    Future.microtask(() {
      if (!mounted) return;
      final nextCount = min(_visibleImages.length + _batchSize, _allImages.length);
      final nextBatch = _allImages.sublist(_visibleImages.length, nextCount);
      setState(() {
        _visibleImages.addAll(nextBatch);
        _isLoadingMore = false;
      });
      AppLog.debug('DEBUG: Lazy loaded batch: now showing ${_visibleImages.length} of ${_allImages.length} images');
    });
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });

    // Pre-fetch next batch when user reaches 2 cards before the current end
    if (index >= _visibleImages.length - 2 && _visibleImages.length < _allImages.length) {
      _loadNextBatch();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPrevious() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToNext() {
    // If we're at the end of the currently rendered batch but more exist, load them immediately
    if (_currentIndex >= _visibleImages.length - 1 && _visibleImages.length < _allImages.length) {
      _loadNextBatch();
    }

    if (_currentIndex >= _allImages.length - 1) {
      // Reached the very end of the deck
      Navigator.of(context).pop();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFD9202)),
              ),
              SizedBox(height: 16),
              Text(
                'Loading flashcard deck...',
                style: TextStyle(color: Colors.white70, fontFamily: 'Poppins'),
              ),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      final w = MediaQuery.of(context).size.width;
      return Scaffold(
        appBar: CustomLogoAppBar(),
        body: Center(
          child: Text(
            _errorMessage!,
            style: TextStyle(
              fontFamily: 'Poppins',
              color: Colors.red,
              fontSize: w * 0.045,
            ),
          ),
        ),
      );
    }

    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: Theme.of(context).textTheme.apply(fontFamily: 'Poppins'),
      ),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: _allImages.isEmpty
            ? const Center(
                child: Text(
                  "No images found for this description.",
                  style: TextStyle(color: Colors.white),
                ),
              )
            : _buildFlashcardViewer(),
      ),
    );
  }

  Widget _buildFlashcardViewer() {
    final padding = MediaQuery.of(context).padding;

    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: PageView.builder(
            controller: _pageController,
            itemCount: _visibleImages.length,
            onPageChanged: _onPageChanged,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _controlsVisible = !_controlsVisible;
                  });
                },
                child: _buildFlashcard(_visibleImages[index], index),
              );
            },
          ),
        ),
        AnimatedOpacity(
          opacity: _controlsVisible ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: IgnorePointer(
            ignoring: !_controlsVisible,
            child: Stack(
              children: [
                _buildBackButton(padding.top),
                _buildArrowButton(isLeft: true),
                _buildArrowButton(isLeft: false),
                _buildPageIndicator(padding.bottom),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFlashcard(Map<String, String> imageData, int index) {
    var imageUrl = imageData['image'] ?? '';
    if (imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
      if (imageUrl.startsWith('/media/')) {
        imageUrl = imageUrl.substring(7);
      } else if (imageUrl.startsWith('media/')) {
        imageUrl = imageUrl.substring(6);
      }
      imageUrl = '${BaseUrl.mediaUrl}$imageUrl';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.contain,
        alignment: Alignment.center,
        memCacheWidth: 1080, // Prevent out-of-memory on devices by limiting bitmap decode resolution
        placeholder: (context, url) => Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 38,
                  height: 38,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFD9202)),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  imageData['caption']?.isNotEmpty == true
                      ? 'Loading ${imageData['caption']}...'
                      : 'Loading Page ${index + 1}...',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
        ),
        errorWidget: (context, error, stackTrace) => Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(
                  Icons.broken_image_rounded,
                  size: 48,
                  color: Colors.grey,
                ),
                SizedBox(height: 8),
                Text(
                  'Failed to load image',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton(double topPadding) {
    return Positioned(
      top: topPadding + 8,
      left: 8,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.4),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  Widget _buildArrowButton({required bool isLeft}) {
    final isLast = _currentIndex == _allImages.length - 1;
    final canTap = isLeft ? _currentIndex > 0 : true;

    return Positioned(
      left: isLeft ? 8 : null,
      right: isLeft ? null : 8,
      top: 0,
      bottom: 0,
      child: Center(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.4),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(
              isLeft
                  ? Icons.chevron_left
                  : (isLast ? Icons.check : Icons.chevron_right),
              color: Colors.white,
              size: 32,
            ),
            onPressed: canTap ? (isLeft ? _goToPrevious : _goToNext) : null,
          ),
        ),
      ),
    );
  }

  Widget _buildPageIndicator(double bottomPadding) {
    final w = MediaQuery.of(context).size.width;

    return Positioned(
      left: 0,
      right: 0,
      bottom: bottomPadding + 16,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white24, width: 0.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${_currentIndex + 1} / ${_allImages.length}',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: w * 0.038,
                ),
              ),
              if (_isLoadingMore) ...[
                const SizedBox(width: 8),
                const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFD9202)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
