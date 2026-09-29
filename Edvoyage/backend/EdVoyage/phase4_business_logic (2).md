# Phase 4 — Business Logic Extraction (Endpoint-wise)

This document is a human-readable behavior spec. It intentionally does **not** introduce any new logic or optimizations.

## API Group: `applications`

### `GET` `/api/v1/applications/applications/`

- **View / function**: `applications.views.ApplicationViewSet.list`

#### Business logic steps (in order)
1. get_queryset currently returns ALL applications (comment: no auth required)
2. DRF list with filters/search/ordering + pagination
3. On exception => 500 {success:false,message:'Error retrieving applications',results:[],count:0}

#### DB operations (inferred)
- READ (count)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `applications.views.ApplicationViewSet.list`

### `POST` `/api/v1/applications/applications/`

- **View / function**: `applications.views.ApplicationViewSet.create`

#### Business logic steps (in order)
1. Create application via serializer
2. Return 201 {success:true,data:<created>,message:'Application created successfully'}
3. On exception => 400

#### DB operations (inferred)
- CREATE

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `applications.views.ApplicationViewSet.create`

### `POST` `/api/v1/applications/applications/test-create/`

- **View / function**: `applications.views.ApplicationViewSet.test_create`

#### Business logic steps (in order)
1. Get or create Django auth.User id=1 test user
2. Override request.user=test_user
3. Delegate to self.create(request)

#### DB operations (inferred)
- CREATE
- READ (get)

#### Conditional logic & edge cases
- Error condition: exception

#### Error cases & status codes
- **400** when exception

#### Shared helpers / utilities referenced
- `applications.views.ApplicationViewSet.test_create`

### `POST` `/api/v1/applications/applications/simple-test/`

- **View / function**: `applications.views.ApplicationViewSet.simple_test`

#### Business logic steps (in order)
1. Get or create test user id=1
2. Get or create test university id=1 (universities.University)
3. Get or create test program id=1 (universities.UniversityProgram)
4. Generate application_number APP-<8 hex>
5. Create Application directly with minimal required fields
6. Return 201 with minimal data

#### DB operations (inferred)
- CREATE
- READ (get)

#### Conditional logic & edge cases
- Error condition: exception

#### Error cases & status codes
- **400** when exception

#### Shared helpers / utilities referenced
- `applications.views.ApplicationViewSet.simple_test`

### `POST` `/api/v1/applications/applications/submit/`

- **View / function**: `applications.views.ApplicationViewSet.submit`

#### Business logic steps (in order)
1. Load application via self.get_object()
2. Require application.status == 'draft' else 400
3. Check required documents exist (documents.filter(is_required=True).exists()) else 400
4. Set status='submitted', submitted_at=now and save
5. Create ApplicationStatus row for status history
6. Return success

#### DB operations (inferred)
- READ (filter)
- UPDATE (save)
- CREATE

#### Conditional logic & edge cases
- Error condition: status != draft
- Error condition: required documents missing
- Error condition: unexpected exception

#### Error cases & status codes
- **400** when status != draft
- **400** when required documents missing
- **500** when unexpected exception

#### Shared helpers / utilities referenced
- `applications.views.ApplicationViewSet.submit`

### `POST` `/api/v1/applications/applications/search/`

- **View / function**: `applications.views.ApplicationViewSet.search`

#### Business logic steps (in order)
1. Validate body
2. Filter queryset by status/priority/university/program/is_complete/is_verified/date_from/date_to
3. Paginate and return results
4. On exception => 500

#### DB operations (inferred)
- READ (filter)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `applications.views.ApplicationViewSet.search`

### `GET` `/api/v1/applications/applications/stats/`

- **View / function**: `applications.views.ApplicationViewSet.stats`

#### Business logic steps (in order)
1. Compute counts by status, by university, recent applications
2. Compute overdue applications (submitted/under_review older than 30 days)
3. Return {success:true,data:<stats>}

#### DB operations (inferred)
- (none inferred)

#### Conditional logic & edge cases
- Error condition: unexpected exception

#### Error cases & status codes
- **500** when unexpected exception

#### Shared helpers / utilities referenced
- `applications.views.ApplicationViewSet.stats`

### `GET` `/api/v1/applications/applications/dashboard/`

- **View / function**: `applications.views.ApplicationViewSet.dashboard`

#### Business logic steps (in order)
1. Build dashboard slices: last 5 applications, last 10 status updates, upcoming interviews, pending fees, recent communications
2. Return {success:true,data:<dashboard>}

#### DB operations (inferred)
- (none inferred)

#### Conditional logic & edge cases
- Error condition: unexpected exception

#### Error cases & status codes
- **500** when unexpected exception

#### Shared helpers / utilities referenced
- `applications.views.ApplicationViewSet.dashboard`

### `GET` `/api/v1/applications/applications/{application_pk}/documents/`

- **View / function**: `applications.views.ApplicationDocumentViewSet.list`

#### Business logic steps (in order)
1. (not specified)

#### DB operations (inferred)
- (none inferred)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `applications.views.ApplicationDocumentViewSet.list`

### `POST` `/api/v1/applications/applications/{application_pk}/documents/`

- **View / function**: `applications.views.ApplicationDocumentViewSet.create`

#### Business logic steps (in order)
1. Resolve application from URL kwarg application_pk and user=request.user
2. serializer.save(application=<application>)

#### DB operations (inferred)
- UPDATE (save)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `applications.views.ApplicationDocumentViewSet.create`

### `GET` `/api/v1/applications/applications/{application_pk}/status/`

- **View / function**: `applications.views.ApplicationStatusViewSet.list`

#### Business logic steps (in order)
1. (not specified)

#### DB operations (inferred)
- (none inferred)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `applications.views.ApplicationStatusViewSet.list`

### `POST` `/api/v1/applications/applications/{application_pk}/status/`

- **View / function**: `applications.views.ApplicationStatusViewSet.create`

#### Business logic steps (in order)
1. Attach application via application_pk and changed_by per serializer

#### DB operations (inferred)
- (none inferred)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `applications.views.ApplicationStatusViewSet.create`

### `GET` `/api/v1/applications/applications/{application_pk}/interviews/`

- **View / function**: `applications.views.ApplicationInterviewViewSet.list`

#### Business logic steps (in order)
1. (not specified)

#### DB operations (inferred)
- (none inferred)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `applications.views.ApplicationInterviewViewSet.list`

### `POST` `/api/v1/applications/applications/{application_pk}/interviews/`

- **View / function**: `applications.views.ApplicationInterviewViewSet.create`

#### Business logic steps (in order)
1. Attach application via application_pk

#### DB operations (inferred)
- (none inferred)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `applications.views.ApplicationInterviewViewSet.create`

### `GET` `/api/v1/applications/applications/{application_pk}/fees/`

- **View / function**: `applications.views.ApplicationFeeViewSet.list`

#### Business logic steps (in order)
1. (not specified)

#### DB operations (inferred)
- (none inferred)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `applications.views.ApplicationFeeViewSet.list`

### `POST` `/api/v1/applications/applications/{application_pk}/fees/`

- **View / function**: `applications.views.ApplicationFeeViewSet.create`

#### Business logic steps (in order)
1. Attach application via application_pk

#### DB operations (inferred)
- (none inferred)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `applications.views.ApplicationFeeViewSet.create`

### `GET` `/api/v1/applications/applications/{application_pk}/communications/`

- **View / function**: `applications.views.ApplicationCommunicationViewSet.list`

#### Business logic steps (in order)
1. (not specified)

#### DB operations (inferred)
- (none inferred)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `applications.views.ApplicationCommunicationViewSet.list`

### `POST` `/api/v1/applications/applications/{application_pk}/communications/`

- **View / function**: `applications.views.ApplicationCommunicationViewSet.create`

#### Business logic steps (in order)
1. (not specified)

#### DB operations (inferred)
- (none inferred)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `applications.views.ApplicationCommunicationViewSet.create`

## API Group: `content`

### `GET` `/api/v1/content/contents/`

- **View / function**: `content.views.ContentViewSet.list`

