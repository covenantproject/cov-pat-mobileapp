import 'package:covid/core/services/preferences_services.dart';
import 'package:covid/locator.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const endPoint = 'https://aws1.covn.in/covid_service/api';
  static const api_key = '5e9471d055ec010029cb2bcb-5d3268cd0aa8776612763a6f321c7dff51';

  Dio client = new Dio();
  PreferencesService preferencesService = locator<PreferencesService>();

  ApiService() {
    updateClientInfo();
  }

  Future updateClientInfo() async {
    client.options.baseUrl = endPoint;
    client.options.headers['api-key'] = api_key;
    client.options.headers['Accept'] = '*/*';
  }

  Future<dynamic> getHomeScreenDetail() async {
    int userId = await preferencesService.getUserId();
    try {
      var response = await client.get('$endPoint/homedetails', queryParameters: {'userId': userId});
      if (response.statusCode == 200) {
        if (response.data['homeDetails'] != null) {
          var parsed = await response.data['homeDetails'];
          return parsed;
        }
        return null;
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<dynamic> getGeofenceForUser() async {
    int userId = await preferencesService.getUserId();
    try {
      var response = await client.get('$endPoint/getgeofence', queryParameters: {'patientId': userId});
      if (response.statusCode == 200) {
        // if (response.data['homeDetails'] != null) {
        //   var parsed = await response.data['homeDetails'];
        //   return parsed;
        // }
        return null;
      }
    } catch (e) {
      print(e.toString());
    }
  }
}
