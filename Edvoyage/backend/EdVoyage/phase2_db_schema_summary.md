# Phase 2 DB Schema Summary (from Django migrations)

**Source JSON:** `phase2_db_schema.json`

**Total models/tables:** 113

## App: `analytics` (11 models)

### `AnalyticsDashboard`

- **db_table**: `analytics_dashboards`
- **primary key**: `id`
- **columns**: 13
- **foreign keys**:
  - `created_by` -> `settings.AUTH_USER_MODEL`
- **one-to-one**: (none)
- **many-to-many**:
  - `shared_with` -> `settings.AUTH_USER_MODEL`

### `AnalyticsEvent`

- **db_table**: `analytics_events`
- **primary key**: `id`
- **columns**: 22
- **foreign keys**:
  - `user` -> `settings.AUTH_USER_MODEL`
- **one-to-one**: (none)
- **many-to-many**: (none)

### `AnalyticsExport`

- **db_table**: `analytics_exports`
- **primary key**: `id`
- **columns**: 15
- **foreign keys**:
  - `created_by` -> `settings.AUTH_USER_MODEL`
- **one-to-one**: (none)
- **many-to-many**: (none)

### `AnalyticsReport`

- **db_table**: `analytics_reports`
- **primary key**: `id`
- **columns**: 21
- **foreign keys**:
  - `created_by` -> `settings.AUTH_USER_MODEL`
- **one-to-one**: (none)
- **many-to-many**:
  - `shared_with` -> `settings.AUTH_USER_MODEL`

### `AnalyticsWidget`

- **db_table**: `analytics_widgets`
- **primary key**: `id`
- **columns**: 16
- **foreign keys**: (none)
- **one-to-one**: (none)
- **many-to-many**: (none)

### `EventType`

- **db_table**: `analytics_eventtype`
- **primary key**: `id`
- **columns**: 8
- **foreign keys**: (none)
- **one-to-one**: (none)
- **many-to-many**: (none)

### `PageType`

- **db_table**: `analytics_pagetype`
- **primary key**: `id`
- **columns**: 8
- **foreign keys**: (none)
- **one-to-one**: (none)
- **many-to-many**: (none)

### `PageView`

- **db_table**: `page_views`
- **primary key**: `id`
- **columns**: 22
- **foreign keys**:
  - `user` -> `settings.AUTH_USER_MODEL`
- **one-to-one**: (none)
- **many-to-many**: (none)

### `SessionType`

- **db_table**: `analytics_sessiontype`
- **primary key**: `id`
- **columns**: 8
- **foreign keys**: (none)
- **one-to-one**: (none)
- **many-to-many**: (none)

### `UserMetrics`

- **db_table**: `user_metrics`
- **primary key**: `id`
- **columns**: 17
- **foreign keys**:
  - `user` -> `settings.AUTH_USER_MODEL`
- **one-to-one**: (none)
- **many-to-many**: (none)

### `UserSession`

- **db_table**: `user_sessions`
- **primary key**: `id`
- **columns**: 21
- **foreign keys**:
  - `user` -> `settings.AUTH_USER_MODEL`
- **one-to-one**: (none)
- **many-to-many**: (none)

## App: `applications` (6 models)

### `Application`

- **db_table**: `applications_application`
- **primary key**: `id`
- **columns**: 22
- **foreign keys**:
  - `program` -> `universities.universityprogram`
  - `university` -> `universities.university`
  - `user` -> `settings.AUTH_USER_MODEL`
- **one-to-one**: (none)
- **many-to-many**: (none)

### `ApplicationCommunication`

- **db_table**: `applications_applicationcommunication`
- **primary key**: `id`
- **columns**: 17
- **foreign keys**:
  - `application` -> `applications.application`
- **one-to-one**: (none)
- **many-to-many**: (none)

### `ApplicationDocument`

- **db_table**: `applications_applicationdocument`
- **primary key**: `id`
- **columns**: 16
- **foreign keys**:
  - `application` -> `applications.application`
  - `verified_by` -> `settings.AUTH_USER_MODEL`
