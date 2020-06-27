import 'package:covid/Models/HomeDetails.dart';
import 'package:covid/core/services/api_services.dart';
import 'package:covid/locator.dart';
import 'package:stacked/stacked.dart';

class DashboardViewModel extends BaseViewModel {
  ApiService apiService = locator<ApiService>();
  HomeDetails homeDetails;

  Future<void> getHomeScreenDetail() async {
    setBusy(true);
    final response = await apiService.getHomeScreenDetail();
    if (response != null) {
      homeDetails = HomeDetails.fromJson(response);
    }
    // Getting geo fence
    final geofenceResponse = await apiService.getGeofenceForUser();
    if (geofenceResponse != null) {
      print(geofenceResponse);
    }
    setBusy(false);
  }
}
