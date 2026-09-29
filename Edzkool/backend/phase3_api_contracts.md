# Phase 3 — API Contracts (Serializers & Validation)

**Source endpoints:** `phase4_api_logic.json`

This document is derived from DRF serializer definitions (fields + validation methods).
It does not include business logic beyond serializer validation.

## API Group: `applications`

### `GET` `/api/v1/applications/applications/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- `applications.serializers.FrontendApplicationSerializer`
  - `id`: `IntegerField` (optional, read_only)
  - `month`: `SerializerMethodField` (optional, read_only)
  - `year`: `SerializerMethodField` (optional, read_only)
  - `name`: `CharField` (required)
  - `email_id`: `CharField` (required)
  - `user`: `IntegerField` (required)
  - `university_id`: `IntegerField` (required)
  - `created_by`: `CharField` (required)
  - `university`: `SerializerMethodField` (optional, read_only)
  - `university_name`: `CharField` (optional, read_only)
  - `program_name`: `CharField` (optional, read_only)
  - `status_display`: `CharField` (optional, read_only)

**Validation rules (serializer-level)**
- (none detected)

### `POST` `/api/v1/applications/applications/`

**Request serializer(s)**
- `applications.serializers.ApplicationCreateSerializer`
  - `university`: `PrimaryKeyRelatedField` (required)
  - `program`: `PrimaryKeyRelatedField` (required)
  - `intended_start_date`: `DateField` (required)
  - `intended_start_semester`: `CharField` (required)
  - `academic_year`: `CharField` (required)
  - `personal_statement`: `CharField` (optional)
  - `research_proposal`: `CharField` (optional)
  - `references`: `JSONField` (optional)
  - `additional_info`: `JSONField` (optional)
  - `notes`: `CharField` (optional)
  - `priority`: `ChoiceField` (optional)

**Response serializer(s)**
- `applications.serializers.ApplicationCreateSerializer`
  - `university`: `PrimaryKeyRelatedField` (required)
  - `program`: `PrimaryKeyRelatedField` (required)
  - `intended_start_date`: `DateField` (required)
  - `intended_start_semester`: `CharField` (required)
  - `academic_year`: `CharField` (required)
  - `personal_statement`: `CharField` (optional)
  - `research_proposal`: `CharField` (optional)
  - `references`: `JSONField` (optional)
  - `additional_info`: `JSONField` (optional)
  - `notes`: `CharField` (optional)
  - `priority`: `ChoiceField` (optional)

**Validation rules (serializer-level)**
- `applications.serializers.ApplicationCreateSerializer.validate`

### `POST` `/api/v1/applications/applications/test-create/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `POST` `/api/v1/applications/applications/simple-test/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `POST` `/api/v1/applications/applications/submit/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `POST` `/api/v1/applications/applications/search/`

**Request serializer(s)**
- `applications.serializers.ApplicationSearchSerializer`
  - `status`: `ChoiceField` (optional)
  - `priority`: `ChoiceField` (optional)
  - `university`: `IntegerField` (optional)
  - `program`: `IntegerField` (optional)
  - `is_complete`: `BooleanField` (optional)
  - `is_verified`: `BooleanField` (optional)
  - `date_from`: `DateField` (optional)
  - `date_to`: `DateField` (optional)

**Response serializer(s)**
- `applications.serializers.ApplicationSearchSerializer`
  - `status`: `ChoiceField` (optional)
  - `priority`: `ChoiceField` (optional)
  - `university`: `IntegerField` (optional)
  - `program`: `IntegerField` (optional)
  - `is_complete`: `BooleanField` (optional)
  - `is_verified`: `BooleanField` (optional)
  - `date_from`: `DateField` (optional)
  - `date_to`: `DateField` (optional)

**Validation rules (serializer-level)**
- (none detected)

### `GET` `/api/v1/applications/applications/stats/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `GET` `/api/v1/applications/applications/dashboard/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `GET` `/api/v1/applications/applications/{application_pk}/documents/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `POST` `/api/v1/applications/applications/{application_pk}/documents/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `GET` `/api/v1/applications/applications/{application_pk}/status/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `POST` `/api/v1/applications/applications/{application_pk}/status/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `GET` `/api/v1/applications/applications/{application_pk}/interviews/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `POST` `/api/v1/applications/applications/{application_pk}/interviews/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `GET` `/api/v1/applications/applications/{application_pk}/fees/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `POST` `/api/v1/applications/applications/{application_pk}/fees/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `GET` `/api/v1/applications/applications/{application_pk}/communications/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `POST` `/api/v1/applications/applications/{application_pk}/communications/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

## API Group: `content`

### `GET` `/api/v1/content/contents/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- `content.serializers.ContentListSerializer`
  - `id`: `IntegerField` (optional, read_only)
  - `title`: `CharField` (required)
  - `description`: `CharField` (required)
  - `content_type`: `ChoiceField` (optional)
  - `category`: `ContentCategoryListSerializer` (optional, read_only)
  - `author`: `UserSerializer` (optional, read_only)
  - `thumbnail_url`: `URLField` (optional)
  - `status`: `ChoiceField` (optional)
  - `is_public`: `BooleanField` (optional)
  - `is_featured`: `BooleanField` (optional)
  - `is_premium`: `BooleanField` (optional)
  - `view_count`: `IntegerField` (optional, read_only)
  - `download_count`: `IntegerField` (optional, read_only)
  - `share_count`: `IntegerField` (optional, read_only)
  - `average_rating`: `DecimalField` (optional, read_only)
  - `rating_count`: `IntegerField` (optional, read_only)
  - `tags`: `ListSerializer` (optional, read_only)
  - `created_at`: `DateTimeField` (optional, read_only)
  - `updated_at`: `DateTimeField` (optional, read_only)

**Validation rules (serializer-level)**
- (none detected)

### `POST` `/api/v1/content/contents/`

**Request serializer(s)**
- `content.serializers.ContentCreateSerializer`
  - `title`: `CharField` (required)
  - `description`: `CharField` (required)
  - `content_type`: `ChoiceField` (optional)
  - `category_id`: `IntegerField` (required)
  - `file_url`: `URLField` (optional)
  - `file_size`: `IntegerField` (optional)
  - `duration`: `IntegerField` (optional)
  - `thumbnail_url`: `URLField` (optional)
  - `status`: `ChoiceField` (optional)
  - `is_public`: `BooleanField` (optional)
  - `is_featured`: `BooleanField` (optional)
  - `is_premium`: `BooleanField` (optional)
  - `meta_title`: `CharField` (optional)
  - `meta_description`: `CharField` (optional)
  - `keywords`: `CharField` (optional)
  - `tag_ids`: `ListField` (optional)

**Response serializer(s)**
- `content.serializers.ContentCreateSerializer`
  - `title`: `CharField` (required)
  - `description`: `CharField` (required)
  - `content_type`: `ChoiceField` (optional)
  - `category_id`: `IntegerField` (required)
  - `file_url`: `URLField` (optional)
  - `file_size`: `IntegerField` (optional)
  - `duration`: `IntegerField` (optional)
  - `thumbnail_url`: `URLField` (optional)
  - `status`: `ChoiceField` (optional)
  - `is_public`: `BooleanField` (optional)
  - `is_featured`: `BooleanField` (optional)
  - `is_premium`: `BooleanField` (optional)
  - `meta_title`: `CharField` (optional)
  - `meta_description`: `CharField` (optional)
  - `keywords`: `CharField` (optional)
  - `tag_ids`: `ListField` (optional)

**Validation rules (serializer-level)**
- `content.serializers.ContentCreateSerializer.validate_category_id`
- `content.serializers.ContentCreateSerializer.validate_tag_ids`