- **one-to-one**: (none)
- **many-to-many**: (none)

### `ApplicationFee`

- **db_table**: `applications_applicationfee`
- **primary key**: `id`
- **columns**: 14
- **foreign keys**:
  - `application` -> `applications.application`
- **one-to-one**: (none)
- **many-to-many**: (none)

### `ApplicationInterview`

- **db_table**: `applications_applicationinterview`
- **primary key**: `id`
- **columns**: 20
- **foreign keys**:
  - `application` -> `applications.application`
- **one-to-one**: (none)
- **many-to-many**: (none)

### `ApplicationStatus`

- **db_table**: `applications_applicationstatus`
- **primary key**: `id`
- **columns**: 7
- **foreign keys**:
  - `application` -> `applications.application`
  - `changed_by` -> `settings.AUTH_USER_MODEL`
- **one-to-one**: (none)
- **many-to-many**: (none)

## App: `bookmarks` (2 models)

### `FavouriteCourse`

- **db_table**: `bookmarks_favouritecourse`
- **primary key**: `id`
- **columns**: 5
- **foreign keys**:
  - `course` -> `courses.course`
- **one-to-one**: (none)
- **many-to-many**: (none)

### `FavouriteUniversity`

- **db_table**: `bookmarks_favouriteuniversity`
- **primary key**: `id`
- **columns**: 5
- **foreign keys**:
  - `university` -> `universities.university`
- **one-to-one**: (none)
- **many-to-many**: (none)

## App: `cavity` (7 models)

### `Comment`

- **db_table**: `cavity_comments`
- **primary key**: `id`
- **columns**: 9
- **foreign keys**:
  - `author` -> `settings.AUTH_USER_MODEL`
  - `parent_comment` -> `cavity.comment`
  - `post` -> `cavity.post`
- **one-to-one**: (none)
- **many-to-many**: (none)

### `CommentLike`

- **db_table**: `cavity_comment_likes`
- **primary key**: `id`
- **columns**: 4
- **foreign keys**:
  - `comment` -> `cavity.comment`
  - `user` -> `settings.AUTH_USER_MODEL`
- **one-to-one**: (none)
- **many-to-many**: (none)

### `Notification`

- **db_table**: `cavity_notifications`
- **primary key**: `id`
- **columns**: 9
- **foreign keys**:
  - `comment` -> `cavity.comment`
  - `post` -> `cavity.post`
  - `recipient` -> `settings.AUTH_USER_MODEL`
  - `sender` -> `settings.AUTH_USER_MODEL`
- **one-to-one**: (none)
- **many-to-many**: (none)

### `Post`

- **db_table**: `cavity_posts`
- **primary key**: `id`
- **columns**: 11
- **foreign keys**:
  - `author` -> `settings.AUTH_USER_MODEL`
- **one-to-one**: (none)
- **many-to-many**: (none)

### `PostLike`

- **db_table**: `cavity_post_likes`
- **primary key**: `id`
- **columns**: 4
- **foreign keys**:
  - `post` -> `cavity.post`
  - `user` -> `settings.AUTH_USER_MODEL`
- **one-to-one**: (none)
- **many-to-many**: (none)

### `PostShare`

- **db_table**: `cavity_post_shares`
- **primary key**: `id`
- **columns**: 5
- **foreign keys**:
  - `post` -> `cavity.post`
  - `user` -> `settings.AUTH_USER_MODEL`
- **one-to-one**: (none)
- **many-to-many**: (none)

### `UserFollow`

- **db_table**: `cavity_user_follows`
- **primary key**: `id`
- **columns**: 4
- **foreign keys**:
  - `follower` -> `settings.AUTH_USER_MODEL`
  - `following` -> `settings.AUTH_USER_MODEL`
- **one-to-one**: (none)
- **many-to-many**: (none)

## App: `chat` (7 models)

### `ChatNotification`

- **db_table**: `chat_notifications`
- **primary key**: `id`
- **columns**: 6
- **foreign keys**:
  - `message` -> `chat.message`
  - `user` -> `chat.chatuser`
- **one-to-one**: (none)
- **many-to-many**: (none)

