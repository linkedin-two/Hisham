from rest_framework import serializers


class SendOTPSerializer(serializers.Serializer):
    contact = serializers.EmailField(required=False)
    email = serializers.EmailField(required=False)
    otp_type = serializers.CharField(max_length=50, default='email', required=False)

    def validate(self, data):
        contact = data.get('contact') or data.get('email')
        if not contact:
            raise serializers.ValidationError({"email": "Either 'email' or 'contact' parameter is required."})
        data['validated_contact'] = contact
        return data
