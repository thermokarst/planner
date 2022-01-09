from django.http import HttpResponseRedirect
from django.views.generic.edit import FormView, UpdateView
from django.urls import reverse_lazy
from django.db.models import Count, Q
from django.views.generic import DetailView, ListView
from django.contrib.auth.mixins import LoginRequiredMixin

from planner.sets.models import Set

from .forms import LinkForm, LinkEditForm
from .models import Link


class IndexView(LoginRequiredMixin, FormView):
    template_name = 'links/index.html'
    form_class = LinkForm
    success_url = reverse_lazy('links:index')

    def get_context_data(self, **kwargs):
        ctx = super().get_context_data(**kwargs)
        ctx['links'] = Link.objects.filter(done=False, sets=None).order_by('-updated_at')
        undone_set_links = Count('links', filter=Q(links__done=False))
        ctx['sets'] = Set.objects.filter(done=False).order_by('-updated_at').annotate(undone_count=undone_set_links)
        return ctx

    def form_valid(self, form):
        form.save()
        return super().form_valid(form)


class DoneListView(LoginRequiredMixin, ListView):
    queryset = Link.objects.filter(done=True)
    ordering = '-updated_at'
    template_name = 'links/done.html'
    context_object_name = 'links'


class MarkAsDoneView(LoginRequiredMixin, DetailView):
    model = Link
    success_url = reverse_lazy('links:index')

    def get(self, *args, **kwargs):
        link = self.get_object()
        if not link.done:
            link.done = True
            link.save()
        return HttpResponseRedirect(self.success_url)


class MarkAsUndoneView(LoginRequiredMixin, DetailView):
    model = Link
    success_url = reverse_lazy('links:index')

    def get(self, *args, **kwargs):
        link = self.get_object()
        if link.done:
            link.done = False
            link.save()
        return HttpResponseRedirect(self.success_url)


class EditView(LoginRequiredMixin, UpdateView):
    model = Link
    form_class = LinkEditForm
    template_name = 'links/edit.html'
    success_url = reverse_lazy('links:index')


class LinkView(LoginRequiredMixin, DetailView):
    model = Link
    template_name = 'links/detail.html'
    context_object_name = 'link'
