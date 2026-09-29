from rest_framework import serializers


class RegisterClassSerializer(serializers.Serializer):
    school_class = serializers.IntegerField(min_value=1, max_value=10)