### `POST` `/api/v1/content/contents/{id}/view/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `POST` `/api/v1/content/contents/{id}/rate/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `POST` `/api/v1/content/contents/{id}/comment/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `POST` `/api/v1/content/contents/{id}/share/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `POST` `/api/v1/content/contents/{id}/download/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `POST` `/api/v1/content/contents/{id}/bookmark/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `GET` `/api/v1/content/contents/{id}/comments/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `GET` `/api/v1/content/contents/{id}/ratings/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `GET` `/api/v1/content/contents/search/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `GET` `/api/v1/content/contents/statistics/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `GET` `/api/v1/content/contents/featured/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `GET` `/api/v1/content/contents/recent/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `GET` `/api/v1/content/contents/popular/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `POST` `/api/v1/content/contents/bulk-action/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `GET` `/api/v1/content/categories/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `POST` `/api/v1/content/categories/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `GET` `/api/v1/content/categories/{id}/contents/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `GET` `/api/v1/content/categories/{id}/statistics/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `GET` `/api/v1/content/tags/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `POST` `/api/v1/content/tags/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `GET` `/api/v1/content/tags/{id}/contents/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `GET` `/api/v1/content/ratings/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `GET` `/api/v1/content/comments/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `GET` `/api/v1/content/shares/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `GET` `/api/v1/content/downloads/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `GET` `/api/v1/content/bookmarks/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `GET` `/api/v1/content/analytics/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `GET` `/api/v1/content/feeds/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

## API Group: `courses`

### `GET` `/api/v1/courses/courses/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `POST` `/api/v1/courses/courses/`

**Request serializer(s)**
- `courses.serializers.CourseCreateSerializer`
  - `name`: `CharField` (required)
  - `code`: `CharField` (required)
  - `description`: `CharField` (required)
  - `short_description`: `CharField` (optional)
  - `university`: `PrimaryKeyRelatedField` (required)
  - `level`: `ChoiceField` (optional)
  - `duration`: `ChoiceField` (optional)
  - `credits`: `IntegerField` (optional)
  - `tuition_fee`: `DecimalField` (required)
  - `currency`: `CharField` (optional)
  - `minimum_gpa`: `DecimalField` (optional)
  - `language_requirements`: `CharField` (optional)
  - `is_featured`: `BooleanField` (optional)
  - `is_popular`: `BooleanField` (optional)
  - `status`: `ChoiceField` (optional)
  - `image`: `ImageField` (optional)
  - `brochure`: `FileField` (optional)

**Response serializer(s)**
- `courses.serializers.CourseCreateSerializer`
  - `name`: `CharField` (required)
  - `code`: `CharField` (required)
  - `description`: `CharField` (required)
  - `short_description`: `CharField` (optional)
  - `university`: `PrimaryKeyRelatedField` (required)
  - `level`: `ChoiceField` (optional)
  - `duration`: `ChoiceField` (optional)
  - `credits`: `IntegerField` (optional)
  - `tuition_fee`: `DecimalField` (required)
  - `currency`: `CharField` (optional)
  - `minimum_gpa`: `DecimalField` (optional)
  - `language_requirements`: `CharField` (optional)
  - `is_featured`: `BooleanField` (optional)
  - `is_popular`: `BooleanField` (optional)
  - `status`: `ChoiceField` (optional)
  - `image`: `ImageField` (optional)
  - `brochure`: `FileField` (optional)

**Validation rules (serializer-level)**
- `courses.serializers.CourseCreateSerializer.validate_code`
- `courses.serializers.CourseCreateSerializer.validate_tuition_fee`

### `GET` `/api/v1/courses/courses/{id}/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- `courses.serializers.CourseDetailSerializer`
  - `id`: `IntegerField` (optional, read_only)
  - `name`: `CharField` (required)
  - `code`: `CharField` (required)
  - `description`: `CharField` (required)
  - `short_description`: `CharField` (optional)
  - `university_name`: `CharField` (optional, read_only)
  - `university_country`: `CharField` (optional, read_only)
  - `university_city`: `CharField` (optional, read_only)
  - `university_website`: `CharField` (optional, read_only)
  - `level`: `ChoiceField` (optional)
  - `duration`: `ChoiceField` (optional)
  - `credits`: `IntegerField` (optional)
  - `subjects`: `ListSerializer` (optional, read_only)
  - `tuition_fee`: `DecimalField` (required)
  - `currency`: `CharField` (optional)
  - `minimum_gpa`: `DecimalField` (optional)
  - `language_requirements`: `CharField` (optional)
  - `fee_structure`: `FeeStructureSerializer` (optional, read_only)
  - `requirements`: `ListSerializer` (optional, read_only)
  - `ratings`: `ListSerializer` (optional, read_only)
  - `average_rating`: `ReadOnlyField` (optional, read_only)
  - `total_applications`: `ReadOnlyField` (optional, read_only)
  - `total_ratings`: `SerializerMethodField` (optional, read_only)
  - `is_featured`: `BooleanField` (optional)
  - `is_popular`: `BooleanField` (optional)
  - `status`: `ChoiceField` (optional)
  - `image`: `ImageField` (optional)
  - `brochure`: `FileField` (optional)
  - `created_at`: `DateTimeField` (optional, read_only)
  - `updated_at`: `DateTimeField` (optional, read_only)

**Validation rules (serializer-level)**
- (none detected)

### `GET` `/api/v1/courses/courses/search/`

**Request serializer(s)**
- `courses.serializers.CourseSearchSerializer`
  - `query`: `CharField` (optional)
  - `university`: `IntegerField` (optional)
  - `level`: `ChoiceField` (optional)
  - `duration`: `ChoiceField` (optional)
  - `min_fee`: `DecimalField` (optional)
  - `max_fee`: `DecimalField` (optional)
  - `subject`: `CharField` (optional)
  - `country`: `CharField` (optional)
  - `featured_only`: `BooleanField` (optional, default=False)
  - `popular_only`: `BooleanField` (optional, default=False)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- `courses.serializers.CourseSearchSerializer.validate`

### `POST` `/api/v1/courses/courses/filter/`

**Request serializer(s)**
- `courses.serializers.CourseFilterSerializer`
  - `universities`: `ListField` (optional)
  - `levels`: `ListField` (optional)
  - `durations`: `ListField` (optional)
  - `subjects`: `ListField` (optional)
  - `countries`: `ListField` (optional)
  - `fee_range`: `DictField` (optional)
  - `rating_min`: `IntegerField` (optional)
  - `status`: `ChoiceField` (optional)

**Response serializer(s)**
- `courses.serializers.CourseFilterSerializer`
  - `universities`: `ListField` (optional)
  - `levels`: `ListField` (optional)
  - `durations`: `ListField` (optional)
  - `subjects`: `ListField` (optional)
  - `countries`: `ListField` (optional)
  - `fee_range`: `DictField` (optional)
  - `rating_min`: `IntegerField` (optional)
  - `status`: `ChoiceField` (optional)

**Validation rules (serializer-level)**
- (none detected)

### `POST` `/api/v1/courses/courses/{id}/apply/`

**Request serializer(s)**
- `courses.serializers.CourseApplicationCreateSerializer`
  - (serializer not found in catalog: `courses.serializers.CourseApplicationCreateSerializer`)

**Response serializer(s)**
- `courses.serializers.CourseApplicationSerializer`
  - (serializer not found in catalog: `courses.serializers.CourseApplicationSerializer`)

**Validation rules (serializer-level)**
- (none detected)

### `POST` `/api/v1/courses/courses/{id}/rate/`

**Request serializer(s)**
- `courses.serializers.CourseRatingSerializer`
  - `rating`: `IntegerField` (required)
  - `review`: `CharField` (optional)

**Response serializer(s)**
- `courses.serializers.CourseRatingSerializer`
  - `id`: `IntegerField` (optional, read_only)
  - `rating`: `IntegerField` (required)
  - `review`: `CharField` (optional)
  - `is_verified`: `BooleanField` (optional, read_only)
  - `user_name`: `CharField` (optional, read_only)
  - `user_email`: `CharField` (optional, read_only)
  - `created_at`: `DateTimeField` (optional, read_only)

**Validation rules (serializer-level)**
- `courses.serializers.CourseRatingSerializer.validate`
- `courses.serializers.CourseRatingSerializer.validate_rating`

### `GET` `/api/v1/courses/courses/stats/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `GET` `/api/v1/courses/subjects/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `POST` `/api/v1/courses/subjects/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `GET` `/api/v1/courses/applications/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

## API Group: `payments`

### `GET` `/api/v1/payments/api/payments/payment-methods/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `POST` `/api/v1/payments/api/payments/payment-methods/`

