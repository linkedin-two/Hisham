import 'package:flutter/material.dart';
import 'package:edvoyage/screens/notes/logo.dart';
import 'package:edvoyage/_env/env.dart';
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
  List<Map<String, String>> _images = [];
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  bool _isLoading = true;
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
      print('DEBUG: FlashcardImages - API data received');

      if (data == null) {
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
      print('DEBUG: FlashcardImages - Total items: ${jsonData.length}');

      final filtered = jsonData.where(
        (item) =>
            item['category'] != null &&
            item['category']['name'] == widget.categoryName &&
            item['subject_name'] == widget.subjectName &&
            item['sub_subject_name'] == widget.subSubjectName &&
            (item['description']?.toString() ?? '') == widget.description,
      );
      print('DEBUG: FlashcardImages - Filtered items: ${filtered.length}');
      print('DEBUG: FlashcardImages - Looking for: cat=${widget.categoryName}, sub=${widget.subjectName}, subsub=${widget.subSubjectName}, desc=${widget.description}');

      final List<Map<String, String>> tempImages = [];

      for (var i in filtered) {
        print('DEBUG: FlashcardImages - Item images: ${i['images']}');
        if (i['images'] != null) {
          for (var img in i['images']) {
            print('DEBUG: FlashcardImages - Adding image: ${img['image']}');
            tempImages.add({
              'image': img['image'].toString(),
              'caption': img['caption'].toString(),
            });
          }
        }
      }

      if (tempImages.isEmpty) {
        setState(() {
          _errorMessage = 'NULL';
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _images = tempImages;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'NULL';
        _isLoading = false;
      });
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
    if (_currentIndex == _images.length - 1) {
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
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
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
        body: _images.isEmpty
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
            itemCount: _images.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _controlsVisible = !_controlsVisible;
                  });
                },
                child: _buildFlashcard(_images[index]),
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

  String _resolveImageUrl(String rawUrl) {
    var imageUrl = rawUrl.trim();
    if (imageUrl.isEmpty) return imageUrl;

    if (imageUrl.contains('edvoyage.work.gd/media/')) {
      imageUrl = imageUrl.substring(imageUrl.indexOf('media/') + 6);
    } else if (imageUrl.contains('localhost:8000/media/')) {
      imageUrl = imageUrl.substring(imageUrl.indexOf('media/') + 6);
    } else if (imageUrl.startsWith('http')) {
      return imageUrl;
    }

    if (imageUrl.startsWith('/media/')) {
      imageUrl = imageUrl.substring(7);
    } else if (imageUrl.startsWith('media/')) {
      imageUrl = imageUrl.substring(6);
    }

    return '${BaseUrl.mediaUrl}$imageUrl';
  }

  Widget _buildFlashcard(Map<String, String> imageData) {
    final imageUrl = _resolveImageUrl(imageData['image'] ?? '');
    print('DEBUG: FlashcardImages - Loading URL: $imageUrl');

    final w = MediaQuery.of(context).size.width;
    final imageErrorIconSize = w * 0.12;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Image.network(
        imageUrl,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.contain,
        alignment: Alignment.center,
        errorBuilder: (context, error, stackTrace) {
        print(
          'DEBUG: FlashcardImages - Failed to load: $imageUrl | $error',
        );
          return Center(
            child: Icon(
              Icons.broken_image,
              size: imageErrorIconSize,
              color: Colors.grey,
            ),
          );
        },
      ),
    );
  }

  Widget _buildBackButton(double topPadding) {
    return Positioned(
      top: topPadding + 8,
      left: 8,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.3),
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
    final isLast = _currentIndex == _images.length - 1;
    final canTap = isLeft ? _currentIndex > 0 : true;

    return Positioned(
      left: isLeft ? 8 : null,
      right: isLeft ? null : 8,
      top: 0,
      bottom: 0,
      child: Center(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
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
            onPressed: canTap
                ? (isLeft ? _goToPrevious : _goToNext)
                : null,
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
            color: Colors.black.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${_currentIndex + 1} / ${_images.length}',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: w * 0.04,
            ),
          ),
        ),
      ),
    );
  }
}
