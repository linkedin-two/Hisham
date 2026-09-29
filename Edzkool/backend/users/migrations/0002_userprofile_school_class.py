# Generated manually for school_class field

from django.core.validators import MaxValueValidator, MinValueValidator
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('users', '0001_initial'),
    ]

    operations = [
        migrations.AddField(
            model_name='userprofile',
            name='school_class',
            field=models.PositiveSmallIntegerField(
                blank=True,
                null=True,
                validators=[MinValueValidator(1), MaxValueValidator(10)],
                verbose_name='School Class',
            ),
        ),
    ]
