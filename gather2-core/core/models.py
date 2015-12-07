# encoding: utf-8
import logging
from django.db import models
from django.contrib.postgres.fields import JSONField
from django.conf import settings
import os
import tempfile
import subprocess
import ast


logger = logging.getLogger(__name__)


class Survey(models.Model):
    name = models.CharField(max_length=15)
    schema = JSONField(blank=False, null=False, default="{}")  # TODO: Make this readonly
    created = models.DateTimeField(auto_now_add=True, db_index=True)
    created_by = models.ForeignKey(settings.AUTH_USER_MODEL, db_index=True)

    def __str__(self):
        return '%s - %r' % (self.id, self.name)


class Response(models.Model):
    survey = models.ForeignKey(Survey)
    data = JSONField(blank=False, null=False)
    created = models.DateTimeField(auto_now_add=True, db_index=True)
    created_by = models.ForeignKey(settings.AUTH_USER_MODEL, db_index=True)


class MapFunction(models.Model):
    code = models.TextField()
    survey = models.ForeignKey(Survey)
    created = models.DateTimeField(auto_now_add=True, db_index=True)


class MapResult(models.Model):
    map_function = models.ForeignKey(MapFunction)
    response = models.ForeignKey(Response)
    data = JSONField(blank=True, null=False, editable=False)
    output = models.TextField(editable=False)
    created = models.DateTimeField(auto_now_add=True, db_index=True)


class ReduceFunction(models.Model):
    code = models.TextField()
    data = JSONField(blank=False, null=False, default="{}")
    output = models.TextField(blank=True, default="")
    map_function = models.ForeignKey(MapFunction)
    created = models.DateTimeField(auto_now_add=True, db_index=True)


def calculate(code, data):
    """
    This takes some python2 code and the data to be applied to it. Returns
    python literals as a list or the raw output.
    """
    # TODO: dont hardcode the tmp dir
    results = []
    with tempfile.TemporaryDirectory(dir='/tmp/') as tmpdirname:
        logger.info('created temporary directory', tmpdirname)
        with tempfile.NamedTemporaryFile(dir=tmpdirname, suffix='.py') as fp:
            # Maybe this should be moved to use stdin in the `communicate`
            # and not written to file.
            sandbox_code = '''
data={data}

{code}
'''.format(data=data, code=code)
            # Write the sandbox code to the tmp file
            fp.write(bytes(sandbox_code, 'UTF-8'))
            # Go back to the beginning so, this may not be needed
            fp.seek(0)
            # Run the code in the sandbox
            raw_out, raw_err = subprocess.Popen(["pypy-sandbox", "--timeout", "1", "--tmp", tmpdirname, os.path.basename(fp.name)],
                                                stdout=subprocess.PIPE,
                                                stderr=subprocess.PIPE
                                                ).communicate()
            # Strip off the "site" import error
            err = '\n'.join(
                (raw_err.decode("utf-8")).splitlines()[1:-1]) or None

            try:
                if raw_out:
                    # See if what was returned was a python literal, this is safe
                    for line in raw_out.decode("utf-8").splitlines():
                        results.append(ast.literal_eval(line.strip()))
                else:
                    results = [None]
            except (ValueError, SyntaxError) as e:
                logger.info(e)
                results = [raw_out.decode("utf-8").strip()]
    return results, err
