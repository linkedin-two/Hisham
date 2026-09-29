from django.db import migrations


def seed_class_meet_links(apps, schema_editor):
    ClassMeetLink = apps.get_model('google_meet', 'ClassMeetLink')
    for class_number in range(1, 11):
        ClassMeetLink.objects.get_or_create(
            class_number=class_number,
            defaults={'meet_url': '', 'is_active': True},
        )


def unseed_class_meet_links(apps, schema_editor):
    ClassMeetLink = apps.get_model('google_meet', 'ClassMeetLink')
    ClassMeetLink.objects.filter(class_number__in=range(1, 11)).delete()


class Migration(migrations.Migration):

    dependencies = [
        ('google_meet', '0001_initial'),
    ]

    operations = [
        migrations.RunPython(seed_class_meet_links, unseed_class_meet_links),
    ]