**Request serializer(s)**
- `payments.serializers.PaymentMethodCreateSerializer`
  - `payment_type`: `ChoiceField` (required)
  - `name`: `CharField` (required)
  - `is_default`: `BooleanField` (optional)
  - `card_last4`: `CharField` (optional)
  - `card_brand`: `CharField` (optional)
  - `card_exp_month`: `IntegerField` (optional)
  - `card_exp_year`: `IntegerField` (optional)
  - `bank_name`: `CharField` (optional)
  - `account_last4`: `CharField` (optional)
  - `account_type`: `CharField` (optional)
  - `wallet_type`: `CharField` (optional)
  - `wallet_id`: `CharField` (optional)
  - `encrypted_data`: `JSONField` (optional)

**Response serializer(s)**
- `payments.serializers.PaymentMethodCreateSerializer`
  - `payment_type`: `ChoiceField` (required)
  - `name`: `CharField` (required)
  - `is_default`: `BooleanField` (optional)
  - `card_last4`: `CharField` (optional)
  - `card_brand`: `CharField` (optional)
  - `card_exp_month`: `IntegerField` (optional)
  - `card_exp_year`: `IntegerField` (optional)
  - `bank_name`: `CharField` (optional)
  - `account_last4`: `CharField` (optional)
  - `account_type`: `CharField` (optional)
  - `wallet_type`: `CharField` (optional)
  - `wallet_id`: `CharField` (optional)
  - `encrypted_data`: `JSONField` (optional)

**Validation rules (serializer-level)**
- `payments.serializers.PaymentMethodCreateSerializer.validate`

### `POST` `/api/v1/payments/api/payments/payment-methods/{uuid}/set_default/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `POST` `/api/v1/payments/api/payments/payment-methods/{uuid}/activate/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `POST` `/api/v1/payments/api/payments/payment-methods/{uuid}/deactivate/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `GET` `/api/v1/payments/api/payments/payment-methods/defaults/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `GET` `/api/v1/payments/api/payments/payment-methods/stats/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `GET` `/api/v1/payments/api/payments/transactions/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `POST` `/api/v1/payments/api/payments/transactions/`

**Request serializer(s)**
- `payments.serializers.PaymentTransactionCreateSerializer`
  - `payment_method`: `PrimaryKeyRelatedField` (optional)
  - `transaction_type`: `ChoiceField` (required)
  - `amount`: `DecimalField` (required)
  - `currency`: `ChoiceField` (optional)
  - `related_object_type`: `CharField` (optional)
  - `related_object_id`: `UUIDField` (optional)
  - `description`: `CharField` (optional)

**Response serializer(s)**
- `payments.serializers.PaymentTransactionCreateSerializer`
  - `payment_method`: `PrimaryKeyRelatedField` (optional)
  - `transaction_type`: `ChoiceField` (required)
  - `amount`: `DecimalField` (required)
  - `currency`: `ChoiceField` (optional)
  - `related_object_type`: `CharField` (optional)
  - `related_object_id`: `UUIDField` (optional)
  - `description`: `CharField` (optional)

**Validation rules (serializer-level)**
- `payments.serializers.PaymentTransactionCreateSerializer.validate`

### `POST` `/api/v1/payments/api/payments/transactions/{uuid}/process_payment/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `POST` `/api/v1/payments/api/payments/transactions/{uuid}/cancel_transaction/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `POST` `/api/v1/payments/api/payments/transactions/{uuid}/request_refund/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `GET` `/api/v1/payments/api/payments/transactions/stats/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `GET` `/api/v1/payments/api/payments/transactions/recent/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `GET` `/api/v1/payments/api/payments/subscriptions/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `POST` `/api/v1/payments/api/payments/subscriptions/`

**Request serializer(s)**
- `payments.serializers.SubscriptionCreateSerializer`
  - `plan_name`: `CharField` (required)
  - `subscription_type`: `ChoiceField` (required)
  - `amount`: `DecimalField` (required)
  - `currency`: `CharField` (optional)
  - `billing_cycle`: `ChoiceField` (required)
  - `start_date`: `DateTimeField` (required)
  - `end_date`: `DateTimeField` (required)
  - `trial_end_date`: `DateTimeField` (optional)
  - `auto_renew`: `BooleanField` (optional)
  - `payment_method`: `PrimaryKeyRelatedField` (optional)
  - `features`: `JSONField` (optional)
  - `limits`: `JSONField` (optional)
  - `description`: `CharField` (optional)

**Response serializer(s)**
- `payments.serializers.SubscriptionCreateSerializer`
  - `plan_name`: `CharField` (required)
  - `subscription_type`: `ChoiceField` (required)
  - `amount`: `DecimalField` (required)
  - `currency`: `CharField` (optional)
  - `billing_cycle`: `ChoiceField` (required)
  - `start_date`: `DateTimeField` (required)
  - `end_date`: `DateTimeField` (required)
  - `trial_end_date`: `DateTimeField` (optional)
  - `auto_renew`: `BooleanField` (optional)
  - `payment_method`: `PrimaryKeyRelatedField` (optional)
  - `features`: `JSONField` (optional)
  - `limits`: `JSONField` (optional)
  - `description`: `CharField` (optional)

**Validation rules (serializer-level)**
- `payments.serializers.SubscriptionCreateSerializer.validate`

### `POST` `/api/v1/payments/api/payments/subscriptions/{uuid}/cancel_subscription/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `POST` `/api/v1/payments/api/payments/subscriptions/{uuid}/renew_subscription/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `POST` `/api/v1/payments/api/payments/subscriptions/{uuid}/change_payment_method/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `GET` `/api/v1/payments/api/payments/subscriptions/active/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `GET` `/api/v1/payments/api/payments/subscriptions/expiring_soon/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `GET` `/api/v1/payments/api/payments/subscriptions/stats/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `GET` `/api/v1/payments/api/payments/invoices/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `POST` `/api/v1/payments/api/payments/invoices/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `POST` `/api/v1/payments/api/payments/invoices/{uuid}/mark_as_paid/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `GET` `/api/v1/payments/api/payments/invoices/{uuid}/download_pdf/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `GET` `/api/v1/payments/api/payments/invoices/overdue/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `GET` `/api/v1/payments/api/payments/invoices/stats/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `GET` `/api/v1/payments/api/payments/refunds/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `POST` `/api/v1/payments/api/payments/refunds/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `POST` `/api/v1/payments/api/payments/refunds/{uuid}/process_refund/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `GET` `/api/v1/payments/api/payments/refunds/stats/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `GET` `/api/v1/payments/api/payments/gateways/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `GET` `/api/v1/payments/api/payments/gateways/supported_methods/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `GET` `/api/v1/payments/api/payments/logs/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `GET` `/api/v1/payments/api/payments/logs/errors/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `GET` `/api/v1/payments/api/payments/stats/overview/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `GET` `/api/v1/payments/api/payments/stats/trends/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

## API Group: `quizzes`

### `GET` `/api/v1/quizzes/quizzes/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- `quizzes.serializers.QuizListSerializer`
  - `id`: `IntegerField` (optional, read_only)
  - `title`: `CharField` (required)
  - `description`: `CharField` (required)
  - `category`: `QuizCategoryListSerializer` (optional, read_only)
  - `creator`: `UserSerializer` (optional, read_only)
  - `time_limit`: `IntegerField` (required)
  - `difficulty`: `ChoiceField` (optional)
  - `status`: `ChoiceField` (optional)
  - `is_public`: `BooleanField` (optional)
  - `is_featured`: `BooleanField` (optional)
  - `total_attempts`: `IntegerField` (optional, read_only)
  - `average_score`: `DecimalField` (optional, read_only)
  - `question_count`: `ReadOnlyField` (optional, read_only)
  - `created_at`: `DateTimeField` (optional, read_only)
  - `updated_at`: `DateTimeField` (optional, read_only)

**Validation rules (serializer-level)**
- (none detected)

### `POST` `/api/v1/quizzes/quizzes/`

**Request serializer(s)**
- `quizzes.serializers.QuizCreateSerializer`
  - `title`: `CharField` (required)
  - `description`: `CharField` (required)
  - `category_id`: `IntegerField` (required)
  - `time_limit`: `IntegerField` (required)
  - `passing_score`: `IntegerField` (required)
  - `max_attempts`: `IntegerField` (optional)
  - `difficulty`: `ChoiceField` (optional)
  - `status`: `ChoiceField` (optional)
  - `is_public`: `BooleanField` (optional)
  - `is_featured`: `BooleanField` (optional)

