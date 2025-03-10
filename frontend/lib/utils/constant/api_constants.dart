class ApiConstants {
  static const String baseUrl = 'http://localhost:5000';

  // Authentication endpoints
  static const String login = '$baseUrl/api/user/login';
  static const String register = '$baseUrl/api/user/register';
  static const String logout = '$baseUrl/api/user/logout';

  // User profile endpoint
  // Use HTTP GET to fetch, PUT/PATCH to update, and DELETE to remove the user profile.
  static const String profile = '$baseUrl/api/user/profile';
}
