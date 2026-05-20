import 'package:flutter/material.dart';
import 'package:arisan_digitalv2/services/api_service.dart';

class GroupProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _groups = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<Map<String, dynamic>> get groups => _groups;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> fetchGroups(int userId) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final data = await ApiService.getGroups(userId);

      if (data['status'] == 'success' && data['data'] != null) {
        _groups = List<Map<String, dynamic>>.from(data['data']);
      } else {
        _errorMessage = data['message'] ?? 'Gagal memuat data grup';
      }
    } catch (e) {
      _errorMessage = 'Koneksi error: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Helper method to refresh without showing loading indicator
  Future<void> refreshGroupsSilent(int userId) async {
    try {
      final data = await ApiService.getGroups(userId);
      if (data['status'] == 'success' && data['data'] != null) {
        _groups = List<Map<String, dynamic>>.from(data['data']);
        notifyListeners();
      }
    } catch (e) {
      // Ignore silent errors
    }
  }
}
