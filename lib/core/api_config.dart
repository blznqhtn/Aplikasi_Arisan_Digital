class ApiConfig {
  static const String baseUrl = 'http://localhost/arisan_digitalv2/api_arisan';

  // Authentication endpoints
  static const String loginUrl = '$baseUrl/endpoints/pengelola/login.php';
  static const String registerUrl = '$baseUrl/endpoints/pengelola/register.php';

  // Pengelola (Admin) endpoints
  static const String homeUrl = '$baseUrl/endpoints/pengelola/home.php';
  static String getGroupsUrl(int userId) => '$homeUrl?user_id=$userId';
  static const String createGroupUrl = '$homeUrl';
  static const String updateGroupUrl = '$homeUrl';
  static const String deleteGroupUrl = '$homeUrl';

  // Group Details endpoints
  static const String groupDetailsUrl = '$baseUrl/endpoints/pengelola/group_details.php';
  static String getParticipantsUrl(int groupId) =>
      '$groupDetailsUrl?group_id=$groupId';
  static const String addParticipantUrl = '$groupDetailsUrl';
  static const String updatePaymentUrl = '$groupDetailsUrl';
  static const String deleteParticipantUrl = '$groupDetailsUrl';

  // History endpoints
  static const String historyUrl = '$baseUrl/endpoints/pengelola/history.php';
  static String getHistoryUrl(int groupId) => '$historyUrl?group_id=$groupId';
  
  // Gacha endpoints
  static const String gachaUrl = '$baseUrl/endpoints/pengelola/gacha.php';
}
