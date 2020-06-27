import 'package:covid/Models/GetGeoLocationModel.dart';
import 'package:covid/Models/HomeDetails.dart';
import 'package:covid/core/services/api_services.dart';
import 'package:covid/locator.dart';
import 'package:stacked/stacked.dart';

class DashboardViewModel extends BaseViewModel {
  ApiService apiService = locator<ApiService>();
  HomeDetails homeDetails;
  List<GeoFenceDatum> geoFenceList = [];
  bool issetlocationenabled = false;

  Future<void> getHomeScreenDetail() async {
    setBusy(true);
    final response = await apiService.getHomeScreenDetail();
    if (response != null) {
      homeDetails = HomeDetails.fromJson(response);
    }
    // Getting geo fence
    final geofenceResponse = await apiService.getGeofenceForUser();
    if (geofenceResponse != null) {
      var parsed = geofenceResponse as List<dynamic>;
      for (var geofence in parsed) {
        geoFenceList.add(GeoFenceDatum.fromJson(geofence));
      }
      issetlocationenabled = false;
      if (geoFenceList.length > 0) {
        GeoFenceDatum currentFenceInfo = geoFenceList.first;
        if (currentFenceInfo.geoFenceSet) {
          issetlocationenabled = true;
        }
      }
      print(geoFenceList);
    }
    setBusy(false);
  }

  Future<void> updateFenceData(double lat, double lng) async {
    await apiService.updateFenceData(lat, lng);
  }
}
