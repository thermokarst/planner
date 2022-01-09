from django.urls import include, path

from . import views

app_name = 'sets'
urlpatterns = [
    path('new/', views.NewView.as_view(), name='new'),
    path('done/', views.DoneView.as_view(), name='done_list'),
    path('<str:slug>/', include([
        path('', views.SetView.as_view(), name='detail'),
        path('search/', views.SearchView.as_view(), name='search'),
        path('edit/', views.EditView.as_view(), name='edit'),
        path('mark_as_done/', views.MarkAsDoneView.as_view(), name='mark_as_done'),
        path('mark_as_undone/', views.MarkAsUndoneView.as_view(), name='mark_as_undone'),
        path('todo/<str:link_slug>/done/', views.MarkLinkAsDoneView.as_view(), name='mark_link_as_done'),
    ])),
]