**Response serializer(s)**
- `quizzes.serializers.QuizCreateSerializer`
  - `title`: `CharField` (required)
  - `description`: `CharField` (required)
  - `category_id`: `IntegerField` (required)
  - `time_limit`: `IntegerField` (required)
  - `passing_score`: `IntegerField` (required)
  - `max_attempts`: `IntegerField` (optional)
  - `difficulty`: `ChoiceField` (optional)
  - `status`: `ChoiceField` (optional)
  - `is_public`: `BooleanField` (optional)
  - `is_featured`: `BooleanField` (optional)

**Validation rules (serializer-level)**
- `quizzes.serializers.QuizCreateSerializer.validate_category_id`

### `POST` `/api/v1/quizzes/quizzes/{id}/start/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `POST` `/api/v1/quizzes/quizzes/{id}/submit/`

**Request (non-serializer hints)**

```json
{
  "json": {
    "answers": "map question_id -> selected option(s)/value"
  }
}
```

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `GET` `/api/v1/quizzes/quizzes/{id}/results/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `GET` `/api/v1/quizzes/quizzes/{id}/leaderboard/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `GET` `/api/v1/quizzes/quizzes/search/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `GET` `/api/v1/quizzes/quizzes/statistics/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `GET` `/api/v1/quizzes/quizzes/featured/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `GET` `/api/v1/quizzes/quizzes/recent/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `GET` `/api/v1/quizzes/quizzes/popular/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `POST` `/api/v1/quizzes/quizzes/{id}/share/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `POST` `/api/v1/quizzes/quizzes/bulk-action/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `GET` `/api/v1/quizzes/categories/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `POST` `/api/v1/quizzes/categories/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `GET` `/api/v1/quizzes/categories/{id}/quizzes/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `GET` `/api/v1/quizzes/categories/{id}/statistics/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `POST` `/api/v1/quizzes/categories/reorder/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `GET` `/api/v1/quizzes/questions/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `POST` `/api/v1/quizzes/questions/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `GET` `/api/v1/quizzes/options/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `POST` `/api/v1/quizzes/options/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `GET` `/api/v1/quizzes/attempts/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `GET` `/api/v1/quizzes/attempts/{uuid}/results/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `GET` `/api/v1/quizzes/analytics/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `GET` `/api/v1/quizzes/shares/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `GET` `/api/v1/quizzes/timers/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `POST` `/api/v1/quizzes/timers/{id}/pause/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `POST` `/api/v1/quizzes/timers/{id}/resume/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

## API Group: `universities`

### `GET` `/api/v1/universities/universities/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- `universities.serializers.UniversitySerializer`
  - `id`: `IntegerField` (optional, read_only)
  - `name`: `CharField` (required)
  - `short_name`: `CharField` (optional)
  - `slug`: `SlugField` (required)
  - `description`: `CharField` (optional)
  - `mission_statement`: `CharField` (optional)
  - `vision_statement`: `CharField` (optional)
  - `university_type`: `ChoiceField` (required)
  - `founded_year`: `IntegerField` (optional)
  - `accreditation`: `CharField` (optional)
  - `website`: `URLField` (optional)
  - `email`: `EmailField` (optional)
  - `phone`: `CharField` (optional)
  - `country`: `CharField` (required)
  - `state`: `CharField` (optional)
  - `city`: `CharField` (required)
  - `address`: `CharField` (optional)
  - `postal_code`: `CharField` (optional)
  - `logo`: `ImageField` (optional)
  - `logo_url`: `SerializerMethodField` (optional, read_only)
  - `banner_image`: `ImageField` (optional)
  - `banner_image_url`: `SerializerMethodField` (optional, read_only)
  - `gallery`: `UniversityGallerySerializer` (optional, read_only)
  - `total_students`: `IntegerField` (optional)
  - `international_students`: `IntegerField` (optional)
  - `faculty_count`: `IntegerField` (optional)
  - `is_active`: `BooleanField` (optional)
  - `is_featured`: `BooleanField` (optional)
  - `is_verified`: `BooleanField` (optional)
  - `age`: `ReadOnlyField` (optional, read_only)
  - `international_student_percentage`: `ReadOnlyField` (optional, read_only)
  - `campuses`: `ListSerializer` (optional, read_only)
  - `rankings`: `ListSerializer` (optional, read_only)
  - `programs`: `ListSerializer` (optional, read_only)
  - `faculties`: `ListSerializer` (optional, read_only)
  - `research`: `ListSerializer` (optional, read_only)
  - `partnerships`: `ListSerializer` (optional, read_only)
  - `feed`: `SerializerMethodField` (optional, read_only)
  - `created_at`: `DateTimeField` (optional, read_only)
  - `updated_at`: `DateTimeField` (optional, read_only)

**Validation rules (serializer-level)**
- `universities.serializers.UniversitySerializer.validate_founded_year`
- `universities.serializers.UniversitySerializer.validate_total_students`

### `POST` `/api/v1/universities/universities/`

**Request serializer(s)**
- `universities.serializers.UniversityCreateSerializer`
  - `name`: `CharField` (required)
  - `short_name`: `CharField` (optional)
  - `slug`: `SlugField` (required)
  - `description`: `CharField` (optional)
  - `mission_statement`: `CharField` (optional)
  - `vision_statement`: `CharField` (optional)
  - `university_type`: `ChoiceField` (required)
  - `founded_year`: `IntegerField` (optional)
  - `accreditation`: `CharField` (optional)
  - `website`: `URLField` (optional)
  - `email`: `EmailField` (optional)
  - `phone`: `CharField` (optional)
  - `country`: `CharField` (required)
  - `state`: `CharField` (optional)
  - `city`: `CharField` (required)
  - `address`: `CharField` (optional)
  - `postal_code`: `CharField` (optional)
  - `logo`: `ImageField` (optional)
  - `banner_image`: `ImageField` (optional)
  - `total_students`: `IntegerField` (optional)
  - `international_students`: `IntegerField` (optional)
  - `faculty_count`: `IntegerField` (optional)
  - `is_active`: `BooleanField` (optional)
  - `is_featured`: `BooleanField` (optional)
  - `is_verified`: `BooleanField` (optional)

**Response serializer(s)**
- `universities.serializers.UniversityCreateSerializer`
  - `name`: `CharField` (required)
  - `short_name`: `CharField` (optional)
  - `slug`: `SlugField` (required)
  - `description`: `CharField` (optional)
  - `mission_statement`: `CharField` (optional)
  - `vision_statement`: `CharField` (optional)
  - `university_type`: `ChoiceField` (required)
  - `founded_year`: `IntegerField` (optional)
  - `accreditation`: `CharField` (optional)
  - `website`: `URLField` (optional)
  - `email`: `EmailField` (optional)
  - `phone`: `CharField` (optional)
  - `country`: `CharField` (required)
  - `state`: `CharField` (optional)
  - `city`: `CharField` (required)
  - `address`: `CharField` (optional)
  - `postal_code`: `CharField` (optional)
  - `logo`: `ImageField` (optional)
  - `banner_image`: `ImageField` (optional)
  - `total_students`: `IntegerField` (optional)
  - `international_students`: `IntegerField` (optional)
  - `faculty_count`: `IntegerField` (optional)
  - `is_active`: `BooleanField` (optional)
  - `is_featured`: `BooleanField` (optional)
  - `is_verified`: `BooleanField` (optional)

**Validation rules (serializer-level)**
- `universities.serializers.UniversityCreateSerializer.validate_slug`