### `ChatRoom`

- **db_table**: `chat_rooms`
- **primary key**: `id`
- **columns**: 6
- **foreign keys**:
  - `created_by` -> `chat.chatuser`
- **one-to-one**: (none)
- **many-to-many**: (none)

### `ChatRoomParticipant`

- **db_table**: `chat_room_participants`
- **primary key**: `id`
- **columns**: 7
- **foreign keys**:
  - `room` -> `chat.chatroom`
  - `user` -> `chat.chatuser`
- **one-to-one**: (none)
- **many-to-many**: (none)

### `ChatUser`

- **db_table**: `chat_users`
- **primary key**: `id`
- **columns**: 12
- **foreign keys**: (none)
- **one-to-one**:
  - `user` -> `settings.AUTH_USER_MODEL`
- **many-to-many**: (none)

### `Contact`

- **db_table**: `chat_contacts`
- **primary key**: `id`
- **columns**: 8
- **foreign keys**:
  - `contact` -> `chat.chatuser`
  - `user` -> `chat.chatuser`
- **one-to-one**: (none)
- **many-to-many**: (none)

### `Message`

- **db_table**: `chat_messages`
- **primary key**: `id`
- **columns**: 13
- **foreign keys**:
  - `reply_to` -> `chat.message`
  - `room` -> `chat.chatroom`
  - `sender` -> `chat.chatuser`
- **one-to-one**: (none)
- **many-to-many**: (none)

### `MessageStatus`

- **db_table**: `chat_message_status`
- **primary key**: `id`
- **columns**: 5
- **foreign keys**:
  - `message` -> `chat.message`
  - `user` -> `chat.chatuser`
- **one-to-one**: (none)
- **many-to-many**: (none)

## App: `content` (12 models)

### `Content`

- **db_table**: `content_content`
- **primary key**: `id`
- **columns**: 25
- **foreign keys**:
  - `author` -> `settings.AUTH_USER_MODEL`
  - `category` -> `content.contentcategory`
- **one-to-one**: (none)
- **many-to-many**: (none)

### `ContentAnalytics`

- **db_table**: `content_contentanalytics`
- **primary key**: `id`
- **columns**: 10
- **foreign keys**:
  - `content` -> `content.content`
  - `user` -> `settings.AUTH_USER_MODEL`
- **one-to-one**: (none)
- **many-to-many**: (none)

### `ContentBookmark`

- **db_table**: `content_contentbookmark`
- **primary key**: `id`
- **columns**: 5
- **foreign keys**:
  - `content` -> `content.content`
  - `user` -> `settings.AUTH_USER_MODEL`
- **one-to-one**: (none)
- **many-to-many**: (none)

### `ContentCategory`

- **db_table**: `content_contentcategory`
- **primary key**: `id`
- **columns**: 8
- **foreign keys**: (none)
- **one-to-one**: (none)
- **many-to-many**: (none)

### `ContentComment`

- **db_table**: `content_contentcomment`
- **primary key**: `id`
- **columns**: 10
- **foreign keys**:
  - `content` -> `content.content`
  - `parent` -> `content.contentcomment`
  - `user` -> `settings.AUTH_USER_MODEL`
- **one-to-one**: (none)
- **many-to-many**: (none)

### `ContentDownload`

- **db_table**: `content_contentdownload`
- **primary key**: `id`
- **columns**: 8
- **foreign keys**:
  - `content` -> `content.content`
  - `user` -> `settings.AUTH_USER_MODEL`
- **one-to-one**: (none)
- **many-to-many**: (none)

### `ContentRating`

- **db_table**: `content_contentrating`
- **primary key**: `id`
- **columns**: 8
- **foreign keys**:
  - `content` -> `content.content`
  - `user` -> `settings.AUTH_USER_MODEL`
- **one-to-one**: (none)
- **many-to-many**: (none)

### `ContentShare`

- **db_table**: `content_contentshare`
- **primary key**: `id`
- **columns**: 10
- **foreign keys**:
  - `content` -> `content.content`
  - `shared_by` -> `settings.AUTH_USER_MODEL`
  - `shared_with` -> `settings.AUTH_USER_MODEL`
