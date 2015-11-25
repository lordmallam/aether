# -*- coding: utf-8 -*-
from rest_framework import serializers
import json
import logging
from .models import Response, Survey, Map
import jsonschema
import string


logger = logging.getLogger(__name__)


# Note: a combinations of JSONB in postgres and json parsing gives a nasty db
# error
# See: https://bugs.python.org/issue10976#msg159391
# and http://www.postgresql.org/message-id/E1YHHV8-00032A-Em@gemulon.postgresql.org
def make_printable(obj):
    if isinstance(obj, dict):
        return {make_printable(k): make_printable(v) for k, v in obj.items()}
    elif isinstance(obj, list):
        return [make_printable(elem) for elem in obj]
    elif isinstance(obj, str):
        return ''.join(x for x in obj if x in string.printable)  # Only printables
    else:
        return obj


class JSONSerializerMixin:

    """ Serializer for JSONField -- required to make field writable"""

    def to_internal_value(self, data):
        if isinstance(data, str):
            try:
                data = json.loads(data)
            except Exception as e:
                raise serializers.ValidationError(str(e))

        return make_printable(data)

    def to_representation(self, value):

        class JSONish(type(value)):

            """
            Helper class to properly render JSON in the HTML form.
            Without this it will either put the JSON as a string in the json response
            or it will put a pyhton dict as a string in html and json renders
            """

            def __str__(self):
                return json.dumps(self, sort_keys=True)

        return JSONish(value)


class JSONSerializer(JSONSerializerMixin, serializers.Serializer):
    pass


class JSONSerializerField(JSONSerializerMixin, serializers.CharField):
    pass


def is_json(value):
    if isinstance(value, str):
        try:
            json.loads(value)
        except Exception as e:
            raise serializers.ValidationError(str(e))
    return True


class JSONSpecValidator(object):

    """
    This validates the submitted json with the schema saved on the Response.Survey.schema
    """

    def __init__(self):
        self.schema = {}

    def __call__(self, value):
        v = jsonschema.Draft4Validator(self.schema)
        errors = sorted(v.iter_errors(value), key=lambda e: e.path)
        if errors:
            raise serializers.ValidationError(list(map(str, errors)))
        return True

    def set_context(self, serializer_field):
        survey_id = serializer_field.parent.initial_data['survey']
        # First (only) or None
        survey = (Survey.objects.filter(id=survey_id) or [None])[0]
        if survey:
            self.schema = survey.schema


class SurveySerialzer(serializers.ModelSerializer):
    url = serializers.HyperlinkedIdentityField('survey-detail')
    map_functions_url = serializers.HyperlinkedIdentityField(
        'survey_map_function-list', read_only=True, lookup_url_kwarg='parent_lookup_survey')
    responses_url = serializers.HyperlinkedIdentityField(
        'survey_response-list', read_only=True, lookup_url_kwarg='parent_lookup_survey')
    schema = JSONSerializerField(validators=[is_json])
    created_by = serializers.PrimaryKeyRelatedField(
        read_only=True,
        default=serializers.CurrentUserDefault())

    class Meta:
        model = Survey


class ResponseSerialzer(serializers.ModelSerializer):
    url = serializers.HyperlinkedIdentityField('response-detail')
    survey_url = serializers.HyperlinkedRelatedField(
        'survey-detail', source='survey', read_only=True)
    data = JSONSerializerField(validators=[JSONSpecValidator()])
    created_by = serializers.PrimaryKeyRelatedField(
        read_only=True,
        default=serializers.CurrentUserDefault())

    class Meta:
        model = Response


class MappedResponseSerializer(ResponseSerialzer):
    mapped_data = JSONSerializerField(read_only=True)
    mapped_err = serializers.CharField(read_only=True)


class MapFunctionSerializer(serializers.ModelSerializer):
    url = serializers.HyperlinkedIdentityField(
        'map_functions-detail', read_only=True)
    survey_url = serializers.HyperlinkedRelatedField('survey-detail', read_only=True, source='survey')
    responses_url = serializers.HyperlinkedIdentityField(
        'map_function_response-list', read_only=True, lookup_url_kwarg='parent_lookup_survey__map')

    class Meta:
        model = Map
