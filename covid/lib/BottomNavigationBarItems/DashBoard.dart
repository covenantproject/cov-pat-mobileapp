import 'package:covid/App_localizations.dart';
import 'package:covid/Models/HomeDetails.dart';
import 'package:covid/Models/TextStyle.dart';
import 'package:covid/Models/config/Configure.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:covid/HomePage.dart';
import 'package:intl/intl.dart';

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
  int userId;
  Configure _configure = new Configure();
  HomedetailsModel homeDetails = HomedetailsModel();
  String healthofficer;
  String healthupdate;
  String emergencycontactno;
  String officerno;
  
  static double lat;
  static double long;
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
       position = res;
       prefs.setDouble('lat', position.latitude);
      prefs.setDouble('long', position.longitude);
     
      lat = prefs.getDouble('lat');
      long = prefs.getDouble('long');
      _map = mapWidget();
    });
  }

  Set<Circle> circles = Set.from([
    Circle(
      circleId: CircleId('${DateTime.now()}'),
      center: new LatLng(lat??100, long??100),
      radius: 50,

      fillColor: Colors.redAccent.withOpacity(0.4),
      visible: true,
      //strokeColor: Colors.red,
      strokeWidth: 1
    )
  ]);
  

  Widget mapWidget() {
    return GoogleMap(
      markers: _createMarker(),
      mapType: MapType.normal,
      initialCameraPosition: CameraPosition(
          target: LatLng(position.latitude, position.longitude), zoom: 17.0),
      onMapCreated: (GoogleMapController controller) {
        _googleMapController = controller;
      },
      circles: circles,
    );
  }

  @override
  void initState() {
    getJsondata();
    
    getCurrentLocation();
    super.initState();
  }

  Future<String> getJsondata() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('userId');
    _config = _configure.serverURL();
    String homeurl = _config.postman + "/homedetails?userId=$userId";
    var homedetailsresponse;
    try {
      homedetailsresponse = await http.get(Uri.encodeFull(homeurl), headers: {
        "Accept": "applicaton/json",
      });
    } catch (ex) {
      print('error $ex');
    }
    setState(() {
      homeDetails = homedetailsModelFromJson(homedetailsresponse.body);
      healthofficer = homeDetails.homeDetails.healthofficername;
      officerno = homeDetails.homeDetails.healthofficerno;
      healthupdate =
          DateFormat.yMMMd().format(homeDetails.homeDetails.lasthealthupdate);
      emergencycontactno = homeDetails.homeDetails.emergencyno;
    });
    return "Success";
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: homeDetails == null
            ? Center(
                child: Container(
                    padding: EdgeInsets.all(0),
                    child: Container(
                        child: const CircularProgressIndicator(
                      strokeWidth: 3,
                    ))),
              )
            : RefreshIndicator(
                onRefresh: getJsondata,
                child: homeDetails == null
                    ? ListView(
                        children: <Widget>[
                          Container(
                            // color: Colors.red,
                            height: MediaQuery.of(context).size.height / 1.4,
                            child: Align(
                              alignment: Alignment.center,
                              child:
                                  Text('Loading', style: styletext.emptylist()),
                            ),
                          ),
                        ],
                      )
                    : Center(
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
                                      padding:
                                          const EdgeInsets.only(bottom: 30),
                                      child: Icon(Icons.album),
                                    ),
                                    title: Padding(
                                      padding: const EdgeInsets.only(top: 10),
                                      child: Text(
                                        AppLocalizations.of(context)
                                            .translate('health_officer'),
                                        style: styletext.placeholderStyle(),
                                      ),
                                    ),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(
                                          top: 5, right: 0),
                                      child: healthofficer != null &&
                                              officerno != null
                                          ? Text(
                                              '$healthofficer\n$officerno' ??
                                                  '-',
                                              style:
                                                  styletext.placeholderStyle(),
                                            )
                                          : Text('-'),
                                    ),
                                  ),
                                  ButtonBar(
                                    buttonPadding:
                                        EdgeInsets.only(top: 0, right: 8),
                                    children: <Widget>[
                                      FlatButton(
                                        child: Text(
                                          AppLocalizations.of(context)
                                              .translate('contact'),
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
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 16.0, vertical: 0),
                                      leading: Icon(Icons.album),
                                      title: Text(
                                        AppLocalizations.of(context)
                                            .translate('last_health'),
                                        style: styletext.placeholderStyle(),
                                      ),
                                      subtitle: Padding(
                                        padding: const EdgeInsets.only(
                                            top: 5, bottom: 0),
                                        child: healthupdate != null
                                            ? Text(
                                                '$healthupdate' ?? '-',
                                                style: styletext
                                                    .placeholderStyle(),
                                              )
                                            : Text('-'),
                                      ),
                                    ),
                                    ButtonBar(
                                      buttonPadding: EdgeInsets.only(
                                          top: 0, right: 8, bottom: 0),
                                      children: <Widget>[
                                        FlatButton(
                                          child: Text(
                                              AppLocalizations.of(context)
                                                  .translate('now-update'),
                                              style: styletext.labelfont()),
                                          onPressed: () {
                                            Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      HomePage(
                                                    type:
                                                        BottomNavigationDemoType
                                                            .withLabels,
                                                    navigationIndex: 1,
                                                  ),
                                                ));
                                            /* ... */
                                          },
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
                                  ListTile(
                                    leading: Icon(Icons.album),
                                    title:
                                        Text('Your emergency contact number'),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(top: 5),
                                      child: emergencycontactno != null
                                          ? new Text('$emergencycontactno')
                                          : new Text('-'),
                                    ),
                                  ),
                                  ButtonBar(
                                    buttonPadding:
                                        EdgeInsets.only(top: 0, right: 8),
                                    children: <Widget>[
                                      FlatButton(
                                        child: Text(
                                          AppLocalizations.of(context)
                                              .translate('contact'),
                                          style: styletext.labelfont(),
                                        ),
                                        onPressed: () {/* ... */},
                                      ),
                                    ],
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
                                        AppLocalizations.of(context)
                                            .translate('location'),
                                        style: styletext.placeholderStyle(),
                                      ),
                                    ),
                                    subtitle: Padding(
                                        padding: const EdgeInsets.only(
                                            top: 10, right: 10),
                                        child:
                                        lat!=null&&long!=null?    Container(height: 300, child: _map):Container()
                                        //Image.network("https://s3.ap-southeast-1.amazonaws.com/cdn.deccanchronicle.com/sites/default/files/anna_salai_chennai_google_map.jpg"),
                                    ),
                                  ),
                                  ButtonBar(
                                    children: <Widget>[
                                      FlatButton(
                                       // disabledTextColor: Colors.grey,
                                        //color: Colors.grey,
                                       // textColor: Colors.grey,
                                        child: Text(
                                          AppLocalizations.of(context)
                                              .translate('location_button'),
                                          //style: styletext.labelfont()
                                          style: styletext.labelfont(),
                                        ),
                                        onPressed: (){},
                                        // () {
                                        //   getCurrentLocation();
                                        //   /* ... */
                                        // },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            )
                          ]),
                        ),
                      ),
              ));
  }
}