#### Business logic steps (in order)
1. (not specified)

#### DB operations (inferred)
- (none inferred)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `content.views.ContentViewSet.list`

### `POST` `/api/v1/content/contents/`

- **View / function**: `content.views.ContentViewSet.create`

#### Business logic steps (in order)
1. serializer.save(author=request.user)

#### DB operations (inferred)
- UPDATE (save)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `content.views.ContentViewSet.create`

### `POST` `/api/v1/content/contents/{id}/view/`

- **View / function**: `content.views.ContentViewSet.view`

#### Business logic steps (in order)
1. Create ContentView row with ip/user_agent/referrer/session_id (user optional)
2. Increment content.view_count and save
3. Create ContentAnalytics(action_type='view')
4. Return 201 ContentViewSerializer(view)

#### DB operations (inferred)
- CREATE
- UPDATE (save)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `content.views.ContentViewSet.view`

### `POST` `/api/v1/content/contents/{id}/rate/`

- **View / function**: `content.views.ContentViewSet.rate`

#### Business logic steps (in order)
1. Validate ContentRatingCreateSerializer
2. If existing rating by user: update; else create
3. Create ContentAnalytics(action_type='rate', metadata includes rating)
4. Return success message

#### DB operations (inferred)
- CREATE
- UPDATE

#### Conditional logic & edge cases
- If existing rating by user: update; else create

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `content.views.ContentViewSet.rate`

### `POST` `/api/v1/content/contents/{id}/comment/`

- **View / function**: `content.views.ContentViewSet.comment`

#### Business logic steps (in order)
1. Validate ContentCommentCreateSerializer; create comment; analytics action_type='comment'

#### DB operations (inferred)
- CREATE

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `content.views.ContentViewSet.comment`

### `POST` `/api/v1/content/contents/{id}/share/`

- **View / function**: `content.views.ContentViewSet.share`

#### Business logic steps (in order)
1. Validate ContentShareCreateSerializer; create share; increment share_count; analytics

#### DB operations (inferred)
- CREATE

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `content.views.ContentViewSet.share`

### `POST` `/api/v1/content/contents/{id}/download/`

- **View / function**: `content.views.ContentViewSet.download`

#### Business logic steps (in order)
1. Validate ContentDownloadCreateSerializer; create download; increment download_count; analytics

#### DB operations (inferred)
- CREATE

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `content.views.ContentViewSet.download`

### `POST` `/api/v1/content/contents/{id}/bookmark/`

- **View / function**: `content.views.ContentViewSet.bookmark`

#### Business logic steps (in order)
1. Validate ContentBookmarkCreateSerializer; create bookmark; analytics

#### DB operations (inferred)
- CREATE

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `content.views.ContentViewSet.bookmark`

### `GET` `/api/v1/content/contents/{id}/comments/`

- **View / function**: `content.views.ContentViewSet.comments`

#### Business logic steps (in order)
1. List approved root comments with pagination

#### DB operations (inferred)
- (none inferred)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `content.views.ContentViewSet.comments`

### `GET` `/api/v1/content/contents/{id}/ratings/`

- **View / function**: `content.views.ContentViewSet.ratings`

#### Business logic steps (in order)
1. List ratings with pagination

#### DB operations (inferred)
- (none inferred)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `content.views.ContentViewSet.ratings`

### `GET` `/api/v1/content/contents/search/`

- **View / function**: `content.views.ContentViewSet.search`

#### Business logic steps (in order)
1. Validate ContentSearchSerializer; filter; paginate

#### DB operations (inferred)
- READ (filter)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `content.views.ContentViewSet.search`

### `GET` `/api/v1/content/contents/statistics/`

- **View / function**: `content.views.ContentViewSet.statistics`

#### Business logic steps (in order)
1. Aggregate overall + per-category stats

#### DB operations (inferred)
- READ (aggregate/annotate)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `content.views.ContentViewSet.statistics`

### `GET` `/api/v1/content/contents/featured/`

- **View / function**: `content.views.ContentViewSet.featured`

#### Business logic steps (in order)
1. (not specified)

#### DB operations (inferred)
- (none inferred)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `content.views.ContentViewSet.featured`

### `GET` `/api/v1/content/contents/recent/`

- **View / function**: `content.views.ContentViewSet.recent`

#### Business logic steps (in order)
1. (not specified)

#### DB operations (inferred)
- (none inferred)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `content.views.ContentViewSet.recent`

### `GET` `/api/v1/content/contents/popular/`

- **View / function**: `content.views.ContentViewSet.popular`

#### Business logic steps (in order)
1. (not specified)

#### DB operations (inferred)
- (none inferred)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `content.views.ContentViewSet.popular`

### `POST` `/api/v1/content/contents/bulk-action/`

- **View / function**: `content.views.ContentViewSet.bulk_action`

#### Business logic steps (in order)
1. Validate ContentBulkActionSerializer (content_ids, action)
2. Filter contents by ids and author=request.user
3. Apply action: publish/archive/delete/feature/unfeature/make_public/make_private
4. Return message with count

#### DB operations (inferred)
- READ (filter)
- DELETE
- READ (count)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `content.views.ContentViewSet.bulk_action`

### `GET` `/api/v1/content/categories/`

- **View / function**: `content.views.ContentCategoryViewSet.list`

#### Business logic steps (in order)
1. (not specified)

#### DB operations (inferred)
- (none inferred)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `content.views.ContentCategoryViewSet.list`

### `POST` `/api/v1/content/categories/`

- **View / function**: `content.views.ContentCategoryViewSet.create`

#### Business logic steps (in order)
1. (not specified)

#### DB operations (inferred)
- (none inferred)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `content.views.ContentCategoryViewSet.create`

### `GET` `/api/v1/content/categories/{id}/contents/`

- **View / function**: `content.views.ContentCategoryViewSet.contents`

#### Business logic steps (in order)
1. List published/active contents in category with pagination

#### DB operations (inferred)
- (none inferred)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `content.views.ContentCategoryViewSet.contents`

### `GET` `/api/v1/content/categories/{id}/statistics/`

- **View / function**: `content.views.ContentCategoryViewSet.statistics`

#### Business logic steps (in order)
1. Aggregate counts for category

#### DB operations (inferred)
- READ (aggregate/annotate)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `content.views.ContentCategoryViewSet.statistics`

### `GET` `/api/v1/content/tags/`

- **View / function**: `content.views.ContentTagViewSet.list`

#### Business logic steps (in order)
1. (not specified)

#### DB operations (inferred)
- (none inferred)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `content.views.ContentTagViewSet.list`

### `POST` `/api/v1/content/tags/`

- **View / function**: `content.views.ContentTagViewSet.create`

#### Business logic steps (in order)
1. (not specified)

#### DB operations (inferred)
- (none inferred)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `content.views.ContentTagViewSet.create`

### `GET` `/api/v1/content/tags/{id}/contents/`

- **View / function**: `content.views.ContentTagViewSet.contents`

#### Business logic steps (in order)
1. List active contents for tag with pagination

#### DB operations (inferred)
- (none inferred)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `content.views.ContentTagViewSet.contents`

### `GET` `/api/v1/content/ratings/`

- **View / function**: `content.views.ContentRatingViewSet.list`

#### Business logic steps (in order)
1. (not specified)

#### DB operations (inferred)
- (none inferred)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `content.views.ContentRatingViewSet.list`

### `GET` `/api/v1/content/comments/`

- **View / function**: `content.views.ContentCommentViewSet.list`

#### Business logic steps (in order)
1. (not specified)

#### DB operations (inferred)
- (none inferred)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `content.views.ContentCommentViewSet.list`

### `GET` `/api/v1/content/shares/`

- **View / function**: `content.views.ContentShareViewSet.list`

#### Business logic steps (in order)
1. (not specified)

#### DB operations (inferred)
- (none inferred)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `content.views.ContentShareViewSet.list`

### `GET` `/api/v1/content/downloads/`

- **View / function**: `content.views.ContentDownloadViewSet.list`

#### Business logic steps (in order)
1. (not specified)

#### DB operations (inferred)
- (none inferred)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `content.views.ContentDownloadViewSet.list`

