from django import forms

from .models import Set


class SetForm(forms.ModelForm):
    class Meta:
        model = Set
        fields = ['name']

    name = forms.CharField(label='', widget=forms.TextInput(attrs={'autofocus': True}))
