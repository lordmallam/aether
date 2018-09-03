# -*- coding: utf-8 -*-
# Generated by Django 1.11.13 on 2018-06-28 07:24
from __future__ import unicode_literals

from django.db import migrations, models
import django.utils.timezone


class Migration(migrations.Migration):

    dependencies = [
        ('odk', '0006_verbose_name'),
    ]

    operations = [
        migrations.AlterModelOptions(
            name='xform',
            options={'ordering': ['title', 'form_id', 'version'], 'verbose_name': 'xform', 'verbose_name_plural': 'xforms'},
        ),
        migrations.AddField(
            model_name='xform',
            name='modified_at',
            field=models.DateTimeField(default=django.utils.timezone.now, verbose_name='modified at'),
        ),
    ]