### `GET` `/api/v1/content/bookmarks/`

- **View / function**: `content.views.ContentBookmarkViewSet.list`

#### Business logic steps (in order)
1. (not specified)

#### DB operations (inferred)
- (none inferred)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `content.views.ContentBookmarkViewSet.list`

### `GET` `/api/v1/content/analytics/`

- **View / function**: `content.views.ContentAnalyticsViewSet.list`

#### Business logic steps (in order)
1. (not specified)

#### DB operations (inferred)
- (none inferred)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `content.views.ContentAnalyticsViewSet.list`

### `GET` `/api/v1/content/feeds/`

- **View / function**: `content.views.FeedListAPIView.get`

#### Business logic steps (in order)
1. List Feed ordered by -date_posted

#### DB operations (inferred)
- (none inferred)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `content.views.FeedListAPIView.get`

## API Group: `courses`

### `GET` `/api/v1/courses/courses/`

- **View / function**: `courses.views.CourseViewSet.list`

#### Business logic steps (in order)
1. get_queryset filters status='active' for list
2. Optional extra filters: min_rating (Avg ratings), min_fee/max_fee
3. DRF list with pagination
4. On exception => 500 {success:false,message:'Error retrieving courses'}

#### DB operations (inferred)
- (none inferred)

#### Conditional logic & edge cases
- Error condition: unexpected exception

#### Error cases & status codes
- **500** when unexpected exception

#### Shared helpers / utilities referenced
- `courses.views.CourseViewSet.list`

### `POST` `/api/v1/courses/courses/`

- **View / function**: `courses.views.CourseViewSet.create`

#### Business logic steps (in order)
1. Create course via serializer
2. Return {success:true,data:<created>,message:'Course created successfully'}
3. On exception => 400

#### DB operations (inferred)
- CREATE

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `courses.views.CourseViewSet.create`

### `GET` `/api/v1/courses/courses/{id}/`

- **View / function**: `courses.views.CourseViewSet.retrieve`

#### Business logic steps (in order)
1. Return detailed course info; on exception return 500

#### DB operations (inferred)
- (none inferred)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `courses.views.CourseViewSet.retrieve`

### `GET` `/api/v1/courses/courses/search/`

- **View / function**: `courses.views.CourseViewSet.search`

#### Business logic steps (in order)
1. Validate query params with CourseSearchSerializer
2. Apply filters: q over name/description/university/subjects; featured_only; popular_only
3. Paginate results

#### DB operations (inferred)
- (none inferred)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `courses.views.CourseViewSet.search`

### `POST` `/api/v1/courses/courses/filter/`

- **View / function**: `courses.views.CourseViewSet.filter`

#### Business logic steps (in order)
1. Validate body
2. Apply filters for universities/levels/durations/subjects/countries/fee_range/rating_min/status
3. Paginate and return results

#### DB operations (inferred)
- (none inferred)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `courses.views.CourseViewSet.filter`

### `POST` `/api/v1/courses/courses/{id}/apply/`

- **View / function**: `courses.views.CourseViewSet.apply`

#### Business logic steps (in order)
1. Get course
2. Validate body with CourseApplicationCreateSerializer
3. Create CourseApplication via serializer.save(user=request.user, course=course)
4. Return 201 {success:true,data:<application>,message:'Application submitted successfully'}

#### DB operations (inferred)
- READ (get)
- CREATE
- UPDATE (save)

#### Conditional logic & edge cases
- Error condition: exception during create

#### Error cases & status codes
- **400** when exception during create

#### Shared helpers / utilities referenced
- `courses.views.CourseViewSet.apply`

### `POST` `/api/v1/courses/courses/{id}/rate/`

- **View / function**: `courses.views.CourseViewSet.rate`

#### Business logic steps (in order)
1. Get course
2. Validate body with CourseRatingSerializer
3. Update or create CourseRating for (user, course)
4. Return 201 if created else 200

#### DB operations (inferred)
- READ (get)
- CREATE
- UPDATE

#### Conditional logic & edge cases
- Return 201 if created else 200
- Error condition: exception

#### Error cases & status codes
- **400** when exception

#### Shared helpers / utilities referenced
- `courses.views.CourseViewSet.rate`

### `GET` `/api/v1/courses/courses/stats/`

- **View / function**: `courses.views.CourseViewSet.stats`

#### Business logic steps (in order)
1. Compute totals: courses, applications, avg rating, counts by level/duration
2. Compute top_courses by avg rating
3. Compute featured/popular courses
4. Return {success:true,data:<stats>}

#### DB operations (inferred)
- (none inferred)

#### Conditional logic & edge cases
- Error condition: unexpected exception

#### Error cases & status codes
- **500** when unexpected exception

#### Shared helpers / utilities referenced
- `courses.views.CourseViewSet.stats`

### `GET` `/api/v1/courses/subjects/`

- **View / function**: `courses.views.SubjectViewSet.list`

#### Business logic steps (in order)
1. (not specified)

#### DB operations (inferred)
- (none inferred)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `courses.views.SubjectViewSet.list`

### `POST` `/api/v1/courses/subjects/`

- **View / function**: `courses.views.SubjectViewSet.create`

#### Business logic steps (in order)
1. (not specified)

#### DB operations (inferred)
- (none inferred)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `courses.views.SubjectViewSet.create`

### `GET` `/api/v1/courses/applications/`

- **View / function**: `courses.views.CourseApplicationViewSet.list`

#### Business logic steps (in order)
1. List CourseApplication filtered by user=request.user

#### DB operations (inferred)
- (none inferred)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `courses.views.CourseApplicationViewSet.list`

## API Group: `payments`

### `GET` `/api/v1/payments/api/payments/payment-methods/`

- **View / function**: `payments.views.PaymentMethodViewSet.list`

#### Business logic steps (in order)
1. List PaymentMethod objects belonging to request.user

#### DB operations (inferred)
- (none inferred)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `payments.views.PaymentMethodViewSet.list`

### `POST` `/api/v1/payments/api/payments/payment-methods/`

- **View / function**: `payments.views.PaymentMethodViewSet.create`

#### Business logic steps (in order)
1. Create PaymentMethod for request.user via serializer

#### DB operations (inferred)
- CREATE

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `payments.views.PaymentMethodViewSet.create`

### `POST` `/api/v1/payments/api/payments/payment-methods/{uuid}/set_default/`

- **View / function**: `payments.views.PaymentMethodViewSet.set_default`

#### Business logic steps (in order)
1. Get payment method
2. Unset is_default on other methods for user
3. Set current is_default=True and save
4. Return serialized payment method

#### DB operations (inferred)
- READ (get)
- UPDATE (save)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `payments.views.PaymentMethodViewSet.set_default`

### `POST` `/api/v1/payments/api/payments/payment-methods/{uuid}/activate/`

- **View / function**: `payments.views.PaymentMethodViewSet.activate`

#### Business logic steps (in order)
1. Set is_active=True and save

#### DB operations (inferred)
- UPDATE (save)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `payments.views.PaymentMethodViewSet.activate`

### `POST` `/api/v1/payments/api/payments/payment-methods/{uuid}/deactivate/`

- **View / function**: `payments.views.PaymentMethodViewSet.deactivate`

#### Business logic steps (in order)
1. Set is_active=False and save

#### DB operations (inferred)
- UPDATE (save)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `payments.views.PaymentMethodViewSet.deactivate`

### `GET` `/api/v1/payments/api/payments/payment-methods/defaults/`

- **View / function**: `payments.views.PaymentMethodViewSet.defaults`

#### Business logic steps (in order)
1. List active default methods for user

#### DB operations (inferred)
- (none inferred)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `payments.views.PaymentMethodViewSet.defaults`

### `GET` `/api/v1/payments/api/payments/payment-methods/stats/`

- **View / function**: `payments.views.PaymentMethodViewSet.stats`

#### Business logic steps (in order)
1. Return counts and group-by payment_type

#### DB operations (inferred)
- (none inferred)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `payments.views.PaymentMethodViewSet.stats`

