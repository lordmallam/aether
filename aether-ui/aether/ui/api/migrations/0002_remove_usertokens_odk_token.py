# -*- coding: utf-8 -*-
# Generated by Django 1.11 on 2018-04-05 15:46
from __future__ import unicode_literals

from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('ui', '0001_initial'),
    ]

    operations = [
        migrations.RemoveField(
            model_name='usertokens',
            name='odk_token',
        ),
    ]