- **one-to-one**: (none)
- **many-to-many**: (none)

### `ContentTag`

- **db_table**: `content_contenttag`
- **primary key**: `id`
- **columns**: 6
- **foreign keys**: (none)
- **one-to-one**: (none)
- **many-to-many**: (none)

### `ContentTagThrough`

- **db_table**: `content_contenttagthrough`
- **primary key**: `id`
- **columns**: 4
- **foreign keys**:
  - `content` -> `content.content`
  - `tag` -> `content.contenttag`
- **one-to-one**: (none)
- **many-to-many**: (none)

### `ContentView`

- **db_table**: `content_contentview`
- **primary key**: `id`
- **columns**: 9
- **foreign keys**:
  - `content` -> `content.content`
  - `user` -> `settings.AUTH_USER_MODEL`
- **one-to-one**: (none)
- **many-to-many**: (none)

### `Feed`

- **db_table**: `content_feed`
- **primary key**: `id`
- **columns**: 6
- **foreign keys**: (none)
- **one-to-one**: (none)
- **many-to-many**: (none)

## App: `courses` (7 models)

### `Course`

- **db_table**: `courses_course`
- **primary key**: `id`
- **columns**: 21
- **foreign keys**:
  - `university` -> `universities.university`
- **one-to-one**: (none)
- **many-to-many**:
  - `subjects` -> `courses.subject` (through `courses.CourseSubject`)

### `CourseApplication`

- **db_table**: `courses_courseapplication`
- **primary key**: `id`
- **columns**: 11
- **foreign keys**:
  - `course` -> `courses.course`
  - `reviewed_by` -> `settings.AUTH_USER_MODEL`
  - `user` -> `settings.AUTH_USER_MODEL`
- **one-to-one**: (none)
- **many-to-many**: (none)

### `CourseRating`

- **db_table**: `courses_courserating`
- **primary key**: `id`
- **columns**: 8
- **foreign keys**:
  - `course` -> `courses.course`
  - `user` -> `settings.AUTH_USER_MODEL`
- **one-to-one**: (none)
- **many-to-many**: (none)

### `CourseRequirement`

- **db_table**: `courses_courserequirement`
- **primary key**: `id`
- **columns**: 9
- **foreign keys**:
  - `course` -> `courses.course`
- **one-to-one**: (none)
- **many-to-many**: (none)

### `CourseSubject`

- **db_table**: `courses_coursesubject`
- **primary key**: `id`
- **columns**: 5
- **foreign keys**:
  - `course` -> `courses.course`
  - `subject` -> `courses.subject`
- **one-to-one**: (none)
- **many-to-many**: (none)

### `FeeStructure`

- **db_table**: `courses_feestructure`
- **primary key**: `id`
- **columns**: 14
- **foreign keys**: (none)
- **one-to-one**:
  - `course` -> `courses.course`
- **many-to-many**: (none)

### `Subject`

- **db_table**: `courses_subject`
- **primary key**: `id`
- **columns**: 8
- **foreign keys**: (none)
- **one-to-one**: (none)
- **many-to-many**: (none)

## App: `feed` (5 models)

### `Bookmark`

- **db_table**: `feed_bookmark`
- **primary key**: `id`
- **columns**: 4
- **foreign keys**:
  - `post` -> `feed.post`
  - `user` -> `settings.AUTH_USER_MODEL`
- **one-to-one**: (none)
- **many-to-many**: (none)

### `Comment`

- **db_table**: `feed_comment`
- **primary key**: `id`
- **columns**: 5
- **foreign keys**:
  - `post` -> `feed.post`
  - `user` -> `settings.AUTH_USER_MODEL`
- **one-to-one**: (none)
- **many-to-many**: (none)

### `FeedCategory`

- **db_table**: `feed_feedcategory`
- **primary key**: `id`
- **columns**: 2
- **foreign keys**: (none)
- **one-to-one**: (none)
- **many-to-many**: (none)

### `Like`

