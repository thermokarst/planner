from django import forms

from .models import Plan


class PlanForm(forms.ModelForm):
    class Meta:
        model = Plan
        fields = ['name']

    name = forms.CharField(label='', widget=forms.TextInput(attrs={'autofocus': True}))
