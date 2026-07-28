class Config {
  static const String baseUrl = 'https://cabcs.onrender.com'; // Remplacez par l'adresse IP de votre serveur
  
  // Auth routes
  static const String loginUrl = '$baseUrl/api/auth/login';
  static const String registerUrl = '$baseUrl/api/auth/register';
  static const String refreshUrl = '$baseUrl/api/auth/refresh';
  static const String heartbeatUrl = '$baseUrl/api/auth/heartbeat';
  static const String logoutUrl = '$baseUrl/api/auth/logout';
  static const String meUrl = '$baseUrl/api/auth/me';
  static const String passwordUrl = '$baseUrl/api/auth/password';

  // Data routes
  static const String sermonsUrl = '$baseUrl/api/sermons';
  static const String eventsUrl = '$baseUrl/api/events';
  static const String postsUrl = '$baseUrl/api/posts';
  static const String filesUrl = '$baseUrl/api/files';
  static const String contactsUrl = '$baseUrl/api/contacts';
  static const String usersUrl = '$baseUrl/api/users';
  static const String donationsUrl = '$baseUrl/api/donations';
  static const String monetbilConfigUrl = '$baseUrl/api/donations/monetbil/config';
  static const String motDuPasteurUrl = '$baseUrl/api/mot_du_pasteur';
}