- **db_table**: `feed_like`
- **primary key**: `id`
- **columns**: 4
- **foreign keys**:
  - `post` -> `feed.post`
  - `user` -> `settings.AUTH_USER_MODEL`
- **one-to-one**: (none)
- **many-to-many**: (none)

### `Post`

- **db_table**: `feed_post`
- **primary key**: `id`
- **columns**: 5
- **foreign keys**:
  - `category` -> `feed.feedcategory`
  - `user` -> `settings.AUTH_USER_MODEL`
- **one-to-one**: (none)
- **many-to-many**: (none)

## App: `notes` (11 models)

### `Category`

- **db_table**: `notes_category`
- **primary key**: `id`
- **columns**: 2
- **foreign keys**: (none)
- **one-to-one**: (none)
- **many-to-many**: (none)

### `ClinicalCase`

- **db_table**: `notes_clinicalcase`
- **primary key**: `id`
- **columns**: 14
- **foreign keys**:
  - `category` -> `notes.category`
  - `doctor` -> `notes.doctor`
  - `subject` -> `notes.subject`
- **one-to-one**: (none)
- **many-to-many**: (none)

### `Doctor`

- **db_table**: `notes_doctor`
- **primary key**: `id`
- **columns**: 2
- **foreign keys**: (none)
- **one-to-one**: (none)
- **many-to-many**: (none)

### `Flashcard`

- **db_table**: `notes_flashcard`
- **primary key**: `id`
- **columns**: 7
- **foreign keys**:
  - `category` -> `notes.category`
  - `sub_subject` -> `notes.subsubject`
  - `subject` -> `notes.subject`
- **one-to-one**: (none)
- **many-to-many**: (none)

### `FlashcardImage`

- **db_table**: `notes_flashcardimage`
- **primary key**: `id`
- **columns**: 4
- **foreign keys**:
  - `flashcard` -> `notes.flashcard`
- **one-to-one**: (none)
- **many-to-many**: (none)

### `MCQ`

- **db_table**: `notes_mcq`
- **primary key**: `id`
- **columns**: 6
- **foreign keys**:
  - `category` -> `notes.category`
  - `subject` -> `notes.subject`
- **one-to-one**: (none)
- **many-to-many**: (none)

### `Option`

- **db_table**: `notes_option`
- **primary key**: `id`
- **columns**: 4
- **foreign keys**:
  - `question` -> `notes.question`
- **one-to-one**: (none)
- **many-to-many**: (none)

### `Question`

- **db_table**: `notes_question`
- **primary key**: `id`
- **columns**: 3
- **foreign keys**:
  - `mcq` -> `notes.mcq`
- **one-to-one**: (none)
- **many-to-many**: (none)

### `Subject`

- **db_table**: `notes_subject`
- **primary key**: `id`
- **columns**: 2
- **foreign keys**: (none)
- **one-to-one**: (none)
- **many-to-many**: (none)

### `SubSubject`

- **db_table**: `notes_subsubject`
- **primary key**: `id`
- **columns**: 3
- **foreign keys**:
  - `subject` -> `notes.subject`
- **one-to-one**: (none)
- **many-to-many**: (none)

### `Video`

- **db_table**: `notes_video`
- **primary key**: `id`
- **columns**: 8
- **foreign keys**:
  - `category` -> `notes.category`
  - `doctor` -> `notes.doctor`
  - `subject` -> `notes.subject`
- **one-to-one**: (none)
- **many-to-many**: (none)

## App: `notifications` (1 models)

### `Notification`

- **db_table**: `notifications`
- **primary key**: `id`
- **columns**: 6
- **foreign keys**: (none)
- **one-to-one**: (none)
- **many-to-many**: (none)

## App: `payments` (7 models)

### `Invoice`

- **db_table**: `invoices`
- **primary key**: `id`
- **columns**: 23
- **foreign keys**:
  - `subscription` -> `payments.subscription`
  - `transaction` -> `payments.paymenttransaction`
  - `user` -> `settings.AUTH_USER_MODEL`
- **one-to-one**: (none)
- **many-to-many**: (none)

### `PaymentGateway`

