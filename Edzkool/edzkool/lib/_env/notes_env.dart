import 'env.dart' as env;

class BaseUrl {
  // Environment mode & Base URL imported from env.dart (SINGLE SOURCE OF TRUTH)
  static const bool isDebug = env.BaseUrl.isDebug;
  static const String baseUrlApi = env.BaseUrl.baseUrlApi;
  static const String baseUrl = env.BaseUrl.baseUrl;

  // Notes API
  static const String notesApi = '$baseUrl/notes/';

  static const String authPath = '$baseUrl/auth/';
  static const String educationPath = '$baseUrl/education/';
  static const String universityPath = '$baseUrl/university/';
  static const String profilePath = '$baseUrl/profile/';
  static const String postBlog = '$baseUrl/blog/post/';
  static const String postBlogUpdate = '$baseUrl/blog/post/<int:id>';
  static const String postComment = '$baseUrl/blog/post/comment';
  static const String postCommentUpdate = '$baseUrl/blog/post/comment/<int:id>';
  static const String getallnotifications = '$baseUrl/auth/getallnotifications';
  static const String getoffernotifications =
      '$baseUrl/auth/getoffernotifications';

  // Auth APIs
  static const String authIndex = '$baseUrl/auth/';
  static const String register = '$baseUrl/auth/register';
  static const String verifyotp = '$baseUrl/auth/verify-otp/';
  static const String login = '$baseUrl/auth/login';
  static const String home = '$baseUrl/auth/home';
  static const String addQuestion = '$baseUrl/auth/add_question';
  static const String addNotification = '$baseUrl/auth/add_notification';
  static const String univSearch = '$baseUrl/auth/user/univsearch';
  static const String logout = '$baseUrl/auth/logout';
  static const String mood = '$baseUrl/auth/mood';
  static const String userUpdate = '$baseUrl/auth/user/';
  static const String userList = '$baseUrl/auth/user_list';
  static const String sendOtp = '$baseUrl/users/otp/create/';
  static const String tokenObtainPair = '$baseUrl/auth/token';
  static const String tokenRefresh = '$baseUrl/auth/token/refresh';
  static const String changePassword = '$baseUrl/auth/change_password/<int:pk>';
  static const String passwordReset = '$baseUrl/auth/password_reset';

  // Education APIs
  static const String profileEducation =
      '$baseUrlApi/api/v1/simple-education/education/update_education/';
  static const String getEducation =
      '$baseUrlApi/api/v1/simple-education/education/my_education/';

  // Work APIs
  static const String profileWork =
      '$baseUrlApi/api/v1/simple-education/work/update_work/';
  static const String getWork =
      '$baseUrlApi/api/v1/simple-education/work/my_work/';

  // Social APIs
  static const String profileSocial =
      '$baseUrlApi/api/v1/simple-education/social/update_social/';
  static const String getSocial =
      '$baseUrlApi/api/v1/simple-education/social/my_social/';
  static const String university = '$baseUrl/education/university';
  static const String universityList = '$baseUrl/universities/universities/';
  static const String universityStats =
      '$baseUrl/universities/universities/stats/';
  static const String analyticsOverview = '$baseUrl/analytics/api/overview/';
  static const String notificationsRecent =
      '$baseUrl/notifications/notifications/recent/';
  static const String notificationsUnread =
      '$baseUrl/notifications/notifications/unread/';
  static const String notificationsStats =
      '$baseUrl/notifications/notifications/stats/';
  static const String bookmarkUniversity =
      '$baseUrl/university/bookmarkUniversity';
  static const String course = '$baseUrl/university/courses/';
  static const String universityDetails = '$baseUrl/university/details';
  static const String courseDetails =
      '$baseUrl/university/course/details/<int:id>';
  static const String universityAbout = '$baseUrl/education/university/about/';

  static const String slot = '$baseUrl/education/slot/';
  static const String slotUpdate = '$baseUrl/education/slot/<int:id>';
  static const String mcqInitial = '$baseUrl/education/mcqinitial';
  static const String notification = '$baseUrl/education/notification';
  static const String notificationOffer =
      '$baseUrl/education/notification/offer';
  static const String teachContent = '$baseUrl/education/teachcontent';
  static const String bookmark = '$baseUrl/education/bookmark/';
  static const String bookmarkView = '$baseUrl/education/bookmarkview/';
  static const String galleryView = '$baseUrl/education/galaryview/<int:id>';
  static const String paymentView = '$baseUrl/education/payment/';
  static const String applicationPost = '$baseUrl/education/application/';
  static const String applicationPut =
      '$baseUrl/education/application/<int:id>';

  static const String applicationView = '$baseUrl/applications/applications/';
  static const String applicationViewId =
      '$baseUrl/applications/applications/<int:id>/';

  static const String viewallapplicationsubmit =
      '$baseUrl/applications/applications/';

  static const String universitydetailsdownload =
      '$baseUrl/university/downloadall';
  static const String universitiesscreen =
      '$baseUrl/university/universitiesscreen';
  static const String universityFeed = '$baseUrl/university/UniversitiesFeed';
  static const String universityCourse = '$baseUrl/university/courses';
  static const String universityImages = '$baseUrl/university/images';
  static const String universityFollowing =
      '$baseUrl/universities/universities/following/';

  static const String universityCheckFollowing =
      '$baseUrl/university/checkfollowing';
  static const String applicationSubmit =
      '$baseUrl/university/applicationsubmit/';
  static const String filtereduniversities =
      '$baseUrl/university/filtereduniversities/';
  static const String scholarships = '$baseUrl/university/scholarships/';

  static const String allCourses = '$baseUrl/courses/courses/';
  static const String coursesStats = '$baseUrl/courses/courses/stats/';

  static const String favouriteUniversities =
      '$baseUrl/bookmarks/universities/';
  static const String favouriteCourses = '$baseUrl/bookmarks/courses/';
  static const String addFavouriteUniversity =
      '$baseUrl/bookmarks/universities/';
  static const String addFavouriteCourse = '$baseUrl/bookmarks/courses/';

  static const String coursedetails = '$baseUrl/course/details';

  static const String notes = '$baseUrl/course/notes/';

  static const String getimages = '$baseUrl/course/getimages/';

  static const String profileEducationHigher =
      '$baseUrl/education/user-education/';
  static const String profileEducationSecondary =
      '$baseUrl/education/user-education/';
  static const String profileEducationLower =
      '$baseUrl/education/user-education/';

  static const String gallery = '$baseUrl/university';
  static const String universityentrance = '$gallery/universityentrance';
  static const String laboratory = '$gallery/laboratory';
  static const String lecturerooms = '$gallery/lecturerooms';
  static const String mcqQuestionOfTheDay = '$baseUrl/quizzes/questions/';
}
