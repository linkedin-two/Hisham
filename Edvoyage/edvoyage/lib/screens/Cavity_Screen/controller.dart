// lib/controllers/feed_controller.dart
import 'package:edvoyage/services/feed_api_service.dart';

class FeedController {
  final ApiService api;
  List<PostModel> posts = [];
  List<CategoryModel> categories = [];

  int? selectedCategoryId;
  String selectedCategoryName = 'All';

  // UI per-post state tracked by post id
  final Map<int, bool> commentOpen = {};
  final Map<int, String> commentText = {};
  final Map<int, bool> shareOpen = {};

  FeedController({ApiService? apiService}) : api = apiService ?? ApiService();

  void selectCategory(int? id, String name) {
    selectedCategoryId = id;
    selectedCategoryName = name;
  }

  // Minimal logging only
  Future<void> loadCategories() async {
    categories = await api.getCategories();
    // keep selected as 'All' if none set
    if (selectedCategoryName == 'All') selectedCategoryId = null;
  }

  Future<void> loadPosts() async {
    // controller fetches posts and initializes UI state
    final fetched = await api.getPosts(categoryId: selectedCategoryId);
    posts = fetched;
    for (final p in posts) {
      commentOpen.putIfAbsent(p.id, () => false);
      commentText.putIfAbsent(p.id, () => '');
      shareOpen.putIfAbsent(p.id, () => false);
    }
  }

  Future<void> refresh() async {
    await loadPosts();
  }

  Future<void> toggleLikeAtIndex(int index, {String? email}) async {
    if (index < 0 || index >= posts.length) return;
    final post = posts[index];

    final status = await api.toggleLike(
      postId: post.id,
      email: email,
    );
    final nowLiked = status == 'liked';
    final newLikes =
        nowLiked ? post.likesCount + 1 : (post.likesCount - 1).clamp(0, 999999);
    posts[index] = post.copyWith(isLikedByUser: nowLiked, likesCount: newLikes);
  }

  void toggleCommentBoxAtIndex(int index) {
    if (index < 0 || index >= posts.length) return;
    final id = posts[index].id;
    final open = commentOpen[id] ?? false;
    commentOpen[id] = !open;
    if (!commentOpen[id]!) commentText[id] = '';
  }

  void updateCommentText(int postId, String text) {
    commentText[postId] = text;
  }

  Future<void> submitCommentAtIndex(int index, {String? email}) async {
    if (index < 0 || index >= posts.length) return;
    final post = posts[index];
    final text = (commentText[post.id] ?? '').trim();
    if (text.isEmpty) return;

    // Use the correct post id and real comment content
    final created = await api.createComment(
      postId: post.id,
      content: text,
      email: email,
    );

    final newComments = [created, ...post.comments];
    posts[index] = post.copyWith(
        comments: newComments, commentsCount: post.commentsCount + 1);

    commentText[post.id] = '';
    commentOpen[post.id] = false;
  }

  void toggleShareAtIndex(int index) {
    if (index < 0 || index >= posts.length) return;
    final id = posts[index].id;
    shareOpen[id] = !(shareOpen[id] ?? false);
  }

  Future<bool> shareToPlatform(int index, String platform) async {
    if (index < 0 || index >= posts.length) return false;
    final post = posts[index];
    final ok = await api.sharePost(post.id.toString(), platform);
    shareOpen[post.id] = false;
    return ok;
  }

  // helper
  String formatTimestamp(String iso) {
    try {
      final dt = DateTime.parse(iso);
      final diff = DateTime.now().difference(dt);
      if (diff.inSeconds < 60) return '${diff.inSeconds}s';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m';
      if (diff.inHours < 24) return '${diff.inHours}h';
      if (diff.inDays < 7) return '${diff.inDays}d';
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return 'Unknown time';
    }
  }
}
