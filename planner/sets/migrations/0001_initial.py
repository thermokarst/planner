# Generated by Django 4.0 on 2022-01-07 00:30

from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    initial = True

    dependencies = [
        ('links', '0001_initial'),
    ]

    operations = [
        migrations.CreateModel(
            name='Set',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('name', models.CharField(max_length=100, verbose_name='Name')),
                ('done', models.BooleanField(default=False, verbose_name='Done?')),
                ('created_at', models.DateTimeField(auto_now_add=True, verbose_name='Created At')),
                ('updated_at', models.DateTimeField(auto_now=True, verbose_name='Updated At')),
            ],
        ),
        migrations.CreateModel(
            name='SetLink',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('created_at', models.DateTimeField(auto_now_add=True, verbose_name='Created At')),
                ('updated_at', models.DateTimeField(auto_now=True, verbose_name='Updated At')),
                ('link', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='links.link')),
                ('set', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='sets.set')),
            ],
        ),
        migrations.AddField(
            model_name='set',
            name='links',
            field=models.ManyToManyField(related_name='links', through='sets.SetLink', to='links.Link'),
        ),
    ]
