import 'package:covid/Models/user_location.dart';
import 'package:location/location.dart';
import 'dart:async';

class LocationService {
  UserLocation _currentLocation;
  UserLocation _previousLocation;
  Location location = Location();

  StreamController<UserLocation> _locationController = StreamController<UserLocation>.broadcast();

  Stream<UserLocation> get locationStream => _locationController.stream;

  void requestLocationPermission() {
    location.requestPermission().then((granted) {
      if (granted == PermissionStatus.granted) {
        location.onLocationChanged.listen((locationData) {
          if (locationData != null) {
            UserLocation value = UserLocation(
              latitude: locationData.latitude,
              longitude: locationData.longitude,
            );
            _locationController.add(value);

            //if (value.latitude != _previousLocation.latitude || value.longitude != _previousLocation.longitude) {
            // Getting user location if the previous location data is different.
            //getUserLocation(value);
            // getServiceArea(value);
            //}
            //_previousLocation = value;
          }
        });
      }
    });
  }

  Future<UserLocation> getLocation() async {
    try {
      var userLocation = await location.getLocation();
      _currentLocation = UserLocation(
        latitude: userLocation.latitude,
        longitude: userLocation.longitude,
      );
    } catch (e) {
      print('Could not get the location: $e');
    }

    return _currentLocation;
  }
}
