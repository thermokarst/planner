from django.http import HttpResponseRedirect
from django.urls import reverse_lazy
from django.views.generic import DetailView, ListView
from django.views.generic.edit import FormView, UpdateView
from django.db.models import Count, Q
from django.contrib.auth.mixins import LoginRequiredMixin

from planner.plans.models import Plan

from .forms import TodoForm, TodoEditForm
from .models import Todo


class IndexView(LoginRequiredMixin, FormView):
    template_name = 'todos/index.html'
    form_class = TodoForm
    success_url = reverse_lazy('todos:index')

    def get_context_data(self, **kwargs):
        ctx = super().get_context_data(**kwargs)
        ctx['todos'] = Todo.objects.filter(done=False, plans=None).order_by('-updated_at')
        undone_plan_todos = Count('todos', filter=Q(todos__done=False))
        ctx['plans'] = Plan.objects.filter(done=False).order_by('-updated_at').annotate(undone_count=undone_plan_todos)
        return ctx

    def form_valid(self, form):
        form.save()
        return super().form_valid(form)


class DoneListView(LoginRequiredMixin, ListView):
    queryset = Todo.objects.filter(done=True)
    ordering = '-updated_at'
    template_name = 'todos/done.html'
    context_object_name = 'todos'


class MarkAsDoneView(LoginRequiredMixin, DetailView):
    model = Todo
    success_url = reverse_lazy('todos:index')

    def get(self, *args, **kwargs):
        todo = self.get_object()
        if not todo.done:
            todo.done = True
            todo.save()
        return HttpResponseRedirect(self.success_url)


class MarkAsUndoneView(LoginRequiredMixin, DetailView):
    model = Todo
    success_url = reverse_lazy('todos:index')

    def get(self, *args, **kwargs):
        todo = self.get_object()
        if todo.done:
            todo.done = False
            todo.save()
        return HttpResponseRedirect(self.success_url)


class EditView(LoginRequiredMixin, UpdateView):
    model = Todo
    form_class = TodoEditForm
    template_name = 'todos/edit.html'
    success_url = reverse_lazy('todos:index')


class TodoView(LoginRequiredMixin, DetailView):
    model = Todo
    template_name = 'todos/detail.html'
    context_object_name = 'todo'
