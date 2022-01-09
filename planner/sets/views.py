from django.http import HttpResponseRedirect
from django.urls import reverse_lazy
from django.views.generic import DetailView, ListView
from django.views.generic.edit import FormView, UpdateView, CreateView
from django.contrib import messages
from django.contrib.auth.mixins import LoginRequiredMixin
from django.views.generic.detail import SingleObjectMixin

from planner.links.forms import LinkForm

from .forms import SetForm
from .models import Link, Set


class NewView(LoginRequiredMixin, CreateView):
    model = Set
    form_class = SetForm
    template_name = 'sets/new.html'
    success_url = reverse_lazy('links:index')


class SetView(LoginRequiredMixin, FormView, SingleObjectMixin):
    model = Set
    form_class = LinkForm
    template_name = 'sets/detail.html'
    context_object_name = 'set'

    def get_success_url(self):
        set = self.get_object()
        return reverse_lazy('sets:detail', args=(set.slug,))

    def get_initial(self):
        if getattr(self, 'object', None) is None:
            self.object = self.get_object()
        initial = super().get_initial()
        initial['sets'] = self.object.id
        return initial

    def form_valid(self, form):
        form.save()
        return super().form_valid(form)

    def get_context_data(self, **kwargs):
        self.object = self.get_object()
        ctx = super().get_context_data(**kwargs)
        ctx['links'] = self.object.links.filter(done=False).order_by('-updated_at')
        return ctx


class MarkLinkAsDoneView(LoginRequiredMixin, DetailView):
    model = Link
    slug_url_kwarg = 'link_slug'

    def get(self, request, *args, **kwargs):
        link = self.get_object()
        if not link.done:
            link.done = True
            link.save()
        set_slug = kwargs['slug']
        url = reverse_lazy('sets:detail', args=(set_slug,))
        return HttpResponseRedirect(url)


class MarkAsDoneView(LoginRequiredMixin, DetailView):
    model = Set
    success_url = reverse_lazy('links:index')

    def get(self, request, *args, **kwargs):
        set = self.get_object()
        undone_count = set.links.filter(done=False).count()

        if undone_count > 0:
            messages.add_message(request, messages.INFO, 'Cannot remove set with outstanding links')

        if undone_count == 0 and not set.done:
            set.done = True
            set.save()

        return HttpResponseRedirect(self.success_url)


class MarkAsUndoneView(LoginRequiredMixin, DetailView):
    model = Set
    success_url = reverse_lazy('links:index')

    def get(self, request, *args, **kwargs):
        set = self.get_object()
        if set.done:
            set.done = False
            set.save()
        return HttpResponseRedirect(self.success_url)


class EditView(LoginRequiredMixin, UpdateView):
    model = Set
    form_class = SetForm
    template_name = 'sets/edit.html'
    success_url = reverse_lazy('links:index')


class DoneView(LoginRequiredMixin, ListView):
    queryset = Set.objects.filter(done=True)
    ordering = '-updated_at'
    template_name = 'sets/done.html'
    context_object_name = 'sets'


class SearchView(LoginRequiredMixin, DetailView):
    model = Set
    template_name = 'sets/search.html'
    context_object_name = 'set'

    def get_context_data(self, **kwargs):
        ctx = super().get_context_data(**kwargs)
        ctx['links'] = self.object.links.filter(done=False).order_by('-updated_at')
        return ctx