### `DELETE` `/api/v1/universities/universities/{id}/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `GET` `/api/v1/universities/universities/{id}/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- `universities.serializers.UniversitySerializer`
  - `id`: `IntegerField` (optional, read_only)
  - `name`: `CharField` (required)
  - `short_name`: `CharField` (optional)
  - `slug`: `SlugField` (required)
  - `description`: `CharField` (optional)
  - `mission_statement`: `CharField` (optional)
  - `vision_statement`: `CharField` (optional)
  - `university_type`: `ChoiceField` (required)
  - `founded_year`: `IntegerField` (optional)
  - `accreditation`: `CharField` (optional)
  - `website`: `URLField` (optional)
  - `email`: `EmailField` (optional)
  - `phone`: `CharField` (optional)
  - `country`: `CharField` (required)
  - `state`: `CharField` (optional)
  - `city`: `CharField` (required)
  - `address`: `CharField` (optional)
  - `postal_code`: `CharField` (optional)
  - `logo`: `ImageField` (optional)
  - `logo_url`: `SerializerMethodField` (optional, read_only)
  - `banner_image`: `ImageField` (optional)
  - `banner_image_url`: `SerializerMethodField` (optional, read_only)
  - `gallery`: `UniversityGallerySerializer` (optional, read_only)
  - `total_students`: `IntegerField` (optional)
  - `international_students`: `IntegerField` (optional)
  - `faculty_count`: `IntegerField` (optional)
  - `is_active`: `BooleanField` (optional)
  - `is_featured`: `BooleanField` (optional)
  - `is_verified`: `BooleanField` (optional)
  - `age`: `ReadOnlyField` (optional, read_only)
  - `international_student_percentage`: `ReadOnlyField` (optional, read_only)
  - `campuses`: `ListSerializer` (optional, read_only)
  - `rankings`: `ListSerializer` (optional, read_only)
  - `programs`: `ListSerializer` (optional, read_only)
  - `faculties`: `ListSerializer` (optional, read_only)
  - `research`: `ListSerializer` (optional, read_only)
  - `partnerships`: `ListSerializer` (optional, read_only)
  - `feed`: `SerializerMethodField` (optional, read_only)
  - `created_at`: `DateTimeField` (optional, read_only)
  - `updated_at`: `DateTimeField` (optional, read_only)

**Validation rules (serializer-level)**
- `universities.serializers.UniversitySerializer.validate_founded_year`
- `universities.serializers.UniversitySerializer.validate_total_students`

### `PATCH` `/api/v1/universities/universities/{id}/`

**Request serializer(s)**
- `universities.serializers.UniversityUpdateSerializer`
  - `name`: `CharField` (required)
  - `short_name`: `CharField` (optional)
  - `description`: `CharField` (optional)
  - `mission_statement`: `CharField` (optional)
  - `vision_statement`: `CharField` (optional)
  - `university_type`: `ChoiceField` (required)
  - `founded_year`: `IntegerField` (optional)
  - `accreditation`: `CharField` (optional)
  - `website`: `URLField` (optional)
  - `email`: `EmailField` (optional)
  - `phone`: `CharField` (optional)
  - `country`: `CharField` (required)
  - `state`: `CharField` (optional)
  - `city`: `CharField` (required)
  - `address`: `CharField` (optional)
  - `postal_code`: `CharField` (optional)
  - `logo`: `ImageField` (optional)
  - `banner_image`: `ImageField` (optional)
  - `total_students`: `IntegerField` (optional)
  - `international_students`: `IntegerField` (optional)
  - `faculty_count`: `IntegerField` (optional)
  - `is_active`: `BooleanField` (optional)
  - `is_featured`: `BooleanField` (optional)
  - `is_verified`: `BooleanField` (optional)

**Response serializer(s)**
- `universities.serializers.UniversityUpdateSerializer`
  - `name`: `CharField` (required)
  - `short_name`: `CharField` (optional)
  - `description`: `CharField` (optional)
  - `mission_statement`: `CharField` (optional)
  - `vision_statement`: `CharField` (optional)
  - `university_type`: `ChoiceField` (required)
  - `founded_year`: `IntegerField` (optional)
  - `accreditation`: `CharField` (optional)
  - `website`: `URLField` (optional)
  - `email`: `EmailField` (optional)
  - `phone`: `CharField` (optional)
  - `country`: `CharField` (required)
  - `state`: `CharField` (optional)
  - `city`: `CharField` (required)
  - `address`: `CharField` (optional)
  - `postal_code`: `CharField` (optional)
  - `logo`: `ImageField` (optional)
  - `banner_image`: `ImageField` (optional)
  - `total_students`: `IntegerField` (optional)
  - `international_students`: `IntegerField` (optional)
  - `faculty_count`: `IntegerField` (optional)
  - `is_active`: `BooleanField` (optional)
  - `is_featured`: `BooleanField` (optional)
  - `is_verified`: `BooleanField` (optional)

**Validation rules (serializer-level)**
- (none detected)

### `PUT` `/api/v1/universities/universities/{id}/`

**Request serializer(s)**
- `universities.serializers.UniversityUpdateSerializer`
  - `name`: `CharField` (required)
  - `short_name`: `CharField` (optional)
  - `description`: `CharField` (optional)
  - `mission_statement`: `CharField` (optional)
  - `vision_statement`: `CharField` (optional)
  - `university_type`: `ChoiceField` (required)
  - `founded_year`: `IntegerField` (optional)
  - `accreditation`: `CharField` (optional)
  - `website`: `URLField` (optional)
  - `email`: `EmailField` (optional)
  - `phone`: `CharField` (optional)
  - `country`: `CharField` (required)
  - `state`: `CharField` (optional)
  - `city`: `CharField` (required)
  - `address`: `CharField` (optional)
  - `postal_code`: `CharField` (optional)
  - `logo`: `ImageField` (optional)
  - `banner_image`: `ImageField` (optional)
  - `total_students`: `IntegerField` (optional)
  - `international_students`: `IntegerField` (optional)
  - `faculty_count`: `IntegerField` (optional)
  - `is_active`: `BooleanField` (optional)
  - `is_featured`: `BooleanField` (optional)
  - `is_verified`: `BooleanField` (optional)

**Response serializer(s)**
- `universities.serializers.UniversityUpdateSerializer`
  - `name`: `CharField` (required)
  - `short_name`: `CharField` (optional)
  - `description`: `CharField` (optional)
  - `mission_statement`: `CharField` (optional)
  - `vision_statement`: `CharField` (optional)
  - `university_type`: `ChoiceField` (required)
  - `founded_year`: `IntegerField` (optional)
  - `accreditation`: `CharField` (optional)
  - `website`: `URLField` (optional)
  - `email`: `EmailField` (optional)
  - `phone`: `CharField` (optional)
  - `country`: `CharField` (required)
  - `state`: `CharField` (optional)
  - `city`: `CharField` (required)
  - `address`: `CharField` (optional)
  - `postal_code`: `CharField` (optional)
  - `logo`: `ImageField` (optional)
  - `banner_image`: `ImageField` (optional)
  - `total_students`: `IntegerField` (optional)
  - `international_students`: `IntegerField` (optional)
  - `faculty_count`: `IntegerField` (optional)
  - `is_active`: `BooleanField` (optional)
  - `is_featured`: `BooleanField` (optional)
  - `is_verified`: `BooleanField` (optional)

**Validation rules (serializer-level)**
- (none detected)

### `GET` `/api/v1/universities/universities/{id}/gallery/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- `universities.serializers.UniversityGallerySerializer`
  - `id`: `IntegerField` (optional, read_only)
  - `university_name`: `CharField` (optional, read_only)
  - `image1`: `ImageField` (optional)
  - `image1_url`: `SerializerMethodField` (optional, read_only)
  - `image2`: `ImageField` (optional)
  - `image2_url`: `SerializerMethodField` (optional, read_only)
  - `image3`: `ImageField` (optional)
  - `image3_url`: `SerializerMethodField` (optional, read_only)
  - `image4`: `ImageField` (optional)
  - `image4_url`: `SerializerMethodField` (optional, read_only)
  - `image5`: `ImageField` (optional)
  - `image5_url`: `SerializerMethodField` (optional, read_only)
  - `image6`: `ImageField` (optional)
  - `image6_url`: `SerializerMethodField` (optional, read_only)
  - `created_at`: `DateTimeField` (optional, read_only)
  - `updated_at`: `DateTimeField` (optional, read_only)

**Validation rules (serializer-level)**
- (none detected)

### `POST` `/api/v1/universities/universities/search/`

**Request serializer(s)**
- `universities.serializers.UniversitySearchSerializer`
  - `query`: `CharField` (optional)
  - `country`: `CharField` (optional)
  - `university_type`: `ChoiceField` (optional)
  - `min_rank`: `IntegerField` (optional)
  - `max_rank`: `IntegerField` (optional)
  - `has_programs`: `BooleanField` (optional)
  - `is_featured`: `BooleanField` (optional)
  - `is_verified`: `BooleanField` (optional)
