from django import forms

from planner.plans.models import Plan

from .models import Todo


class TodoForm(forms.ModelForm):
    class Meta:
        model = Todo
        fields = ['title', 'body', 'plans']

    title = forms.CharField(label='', widget=forms.TextInput(attrs={'autofocus': True}))
    body = forms.CharField(widget=forms.Textarea, label='', required=False)
    plans = forms.CharField(widget=forms.HiddenInput, required=False)


class TodoEditForm(TodoForm):
    plans = forms.ModelMultipleChoiceField(
        label='plans',
        queryset=Plan.objects.filter(done=False).order_by('-updated_at'),
        required=False,
        widget=forms.CheckboxSelectMultiple(),
    )
