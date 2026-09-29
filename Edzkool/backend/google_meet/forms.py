from django import forms
from django.core.exceptions import ValidationError

from .models import ClassMeetLink


class ClassMeetLinkForm(forms.ModelForm):
    class Meta:
        model = ClassMeetLink
        fields = ['class_number', 'meet_url', 'is_active']
        widgets = {
            'meet_url': forms.URLInput(attrs={
                'placeholder': 'https://meet.google.com/xxx-xxxx-xxx',
                'style': 'width: 100%;',
            }),
        }

    def clean_meet_url(self):
        meet_url = (self.cleaned_data.get('meet_url') or '').strip()
        if not meet_url:
            return ''
        if not meet_url.startswith(('http://', 'https://')):
            raise ValidationError('Meet URL must start with http:// or https://')
        return meet_url

    def clean_class_number(self):
        class_number = self.cleaned_data.get('class_number')
        if class_number is not None and not (1 <= class_number <= 10):
            raise ValidationError('Class number must be between 1 and 10.')
        return class_number