- `universities.serializers.UniversitySerializer`
  - `name`: `CharField` (required)
  - `short_name`: `CharField` (optional)
  - `slug`: `SlugField` (required)
  - `description`: `CharField` (optional)
  - `mission_statement`: `CharField` (optional)
  - `vision_statement`: `CharField` (optional)
  - `university_type`: `ChoiceField` (required)
  - `founded_year`: `IntegerField` (optional)
  - `accreditation`: `CharField` (optional)
  - `website`: `URLField` (optional)
  - `email`: `EmailField` (optional)
  - `phone`: `CharField` (optional)
  - `country`: `CharField` (required)
  - `state`: `CharField` (optional)
  - `city`: `CharField` (required)
  - `address`: `CharField` (optional)
  - `postal_code`: `CharField` (optional)
  - `logo`: `ImageField` (optional)
  - `banner_image`: `ImageField` (optional)
  - `total_students`: `IntegerField` (optional)
  - `international_students`: `IntegerField` (optional)
  - `faculty_count`: `IntegerField` (optional)
  - `is_active`: `BooleanField` (optional)
  - `is_featured`: `BooleanField` (optional)
  - `is_verified`: `BooleanField` (optional)

**Response serializer(s)**
- `universities.serializers.UniversitySearchSerializer`
  - `query`: `CharField` (optional)
  - `country`: `CharField` (optional)
  - `university_type`: `ChoiceField` (optional)
  - `min_rank`: `IntegerField` (optional)
  - `max_rank`: `IntegerField` (optional)
  - `has_programs`: `BooleanField` (optional)
  - `is_featured`: `BooleanField` (optional)
  - `is_verified`: `BooleanField` (optional)
- `universities.serializers.UniversitySerializer`
  - `id`: `IntegerField` (optional, read_only)
  - `name`: `CharField` (required)
  - `short_name`: `CharField` (optional)
  - `slug`: `SlugField` (required)
  - `description`: `CharField` (optional)
  - `mission_statement`: `CharField` (optional)
  - `vision_statement`: `CharField` (optional)
  - `university_type`: `ChoiceField` (required)
  - `founded_year`: `IntegerField` (optional)
  - `accreditation`: `CharField` (optional)
  - `website`: `URLField` (optional)
  - `email`: `EmailField` (optional)
  - `phone`: `CharField` (optional)
  - `country`: `CharField` (required)
  - `state`: `CharField` (optional)
  - `city`: `CharField` (required)
  - `address`: `CharField` (optional)
  - `postal_code`: `CharField` (optional)
  - `logo`: `ImageField` (optional)
  - `logo_url`: `SerializerMethodField` (optional, read_only)
  - `banner_image`: `ImageField` (optional)
  - `banner_image_url`: `SerializerMethodField` (optional, read_only)
  - `gallery`: `UniversityGallerySerializer` (optional, read_only)
  - `total_students`: `IntegerField` (optional)
  - `international_students`: `IntegerField` (optional)
  - `faculty_count`: `IntegerField` (optional)
  - `is_active`: `BooleanField` (optional)
  - `is_featured`: `BooleanField` (optional)
  - `is_verified`: `BooleanField` (optional)
  - `age`: `ReadOnlyField` (optional, read_only)
  - `international_student_percentage`: `ReadOnlyField` (optional, read_only)
  - `campuses`: `ListSerializer` (optional, read_only)
  - `rankings`: `ListSerializer` (optional, read_only)
  - `programs`: `ListSerializer` (optional, read_only)
  - `faculties`: `ListSerializer` (optional, read_only)
  - `research`: `ListSerializer` (optional, read_only)
  - `partnerships`: `ListSerializer` (optional, read_only)
  - `feed`: `SerializerMethodField` (optional, read_only)
  - `created_at`: `DateTimeField` (optional, read_only)
  - `updated_at`: `DateTimeField` (optional, read_only)

**Validation rules (serializer-level)**
- `universities.serializers.UniversitySearchSerializer.validate`
- `universities.serializers.UniversitySerializer.validate_founded_year`
- `universities.serializers.UniversitySerializer.validate_total_students`

### `GET` `/api/v1/universities/universities/stats/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- `universities.serializers.UniversitySerializer`
  - `id`: `IntegerField` (optional, read_only)
  - `name`: `CharField` (required)
  - `short_name`: `CharField` (optional)
  - `slug`: `SlugField` (required)
  - `description`: `CharField` (optional)
  - `mission_statement`: `CharField` (optional)
  - `vision_statement`: `CharField` (optional)
  - `university_type`: `ChoiceField` (required)
  - `founded_year`: `IntegerField` (optional)
  - `accreditation`: `CharField` (optional)
  - `website`: `URLField` (optional)
  - `email`: `EmailField` (optional)
  - `phone`: `CharField` (optional)
  - `country`: `CharField` (required)
  - `state`: `CharField` (optional)
  - `city`: `CharField` (required)
  - `address`: `CharField` (optional)
  - `postal_code`: `CharField` (optional)
  - `logo`: `ImageField` (optional)
  - `logo_url`: `SerializerMethodField` (optional, read_only)
  - `banner_image`: `ImageField` (optional)
  - `banner_image_url`: `SerializerMethodField` (optional, read_only)
  - `gallery`: `UniversityGallerySerializer` (optional, read_only)
  - `total_students`: `IntegerField` (optional)
  - `international_students`: `IntegerField` (optional)
  - `faculty_count`: `IntegerField` (optional)
  - `is_active`: `BooleanField` (optional)
  - `is_featured`: `BooleanField` (optional)
  - `is_verified`: `BooleanField` (optional)
  - `age`: `ReadOnlyField` (optional, read_only)
  - `international_student_percentage`: `ReadOnlyField` (optional, read_only)
  - `campuses`: `ListSerializer` (optional, read_only)
  - `rankings`: `ListSerializer` (optional, read_only)
  - `programs`: `ListSerializer` (optional, read_only)
  - `faculties`: `ListSerializer` (optional, read_only)
  - `research`: `ListSerializer` (optional, read_only)
  - `partnerships`: `ListSerializer` (optional, read_only)
  - `feed`: `SerializerMethodField` (optional, read_only)
  - `created_at`: `DateTimeField` (optional, read_only)
  - `updated_at`: `DateTimeField` (optional, read_only)

**Validation rules (serializer-level)**
- `universities.serializers.UniversitySerializer.validate_founded_year`
- `universities.serializers.UniversitySerializer.validate_total_students`

### `POST` `/api/v1/universities/universities/compare/`

**Request (non-serializer hints)**

```json
{
  "json": {
    "university_ids": "array of 2-5 IDs"
  }
}
```

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `GET` `/api/v1/universities/universities/{id}/rankings/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `GET` `/api/v1/universities/universities/{id}/programs/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `GET` `/api/v1/universities/campuses/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `POST` `/api/v1/universities/campuses/`

**Request serializer(s)**
- `universities.serializers.CampusCreateSerializer`
  - `university`: `PrimaryKeyRelatedField` (required)
  - `name`: `CharField` (required)
  - `campus_type`: `ChoiceField` (optional)
  - `address`: `CharField` (required)
  - `city`: `CharField` (required)
  - `state`: `CharField` (optional)
  - `country`: `CharField` (required)
  - `postal_code`: `CharField` (optional)
  - `phone`: `CharField` (optional)
  - `email`: `EmailField` (optional)
  - `website`: `URLField` (optional)
  - `facilities`: `JSONField` (optional)
  - `accommodation`: `CharField` (optional)
  - `transportation`: `CharField` (optional)
  - `images`: `JSONField` (optional)
  - `virtual_tour_url`: `URLField` (optional)
  - `is_active`: `BooleanField` (optional)
  - `is_main_campus`: `BooleanField` (optional)

**Response serializer(s)**
- `universities.serializers.CampusCreateSerializer`
  - `university`: `PrimaryKeyRelatedField` (required)
  - `name`: `CharField` (required)
  - `campus_type`: `ChoiceField` (optional)
  - `address`: `CharField` (required)
  - `city`: `CharField` (required)
  - `state`: `CharField` (optional)
  - `country`: `CharField` (required)
  - `postal_code`: `CharField` (optional)
  - `phone`: `CharField` (optional)
  - `email`: `EmailField` (optional)
  - `website`: `URLField` (optional)
  - `facilities`: `JSONField` (optional)
  - `accommodation`: `CharField` (optional)
  - `transportation`: `CharField` (optional)
  - `images`: `JSONField` (optional)
  - `virtual_tour_url`: `URLField` (optional)
  - `is_active`: `BooleanField` (optional)
  - `is_main_campus`: `BooleanField` (optional)

**Validation rules (serializer-level)**
- (none detected)

### `GET` `/api/v1/universities/rankings/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `POST` `/api/v1/universities/rankings/`

