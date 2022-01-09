from django import forms


class OmniForm(forms.Form):
    value = forms.CharField(label='', widget=forms.Textarea(attrs={'autofocus': True}))
