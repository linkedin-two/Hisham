from django.db import migrations, models


def populate_video_url(apps, schema_editor):
    Video = apps.get_model('notes', 'Video')
    for video in Video.objects.all():
        url = (
            getattr(video, 'youtube_url', None)
            or getattr(video, 'google_drive_url', None)
            or ''
        )
        if not url and getattr(video, 'video_file', None):
            url = video.video_file.name
        video.video_url = url or 'https://www.youtube.com/watch?v=dQw4w9WgXcQ'
        video.save(update_fields=['video_url'])


class Migration(migrations.Migration):

    dependencies = [
        ('notes', '0002_remove_video_video_url_video_google_drive_url_and_more'),
    ]

    operations = [
        migrations.AddField(
            model_name='video',
            name='video_url',
            field=models.URLField(blank=True, default=''),
        ),
        migrations.RunPython(populate_video_url, migrations.RunPython.noop),
        migrations.AlterField(
            model_name='video',
            name='video_url',
            field=models.URLField(),
        ),
        migrations.RemoveField(
            model_name='video',
            name='youtube_url',
        ),
        migrations.RemoveField(
            model_name='video',
            name='google_drive_url',
        ),
        migrations.RemoveField(
            model_name='video',
            name='video_file',
        ),
        migrations.AlterField(
            model_name='video',
            name='logo',
            field=models.ImageField(upload_to='video_logos/'),
        ),
    ]
