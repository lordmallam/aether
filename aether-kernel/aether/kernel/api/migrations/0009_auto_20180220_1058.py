# -*- coding: utf-8 -*-
# Generated by Django 1.11.9 on 2018-02-20 10:58
from __future__ import unicode_literals

from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        ('kernel', '0008_auto_20180208_0933'),
    ]

    operations = [
        migrations.AlterField(
            model_name='entity',
            name='projectschema',
            field=models.ForeignKey(null=True, on_delete=django.db.models.deletion.SET_NULL, related_name='entities', to='kernel.ProjectSchema'),
        ),
        migrations.AlterField(
            model_name='entity',
            name='submission',
            field=models.ForeignKey(null=True, blank=True, on_delete=django.db.models.deletion.SET_NULL, related_name='entities', to='kernel.Submission'),
        ),
    ]