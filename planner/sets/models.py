from django.conf import settings
from django.db import models
from django_hashids import HashidsField

from planner.links.models import Link


_salts = settings.DJANGO_HASHID_SALTS


class Set(models.Model):
    slug = HashidsField(real_field_name='id', salt=_salts['set'])
    name = models.CharField(max_length=100, verbose_name='Name')
    done = models.BooleanField(default=False, verbose_name='Done?')
    links = models.ManyToManyField(Link, through='SetLink', related_name='links')
    created_at = models.DateTimeField(auto_now_add=True, verbose_name='Created At')
    updated_at = models.DateTimeField(auto_now=True, verbose_name='Updated At')

    def __str__(self):
        return self.name


class SetLink(models.Model):
    link = models.ForeignKey(Link, on_delete=models.CASCADE)
    set = models.ForeignKey(Set, on_delete=models.CASCADE)
    created_at = models.DateTimeField(auto_now_add=True, verbose_name='Created At')
    updated_at = models.DateTimeField(auto_now=True, verbose_name='Updated At')