- **db_table**: `payment_gateways`
- **primary key**: `id`
- **columns**: 18
- **foreign keys**: (none)
- **one-to-one**: (none)
- **many-to-many**: (none)

### `PaymentLog`

- **db_table**: `payment_logs`
- **primary key**: `id`
- **columns**: 7
- **foreign keys**:
  - `gateway` -> `payments.paymentgateway`
  - `transaction` -> `payments.paymenttransaction`
- **one-to-one**: (none)
- **many-to-many**: (none)

### `PaymentMethod`

- **db_table**: `payment_methods`
- **primary key**: `id`
- **columns**: 20
- **foreign keys**:
  - `user` -> `settings.AUTH_USER_MODEL`
- **one-to-one**: (none)
- **many-to-many**: (none)

### `PaymentTransaction`

- **db_table**: `payment_transactions`
- **primary key**: `id`
- **columns**: 22
- **foreign keys**:
  - `payment_method` -> `payments.paymentmethod`
  - `user` -> `settings.AUTH_USER_MODEL`
- **one-to-one**: (none)
- **many-to-many**: (none)

### `Refund`

- **db_table**: `refunds`
- **primary key**: `id`
- **columns**: 15
- **foreign keys**:
  - `transaction` -> `payments.paymenttransaction`
  - `user` -> `settings.AUTH_USER_MODEL`
- **one-to-one**: (none)
- **many-to-many**: (none)

### `Subscription`

- **db_table**: `subscriptions`
- **primary key**: `id`
- **columns**: 21
- **foreign keys**:
  - `payment_method` -> `payments.paymentmethod`
  - `user` -> `settings.AUTH_USER_MODEL`
- **one-to-one**: (none)
- **many-to-many**: (none)

## App: `quizzes` (9 models)

### `Option`

- **db_table**: `quizzes_option`
- **primary key**: `id`
- **columns**: 6
- **foreign keys**:
  - `question` -> `quizzes.question`
- **one-to-one**: (none)
- **many-to-many**: (none)

### `Question`

- **db_table**: `quizzes_question`
- **primary key**: `id`
- **columns**: 10
- **foreign keys**:
  - `quiz` -> `quizzes.quiz`
- **one-to-one**: (none)
- **many-to-many**: (none)

### `Quiz`

- **db_table**: `quizzes_quiz`
- **primary key**: `id`
- **columns**: 18
- **foreign keys**:
  - `category` -> `quizzes.quizcategory`
  - `creator` -> `settings.AUTH_USER_MODEL`
- **one-to-one**: (none)
- **many-to-many**: (none)

### `QuizAnalytics`

- **db_table**: `quizzes_quizanalytics`
- **primary key**: `id`
- **columns**: 9
- **foreign keys**:
  - `quiz` -> `quizzes.quiz`
  - `user` -> `settings.AUTH_USER_MODEL`
- **one-to-one**: (none)
- **many-to-many**: (none)

### `QuizAttempt`

- **db_table**: `quizzes_quizattempt`
- **primary key**: `id`
- **columns**: 15
- **foreign keys**:
  - `quiz` -> `quizzes.quiz`
  - `user` -> `settings.AUTH_USER_MODEL`
- **one-to-one**: (none)
- **many-to-many**: (none)

### `QuizCategory`

- **db_table**: `quizzes_quizcategory`
- **primary key**: `id`
- **columns**: 8
- **foreign keys**: (none)
- **one-to-one**: (none)
- **many-to-many**: (none)

### `QuizResult`

- **db_table**: `quizzes_quizresult`
- **primary key**: `id`
- **columns**: 10
- **foreign keys**:
  - `question` -> `quizzes.question`
- **one-to-one**:
  - `attempt` -> `quizzes.quizattempt`
- **many-to-many**: (none)

### `QuizShare`

- **db_table**: `quizzes_quizshare`
- **primary key**: `id`
- **columns**: 10
- **foreign keys**:
  - `quiz` -> `quizzes.quiz`
  - `shared_by` -> `settings.AUTH_USER_MODEL`
  - `shared_with` -> `settings.AUTH_USER_MODEL`