### `GET` `/api/v1/payments/api/payments/transactions/`

- **View / function**: `payments.views.PaymentTransactionViewSet.list`

#### Business logic steps (in order)
1. List user transactions

#### DB operations (inferred)
- (none inferred)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `payments.views.PaymentTransactionViewSet.list`

### `POST` `/api/v1/payments/api/payments/transactions/`

- **View / function**: `payments.views.PaymentTransactionViewSet.create`

#### Business logic steps (in order)
1. (not specified)

#### DB operations (inferred)
- (none inferred)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `payments.views.PaymentTransactionViewSet.create`

### `POST` `/api/v1/payments/api/payments/transactions/{uuid}/process_payment/`

- **View / function**: `payments.views.PaymentTransactionViewSet.process_payment`

#### Business logic steps (in order)
1. Require transaction.status == 'pending' else 400
2. Set status='processing' and save
3. Create PaymentLog info 'Payment processing started'
4. Simulate success: set status='completed', set processed_at/completed_at=now
5. Create PaymentLog info 'Payment completed successfully'
6. Return serialized transaction
7. On exception: set status='failed', create error PaymentLog, return 500

#### DB operations (inferred)
- UPDATE (save)
- CREATE

#### Conditional logic & edge cases
- Error condition: status not pending
- Error condition: exception during processing

#### Error cases & status codes
- **400** when status not pending
- **500** when exception during processing

#### Shared helpers / utilities referenced
- `payments.views.PaymentTransactionViewSet.process_payment`

### `POST` `/api/v1/payments/api/payments/transactions/{uuid}/cancel_transaction/`

- **View / function**: `payments.views.PaymentTransactionViewSet.cancel_transaction`

#### Business logic steps (in order)
1. Require status in ['pending','processing'] else 400
2. Set status='cancelled' and save
3. Create PaymentLog info 'Transaction cancelled by user'
4. Return serialized transaction

#### DB operations (inferred)
- UPDATE (save)
- CREATE

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `payments.views.PaymentTransactionViewSet.cancel_transaction`

### `POST` `/api/v1/payments/api/payments/transactions/{uuid}/request_refund/`

- **View / function**: `payments.views.PaymentTransactionViewSet.request_refund`

#### Business logic steps (in order)
1. Require transaction.is_refundable else 400
2. Read amount (default transaction.amount), reason, notes
3. If amount > transaction.amount => 400
4. Create Refund(transaction, user, amount, currency, reason, notes)
5. Return 201 with RefundSerializer

#### DB operations (inferred)
- CREATE

#### Conditional logic & edge cases
- If amount > transaction.amount => 400
- Error condition: not refundable
- Error condition: amount exceeds transaction

#### Error cases & status codes
- **400** when not refundable
- **400** when amount exceeds transaction

#### Shared helpers / utilities referenced
- `payments.views.PaymentTransactionViewSet.request_refund`

### `GET` `/api/v1/payments/api/payments/transactions/stats/`

- **View / function**: `payments.views.PaymentTransactionViewSet.stats`

#### Business logic steps (in order)
1. Aggregate over last N days (default 30)

#### DB operations (inferred)
- READ (aggregate/annotate)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `payments.views.PaymentTransactionViewSet.stats`

### `GET` `/api/v1/payments/api/payments/transactions/recent/`

- **View / function**: `payments.views.PaymentTransactionViewSet.recent`

#### Business logic steps (in order)
1. Return last N (default 10)

#### DB operations (inferred)
- (none inferred)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `payments.views.PaymentTransactionViewSet.recent`

### `GET` `/api/v1/payments/api/payments/subscriptions/`

- **View / function**: `payments.views.SubscriptionViewSet.list`

#### Business logic steps (in order)
1. (not specified)

#### DB operations (inferred)
- (none inferred)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `payments.views.SubscriptionViewSet.list`

### `POST` `/api/v1/payments/api/payments/subscriptions/`

- **View / function**: `payments.views.SubscriptionViewSet.create`

#### Business logic steps (in order)
1. (not specified)

#### DB operations (inferred)
- (none inferred)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `payments.views.SubscriptionViewSet.create`

### `POST` `/api/v1/payments/api/payments/subscriptions/{uuid}/cancel_subscription/`

- **View / function**: `payments.views.SubscriptionViewSet.cancel_subscription`

#### Business logic steps (in order)
1. Require status in ['active','trial']; set cancelled+auto_renew=false

#### DB operations (inferred)
- (none inferred)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `payments.views.SubscriptionViewSet.cancel_subscription`

### `POST` `/api/v1/payments/api/payments/subscriptions/{uuid}/renew_subscription/`

- **View / function**: `payments.views.SubscriptionViewSet.renew_subscription`

#### Business logic steps (in order)
1. Require status=='cancelled'; set active+auto_renew=true

#### DB operations (inferred)
- (none inferred)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `payments.views.SubscriptionViewSet.renew_subscription`

### `POST` `/api/v1/payments/api/payments/subscriptions/{uuid}/change_payment_method/`

- **View / function**: `payments.views.SubscriptionViewSet.change_payment_method`

#### Business logic steps (in order)
1. Require payment_method_id present else 400
2. Fetch PaymentMethod(id=payment_method_id,user=request.user) else 404
3. Set subscription.payment_method and save
4. Return serialized subscription

#### DB operations (inferred)
- UPDATE (save)

#### Conditional logic & edge cases
- Error condition: missing payment_method_id
- Error condition: payment method not found

#### Error cases & status codes
- **400** when missing payment_method_id
- **404** when payment method not found

#### Shared helpers / utilities referenced
- `payments.views.SubscriptionViewSet.change_payment_method`

### `GET` `/api/v1/payments/api/payments/subscriptions/active/`

- **View / function**: `payments.views.SubscriptionViewSet.active`

#### Business logic steps (in order)
1. List active subscriptions

#### DB operations (inferred)
- (none inferred)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `payments.views.SubscriptionViewSet.active`

### `GET` `/api/v1/payments/api/payments/subscriptions/expiring_soon/`

- **View / function**: `payments.views.SubscriptionViewSet.expiring_soon`

#### Business logic steps (in order)
1. Filter end_date <= now+days

#### DB operations (inferred)
- READ (filter)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `payments.views.SubscriptionViewSet.expiring_soon`

### `GET` `/api/v1/payments/api/payments/subscriptions/stats/`

- **View / function**: `payments.views.SubscriptionViewSet.stats`

#### Business logic steps (in order)
1. (not specified)

#### DB operations (inferred)
- (none inferred)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `payments.views.SubscriptionViewSet.stats`

### `GET` `/api/v1/payments/api/payments/invoices/`

- **View / function**: `payments.views.InvoiceViewSet.list`

#### Business logic steps (in order)
1. (not specified)

#### DB operations (inferred)
- (none inferred)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `payments.views.InvoiceViewSet.list`

### `POST` `/api/v1/payments/api/payments/invoices/`

- **View / function**: `payments.views.InvoiceViewSet.create`

#### Business logic steps (in order)
1. (not specified)

#### DB operations (inferred)
- (none inferred)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `payments.views.InvoiceViewSet.create`

### `POST` `/api/v1/payments/api/payments/invoices/{uuid}/mark_as_paid/`

- **View / function**: `payments.views.InvoiceViewSet.mark_as_paid`

#### Business logic steps (in order)
1. Reject if already paid; else set paid status and paid_date

#### DB operations (inferred)
- (none inferred)

#### Conditional logic & edge cases
- Reject if already paid; else set paid status and paid_date

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `payments.views.InvoiceViewSet.mark_as_paid`

### `GET` `/api/v1/payments/api/payments/invoices/{uuid}/download_pdf/`

- **View / function**: `payments.views.InvoiceViewSet.download_pdf`

#### Business logic steps (in order)
1. Placeholder response (no real PDF generation)

#### DB operations (inferred)
- (none inferred)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `payments.views.InvoiceViewSet.download_pdf`

### `GET` `/api/v1/payments/api/payments/invoices/overdue/`

- **View / function**: `payments.views.InvoiceViewSet.overdue`

