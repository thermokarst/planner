# Generated by Django 4.0 on 2022-01-06 04:58

from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    initial = True

    dependencies = [
        ('plans', '0001_initial'),
        ('todos', '0001_initial'),
    ]

    operations = [
        migrations.AddField(
            model_name='plannedtodo',
            name='todo',
            field=models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='todos.todo'),
        ),
        migrations.AddField(
            model_name='plan',
            name='todos',
            field=models.ManyToManyField(related_name='todos', through='plans.PlannedTodo', to='todos.Todo'),
        ),
    ]