- **one-to-one**: (none)
- **many-to-many**: (none)

### `QuizTimer`

- **db_table**: `quizzes_quiztimer`
- **primary key**: `id`
- **columns**: 10
- **foreign keys**: (none)
- **one-to-one**:
  - `attempt` -> `quizzes.quizattempt`
- **many-to-many**: (none)

## App: `simple_education` (3 models)

### `SimpleEducation`

- **db_table**: `simple_education_simpleeducation`
- **primary key**: `id`
- **columns**: 10
- **foreign keys**:
  - `user` -> `settings.AUTH_USER_MODEL`
- **one-to-one**: (none)
- **many-to-many**: (none)

### `SimpleSocial`

- **db_table**: `simple_education_simplesocial`
- **primary key**: `id`
- **columns**: 8
- **foreign keys**:
  - `user` -> `settings.AUTH_USER_MODEL`
- **one-to-one**: (none)
- **many-to-many**: (none)

### `SimpleWork`

- **db_table**: `simple_education_simplework`
- **primary key**: `id`
- **columns**: 8
- **foreign keys**:
  - `user` -> `settings.AUTH_USER_MODEL`
- **one-to-one**: (none)
- **many-to-many**: (none)

## App: `study_abroad` (6 models)

### `StudyAbroadApplication`

- **db_table**: `study_abroad_studyabroadapplication`
- **primary key**: `id`
- **columns**: 27
- **foreign keys**:
  - `program` -> `study_abroad.studyabroadprogram`
  - `reviewer` -> `settings.AUTH_USER_MODEL`
  - `user` -> `settings.AUTH_USER_MODEL`
- **one-to-one**: (none)
- **many-to-many**: (none)

### `StudyAbroadEvent`

- **db_table**: `study_abroad_studyabroadevent`
- **primary key**: `id`
- **columns**: 16
- **foreign keys**: (none)
- **one-to-one**: (none)
- **many-to-many**: (none)

### `StudyAbroadEventRegistration`

- **db_table**: `study_abroad_studyabroadeventregistration`
- **primary key**: `id`
- **columns**: 11
- **foreign keys**:
  - `event` -> `study_abroad.studyabroadevent`
  - `user` -> `settings.AUTH_USER_MODEL`
- **one-to-one**: (none)
- **many-to-many**: (none)

### `StudyAbroadExperience`

- **db_table**: `study_abroad_studyabroadexperience`
- **primary key**: `id`
- **columns**: 14
- **foreign keys**:
  - `program` -> `study_abroad.studyabroadprogram`
  - `user` -> `settings.AUTH_USER_MODEL`
- **one-to-one**: (none)
- **many-to-many**: (none)

### `StudyAbroadProgram`

- **db_table**: `study_abroad_studyabroadprogram`
- **primary key**: `id`
- **columns**: 37
- **foreign keys**: (none)
- **one-to-one**: (none)
- **many-to-many**: (none)

### `StudyAbroadResource`

- **db_table**: `study_abroad_studyabroadresource`
- **primary key**: `id`
- **columns**: 15
- **foreign keys**: (none)
- **one-to-one**: (none)
- **many-to-many**: (none)

## App: `timer` (5 models)

### `TimerBreak`

- **db_table**: `timer_timerbreak`
- **primary key**: `id`
- **columns**: 13
- **foreign keys**:
  - `timer_session` -> `timer.timersession`
- **one-to-one**: (none)
- **many-to-many**: (none)

### `TimerGoal`

- **db_table**: `timer_timergoal`
- **primary key**: `id`
- **columns**: 17
- **foreign keys**:
  - `user` -> `settings.AUTH_USER_MODEL`
- **one-to-one**: (none)
- **many-to-many**: (none)

### `TimerSession`

- **db_table**: `timer_timersession`
- **primary key**: `id`
- **columns**: 20
- **foreign keys**:
  - `user` -> `settings.AUTH_USER_MODEL`
- **one-to-one**: (none)
- **many-to-many**: (none)

### `TimerStatistics`

