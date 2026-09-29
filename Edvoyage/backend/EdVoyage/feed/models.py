from django.db import models
from django.contrib.auth.models import User


class FeedCategory(models.Model):
    """Category such as 'NEET 2023', '1st Year MBBS', etc."""
    name = models.CharField(max_length=100, unique=True)

    def __str__(self):
        return self.name


class Post(models.Model):
    """Main feed post."""
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name="posts")
    category = models.ForeignKey(FeedCategory, on_delete=models.SET_NULL, null=True, related_name="posts")
    content = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f'Post {self.content} by {self.user.username} in {self.category.name if self.category else "Uncategorized"}'
    @property
    def likes_count(self):
        return self.likes.count()

    @property
    def comments_count(self):
        return self.comments.count()


class Comment(models.Model):
    """Comments under a post."""
    post = models.ForeignKey(Post, related_name='comments', on_delete=models.CASCADE)
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='comments')

    content = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f'Comment {self.content} by {self.user.username} on {self.post.content[:20]}'


class Like(models.Model):
    """Like on a post (one like per user per post)."""
    post = models.ForeignKey(Post, related_name='likes', on_delete=models.CASCADE)
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='likes')

    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = ("post", "user")  # prevents multiple likes

    def __str__(self):
        return f'{self.user.username} liked {self.post.content[:20]}'

# one more model for storing the bookmarked posts by users
class Bookmark(models.Model):
    """Bookmark on a post (one bookmark per user per post)."""
    post = models.ForeignKey(Post, related_name='bookmarks', on_delete=models.CASCADE)
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='bookmarks')

    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = ("post", "user")  # prevents multiple bookmarks

    def __str__(self):
        return f'{self.user.username} bookmarked {self.post.content[:20]}'
