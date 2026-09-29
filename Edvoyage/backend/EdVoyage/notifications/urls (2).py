from django.urls import path

from .views import (
    NotificationListView,
    OfferNotificationListView,
    NonOfferNotificationListView,
)


urlpatterns = [
    path('notifications/', NotificationListView.as_view(), name='notifications'),
    path('notifications/offers/', OfferNotificationListView.as_view(), name='notifications-offers'),
    path('notifications/non-offers/', NonOfferNotificationListView.as_view(), name='notifications-non-offers'),
]