- **db_table**: `timer_timerstatistics`
- **primary key**: `id`
- **columns**: 19
- **foreign keys**:
  - `user` -> `settings.AUTH_USER_MODEL`
- **one-to-one**: (none)
- **many-to-many**: (none)

### `TimerTemplate`

- **db_table**: `timer_timertemplate`
- **primary key**: `id`
- **columns**: 17
- **foreign keys**:
  - `user` -> `settings.AUTH_USER_MODEL`
- **one-to-one**: (none)
- **many-to-many**: (none)

## App: `universities` (9 models)

### `Campus`

- **db_table**: `universities_campus`
- **primary key**: `id`
- **columns**: 21
- **foreign keys**:
  - `university` -> `universities.university`
- **one-to-one**: (none)
- **many-to-many**: (none)

### `Feed`

- **db_table**: `universities_feed`
- **primary key**: `id`
- **columns**: 7
- **foreign keys**:
  - `university` -> `universities.university`
- **one-to-one**: (none)
- **many-to-many**: (none)

### `University`

- **db_table**: `universities_university`
- **primary key**: `id`
- **columns**: 28
- **foreign keys**: (none)
- **one-to-one**: (none)
- **many-to-many**: (none)

### `UniversityFaculty`

- **db_table**: `universities_universityfaculty`
- **primary key**: `id`
- **columns**: 16
- **foreign keys**:
  - `university` -> `universities.university`
- **one-to-one**: (none)
- **many-to-many**: (none)

### `UniversityGallery`

- **db_table**: `universities_universitygallery`
- **primary key**: `id`
- **columns**: 10
- **foreign keys**: (none)
- **one-to-one**:
  - `university` -> `universities.university`
- **many-to-many**: (none)

### `UniversityPartnership`

- **db_table**: `universities_universitypartnership`
- **primary key**: `id`
- **columns**: 14
- **foreign keys**:
  - `university` -> `universities.university`
- **one-to-one**: (none)
- **many-to-many**: (none)

### `UniversityProgram`

- **db_table**: `universities_universityprogram`
- **primary key**: `id`
- **columns**: 17
- **foreign keys**:
  - `university` -> `universities.university`
- **one-to-one**: (none)
- **many-to-many**: (none)

### `UniversityRanking`

- **db_table**: `universities_universityranking`
- **primary key**: `id`
- **columns**: 12
- **foreign keys**:
  - `university` -> `universities.university`
- **one-to-one**: (none)
- **many-to-many**: (none)

### `UniversityResearch`

- **db_table**: `universities_universityresearch`
- **primary key**: `id`
- **columns**: 15
- **foreign keys**:
  - `university` -> `universities.university`
- **one-to-one**: (none)
- **many-to-many**: (none)

## App: `users` (5 models)

### `BiometricAuthentication`

- **db_table**: `users_biometricauthentication`
- **primary key**: `id`
- **columns**: 11
- **foreign keys**:
  - `user` -> `settings.AUTH_USER_MODEL`
- **one-to-one**: (none)
- **many-to-many**: (none)

### `OTPVerification`

- **db_table**: `users_otpverification`
- **primary key**: `id`
- **columns**: 16
- **foreign keys**:
  - `user` -> `settings.AUTH_USER_MODEL`
- **one-to-one**: (none)
- **many-to-many**: (none)

### `UserActivity`

- **db_table**: `users_useractivity`
- **primary key**: `id`
- **columns**: 8
- **foreign keys**:
  - `user` -> `settings.AUTH_USER_MODEL`
- **one-to-one**: (none)
- **many-to-many**: (none)

### `UserProfile`

- **db_table**: `users_userprofile`
- **primary key**: `id`
- **columns**: 22
- **foreign keys**: (none)
- **one-to-one**:
  - `user` -> `settings.AUTH_USER_MODEL`
- **many-to-many**: (none)

### `UserSession`

- **db_table**: `users_usersession`
- **primary key**: `id`
- **columns**: 18
- **foreign keys**:
  - `user` -> `settings.AUTH_USER_MODEL`
- **one-to-one**: (none)
- **many-to-many**: (none)