#### Business logic steps (in order)
1. Filter status in ['sent','draft'] and due_date < now

#### DB operations (inferred)
- READ (filter)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `payments.views.InvoiceViewSet.overdue`

### `GET` `/api/v1/payments/api/payments/invoices/stats/`

- **View / function**: `payments.views.InvoiceViewSet.stats`

#### Business logic steps (in order)
1. (not specified)

#### DB operations (inferred)
- (none inferred)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `payments.views.InvoiceViewSet.stats`

### `GET` `/api/v1/payments/api/payments/refunds/`

- **View / function**: `payments.views.RefundViewSet.list`

#### Business logic steps (in order)
1. (not specified)

#### DB operations (inferred)
- (none inferred)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `payments.views.RefundViewSet.list`

### `POST` `/api/v1/payments/api/payments/refunds/`

- **View / function**: `payments.views.RefundViewSet.create`

#### Business logic steps (in order)
1. (not specified)

#### DB operations (inferred)
- (none inferred)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `payments.views.RefundViewSet.create`

### `POST` `/api/v1/payments/api/payments/refunds/{uuid}/process_refund/`

- **View / function**: `payments.views.RefundViewSet.process_refund`

#### Business logic steps (in order)
1. Require pending; simulate processing; update transaction to refunded/partially_refunded

#### DB operations (inferred)
- UPDATE

#### Conditional logic & edge cases
- Error condition: not pending
- Error condition: exception

#### Error cases & status codes
- **400** when not pending
- **500** when exception

#### Shared helpers / utilities referenced
- `payments.views.RefundViewSet.process_refund`

### `GET` `/api/v1/payments/api/payments/refunds/stats/`

- **View / function**: `payments.views.RefundViewSet.stats`

#### Business logic steps (in order)
1. (not specified)

#### DB operations (inferred)
- (none inferred)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `payments.views.RefundViewSet.stats`

### `GET` `/api/v1/payments/api/payments/gateways/`

- **View / function**: `payments.views.PaymentGatewayViewSet.list`

#### Business logic steps (in order)
1. List active gateways

#### DB operations (inferred)
- (none inferred)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `payments.views.PaymentGatewayViewSet.list`

### `GET` `/api/v1/payments/api/payments/gateways/supported_methods/`

- **View / function**: `payments.views.PaymentGatewayViewSet.supported_methods`

#### Business logic steps (in order)
1. Return mapping gateway_type -> supported currencies/methods/fees

#### DB operations (inferred)
- (none inferred)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `payments.views.PaymentGatewayViewSet.supported_methods`

### `GET` `/api/v1/payments/api/payments/logs/`

- **View / function**: `payments.views.PaymentLogViewSet.list`

#### Business logic steps (in order)
1. List logs for request.user transactions

#### DB operations (inferred)
- (none inferred)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `payments.views.PaymentLogViewSet.list`

### `GET` `/api/v1/payments/api/payments/logs/errors/`

- **View / function**: `payments.views.PaymentLogViewSet.errors`

#### Business logic steps (in order)
1. Filter level in ['error','critical']

#### DB operations (inferred)
- READ (filter)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `payments.views.PaymentLogViewSet.errors`

### `GET` `/api/v1/payments/api/payments/stats/overview/`

- **View / function**: `payments.views.PaymentStatsViewSet.overview`

#### Business logic steps (in order)
1. Aggregate transactions/subscriptions/payment_methods for last N days

#### DB operations (inferred)
- READ (aggregate/annotate)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `payments.views.PaymentStatsViewSet.overview`

### `GET` `/api/v1/payments/api/payments/stats/trends/`

- **View / function**: `payments.views.PaymentStatsViewSet.trends`

#### Business logic steps (in order)
1. Return daily transaction totals + subscription counts using DATE(created_at) grouping

#### DB operations (inferred)
- (none inferred)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `payments.views.PaymentStatsViewSet.trends`

## API Group: `quizzes`

### `GET` `/api/v1/quizzes/quizzes/`

- **View / function**: `quizzes.views.QuizViewSet.list`

#### Business logic steps (in order)
1. (not specified)

#### DB operations (inferred)
- (none inferred)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `quizzes.views.QuizViewSet.list`

### `POST` `/api/v1/quizzes/quizzes/`

- **View / function**: `quizzes.views.QuizViewSet.create`

#### Business logic steps (in order)
1. serializer.save(creator=request.user)

#### DB operations (inferred)
- UPDATE (save)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `quizzes.views.QuizViewSet.create`

### `POST` `/api/v1/quizzes/quizzes/{id}/start/`

- **View / function**: `quizzes.views.QuizViewSet.start_quiz`

#### Business logic steps (in order)
1. Reject if quiz.is_active is false => 400
2. Count existing attempts for (quiz,user); if >= quiz.max_attempts => 400
3. Create QuizAttempt(status='in_progress')
4. If quiz.time_limit>0 create QuizTimer(time_limit seconds, time_remaining seconds)
5. Create QuizAnalytics(action_type='start', ip/user_agent)
6. Return 201 QuizAttemptSerializer

#### DB operations (inferred)
- READ (count)
- CREATE

#### Conditional logic & edge cases
- Reject if quiz.is_active is false => 400
- Count existing attempts for (quiz,user); if >= quiz.max_attempts => 400
- If quiz.time_limit>0 create QuizTimer(time_limit seconds, time_remaining seconds)
- Error condition: quiz not active
- Error condition: max attempts reached

#### Error cases & status codes
- **400** when quiz not active
- **400** when max attempts reached

#### Shared helpers / utilities referenced
- `quizzes.views.QuizViewSet.start_quiz`

### `POST` `/api/v1/quizzes/quizzes/{id}/submit/`

- **View / function**: `quizzes.views.QuizViewSet.submit_quiz`

#### Business logic steps (in order)
1. Find QuizAttempt for (quiz,user,status='in_progress'); if none => 400
2. Iterate questions; compute total_points, earned_points, questions_attempted, questions_correct
3. Determine correctness by question_type:
4. - multiple_choice: compare selected option ids to correct options
5. - true_false: compare text
6. - else: text compare
7. Create QuizResult per question attempted
8. Compute percentage and passed (>= quiz.passing_score)
9. Update attempt fields and mark status='completed'
10. Update quiz.total_attempts and quiz.average_score
11. Create QuizAnalytics(action_type='complete')
12. Return QuizAttemptSerializer

#### DB operations (inferred)
- CREATE
- UPDATE

#### Conditional logic & edge cases
- Find QuizAttempt for (quiz,user,status='in_progress'); if none => 400
- Error condition: no active attempt found

#### Error cases & status codes
- **400** when no active attempt found

#### Shared helpers / utilities referenced
- `quizzes.views.QuizViewSet.submit_quiz`

### `GET` `/api/v1/quizzes/quizzes/{id}/results/`

- **View / function**: `quizzes.views.QuizViewSet.results`

#### Business logic steps (in order)
1. List completed attempts for user ordered by -completed_at

#### DB operations (inferred)
- (none inferred)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `quizzes.views.QuizViewSet.results`

### `GET` `/api/v1/quizzes/quizzes/{id}/leaderboard/`

- **View / function**: `quizzes.views.QuizViewSet.leaderboard`

#### Business logic steps (in order)
1. Top 10 completed attempts by percentage then time_taken

#### DB operations (inferred)
- (none inferred)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `quizzes.views.QuizViewSet.leaderboard`

### `GET` `/api/v1/quizzes/quizzes/search/`

- **View / function**: `quizzes.views.QuizViewSet.search`

#### Business logic steps (in order)
1. Validate with QuizSearchSerializer; filter; paginate

#### DB operations (inferred)
- READ (filter)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `quizzes.views.QuizViewSet.search`

### `GET` `/api/v1/quizzes/quizzes/statistics/`

- **View / function**: `quizzes.views.QuizViewSet.statistics`

#### Business logic steps (in order)
1. Aggregate overall and per-category stats

#### DB operations (inferred)
- READ (aggregate/annotate)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `quizzes.views.QuizViewSet.statistics`

### `GET` `/api/v1/quizzes/quizzes/featured/`

