import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:arisan_digitalv2/core/api_config.dart';

class ApiService {
  // Generic POST request method
  static Future<Map<String, dynamic>> post(
      String url, Map<String, dynamic> body) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return decoded;
      } else {
        return {
          'status': 'error',
          'message': 'Gagal terhubung ke server. Status: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Terjadi kesalahan koneksi: $e'};
    }
  }

  // Generic GET request method
  static Future<Map<String, dynamic>> get(String url) async {
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return decoded;
      } else {
        return {
          'status': 'error',
          'message': 'Gagal terhubung ke server. Status: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Terjadi kesalahan koneksi: $e'};
    }
  }

  // Login Pengelola
  static Future<Map<String, dynamic>> login(
      String username, String password) async {
    return await post(ApiConfig.loginUrl, {
      'username': username,
      'password': password,
    });
  }

  // Register Pengelola
  static Future<Map<String, dynamic>> register(
      String username, String email, String password) async {
    return await post(ApiConfig.registerUrl, {
      'username': username,
      'email': email,
      'password': password,
    });
  }

  // --- Home Pengelola ---
  static Future<Map<String, dynamic>> getGroups(int userId) async {
    return await get(ApiConfig.getGroupsUrl(userId));
  }

  static Future<Map<String, dynamic>> createGroup(int userId, String groupName,
      int contribution, String startMonth, int participants) async {
    return await post(ApiConfig.createGroupUrl, {
      'action': 'create',
      'user_id': userId,
      'group_name': groupName,
      'contribution_amount': contribution,
      'start_month': startMonth,
      'total_participants': participants,
    });
  }

  static Future<Map<String, dynamic>> updateGroup(
      int userId, int groupId, String groupName) async {
    return await post(ApiConfig.updateGroupUrl, {
      'action': 'update',
      'user_id': userId,
      'group_id': groupId,
      'group_name': groupName,
    });
  }

  static Future<Map<String, dynamic>> deleteGroup(
      int userId, int groupId) async {
    return await post(ApiConfig.deleteGroupUrl, {
      'action': 'delete',
      'user_id': userId,
      'group_id': groupId,
    });
  }

  // --- Gacha Pengelola ---
  static Future<Map<String, dynamic>> checkArisanStatus(int groupId) async {
    return await post('${ApiConfig.baseUrl}/gachapengelola.php', {
      'action': 'check_status',
      'group_id': groupId,
    });
  }

  static Future<Map<String, dynamic>> getEligibleParticipants(
      int groupId, int currentMonth) async {
    return await get(
        '${ApiConfig.baseUrl}/gachapengelola.php?group_id=$groupId&current_month=$currentMonth');
  }

  static Future<Map<String, dynamic>> recordWinner(
      int groupId, int participantId, int currentMonth) async {
    return await post('${ApiConfig.baseUrl}/gachapengelola.php', {
      'action': 'record_winner',
      'group_id': groupId,
      'participant_id': participantId,
      'current_month': currentMonth,
    });
  }

  // --- Group Details Pengelola ---
  static Future<Map<String, dynamic>> getParticipants(int groupId) async {
    return await get(ApiConfig.getParticipantsUrl(groupId));
  }

  static Future<Map<String, dynamic>> addParticipant(
      int groupId, String name, String password) async {
    return await post(ApiConfig.addParticipantUrl, {
      'action': 'add',
      'group_id': groupId,
      'name': name,
      'password': password,
    });
  }

  static Future<Map<String, dynamic>> deleteParticipant(
      int groupId, int participantId) async {
    return await post(ApiConfig.deleteParticipantUrl, {
      'action': 'delete',
      'group_id': groupId,
      'participant_id': participantId,
    });
  }

  static Future<Map<String, dynamic>> checkDrawDate(int groupId) async {
    return await get(
        '${ApiConfig.gachaUrl}?group_id=$groupId&check_draw_date=true');
  }

  static Future<Map<String, dynamic>> setDrawDate(
      int groupId, String drawDate, int currentMonth) async {
    return await post(ApiConfig.gachaUrl, {
      'action': 'set_draw_date',
      'group_id': groupId,
      'draw_date': drawDate,
      'current_month': currentMonth,
    });
  }

  // --- History Pengelola ---
  static Future<Map<String, dynamic>> getHistory(int groupId) async {
    return await get(
        '${ApiConfig.historyUrl}?group_id=$groupId');
  }

  static Future<Map<String, dynamic>> recordWinnerFromHistory(
      int groupId, int participantId, int monthNumber) async {
    return await post(ApiConfig.historyUrl, {
      'action': 'record_winner',
      'group_id': groupId,
      'participant_id': participantId,
      'month': monthNumber,
    });
  }

  static Future<Map<String, dynamic>> advanceMonth(int groupId) async {
    return await post(ApiConfig.historyUrl, {
      'action': 'advance_month',
      'group_id': groupId,
    });
  }

  // --- Peserta ---
  static Future<Map<String, dynamic>> loginParticipant(
      String name, String password) async {
    return await post(ApiConfig.groupDetailsUrl, {
      'action': 'login_participant',
      'name': name,
      'password': password,
    });
  }

  static Future<Map<String, dynamic>> getParticipantPayments(
      int groupId, int participantId) async {
    return await get(
        '${ApiConfig.baseUrl}/endpoints/peserta/group_details.php?action=get_participant_payments&group_id=$groupId&participant_id=$participantId');
  }

  static Future<Map<String, dynamic>> getWinnersHistory(int groupId) async {
    return await get(
        '${ApiConfig.baseUrl}/endpoints/peserta/group_details.php?action=get_winners_history&group_id=$groupId');
  }

  static Future<Map<String, dynamic>> updatePayment(
      int groupId, int participantId,
      [String actionType = 'update_payment']) async {
    return await post(ApiConfig.updatePaymentUrl, {
      'action': actionType,
      'group_id': groupId,
      'participant_id': participantId,
    });
  }
}
