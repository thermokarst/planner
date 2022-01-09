from django import forms

from planner.sets.models import Set

from .models import Link


class LinkForm(forms.ModelForm):
    class Meta:
        model = Link
        fields = ['url', 'sets']

    url = forms.CharField(label='', widget=forms.TextInput(attrs={'autofocus': True}))
    sets = forms.CharField(widget=forms.HiddenInput, required=False)


class LinkEditForm(LinkForm):
    sets = forms.ModelMultipleChoiceField(
        label='sets',
        queryset=Set.objects.filter(done=False).order_by('-updated_at'),
        required=False,
        widget=forms.CheckboxSelectMultiple(),
    )