- **View / function**: `quizzes.views.QuizViewSet.featured`

#### Business logic steps (in order)
1. Filter is_featured=True

#### DB operations (inferred)
- READ (filter)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `quizzes.views.QuizViewSet.featured`

### `GET` `/api/v1/quizzes/quizzes/recent/`

- **View / function**: `quizzes.views.QuizViewSet.recent`

#### Business logic steps (in order)
1. Order by -created_at limit 10

#### DB operations (inferred)
- (none inferred)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `quizzes.views.QuizViewSet.recent`

### `GET` `/api/v1/quizzes/quizzes/popular/`

- **View / function**: `quizzes.views.QuizViewSet.popular`

#### Business logic steps (in order)
1. Order by -total_attempts limit 10

#### DB operations (inferred)
- (none inferred)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `quizzes.views.QuizViewSet.popular`

### `POST` `/api/v1/quizzes/quizzes/{id}/share/`

- **View / function**: `quizzes.views.QuizViewSet.share`

#### Business logic steps (in order)
1. Validate QuizShareCreateSerializer; save share; create analytics share; return message

#### DB operations (inferred)
- CREATE
- UPDATE (save)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `quizzes.views.QuizViewSet.share`

### `POST` `/api/v1/quizzes/quizzes/bulk-action/`

- **View / function**: `quizzes.views.QuizViewSet.bulk_action`

#### Business logic steps (in order)
1. Validate QuizBulkActionSerializer (quiz_ids, action)
2. Filter quizzes by ids and creator=request.user
3. Perform action: publish/archive/delete/feature/unfeature
4. Return message with count

#### DB operations (inferred)
- READ (filter)
- DELETE
- READ (count)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `quizzes.views.QuizViewSet.bulk_action`

### `GET` `/api/v1/quizzes/categories/`

- **View / function**: `quizzes.views.QuizCategoryViewSet.list`

#### Business logic steps (in order)
1. (not specified)

#### DB operations (inferred)
- (none inferred)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `quizzes.views.QuizCategoryViewSet.list`

### `POST` `/api/v1/quizzes/categories/`

- **View / function**: `quizzes.views.QuizCategoryViewSet.create`

#### Business logic steps (in order)
1. (not specified)

#### DB operations (inferred)
- (none inferred)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `quizzes.views.QuizCategoryViewSet.create`

### `GET` `/api/v1/quizzes/categories/{id}/quizzes/`

- **View / function**: `quizzes.views.QuizCategoryViewSet.quizzes`

#### Business logic steps (in order)
1. List active quizzes in category with pagination

#### DB operations (inferred)
- (none inferred)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `quizzes.views.QuizCategoryViewSet.quizzes`

### `GET` `/api/v1/quizzes/categories/{id}/statistics/`

- **View / function**: `quizzes.views.QuizCategoryViewSet.statistics`

#### Business logic steps (in order)
1. Compute totals/averages from quizzes in category

#### DB operations (inferred)
- (none inferred)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `quizzes.views.QuizCategoryViewSet.statistics`

### `POST` `/api/v1/quizzes/categories/reorder/`

- **View / function**: `quizzes.views.QuizCategoryViewSet.reorder`

#### Business logic steps (in order)
1. Update order field per provided category_ids list

#### DB operations (inferred)
- UPDATE

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `quizzes.views.QuizCategoryViewSet.reorder`

### `GET` `/api/v1/quizzes/questions/`

- **View / function**: `quizzes.views.QuestionViewSet.list`

#### Business logic steps (in order)
1. (not specified)

#### DB operations (inferred)
- (none inferred)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `quizzes.views.QuestionViewSet.list`

### `POST` `/api/v1/quizzes/questions/`

- **View / function**: `quizzes.views.QuestionViewSet.create`

#### Business logic steps (in order)
1. (not specified)

#### DB operations (inferred)
- (none inferred)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `quizzes.views.QuestionViewSet.create`

### `GET` `/api/v1/quizzes/options/`

- **View / function**: `quizzes.views.OptionViewSet.list`

#### Business logic steps (in order)
1. (not specified)

#### DB operations (inferred)
- (none inferred)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `quizzes.views.OptionViewSet.list`

### `POST` `/api/v1/quizzes/options/`

- **View / function**: `quizzes.views.OptionViewSet.create`

#### Business logic steps (in order)
1. (not specified)

#### DB operations (inferred)
- (none inferred)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `quizzes.views.OptionViewSet.create`

### `GET` `/api/v1/quizzes/attempts/`

- **View / function**: `quizzes.views.QuizAttemptViewSet.list`

#### Business logic steps (in order)
1. (not specified)

#### DB operations (inferred)
- (none inferred)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `quizzes.views.QuizAttemptViewSet.list`

### `GET` `/api/v1/quizzes/attempts/{uuid}/results/`

- **View / function**: `quizzes.views.QuizAttemptViewSet.results`

#### Business logic steps (in order)
1. Return QuizResult rows for attempt

#### DB operations (inferred)
- (none inferred)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `quizzes.views.QuizAttemptViewSet.results`

### `GET` `/api/v1/quizzes/analytics/`

- **View / function**: `quizzes.views.QuizAnalyticsViewSet.list`

#### Business logic steps (in order)
1. (not specified)

#### DB operations (inferred)
- (none inferred)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `quizzes.views.QuizAnalyticsViewSet.list`

### `GET` `/api/v1/quizzes/shares/`

- **View / function**: `quizzes.views.QuizShareViewSet.list`

#### Business logic steps (in order)
1. (not specified)

#### DB operations (inferred)
- (none inferred)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `quizzes.views.QuizShareViewSet.list`

### `GET` `/api/v1/quizzes/timers/`

- **View / function**: `quizzes.views.QuizTimerViewSet.list`

#### Business logic steps (in order)
1. (not specified)

#### DB operations (inferred)
- (none inferred)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `quizzes.views.QuizTimerViewSet.list`

### `POST` `/api/v1/quizzes/timers/{id}/pause/`

- **View / function**: `quizzes.views.QuizTimerViewSet.pause`

#### Business logic steps (in order)
1. Call timer.pause(); return updated timer

#### DB operations (inferred)
- (none inferred)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `quizzes.views.QuizTimerViewSet.pause`
- `timer.pause`

### `POST` `/api/v1/quizzes/timers/{id}/resume/`

- **View / function**: `quizzes.views.QuizTimerViewSet.resume`

#### Business logic steps (in order)
1. Call timer.resume(); return updated timer

#### DB operations (inferred)
- (none inferred)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `quizzes.views.QuizTimerViewSet.resume`
- `timer.resume`

## API Group: `universities`

### `GET` `/api/v1/universities/universities/`

- **View / function**: `universities.views.UniversityViewSet.list`

#### Business logic steps (in order)
1. get_queryset filters is_active=True for list action
2. DRF list applies filters/search/ordering + pagination
3. Wrapped in try/except; on exception returns 500 {success:false,message:'Error retrieving universities'}

#### DB operations (inferred)
- (none inferred)

#### Conditional logic & edge cases
- Error condition: unexpected exception

#### Error cases & status codes
- **500** when unexpected exception

#### Shared helpers / utilities referenced
- `universities.views.UniversityViewSet.list`

### `POST` `/api/v1/universities/universities/`

- **View / function**: `universities.views.UniversityViewSet.create`

#### Business logic steps (in order)
1. Use UniversityCreateSerializer
2. Call DRF create
3. Return 201 {success:true,data:<created>,message:'University created successfully'}
4. On error => 400 {success:false,message:'Error creating university'}

#### DB operations (inferred)
- CREATE

#### Conditional logic & edge cases
- Error condition: exception during create

#### Error cases & status codes
- **400** when exception during create

#### Shared helpers / utilities referenced
- `universities.views.UniversityViewSet.create`
- `DRF`

### `DELETE` `/api/v1/universities/universities/{id}/`

- **View / function**: `universities.views.UniversityViewSet.destroy`

#### Business logic steps (in order)
1. (not specified)

#### DB operations (inferred)
- (none inferred)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `universities.views.UniversityViewSet.destroy`

