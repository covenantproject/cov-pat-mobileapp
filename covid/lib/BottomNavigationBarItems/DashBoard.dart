import 'package:covid/Models/HomeDetails.dart';
import 'package:covid/Models/TextStyle.dart';
import 'package:covid/Models/config/Configure.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class DashBoard extends StatefulWidget {
  const DashBoard({Key key}) : super(key: key);

  @override
  _DashBoardState createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> with TickerProviderStateMixin {
  TextStyleFormate styletext = TextStyleFormate();
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  GoogleMapController _googleMapController;
  Position position = Position();
  Widget _map;
  var _config;
  Configure _configure = new Configure();
  HomeDetails homeDetails=HomeDetails();
  Set<Marker> _createMarker() {
    return <Marker>[
      Marker(
          markerId: MarkerId('Home'),
          position: LatLng(position.latitude, position.longitude),
          icon: BitmapDescriptor.defaultMarker,
          infoWindow: InfoWindow(title: "Home"))
    ].toSet();
  }

  void getCurrentLocation() async {
    Position res = await Geolocator().getCurrentPosition();
     SharedPreferences prefs = await _prefs;
    setState(() {
     prefs.setDouble('lat', position.latitude);
     prefs.setDouble('long', position.longitude);
      position = res;
      _map=mapWidget();
    });
  }

  Widget mapWidget() {
    return GoogleMap(
      markers: _createMarker(),
      mapType: MapType.normal,
      initialCameraPosition: CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 15.0),
      onMapCreated: (GoogleMapController controller) {
        _googleMapController = controller;
      },
    );
  }

  @override
  void initState() {
   // getJsondata();
    getCurrentLocation();
    Future.delayed(const Duration(seconds: 2), () {});
    super.initState();
  }
Future<String> getJsondata() async { 
  _config = _configure.serverURL();
    String homeurl = _config.sit +
        "/homedetails?userId=21";
    var homedetailsresponse;
    try {
      homedetailsresponse =
          await http.get(Uri.encodeFull(homeurl), headers: {
        "Accept": "applicaton/json",
      });

      
    } catch (ex) {
      print('error $ex');
    }
    setState(() {
      homeDetails = homeDetailsFromJson(homedetailsresponse.body);
    
    });
    return "Success";
  }
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Column(children: <Widget>[
            Card(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ListTile(
                    dense: true,
                    leading: Padding(
                      padding: const EdgeInsets.only(bottom: 30),
                      child: Icon(Icons.album),
                    ),
                    title: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        'Your health officer',
                        style: styletext.placeholderStyle(),
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 5, right: 0),
                      child: Text(
                        '${homeDetails.healthofficername}\n${homeDetails.healthofficerno}'??' ',
                        style: styletext.placeholderStyle(),
                      ),
                    ),
                  ),
                  ButtonBar(
                    buttonPadding: EdgeInsets.only(top: 0, right: 8),
                    children: <Widget>[
                      FlatButton(
                        child: Text(
                          'CONTACT',
                          style: styletext.labelfont(),
                        ),
                        onPressed: () {/* ... */},
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              child: Card(
                semanticContainer: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ListTile(
                      dense: true,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
                      leading: Icon(Icons.album),
                      title: Text(
                        'Your last health update',
                        style: styletext.placeholderStyle(),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 5, bottom: 0),
                        child: Text(
                          ''??' ',
                          style: styletext.placeholderStyle(),
                        ),
                      ),
                    ),
                    ButtonBar(
                      buttonPadding:
                          EdgeInsets.only(top: 0, right: 8, bottom: 0),
                      children: <Widget>[
                        FlatButton(
                          child:
                              Text('UPDATE NOW', style: styletext.labelfont()),
                          onPressed: () {/* ... */},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Card(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const ListTile(
                    leading: Icon(Icons.album),
                    title: Text('Your emergency contact number'),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Text(""),
                    ),
                  ),
                ],
              ),
            ),
            Card(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ListTile(
                    dense: true,
                    leading: Icon(Icons.album),
                    title: Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        'Your current location',
                        style: styletext.placeholderStyle(),
                      ),
                    ),
                    subtitle: Padding(
                        padding: const EdgeInsets.only(top: 10, right: 10),
                        child: Container(height: 300, child: _map)
                        //Image.network("https://s3.ap-southeast-1.amazonaws.com/cdn.deccanchronicle.com/sites/default/files/anna_salai_chennai_google_map.jpg"),
                        ),
                  ),
                  ButtonBar(
                    children: <Widget>[
                      FlatButton(
                        child: Text('CHANGE LOCATION',
                            style: styletext.labelfont()),
                        onPressed: () {
                          getCurrentLocation();
                          /* ... */
                        },
                      ),
                    ],
                  ),
                ],
              ),
            )
          ]),
        ),
      ),
    );
  }
}
