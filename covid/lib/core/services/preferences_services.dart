import 'dart:async';

import 'package:frideos_core/frideos_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  StreamController<int> customerIdController = StreamController<int>();

  Stream<int> get customerId => customerIdController.stream;
  //
  final StreamedValue mobileNumber = StreamedValue<String>(initialData: '');
  final StreamedValue isOPTVisible = StreamedValue<bool>(initialData: false);

  PreferencesService() {
    updateCustomerIdStream();
  }

  void updateCustomerIdStream() async {
    final customerId = await getUserId();
    customerIdController.add(customerId);
  }

  // Check if the user is logged In
  Future<bool> isUserLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userid = prefs.getString('userId');
    if (userid != null && userid != '') {
      return true;
    }
    return false;
  }

  // Get logged in user id
  Future<int> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int userid = prefs.getInt('userId');
    if (userid != null) {
      return userid;
    }
    return -1;
  }

  Future<String> getUserInfo(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userid = prefs.getString(key);
    if (userid != null && userid != '') {
      return userid;
    }
    return '';
  }

  Future<bool> setUserInfo(String key, String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
    return true;
  }
}
