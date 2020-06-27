import 'package:covid/core/services/api_services.dart';
import 'package:covid/core/services/location_services.dart';
import 'package:covid/core/services/preferences_services.dart';
import 'package:get_it/get_it.dart';

GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton(() => ApiService());
  locator.registerLazySingleton(() => PreferencesService());
  locator.registerLazySingleton(() => LocationService());
}
