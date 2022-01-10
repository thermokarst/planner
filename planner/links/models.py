from django.conf import settings
from django.db import models
from django_hashids import HashidsField


_salts = settings.DJANGO_HASHID_SALTS


class Link(models.Model):
    slug = HashidsField(real_field_name='id', salt=_salts['link'])
    url = models.URLField(verbose_name='URL')
    label = models.CharField(max_length=500, blank=True, verbose_name='Label')
    sets = models.ManyToManyField('sets.Set', through='sets.SetLink', related_name='sets')
    done = models.BooleanField(default=False, verbose_name='Done?')
    created_at = models.DateTimeField(auto_now_add=True, verbose_name='Created At')
    updated_at = models.DateTimeField(auto_now=True, verbose_name='Updated At')

    def __str__(self):
        return self.url