**Request serializer(s)**
- `universities.serializers.UniversityRankingCreateSerializer`
  - `university`: `PrimaryKeyRelatedField` (required)
  - `ranking_type`: `ChoiceField` (required)
  - `ranking_source`: `CharField` (required)
  - `rank`: `IntegerField` (required)
  - `total_institutions`: `IntegerField` (optional)
  - `score`: `DecimalField` (optional)
  - `year`: `IntegerField` (required)
  - `methodology`: `CharField` (optional)
  - `criteria`: `JSONField` (optional)

**Response serializer(s)**
- `universities.serializers.UniversityRankingCreateSerializer`
  - `university`: `PrimaryKeyRelatedField` (required)
  - `ranking_type`: `ChoiceField` (required)
  - `ranking_source`: `CharField` (required)
  - `rank`: `IntegerField` (required)
  - `total_institutions`: `IntegerField` (optional)
  - `score`: `DecimalField` (optional)
  - `year`: `IntegerField` (required)
  - `methodology`: `CharField` (optional)
  - `criteria`: `JSONField` (optional)

**Validation rules (serializer-level)**
- `universities.serializers.UniversityRankingCreateSerializer.validate`

### `GET` `/api/v1/universities/programs/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `POST` `/api/v1/universities/programs/`

**Request serializer(s)**
- `universities.serializers.UniversityProgramCreateSerializer`
  - `university`: `PrimaryKeyRelatedField` (required)
  - `name`: `CharField` (required)
  - `program_level`: `ChoiceField` (required)
  - `program_type`: `ChoiceField` (required)
  - `description`: `CharField` (optional)
  - `objectives`: `CharField` (optional)
  - `outcomes`: `CharField` (optional)
  - `duration_years`: `IntegerField` (required)
  - `total_credits`: `IntegerField` (optional)
  - `semesters`: `IntegerField` (optional)
  - `entry_requirements`: `CharField` (optional)
  - `language_requirements`: `CharField` (optional)
  - `is_active`: `BooleanField` (optional)
  - `is_featured`: `BooleanField` (optional)

**Response serializer(s)**
- `universities.serializers.UniversityProgramCreateSerializer`
  - `university`: `PrimaryKeyRelatedField` (required)
  - `name`: `CharField` (required)
  - `program_level`: `ChoiceField` (required)
  - `program_type`: `ChoiceField` (required)
  - `description`: `CharField` (optional)
  - `objectives`: `CharField` (optional)
  - `outcomes`: `CharField` (optional)
  - `duration_years`: `IntegerField` (required)
  - `total_credits`: `IntegerField` (optional)
  - `semesters`: `IntegerField` (optional)
  - `entry_requirements`: `CharField` (optional)
  - `language_requirements`: `CharField` (optional)
  - `is_active`: `BooleanField` (optional)
  - `is_featured`: `BooleanField` (optional)

**Validation rules (serializer-level)**
- (none detected)

### `GET` `/api/v1/universities/faculties/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `POST` `/api/v1/universities/faculties/`

**Request serializer(s)**
- `universities.serializers.UniversityFacultyCreateSerializer`
  - `university`: `PrimaryKeyRelatedField` (required)
  - `name`: `CharField` (required)
  - `short_name`: `CharField` (optional)
  - `description`: `CharField` (optional)
  - `mission`: `CharField` (optional)
  - `email`: `EmailField` (optional)
  - `phone`: `CharField` (optional)
  - `website`: `URLField` (optional)
  - `student_count`: `IntegerField` (optional)
  - `faculty_count`: `IntegerField` (optional)
  - `logo`: `ImageField` (optional)
  - `images`: `JSONField` (optional)
  - `is_active`: `BooleanField` (optional)

**Response serializer(s)**
- `universities.serializers.UniversityFacultyCreateSerializer`
  - `university`: `PrimaryKeyRelatedField` (required)
  - `name`: `CharField` (required)
  - `short_name`: `CharField` (optional)
  - `description`: `CharField` (optional)
  - `mission`: `CharField` (optional)
  - `email`: `EmailField` (optional)
  - `phone`: `CharField` (optional)
  - `website`: `URLField` (optional)
  - `student_count`: `IntegerField` (optional)
  - `faculty_count`: `IntegerField` (optional)
  - `logo`: `ImageField` (optional)
  - `images`: `JSONField` (optional)
  - `is_active`: `BooleanField` (optional)

**Validation rules (serializer-level)**
- (none detected)

### `GET` `/api/v1/universities/research/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `POST` `/api/v1/universities/research/`

**Request serializer(s)**
- `universities.serializers.UniversityResearchCreateSerializer`
  - `university`: `PrimaryKeyRelatedField` (required)
  - `title`: `CharField` (required)
  - `research_area`: `ChoiceField` (required)
  - `description`: `CharField` (required)
  - `objectives`: `CharField` (optional)
  - `methodology`: `CharField` (optional)
  - `funding_amount`: `DecimalField` (optional)
  - `funding_source`: `CharField` (optional)
  - `start_date`: `DateField` (required)
  - `end_date`: `DateField` (optional)
  - `status`: `ChoiceField` (optional)
  - `publications`: `JSONField` (optional)

**Response serializer(s)**
- `universities.serializers.UniversityResearchCreateSerializer`
  - `university`: `PrimaryKeyRelatedField` (required)
  - `title`: `CharField` (required)
  - `research_area`: `ChoiceField` (required)
  - `description`: `CharField` (required)
  - `objectives`: `CharField` (optional)
  - `methodology`: `CharField` (optional)
  - `funding_amount`: `DecimalField` (optional)
  - `funding_source`: `CharField` (optional)
  - `start_date`: `DateField` (required)
  - `end_date`: `DateField` (optional)
  - `status`: `ChoiceField` (optional)
  - `publications`: `JSONField` (optional)

**Validation rules (serializer-level)**
- (none detected)

### `GET` `/api/v1/universities/partnerships/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `POST` `/api/v1/universities/partnerships/`

**Request serializer(s)**
- `universities.serializers.UniversityPartnershipCreateSerializer`
  - `university`: `PrimaryKeyRelatedField` (required)
  - `partner_name`: `CharField` (required)
  - `partnership_type`: `ChoiceField` (required)
  - `description`: `CharField` (required)
  - `objectives`: `CharField` (optional)
  - `partner_contact`: `CharField` (optional)
  - `partner_email`: `EmailField` (optional)
  - `partner_website`: `URLField` (optional)
  - `start_date`: `DateField` (required)
  - `end_date`: `DateField` (optional)
  - `status`: `ChoiceField` (optional)

**Response serializer(s)**
- `universities.serializers.UniversityPartnershipCreateSerializer`
  - `university`: `PrimaryKeyRelatedField` (required)
  - `partner_name`: `CharField` (required)
  - `partnership_type`: `ChoiceField` (required)
  - `description`: `CharField` (required)
  - `objectives`: `CharField` (optional)
  - `partner_contact`: `CharField` (optional)
  - `partner_email`: `EmailField` (optional)
  - `partner_website`: `URLField` (optional)
  - `start_date`: `DateField` (required)
  - `end_date`: `DateField` (optional)
  - `status`: `ChoiceField` (optional)

**Validation rules (serializer-level)**
- (none detected)

### `GET` `/api/v1/universities/feeds/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `POST` `/api/v1/universities/feeds/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

## API Group: `users`

### `GET` `/api/v1/users/users/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- `users.serializers.UserSerializer`
  - `id`: `IntegerField` (optional, read_only)
  - `username`: `CharField` (required)
  - `email`: `EmailField` (optional)
  - `first_name`: `CharField` (optional)
  - `last_name`: `CharField` (optional)
  - `date_joined`: `DateTimeField` (optional)
  - `last_login`: `DateTimeField` (optional)
  - `is_active`: `BooleanField` (optional)
  - `profile`: `SerializerMethodField` (optional, read_only)

