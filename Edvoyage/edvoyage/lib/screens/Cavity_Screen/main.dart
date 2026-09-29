// lib/screens/feed_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:edvoyage/screens/Cavity_Screen/controller.dart';
import 'package:edvoyage/services/feed_api_service.dart';
import 'package:edvoyage/utils/colors/colors.dart';
import 'package:edvoyage/screens/notes/logo.dart';
import 'package:edvoyage/providers/user_email_provider.dart';
import 'package:edvoyage/screens/WebPage/webpage.dart';
import 'package:edvoyage/screens/chat/conversations_screen.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  final FeedController controller = FeedController(apiService: ApiService());
  bool isLoading = true;
  bool isDropdownOpen = false;

  late double _w;
  late double _h;
  late double _padH;
  late double _padV;
  late double _cardHPad;
  late double _cardVPad;
  late double _gapSm;
  late double _gapXs;
  late double _iconSm;
  late double _textMd;
  late double _textSm;
  late double _textXs;

  @override
  void initState() {
    super.initState();
    _initAll();
  }

  Future<void> _initAll() async {
    setState(() => isLoading = true);
    await controller.loadCategories();
    await controller.loadPosts();
    setState(() => isLoading = false);
  }

  Future<void> _onRefresh() async {
    await controller.refresh();
    setState(() {}); // refresh UI
  }

  Widget _buildHeader() {
    final double iconSize = (_w * 0.07).clamp(22.0, 30.0).toDouble();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: _padH, vertical: _padV),
      decoration: BoxDecoration(color: whiteColor, boxShadow: [
        BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2))
      ]),
      child: Row(
        children: [
          Text('Cavity',
              style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: (_w * 0.055).clamp(18.0, 24.0),
                  fontWeight: FontWeight.w700,
                  color: titlecolor)),
          Spacer(),
          GestureDetector(
            onTap: () => setState(() => isDropdownOpen = !isDropdownOpen),
            child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: _padH * 0.8, vertical: _gapXs * 0.6),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: primaryColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Text(controller.selectedCategoryName,
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: _textMd,
                          fontWeight: FontWeight.w600,
                          color: primaryColor)),
                  SizedBox(width: (_w * 0.02).clamp(6.0, 10.0)),
                  AnimatedRotation(
                      turns: isDropdownOpen ? 0.5 : 0,
                      duration: Duration(milliseconds: 200),
                      child: Icon(Icons.keyboard_arrow_down,
                          color: primaryColor, size: _iconSm)),
                ],
              ),
            ),
          ),
          SizedBox(width: (_w * 0.03).clamp(8.0, 14.0)),
          GestureDetector(
            onTap: () {
              if (isDropdownOpen) {
                setState(() => isDropdownOpen = false);
              }
              final userEmail = ref.read(userEmailProvider);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ConversationsScreen(userEmail: userEmail),
                ),
              );
            },
            child: Image.asset(
              'assets/message.png',
              width: iconSize,
              height: iconSize,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYearSelectionModal() {
    if (!isDropdownOpen) return SizedBox.shrink();
    final size = MediaQuery.sizeOf(context);
    final w = size.width;
    final h = size.height;

    final modalTop = (h * 0.1).clamp(60.0, 110.0);
    final modalRight = (w * 0.05).clamp(12.0, 24.0);
    final modalW = (w * 0.5).clamp(180.0, 260.0);
    final modalMaxH = (h * 0.45).clamp(240.0, 420.0);
    final modalMinH = (h * 0.14).clamp(96.0, 140.0);

    final headerPad = (w * 0.04).clamp(12.0, 18.0);
    final itemHPad = (w * 0.04).clamp(12.0, 18.0);
    final itemVPad = (h * 0.012).clamp(8.0, 12.0);
    final modalTitleFs = (w * 0.04).clamp(14.0, 16.0);
    final modalItemFs = (w * 0.033).clamp(12.0, 14.0);
    final modalIcon = (w * 0.05).clamp(18.0, 22.0);

    final names = [
      'All',
      ...controller.categories
          .where((c) => c.name.isNotEmpty)
          .map((c) => c.name)
    ];

    return Positioned(
      top: modalTop,
      right: modalRight,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: modalW,
          constraints:
              BoxConstraints(maxHeight: modalMaxH, minHeight: modalMinH),
          decoration: BoxDecoration(
              color: whiteColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 4))
              ]),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(headerPad),
                decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12))),
                child: Row(children: [
                  Icon(Icons.filter_list, color: primaryColor, size: modalIcon),
                  SizedBox(width: (w * 0.02).clamp(6.0, 10.0)),
                  Expanded(
                      child: Text('Select Category',
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: modalTitleFs,
                              fontWeight: FontWeight.w600,
                              color: primaryColor)))
                ]),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: names.map((name) {
                      final isSelected =
                          name == controller.selectedCategoryName;
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () async {
                            // when a user taps a category:
                            // 1) find its ID (if not 'All')
                            // 2) update controller.selectedCategoryName / selectedCategoryId
                            // 3) fetch posts filtered by that category (pass ID to backend)
                            setState(() {
                              isDropdownOpen = false;
                              controller.selectedCategoryName = name;
                            });

                            if (name == 'All') {
                              controller.selectCategory(null, 'All');
                            } else {
                              // find category safely
                              final cat = controller.categories
                                  .firstWhere((c) => c.name == name);
                              controller.selectCategory(cat.id, cat.name);
                            }

                            // Load posts for the selected category (this calls API with the selected ID).
                            setState(() => isLoading = true);
                            await controller.loadPosts();
                            setState(() => isLoading = false);
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: itemHPad, vertical: itemVPad),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? primaryColor.withOpacity(0.1)
                                  : Colors.transparent,
                              border: Border(
                                  bottom: BorderSide(
                                      color: grey1.withOpacity(0.3),
                                      width: 0.5)),
                            ),
                            child: Row(children: [
                              Flexible(
                                  child: Text(name,
                                      style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: modalItemFs,
                                          fontWeight: isSelected
                                              ? FontWeight.w600
                                              : FontWeight.w400,
                                          color: isSelected
                                              ? primaryColor
                                              : titlecolor))),
                              if (isSelected)
                                Icon(Icons.check,
                                    color: primaryColor, size: modalIcon)
                            ]),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialIcon(
      String name, Color color, IconData icon, String baseUrl, PostModel post,
      {bool isInstagram = false}) {
    return GestureDetector(
      onTap: () =>
          _shareToSocial(name, baseUrl, post, isInstagram: isInstagram),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: (_w * 0.11).clamp(40.0, 50.0),
            height: (_w * 0.11).clamp(40.0, 50.0),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Center(
              child:
                  Icon(icon, color: color, size: (_w * 0.06).clamp(22.0, 28.0)),
            ),
          ),
          SizedBox(height: 4),
          Text(
            name,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: _textXs,
              color: titlecolor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _shareToSocial(String platform, String baseUrl, PostModel post,
      {bool isInstagram = false}) async {
    final String postUrl = 'https://edvoyage.com/post/${post.id}';
    final String shareText =
        '${post.content}\n\nCheck out this post on EdVoyage!';

    String url;
    if (platform == 'Gmail') {
      url =
          '$baseUrl${Uri.encodeComponent(shareText)}\n\n${Uri.encodeComponent(postUrl)}';
    } else if (platform == 'WhatsApp' || platform == 'Telegram') {
      url = '$baseUrl${Uri.encodeComponent('$shareText\n\n$postUrl')}';
    } else if (isInstagram) {
      // Instagram doesn't support direct sharing, open app or website
      final Uri instagramUri = Uri.parse('instagram://app');
      if (await canLaunchUrl(instagramUri)) {
        await launchUrl(instagramUri, mode: LaunchMode.externalApplication);
        return;
      } else {
        url = baseUrl;
      }
    } else {
      url = '$baseUrl${Uri.encodeComponent(postUrl)}';
    }

    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      // Fallback to web URL if app not installed
      final Uri webUri = Uri.parse(isInstagram ? baseUrl : url);
      if (await canLaunchUrl(webUri)) {
        await launchUrl(webUri, mode: LaunchMode.platformDefault);
      }
    }
  }

  Widget _buildPostBlock(PostModel post, int index) {
    final userName =
        post.user.fullName.isNotEmpty ? post.user.fullName : post.user.username;
    final tag = post.category?.name ?? 'Uncategorized';
    final ts = controller.formatTimestamp(post.createdAt);
    final isCommentOpen = controller.commentOpen[post.id] ?? false;
    final isShareOpen = controller.shareOpen[post.id] ?? false;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: _cardHPad, vertical: _cardVPad),
      decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 2))
          ]),
      child: Column(children: [
        Padding(
          padding: EdgeInsets.all((_w * 0.04).clamp(12.0, 18.0)),
          child: Row(children: [
            Container(
                width: (_w * 0.1).clamp(36.0, 44.0),
                height: (_w * 0.1).clamp(36.0, 44.0),
                decoration: BoxDecoration(
                    color: Colors.red, borderRadius: BorderRadius.circular(8)),
                child: Center(
                    child:
                        Icon(Icons.person, color: whiteColor, size: _iconSm))),
            SizedBox(width: (_w * 0.03).clamp(8.0, 14.0)),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(userName,
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: _textMd,
                          fontWeight: FontWeight.w600,
                          color: titlecolor)),
                  SizedBox(height: 2),
                  Row(children: [
                    Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                            color: secondaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8)),
                        child: Text(tag,
                            style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: _textXs,
                                fontWeight: FontWeight.w500,
                                color: secondaryColor))),
                    SizedBox(width: 8),
                    Text(ts,
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: _textXs,
                            color: grey3,
                            fontStyle: FontStyle.italic))
                  ])
                ]))
          ]),
        ),
        Divider(color: grey1.withOpacity(0.3), height: 1),
        Padding(
          padding: EdgeInsets.all((_w * 0.04).clamp(12.0, 18.0)),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
                post.content.isNotEmpty ? post.content : 'No content available',
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: _textMd,
                    height: 1.6,
                    color: titlecolor)),
            SizedBox(height: _gapSm),
            Row(children: [
              GestureDetector(
                onTap: () async {
                  final email = ref.read(userEmailProvider);
                  print('DEBUG: Toggling like with email: $email');
                  await controller.toggleLikeAtIndex(index, email: email);
                  setState(() {});
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                      color: (post.likesCount) > 0
                          ? Colors.green.withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: (post.likesCount) > 0
                          ? Border.all(color: Colors.green.withOpacity(0.3))
                          : null),
                  child: Row(children: [
                    Icon(
                        post.isLikedByUser
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: (post.likesCount) > 0
                            ? Colors.green
                            : (post.isLikedByUser ? primaryColor : grey3),
                        size: _iconSm),
                    SizedBox(width: (_w * 0.02).clamp(6.0, 10.0)),
                    Text('${post.likesCount}',
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: _textSm,
                            color: (post.likesCount) > 0
                                ? Colors.green
                                : (post.isLikedByUser ? primaryColor : grey3)))
                  ]),
                ),
              ),
              SizedBox(width: (_w * 0.04).clamp(10.0, 18.0)),
              GestureDetector(
                onTap: () {
                  controller.toggleCommentBoxAtIndex(index);
                  setState(() {});
                },
                child: Row(children: [
                  Icon(isCommentOpen ? Icons.comment : Icons.comment_outlined,
                      color: isCommentOpen ? primaryColor : grey3,
                      size: _iconSm),
                  SizedBox(width: (_w * 0.02).clamp(6.0, 10.0)),
                  Text('${post.commentsCount}',
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: _textSm,
                          color: isCommentOpen ? primaryColor : grey3))
                ]),
              ),
              Spacer(),
              GestureDetector(
                onTap: () {
                  controller.toggleShareAtIndex(index);
                  setState(() {});
                },
                child: Icon(isShareOpen ? Icons.share : Icons.share_outlined,
                    color: isShareOpen ? primaryColor : grey3, size: _iconSm),
              )
            ]),
            if (isCommentOpen) ...[
              SizedBox(height: _gapSm),
              Container(
                padding: EdgeInsets.all((_w * 0.03).clamp(10.0, 14.0)),
                decoration: BoxDecoration(
                    color: grey1.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8)),
                child: Row(children: [
                  Expanded(
                    child: TextField(
                      controller: TextEditingController(
                          text: controller.commentText[post.id] ?? ''),
                      onChanged: (v) =>
                          controller.updateCommentText(post.id, v),
                      decoration: InputDecoration(
                          hintText: 'Write a comment...',
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: _textSm,
                              color: grey3)),
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: _textSm,
                          color: titlecolor),
                    ),
                  ),
                  SizedBox(width: (_w * 0.02).clamp(6.0, 10.0)),
                  GestureDetector(
                    onTap: () async {
                      final email = ref.read(userEmailProvider);
                      await controller.submitCommentAtIndex(index,
                          email: email);
                      setState(() {});
                    },
                    child: Icon(Icons.send, color: primaryColor, size: _iconSm),
                  )
                ]),
              )
            ],
            if (post.comments.isNotEmpty) ...[
              SizedBox(height: _gapSm),
              Container(
                padding: EdgeInsets.all((_w * 0.03).clamp(10.0, 14.0)),
                decoration: BoxDecoration(
                    color: grey1.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8)),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Comments',
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: _textSm,
                              fontWeight: FontWeight.w600,
                              color: titlecolor)),
                      SizedBox(height: _gapXs),
                      ...post.comments.map((comment) {
                        final commenter = comment.user;
                        final name = commenter.fullName.isNotEmpty
                            ? commenter.fullName
                            : commenter.username;
                        return Container(
                          margin: EdgeInsets.only(bottom: 8),
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              color: whiteColor,
                              borderRadius: BorderRadius.circular(6),
                              border:
                                  Border.all(color: grey1.withOpacity(0.2))),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: [
                                  Container(
                                      width: (_w * 0.06).clamp(20.0, 26.0),
                                      height: (_w * 0.06).clamp(20.0, 26.0),
                                      decoration: BoxDecoration(
                                          color: primaryColor.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                      child: Center(
                                          child: Icon(Icons.person,
                                              color: primaryColor,
                                              size: (_w * 0.03)
                                                  .clamp(10.0, 14.0)))),
                                  SizedBox(width: (_w * 0.02).clamp(6.0, 10.0)),
                                  Expanded(
                                      child: Text(name,
                                          style: TextStyle(
                                              fontFamily: 'Poppins',
                                              fontSize: _textSm,
                                              fontWeight: FontWeight.w600,
                                              color: titlecolor))),
                                  Text(
                                      controller
                                          .formatTimestamp(comment.createdAt),
                                      style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: _textXs,
                                          color: grey3))
                                ]),
                                SizedBox(height: (_h * 0.006).clamp(2.0, 6.0)),
                                Text(comment.content,
                                    style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: _textSm,
                                        color: titlecolor))
                              ]),
                        );
                      })
                    ]),
              )
            ],
            if (isShareOpen) ...[
              SizedBox(height: _gapSm),
              Container(
                padding: EdgeInsets.all((_w * 0.04).clamp(12.0, 18.0)),
                decoration: BoxDecoration(
                    color: grey1.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8)),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Share to:',
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: _textSm,
                              fontWeight: FontWeight.w600,
                              color: titlecolor)),
                      SizedBox(height: _gapXs),
                      Wrap(
                          spacing: (_w * 0.04).clamp(12.0, 18.0),
                          runSpacing: _gapSm,
                          children: [
                            _buildSocialIcon(
                              'LinkedIn',
                              Color(0xFF0077B5),
                              Icons.business,
                              'https://www.linkedin.com/sharing/share-offsite/?url=',
                              post,
                            ),
                            _buildSocialIcon(
                              'WhatsApp',
                              Color(0xFF25D366),
                              Icons.chat,
                              'https://wa.me/?text=',
                              post,
                            ),
                            _buildSocialIcon(
                              'Telegram',
                              Color(0xFF0088CC),
                              Icons.send,
                              'https://t.me/share/url?url=',
                              post,
                            ),
                            _buildSocialIcon(
                              'X',
                              Colors.black,
                              Icons.alternate_email,
                              'https://twitter.com/intent/tweet?text=',
                              post,
                            ),
                            _buildSocialIcon(
                              'Facebook',
                              Color(0xFF1877F2),
                              Icons.facebook,
                              'https://www.facebook.com/sharer/sharer.php?u=',
                              post,
                            ),
                            _buildSocialIcon(
                              'Reddit',
                              Color(0xFFFF4500),
                              Icons.reddit,
                              'https://www.reddit.com/submit?url=',
                              post,
                            ),
                            _buildSocialIcon(
                              'Instagram',
                              Color(0xFFE4405F),
                              Icons.camera_alt,
                              'https://www.instagram.com/',
                              post,
                              isInstagram: true,
                            ),
                            _buildSocialIcon(
                              'Gmail',
                              Color(0xFFEA4335),
                              Icons.email,
                              'mailto:?subject=Check this out&body=',
                              post,
                            ),
                          ])
                    ]),
              )
            ]
          ]),
        ),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    _w = size.width;
    _h = size.height;

    _padH = (_w * 0.05).clamp(12.0, 24.0);
    _padV = (_h * 0.02).clamp(10.0, 18.0);
    _cardHPad = (_w * 0.05).clamp(12.0, 24.0);
    _cardVPad = (_h * 0.01).clamp(6.0, 10.0);
    _gapSm = (_h * 0.02).clamp(10.0, 16.0);
    _gapXs = (_h * 0.01).clamp(6.0, 12.0);
    _iconSm = (_w * 0.055).clamp(18.0, 26.0);
    _textMd = (_w * 0.035).clamp(13.0, 16.0);
    _textSm = (_w * 0.03).clamp(11.0, 13.0);
    _textXs = (_w * 0.028).clamp(10.0, 12.0);

    return Scaffold(
      appBar: const CustomLogoAppBar(),
      backgroundColor: color3,
      body: SafeArea(
        child: Stack(children: [
          Column(children: [
            _buildHeader(),
            Expanded(
              child: isLoading
                  ? Center(
                      child: CircularProgressIndicator(color: primaryColor))
                  : controller.posts.isEmpty
                      ? Center(
                          child: Text('NO POSTS',
                              style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: (_w * 0.045).clamp(16.0, 20.0),
                                  fontWeight: FontWeight.w600,
                                  color: titlecolor)))
                      : RefreshIndicator(
                          onRefresh: _onRefresh,
                          child: ListView.builder(
                              padding: EdgeInsets.symmetric(vertical: _gapXs),
                              itemCount: controller.posts.length,
                              itemBuilder: (ctx, idx) =>
                                  _buildPostBlock(controller.posts[idx], idx))),
            )
          ]),
          if (isDropdownOpen)
            Positioned.fill(
                child: GestureDetector(
                    onTap: () => setState(() => isDropdownOpen = false),
                    child: Container(color: Colors.transparent))),
          _buildYearSelectionModal()
        ]),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final textController = TextEditingController();
          final selectedId = controller.selectedCategoryId;
          final fallbackCategoryId = controller.categories.isNotEmpty
              ? controller.categories.first.id
              : null;
          final categoryId = selectedId ?? fallbackCategoryId;

          if (categoryId == null) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text('No category found. Please refresh and try again.'),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }

          final content = await showDialog<String>(
            context: context,
            builder: (ctx) {
              return AlertDialog(
                title: Text('Create Post'),
                content: TextField(
                  controller: textController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: "What's on your mind?",
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx, textController.text);
                    },
                    child: Text('Post'),
                  ),
                ],
              );
            },
          );

          final trimmed = (content ?? '').trim();
          if (trimmed.isEmpty) return;

          try {
            setState(() => isLoading = true);
            final email = ref.read(userEmailProvider);
            print('DEBUG: Creating post with email: $email');
            await controller.api.createPost(
              categoryId: categoryId,
              content: trimmed,
              email: email,
            );
            await controller.loadPosts();
            if (!mounted) return;
            setState(() => isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Post created successfully'),
                backgroundColor: Colors.green,
              ),
            );
          } catch (e) {
            if (!mounted) return;
            setState(() => isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to create post: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        backgroundColor: primaryColor,
        child: Icon(Icons.add, color: whiteColor),
      ),
    );
  }
}
