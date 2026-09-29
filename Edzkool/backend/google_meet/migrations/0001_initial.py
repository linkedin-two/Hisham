# Generated manually

import django.core.validators
from django.db import migrations, models


class Migration(migrations.Migration):

    initial = True

    dependencies = [
    ]

    operations = [
        migrations.CreateModel(
            name='ClassMeetLink',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('class_number', models.PositiveSmallIntegerField(
                    unique=True,
                    validators=[
                        django.core.validators.MinValueValidator(1),
                        django.core.validators.MaxValueValidator(10),
                    ],
                    verbose_name='Class Number',
                )),
                ('meet_url', models.URLField(blank=True, default='', max_length=500, verbose_name='Meet URL')),
                ('is_active', models.BooleanField(default=True, verbose_name='Active')),
                ('updated_at', models.DateTimeField(auto_now=True)),
            ],
            options={
                'verbose_name': 'Class Meet Link',
                'verbose_name_plural': 'Class Meet Links',
                'ordering': ['class_number'],
            },
        ),
    ]
