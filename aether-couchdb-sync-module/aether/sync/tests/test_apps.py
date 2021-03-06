# Copyright (C) 2018 by eHealth Africa : http://www.eHealthAfrica.org
#
# See the NOTICE file distributed with this work for additional information
# regarding copyright ownership.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

from django.apps import apps
from django.test import TestCase
from django_rq import get_scheduler


class AppsTests(TestCase):

    def test_app_config(self):
        # this is only valid in tests, the correct name is `aether.sync`
        self.assertEquals(apps.get_app_config('sync').verbose_name, 'Aether CouchDB-Sync')

    def test_scheduler(self):
        scheduler = get_scheduler('default')
        jobs = scheduler.get_jobs()

        self.assertEquals(len(jobs), 1, 'only one job')
