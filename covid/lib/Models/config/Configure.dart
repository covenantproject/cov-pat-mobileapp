import 'package:flutter/services.dart';
import 'package:covid/Models/config/Config.dart';

class Configure
{
Config serverURL()
{
Config config = new Config();
config.postman="https://aws1.covn.in/covid_service/api";
//config.postman="https://ac8e41d9-d2d4-47e5-97cf-56161cace55d.mock.pstmn.io";
config.apikey="5e9471d055ec010029cb2bcb-5d3268cd0aa8776612763a6f321c7dff51";
config.api="http://blockchain.eastus.cloudapp.azure.com:8080/covid_service/api";
config.sit="https://ac8e41d9-d2d4-47e5-97cf-56161cace55d.mock.pstmn.io";
return config;
}
// Future<void> setup() async {
//   await initializeTimeZone();
//   final detroit = getLocation('America/Detroit');
//   final now = new TZDateTime.now(detroit);
// }


}