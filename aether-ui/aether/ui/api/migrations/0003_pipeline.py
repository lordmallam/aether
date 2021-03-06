# -*- coding: utf-8 -*-
# Generated by Django 1.11.12 on 2018-04-18 11:59
from __future__ import unicode_literals

import django.contrib.postgres.fields.jsonb
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('ui', '0002_remove_usertokens_odk_token'),
    ]

    operations = [
        migrations.AlterModelOptions(
            name='pipeline',
            options={'ordering': ('name',)},
        ),
        migrations.AddField(
            model_name='pipeline',
            name='entity_types',
            field=django.contrib.postgres.fields.jsonb.JSONField(null=True, blank=True, default=list),
        ),
        migrations.AddField(
            model_name='pipeline',
            name='input',
            field=django.contrib.postgres.fields.jsonb.JSONField(null=True, blank=True, default=dict),
        ),
        migrations.AddField(
            model_name='pipeline',
            name='mapping',
            field=django.contrib.postgres.fields.jsonb.JSONField(null=True, blank=True, default=list),
        ),
        migrations.AddField(
            model_name='pipeline',
            name='mapping_errors',
            field=django.contrib.postgres.fields.jsonb.JSONField(null=True, blank=True, editable=False),
        ),
        migrations.AddField(
            model_name='pipeline',
            name='output',
            field=django.contrib.postgres.fields.jsonb.JSONField(null=True, blank=True, editable=False),
        ),
        migrations.AddField(
            model_name='pipeline',
            name='schema',
            field=django.contrib.postgres.fields.jsonb.JSONField(null=True, blank=True, default=dict),
        ),
        migrations.AlterField(
            model_name='pipeline',
            name='name',
            field=models.CharField(max_length=100, unique=True),
        ),
    ]