### `GET` `/api/v1/universities/universities/{id}/`

- **View / function**: `universities.views.UniversityViewSet.retrieve`

#### Business logic steps (in order)
1. Load university object
2. Serialize and return {success:true,data:<university>,message:'University <name> retrieved successfully'}
3. On exception => 500 {success:false,message:'Error retrieving university'}

#### DB operations (inferred)
- (none inferred)

#### Conditional logic & edge cases
- Error condition: unexpected exception

#### Error cases & status codes
- **500** when unexpected exception

#### Shared helpers / utilities referenced
- `universities.views.UniversityViewSet.retrieve`

### `PATCH` `/api/v1/universities/universities/{id}/`

- **View / function**: `universities.views.UniversityViewSet.partial_update`

#### Business logic steps (in order)
1. (not specified)

#### DB operations (inferred)
- (none inferred)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `universities.views.UniversityViewSet.partial_update`

### `PUT` `/api/v1/universities/universities/{id}/`

- **View / function**: `universities.views.UniversityViewSet.update`

#### Business logic steps (in order)
1. (not specified)

#### DB operations (inferred)
- (none inferred)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `universities.views.UniversityViewSet.update`

### `GET` `/api/v1/universities/universities/{id}/gallery/`

- **View / function**: `universities.views.UniversityViewSet.gallery`

#### Business logic steps (in order)
1. Get university
2. Try to access university.gallery (OneToOne/related)
3. If exists: serialize gallery and return {success:true,data:<gallery>,message:'Gallery for <name>'}
4. If missing: return {success:true,data:null,message:'No gallery found for <name>'}
5. On exception => 500

#### DB operations (inferred)
- READ (get)

#### Conditional logic & edge cases
- If exists: serialize gallery and return {success:true,data:<gallery>,message:'Gallery for <name>'}
- If missing: return {success:true,data:null,message:'No gallery found for <name>'}
- Error condition: unexpected exception

#### Error cases & status codes
- **500** when unexpected exception

#### Shared helpers / utilities referenced
- `universities.views.UniversityViewSet.gallery`

### `POST` `/api/v1/universities/universities/search/`

- **View / function**: `universities.views.UniversityViewSet.search`

#### Business logic steps (in order)
1. Validate body with UniversitySearchSerializer
2. Start queryset University.objects.filter(is_active=True)
3. Apply text query across name/short_name/description/country/city
4. Apply filters: country, university_type
5. Apply ranking filters using rankings__rank range
6. If has_programs => filter programs not null
7. Apply status filters: is_featured, is_verified
8. Paginate if possible; otherwise return list
9. On exception => 500

#### DB operations (inferred)
- READ (filter)

#### Conditional logic & edge cases
- If has_programs => filter programs not null
- Paginate if possible; otherwise return list
- Error condition: unexpected exception

#### Error cases & status codes
- **500** when unexpected exception

#### Shared helpers / utilities referenced
- `universities.views.UniversityViewSet.search`

### `GET` `/api/v1/universities/universities/stats/`

- **View / function**: `universities.views.UniversityViewSet.stats`

#### Business logic steps (in order)
1. Compute counts: total, active, featured, verified
2. Aggregate universities_by_country and universities_by_type
3. Compute top_ranked_universities by min ranking
4. Get recent universities
5. Return {success:true,data:<stats>}

#### DB operations (inferred)
- READ (aggregate/annotate)
- READ (get)

#### Conditional logic & edge cases
- Error condition: unexpected exception

#### Error cases & status codes
- **500** when unexpected exception

#### Shared helpers / utilities referenced
- `universities.views.UniversityViewSet.stats`

### `POST` `/api/v1/universities/universities/compare/`

- **View / function**: `universities.views.UniversityViewSet.compare`

#### Business logic steps (in order)
1. Validate 2-5 IDs else 400
2. Fetch universities by ids; if any missing => 404
3. For each university, include rankings and programs comparisons
4. Return {success:true,data:{universities,comparison_data,ranking_comparison,program_comparison}}

#### DB operations (inferred)
- (none inferred)

#### Conditional logic & edge cases
- Fetch universities by ids; if any missing => 404
- Error condition: <2 or >5 IDs
- Error condition: some university IDs not found
- Error condition: unexpected exception

#### Error cases & status codes
- **400** when <2 or >5 IDs
- **404** when some university IDs not found
- **500** when unexpected exception

#### Shared helpers / utilities referenced
- `universities.views.UniversityViewSet.compare`

### `GET` `/api/v1/universities/universities/{id}/rankings/`

- **View / function**: `universities.views.UniversityViewSet.rankings`

#### Business logic steps (in order)
1. Fetch university
2. Load related rankings ordered by -year, ranking_type
3. Serialize list and return success

#### DB operations (inferred)
- (none inferred)

#### Conditional logic & edge cases
- Error condition: unexpected exception

#### Error cases & status codes
- **500** when unexpected exception

#### Shared helpers / utilities referenced
- `universities.views.UniversityViewSet.rankings`

### `GET` `/api/v1/universities/universities/{id}/programs/`

- **View / function**: `universities.views.UniversityViewSet.programs`

#### Business logic steps (in order)
1. Fetch university
2. Filter programs is_active=True ordered by level/name
3. Serialize list and return success

#### DB operations (inferred)
- READ (filter)

#### Conditional logic & edge cases
- Error condition: unexpected exception

#### Error cases & status codes
- **500** when unexpected exception

#### Shared helpers / utilities referenced
- `universities.views.UniversityViewSet.programs`

### `GET` `/api/v1/universities/campuses/`

- **View / function**: `universities.views.CampusViewSet.list`

#### Business logic steps (in order)
1. List active campuses (action list filters is_active=True)

#### DB operations (inferred)
- (none inferred)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `universities.views.CampusViewSet.list`

### `POST` `/api/v1/universities/campuses/`

- **View / function**: `universities.views.CampusViewSet.create`

#### Business logic steps (in order)
1. (not specified)

#### DB operations (inferred)
- (none inferred)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `universities.views.CampusViewSet.create`

### `GET` `/api/v1/universities/rankings/`

- **View / function**: `universities.views.UniversityRankingViewSet.list`

#### Business logic steps (in order)
1. (not specified)

#### DB operations (inferred)
- (none inferred)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `universities.views.UniversityRankingViewSet.list`

### `POST` `/api/v1/universities/rankings/`

- **View / function**: `universities.views.UniversityRankingViewSet.create`

#### Business logic steps (in order)
1. (not specified)

#### DB operations (inferred)
- (none inferred)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `universities.views.UniversityRankingViewSet.create`

### `GET` `/api/v1/universities/programs/`

- **View / function**: `universities.views.UniversityProgramViewSet.list`

#### Business logic steps (in order)
1. List active programs (filters is_active=True for list)

#### DB operations (inferred)
- (none inferred)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `universities.views.UniversityProgramViewSet.list`

### `POST` `/api/v1/universities/programs/`

- **View / function**: `universities.views.UniversityProgramViewSet.create`

#### Business logic steps (in order)
1. (not specified)

#### DB operations (inferred)
- (none inferred)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `universities.views.UniversityProgramViewSet.create`

### `GET` `/api/v1/universities/faculties/`

- **View / function**: `universities.views.UniversityFacultyViewSet.list`

#### Business logic steps (in order)
1. List active faculties (filters is_active=True for list)

#### DB operations (inferred)
- (none inferred)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `universities.views.UniversityFacultyViewSet.list`

### `POST` `/api/v1/universities/faculties/`

- **View / function**: `universities.views.UniversityFacultyViewSet.create`

#### Business logic steps (in order)
1. (not specified)

#### DB operations (inferred)
- (none inferred)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `universities.views.UniversityFacultyViewSet.create`

### `GET` `/api/v1/universities/research/`

- **View / function**: `universities.views.UniversityResearchViewSet.list`

#### Business logic steps (in order)
1. (not specified)

#### DB operations (inferred)
- (none inferred)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `universities.views.UniversityResearchViewSet.list`

### `POST` `/api/v1/universities/research/`

