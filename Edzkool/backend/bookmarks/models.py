from django.db import models
from users.models import User
from universities.models import University
from courses.models import Course

class FavouriteUniversity(models.Model):
    email = models.EmailField()
    university = models.ForeignKey(University, on_delete=models.CASCADE, related_name='favourite_universities')
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        verbose_name = "Favourite University"
        verbose_name_plural = "Favourite Universities"
        unique_together = ['email', 'university']
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.email} - {self.university.name}"
class FavouriteCourse(models.Model):
    email = models.EmailField()
    course = models.ForeignKey(Course, on_delete=models.CASCADE, related_name='favourite_courses')
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        verbose_name = "Favourite Course"
        verbose_name_plural = "Favourite Courses"
        unique_together = ['email', 'course']
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.email} - {self.course.name}"