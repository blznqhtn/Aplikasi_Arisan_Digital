import 'package:flutter/material.dart';

class RefreshManager {
  // Singleton pattern
  static final RefreshManager _instance = RefreshManager._internal();
  factory RefreshManager() => _instance;
  RefreshManager._internal();

  // Callback functions to refresh different screens
  Function? refreshHome;
  Function? refreshGroupDetails;
  Function? refreshHistory;
  Function? refreshGacha;

  // Method to trigger a refresh in all registered screens
  void refreshAll(BuildContext context) {
    if (refreshHome != null) refreshHome!();
    if (refreshGroupDetails != null) refreshGroupDetails!();
    if (refreshHistory != null) refreshHistory!();
    if (refreshGacha != null) refreshGacha!();

    // Show a confirmation message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Semua data berhasil diperbarui'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  // Register refresh callbacks for each screen
  void registerHomeRefresh(Function callback) {
    refreshHome = callback;
  }

  void registerGroupDetailsRefresh(Function callback) {
    refreshGroupDetails = callback;
  }

  void registerHistoryRefresh(Function callback) {
    refreshHistory = callback;
  }

  void registerGachaRefresh(Function callback) {
    refreshGacha = callback;
  }
}