- **View / function**: `universities.views.UniversityResearchViewSet.create`

#### Business logic steps (in order)
1. (not specified)

#### DB operations (inferred)
- (none inferred)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `universities.views.UniversityResearchViewSet.create`

### `GET` `/api/v1/universities/partnerships/`

- **View / function**: `universities.views.UniversityPartnershipViewSet.list`

#### Business logic steps (in order)
1. (not specified)

#### DB operations (inferred)
- (none inferred)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `universities.views.UniversityPartnershipViewSet.list`

### `POST` `/api/v1/universities/partnerships/`

- **View / function**: `universities.views.UniversityPartnershipViewSet.create`

#### Business logic steps (in order)
1. (not specified)

#### DB operations (inferred)
- (none inferred)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `universities.views.UniversityPartnershipViewSet.create`

### `GET` `/api/v1/universities/feeds/`

- **View / function**: `universities.views.FeedViewSet.list`

#### Business logic steps (in order)
1. (not specified)

#### DB operations (inferred)
- (none inferred)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `universities.views.FeedViewSet.list`

### `POST` `/api/v1/universities/feeds/`

- **View / function**: `universities.views.FeedViewSet.create`

#### Business logic steps (in order)
1. (not specified)

#### DB operations (inferred)
- (none inferred)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `universities.views.FeedViewSet.create`

## API Group: `users`

### `GET` `/api/v1/users/users/`

- **View / function**: `users.views.list_users`

#### Business logic steps (in order)
1. Query all User rows (User.objects.all())
2. Serialize with UserSerializer(many=True)
3. Return {success: true, data: [...]}

#### DB operations (inferred)
- (none inferred)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `users.views.list_users`

### `GET` `/api/v1/users/users/by-email/`

- **View / function**: `users.views.get_user_by_email`

#### Business logic steps (in order)
1. Read email from request.query_params['email']
2. If missing/blank => 400 {success:false,message:'Email parameter is required'}
3. Call _get_or_create_user_by_email(email)
4. Helper searches User by email (case-insensitive) OR profile.email; if not found creates a new User w/ unique username + unusable password and ensures UserProfile exists
5. Serialize user with UserSerializer
6. Return {success:true,data:user}

#### DB operations (inferred)
- CREATE

#### Conditional logic & edge cases
- If missing/blank => 400 {success:false,message:'Email parameter is required'}
- Helper searches User by email (case-insensitive) OR profile.email; if not found creates a new User w/ unique username + unusable password and ensures UserProfile exists
- Error condition: email missing

#### Error cases & status codes
- **400** when email missing -> {success:false,message:'Email parameter is required'}

#### Shared helpers / utilities referenced
- `users.views.get_user_by_email`
- `_get_or_create_user_by_email`

### `POST` `/api/v1/users/upload-profile-image/`

- **View / function**: `users.views.upload_profile_image`

#### Business logic steps (in order)
1. Read email from request.data['email'] or request.query_params['email']
2. Validate email present => else 400
3. Read profile_picture from request.FILES
4. Validate file present => else 400
5. Call _get_or_create_user_by_email(email)
6. Get or create UserProfile(user=user, defaults={email:user.email})
7. Set profile.profile_picture=file and save
8. Serialize user and return success

#### DB operations (inferred)
- CREATE
- READ (get)
- UPDATE (save)

#### Conditional logic & edge cases
- Error condition: email missing
- Error condition: profile_picture missing

#### Error cases & status codes
- **400** when email missing -> {success:false,message:'Email parameter is required'}
- **400** when profile_picture missing -> {success:false,message:'profile_picture file is required'}

#### Shared helpers / utilities referenced
- `users.views.upload_profile_image`
- `_get_or_create_user_by_email`

### `POST` `/api/v1/users/send-otp/`

- **View / function**: `users.sub_views.SendOTPView.post`

#### Business logic steps (in order)
1. Read contact from request.data['contact']
2. Validate present and contains '@'
3. Generate 6-digit numeric OTP
4. Create OTPVerification(otp_type='register', contact=contact, otp_code=otp_code)
5. EmailService.send_otp_email(contact, otp_code)
6. Return 201 with {success:true,message:'OTP sent',otp:<code>}

#### DB operations (inferred)
- CREATE

#### Conditional logic & edge cases
- Error condition: contact missing
- Error condition: contact not email-like

#### Error cases & status codes
- **400** when contact missing -> {success:false,message:'Email required'}
- **400** when contact not email-like -> {success:false,message:'Invalid email'}

#### Shared helpers / utilities referenced
- `users.sub_views.SendOTPView.post`

### `GET` `/api/v1/users/otp/`

- **View / function**: `users.otp_views.OTPVerificationViewSet.list`

#### Business logic steps (in order)
1. Return OTPVerification queryset (get_queryset returns OTPVerification.objects.all())

#### DB operations (inferred)
- (none inferred)

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `users.otp_views.OTPVerificationViewSet.list`

### `POST` `/api/v1/users/otp/`

- **View / function**: `users.otp_views.OTPVerificationViewSet.create`

#### Business logic steps (in order)
1. Standard DRF create for OTPVerification using serializer_class=OTPVerificationSerializer

#### DB operations (inferred)
- CREATE

#### Conditional logic & edge cases
- (none detected)

#### Error cases & status codes
- (none listed)

#### Shared helpers / utilities referenced
- `users.otp_views.OTPVerificationViewSet.create`

### `POST` `/api/v1/users/otp/create/`

- **View / function**: `users.otp_views.OTPVerificationViewSet.create_otp`

#### Business logic steps (in order)
1. Validate request with OTPCreateSerializer (otp_type, contact)
2. Generate OTP code (6 digits)
3. Create OTPVerification row
4. Send email via EmailService.send_otp_email
5. If email send succeeds => return 201 with OTPVerificationSerializer(otp)
6. If email send fails => delete OTP row and return 500

#### DB operations (inferred)
- CREATE
- DELETE

#### Conditional logic & edge cases
- If email send succeeds => return 201 with OTPVerificationSerializer(otp)
- If email send fails => delete OTP row and return 500
- Error condition: EmailService.send_otp_email returns falsy

#### Error cases & status codes
- **500** when EmailService.send_otp_email returns falsy -> {success:false,message:'Failed to send email'}

#### Shared helpers / utilities referenced
- `users.otp_views.OTPVerificationViewSet.create_otp`

### `POST` `/api/v1/users/otp/verify/`

- **View / function**: `users.otp_views.OTPVerificationViewSet.verify_otp`

#### Business logic steps (in order)
1. Validate request with OTPVerifySerializer (contact, otp_code)
2. Lookup most recent OTPVerification for (contact case-insensitive, otp_code)
3. If not found => 400 Invalid OTP
4. If is_blocked and blocked_until in future => 429
5. If already verified => 200 'OTP already verified'
6. If expired (is_expired_property true) => mark is_expired and return 400 'OTP expired'
7. Mark OTP verified: set is_verified=true, verified_at=now, clear failed_attempts/is_blocked/blocked_until
8. Auto-register user if no User exists for email==contact: create with unique username + unusable password
9. Ensure UserProfile exists and has email
10. Return 200 {success:true,message:'OTP verified',created_user:<bool>,data:<UserSerializer>}

#### DB operations (inferred)
- CREATE

#### Conditional logic & edge cases
- If not found => 400 Invalid OTP
- If is_blocked and blocked_until in future => 429
- If already verified => 200 'OTP already verified'
- If expired (is_expired_property true) => mark is_expired and return 400 'OTP expired'
- Auto-register user if no User exists for email==contact: create with unique username + unusable password
- Error condition: OTP not found
- Error condition: OTP temporarily blocked
- Error condition: OTP expired

#### Error cases & status codes
- **400** when OTP not found -> {success:false,message:'Invalid OTP'}
- **429** when OTP temporarily blocked -> {success:false,message:'OTP is temporarily blocked. Try later.'}
- **400** when OTP expired -> {success:false,message:'OTP expired'}

#### Shared helpers / utilities referenced
- `users.otp_views.OTPVerificationViewSet.verify_otp`
