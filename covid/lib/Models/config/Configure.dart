import 'package:flutter/services.dart';
import 'package:covid/Models/config/Config.dart';

class Configure
{
Config serverURL()
{
Config config = new Config();
config.postman="https://ac8e41d9-d2d4-47e5-97cf-56161cace55d.mock.pstmn.io";
config.apikey="";
config.api="http://3.11.140.220:8086";
config.sit="http://blockchain.eastus.cloudapp.azure.com:8080/covid_service/covid";
return config;
}
// Future<void> setup() async {
//   await initializeTimeZone();
//   final detroit = getLocation('America/Detroit');
//   final now = new TZDateTime.now(detroit);
// }


}