"""
URL patterns for universities app.
Defines API endpoints for university management and related data.
"""

from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import (
    UniversityViewSet, CampusViewSet, UniversityRankingViewSet,
    UniversityProgramViewSet, UniversityFacultyViewSet,
    UniversityResearchViewSet, UniversityPartnershipViewSet, FeedViewSet
)

# Create router for ViewSets
router = DefaultRouter()
router.register(r'universities', UniversityViewSet, basename='university')
router.register(r'campuses', CampusViewSet, basename='campus')
router.register(r'rankings', UniversityRankingViewSet, basename='ranking')
router.register(r'programs', UniversityProgramViewSet, basename='program')
router.register(r'faculties', UniversityFacultyViewSet, basename='faculty')
router.register(r'research', UniversityResearchViewSet, basename='research')
router.register(r'partnerships', UniversityPartnershipViewSet, basename='partnership')
router.register(r"feeds", FeedViewSet, basename="feed")

app_name = 'universities'

urlpatterns = [
    # Direct path for frontend compatibility
    path('filtereduniversities/', UniversityViewSet.as_view({'post': 'filtereduniversities'}), name='filtered-universities'),
    # Include router URLs
    path('', include(router.urls)),
]