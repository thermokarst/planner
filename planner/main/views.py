from django.urls import reverse_lazy
from django.views.generic.edit import FormView
from django.core.validators import URLValidator
from django.core.exceptions import ValidationError
from django.contrib.auth.mixins import LoginRequiredMixin

from planner.links.models import Link
from planner.todos.models import Todo

from .forms import OmniForm


class IndexView(LoginRequiredMixin, FormView):
    template_name = 'index.html'
    form_class = OmniForm
    success_url = reverse_lazy('main:index')

    def form_valid(self, form):
        value = form.cleaned_data['value']
        url_validator = URLValidator()

        lines = [val.strip() for val in value.splitlines()]

        are_urls = []
        for line in lines:
            try:
                url_validator(line)
                are_urls.append(True)
            except ValidationError:
                are_urls.append(False)

        if all(are_urls):
            Link.objects.bulk_create([Link(url=url) for url in lines])
        else:
            title = lines[0]
            body = '\n'.join(lines[1:])
            Todo.objects.create(title=title, body=body)

        return super().form_valid(form)
