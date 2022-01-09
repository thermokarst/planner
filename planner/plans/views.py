from django.http import HttpResponseRedirect
from django.urls import reverse_lazy
from django.views.generic import DetailView, ListView
from django.views.generic.edit import FormView, UpdateView, CreateView
from django.contrib import messages
from django.contrib.auth.mixins import LoginRequiredMixin
from django.views.generic.detail import SingleObjectMixin

from planner.todos.forms import TodoForm

from .forms import PlanForm
from .models import Todo, Plan


class NewView(LoginRequiredMixin, CreateView):
    model = Plan
    form_class = PlanForm
    template_name = 'plans/new.html'
    success_url = reverse_lazy('todos:index')


class PlanView(LoginRequiredMixin, FormView, SingleObjectMixin):
    model = Plan
    form_class = TodoForm
    template_name = 'plans/detail.html'
    context_object_name = 'plan'

    def get_success_url(self):
        plan = self.get_object()
        return reverse_lazy('plans:detail', args=(plan.slug,))

    def get_initial(self):
        if getattr(self, 'object', None) is None:
            self.object = self.get_object()
        initial = super().get_initial()
        initial['plans'] = self.object.id
        return initial

    def form_valid(self, form):
        form.save()
        return super().form_valid(form)

    def get_context_data(self, **kwargs):
        self.object = self.get_object()
        ctx = super().get_context_data(**kwargs)
        ctx['todos'] = self.object.todos.filter(done=False).order_by('-updated_at')
        return ctx


class MarkTodoAsDoneView(LoginRequiredMixin, DetailView):
    model = Todo
    slug_url_kwarg = 'todo_slug'

    def get(self, request, *args, **kwargs):
        todo = self.get_object()
        if not todo.done:
            todo.done = True
            todo.save()
        plan_slug = kwargs['slug']
        url = reverse_lazy('plans:detail', args=(plan_slug,))
        return HttpResponseRedirect(url)


class MarkAsDoneView(LoginRequiredMixin, DetailView):
    model = Plan
    success_url = reverse_lazy('todos:index')

    def get(self, request, *args, **kwargs):
        plan = self.get_object()
        undone_count = plan.todos.filter(done=False).count()

        if undone_count > 0:
            messages.add_message(request, messages.INFO, 'Cannot remove plan with outstanding todos')

        if undone_count == 0 and not plan.done:
            plan.done = True
            plan.save()

        return HttpResponseRedirect(self.success_url)


class MarkAsUndoneView(LoginRequiredMixin, DetailView):
    model = Plan
    success_url = reverse_lazy('todos:index')

    def get(self, request, *args, **kwargs):
        plan = self.get_object()
        if plan.done:
            plan.done = False
            plan.save()
        return HttpResponseRedirect(self.success_url)


class EditView(LoginRequiredMixin, UpdateView):
    model = Plan
    form_class = PlanForm
    template_name = 'plans/edit.html'
    success_url = reverse_lazy('todos:index')


class DoneView(LoginRequiredMixin, ListView):
    queryset = Plan.objects.filter(done=True)
    ordering = '-updated_at'
    template_name = 'plans/done.html'
    context_object_name = 'plans'
