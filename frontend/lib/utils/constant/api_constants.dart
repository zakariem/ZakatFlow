class ApiConstants {
  static const String baseUrl = 'http://localhost:8000';
  // static const String baseUrl = 'https://zakat-flow-backend.onrender.com';

  // Authentication endpoints
  static const String login = '$baseUrl/api/user/login';
  static const String register = '$baseUrl/api/user/register';
  static const String logout = '$baseUrl/api/user/logout';

  // User profile endpoint
  // Use HTTP GET to fetch, PUT/PATCH to update, and DELETE to remove the user profile.
  static const String profile = '$baseUrl/api/user/profile';

  // upload
  static const String upload = '$baseUrl/api/user/upload';

  //Agents
  static const String agents = '$baseUrl/api/user/agents';

  //Payments
  static const String payments = '$baseUrl/api/payments';
}
