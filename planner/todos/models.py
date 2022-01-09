from django.conf import settings
from django.db import models
from django_hashids import HashidsField


_salts = settings.DJANGO_HASHID_SALTS


class Todo(models.Model):
    slug = HashidsField(real_field_name='id', salt=_salts['todo'])
    title = models.CharField(max_length=100, verbose_name='Title')
    body = models.TextField(blank=True, verbose_name='Body')
    done = models.BooleanField(default=False, verbose_name='Done?')
    plans = models.ManyToManyField('plans.Plan', through='plans.PlannedTodo', related_name='plans')
    created_at = models.DateTimeField(auto_now_add=True, verbose_name='Created At')
    updated_at = models.DateTimeField(auto_now=True, verbose_name='Updated At')

    def __str__(self):
        return self.title
