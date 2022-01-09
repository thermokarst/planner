from django.conf import settings
from django.db import models
from django_hashids import HashidsField

from planner.todos.models import Todo


_salts = settings.DJANGO_HASHID_SALTS


class Plan(models.Model):
    slug = HashidsField(real_field_name='id', salt=_salts['plan'])
    name = models.CharField(max_length=100, verbose_name='Name')
    done = models.BooleanField(default=False, verbose_name='Done?')
    todos = models.ManyToManyField(Todo, through='PlannedTodo', related_name='todos')
    created_at = models.DateTimeField(auto_now_add=True, verbose_name='Created At')
    updated_at = models.DateTimeField(auto_now=True, verbose_name='Updated At')

    def __str__(self):
        return self.name


class PlannedTodo(models.Model):
    todo = models.ForeignKey(Todo, on_delete=models.CASCADE)
    plan = models.ForeignKey(Plan, on_delete=models.CASCADE)
    created_at = models.DateTimeField(auto_now_add=True, verbose_name='Created At')
    updated_at = models.DateTimeField(auto_now=True, verbose_name='Updated At')
