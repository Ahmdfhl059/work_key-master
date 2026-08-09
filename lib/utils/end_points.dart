class EndPoints {


  ///AUTH
  static final String signup = '/v1/citizen/register';
  static final String fcm = '/fcm-token';
  static final String login = '/v1/citizen/login';
  static final String verifyEmail = '/v1/citizen/verify';
  static final String resendVerifyEmail = '/v1/citizen/request-otp';
  static final String requestCode = '/password/requestCode';
  static final String forgotPassword = '/password/reset-with-code';
  static final String logout = '/logout';

  ///PROFILE
  static final String showProfile = "/profile";
  static final String updateProfile = "/update-profile";


  static final String indexAgencies = '/v1/agencies';
  static final String indexNotifications = '/v1/citizen/notifications';
  static final String indexComplaintLog = '/v1/complaints';
  static final String indexCities = '/v1/cities';
  static final String indexStates = '/v1/states';
  static final String indexComplaintType = '/v1/complaint-types/1';
  static final String registerComplaint=  "/v1/complaints";

}