from django.urls import include, path

from . import views

app_name = 'todos'
urlpatterns = [
    path('', views.IndexView.as_view(), name='index'),
    path('done/', views.DoneListView.as_view(), name='done_list'),
    path('<str:slug>/', include([
        path('', views.TodoView.as_view(), name='detail'),
        path('edit/', views.EditView.as_view(), name='edit'),
        path('mark_as_done/', views.MarkAsDoneView.as_view(), name='mark_as_done'),
        path('mark_as_undone/', views.MarkAsUndoneView.as_view(), name='mark_as_undone'),
    ])),
]