**Validation rules (serializer-level)**
- (none detected)

### `GET` `/api/v1/users/users/by-email/`

**Request (non-serializer hints)**

```json
{
  "query_params": {
    "email": "required"
  }
}
```

**Request serializer(s)**
- (none)

**Response serializer(s)**
- `users.serializers.UserSerializer`
  - `id`: `IntegerField` (optional, read_only)
  - `username`: `CharField` (required)
  - `email`: `EmailField` (optional)
  - `first_name`: `CharField` (optional)
  - `last_name`: `CharField` (optional)
  - `date_joined`: `DateTimeField` (optional)
  - `last_login`: `DateTimeField` (optional)
  - `is_active`: `BooleanField` (optional)
  - `profile`: `SerializerMethodField` (optional, read_only)

**Validation rules (serializer-level)**
- (none detected)

### `POST` `/api/v1/users/upload-profile-image/`

**Request (non-serializer hints)**

```json
{
  "content_type": "multipart/form-data",
  "fields": {
    "email": "required (form field or query param)",
    "profile_picture": "required (file)"
  }
}
```

**Request serializer(s)**
- `users.serializers.UserSerializer`
  - `username`: `CharField` (required)
  - `email`: `EmailField` (optional)
  - `first_name`: `CharField` (optional)
  - `last_name`: `CharField` (optional)
  - `date_joined`: `DateTimeField` (optional)
  - `last_login`: `DateTimeField` (optional)
  - `is_active`: `BooleanField` (optional)

**Response serializer(s)**
- `users.serializers.UserSerializer`
  - `id`: `IntegerField` (optional, read_only)
  - `username`: `CharField` (required)
  - `email`: `EmailField` (optional)
  - `first_name`: `CharField` (optional)
  - `last_name`: `CharField` (optional)
  - `date_joined`: `DateTimeField` (optional)
  - `last_login`: `DateTimeField` (optional)
  - `is_active`: `BooleanField` (optional)
  - `profile`: `SerializerMethodField` (optional, read_only)

**Validation rules (serializer-level)**
- (none detected)

### `POST` `/api/v1/users/send-otp/`

**Request (non-serializer hints)**

```json
{
  "json": {
    "contact": "required email"
  }
}
```

**Request serializer(s)**
- (none)

**Response serializer(s)**
- (none)

**Validation rules (serializer-level)**
- (none detected)

### `GET` `/api/v1/users/otp/`

**Request serializer(s)**
- (none)

**Response serializer(s)**
- `users.serializers.OTPVerificationSerializer`
  - `id`: `IntegerField` (optional, read_only)
  - `user`: `UserMinimalSerializer` (optional, read_only)
  - `otp_type`: `ChoiceField` (required)
  - `contact`: `CharField` (required)
  - `otp_code`: `CharField` (required)
  - `is_verified`: `BooleanField` (optional)
  - `is_expired`: `BooleanField` (optional)
  - `failed_attempts`: `IntegerField` (optional)
  - `max_attempts`: `IntegerField` (optional)
  - `blocked_until`: `DateTimeField` (optional)
  - `is_blocked`: `BooleanField` (optional)
  - `device_id`: `CharField` (optional)
  - `device_type`: `CharField` (optional)
  - `created_at`: `DateTimeField` (optional, read_only)
  - `expires_at`: `DateTimeField` (required)
  - `verified_at`: `DateTimeField` (optional)
  - `is_valid`: `ReadOnlyField` (optional, read_only)

**Validation rules (serializer-level)**
- (none detected)

### `POST` `/api/v1/users/otp/`

**Request serializer(s)**
- `users.serializers.OTPVerificationSerializer`
  - `otp_type`: `ChoiceField` (required)
  - `contact`: `CharField` (required)
  - `otp_code`: `CharField` (required)
  - `is_verified`: `BooleanField` (optional)
  - `is_expired`: `BooleanField` (optional)
  - `failed_attempts`: `IntegerField` (optional)
  - `max_attempts`: `IntegerField` (optional)
  - `blocked_until`: `DateTimeField` (optional)
  - `is_blocked`: `BooleanField` (optional)
  - `device_id`: `CharField` (optional)
  - `device_type`: `CharField` (optional)
  - `expires_at`: `DateTimeField` (required)
  - `verified_at`: `DateTimeField` (optional)

**Response serializer(s)**
- `users.serializers.OTPVerificationSerializer`
  - `id`: `IntegerField` (optional, read_only)
  - `user`: `UserMinimalSerializer` (optional, read_only)
  - `otp_type`: `ChoiceField` (required)
  - `contact`: `CharField` (required)
  - `otp_code`: `CharField` (required)
  - `is_verified`: `BooleanField` (optional)
  - `is_expired`: `BooleanField` (optional)
  - `failed_attempts`: `IntegerField` (optional)
  - `max_attempts`: `IntegerField` (optional)
  - `blocked_until`: `DateTimeField` (optional)
  - `is_blocked`: `BooleanField` (optional)
  - `device_id`: `CharField` (optional)
  - `device_type`: `CharField` (optional)
  - `created_at`: `DateTimeField` (optional, read_only)
  - `expires_at`: `DateTimeField` (required)
  - `verified_at`: `DateTimeField` (optional)
  - `is_valid`: `ReadOnlyField` (optional, read_only)

**Validation rules (serializer-level)**
- (none detected)

### `POST` `/api/v1/users/otp/create/`

**Request serializer(s)**
- `users.serializers.OTPCreateSerializer`
  - `otp_type`: `ChoiceField` (required)
  - `contact`: `EmailField` (required)
  - `device_id`: `CharField` (optional)
  - `device_type`: `CharField` (optional)

**Response serializer(s)**
- `users.serializers.OTPVerificationSerializer`
  - `id`: `IntegerField` (optional, read_only)
  - `user`: `UserMinimalSerializer` (optional, read_only)
  - `otp_type`: `ChoiceField` (required)
  - `contact`: `CharField` (required)
  - `otp_code`: `CharField` (required)
  - `is_verified`: `BooleanField` (optional)
  - `is_expired`: `BooleanField` (optional)
  - `failed_attempts`: `IntegerField` (optional)
  - `max_attempts`: `IntegerField` (optional)
  - `blocked_until`: `DateTimeField` (optional)
  - `is_blocked`: `BooleanField` (optional)
  - `device_id`: `CharField` (optional)
  - `device_type`: `CharField` (optional)
  - `created_at`: `DateTimeField` (optional, read_only)
  - `expires_at`: `DateTimeField` (required)
  - `verified_at`: `DateTimeField` (optional)
  - `is_valid`: `ReadOnlyField` (optional, read_only)

**Validation rules (serializer-level)**
- `users.serializers.OTPCreateSerializer.validate_contact`

### `POST` `/api/v1/users/otp/verify/`

**Request serializer(s)**
- `users.serializers.OTPVerifySerializer`
  - `otp_code`: `CharField` (required)
  - `contact`: `EmailField` (required)
  - `device_id`: `CharField` (optional)
  - `device_type`: `CharField` (optional)
- `users.serializers.UserSerializer`
  - `username`: `CharField` (required)
  - `email`: `EmailField` (optional)
  - `first_name`: `CharField` (optional)
  - `last_name`: `CharField` (optional)
  - `date_joined`: `DateTimeField` (optional)
  - `last_login`: `DateTimeField` (optional)
  - `is_active`: `BooleanField` (optional)

**Response serializer(s)**
- `users.serializers.OTPVerifySerializer`
  - `otp_code`: `CharField` (required)
  - `contact`: `EmailField` (required)
  - `device_id`: `CharField` (optional)
  - `device_type`: `CharField` (optional)
- `users.serializers.UserSerializer`
  - `id`: `IntegerField` (optional, read_only)
  - `username`: `CharField` (required)
  - `email`: `EmailField` (optional)
  - `first_name`: `CharField` (optional)
  - `last_name`: `CharField` (optional)
  - `date_joined`: `DateTimeField` (optional)
  - `last_login`: `DateTimeField` (optional)
  - `is_active`: `BooleanField` (optional)
  - `profile`: `SerializerMethodField` (optional, read_only)

**Validation rules (serializer-level)**
- `users.serializers.OTPVerifySerializer.validate_contact`
