# -*- coding: utf-8 -*-
# Generated by Django 1.11.13 on 2018-05-31 08:12
from __future__ import unicode_literals

import django.contrib.postgres.fields.jsonb
from django.db import migrations, models
import django.utils.timezone
import model_utils.fields
import uuid


class Migration(migrations.Migration):

    replaces = [
        ('ui', '0001_initial'),
        ('ui', '0002_remove_usertokens_odk_token'),
        ('ui', '0003_pipeline'),
        ('ui', '0004_pipeline_kernel_refs'),
        ('ui', '0005_pipeline_published_on'),
        ('ui', '0006_remove_usertokens'),
    ]

    initial = True

    dependencies = [
    ]

    operations = [
        migrations.CreateModel(
            name='Pipeline',
            fields=[
                ('created', model_utils.fields.AutoCreatedField(default=django.utils.timezone.now, editable=False, verbose_name='created')),
                ('modified', model_utils.fields.AutoLastModifiedField(default=django.utils.timezone.now, editable=False, verbose_name='modified')),
                ('id', models.UUIDField(default=uuid.uuid4, editable=False, primary_key=True, serialize=False)),
                ('name', models.CharField(max_length=100, unique=True)),
                ('entity_types', django.contrib.postgres.fields.jsonb.JSONField(null=True, blank=True, default=list)),
                ('input', django.contrib.postgres.fields.jsonb.JSONField(null=True, blank=True, default=dict)),
                ('mapping', django.contrib.postgres.fields.jsonb.JSONField(null=True, blank=True, default=list)),
                ('mapping_errors', django.contrib.postgres.fields.jsonb.JSONField(null=True, blank=True, editable=False)),
                ('output', django.contrib.postgres.fields.jsonb.JSONField(null=True, blank=True, editable=False)),
                ('schema', django.contrib.postgres.fields.jsonb.JSONField(null=True, blank=True, default=dict)),
                ('kernel_refs', django.contrib.postgres.fields.jsonb.JSONField(null=True, blank=True, editable=False)),
                ('published_on', models.DateTimeField(null=True, blank=True, editable=False)),
            ],
            options={
                'abstract': False,
                'ordering': ('name',),
            },
        ),
    ]