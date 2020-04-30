import 'package:covid/App_localizations.dart';
import 'package:covid/Models/HomeDetails.dart';
import 'package:covid/Models/TextStyle.dart';
import 'package:covid/Models/config/Configure.dart';
import 'package:covid/Models/GetGeoLocationModel.dart';
import 'package:covid/Models/config/env.dart';
import 'package:covid/Models/util/DialogBox.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:covid/HomePage.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:convert' as JSON;

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
   DialogBox dialogBox = DialogBox();
  Configure _configure = new Configure();
  HomedetailsModel homeDetails = HomedetailsModel();
  String healthofficer;
  String healthupdate;
  String emergencycontactno;
  String officerno;
  bool issetlocationenabled;
  GetGeoLocationModel geoFenceLocationModel=GetGeoLocationModel();
  static double lastgeolat;
 static double lastegeolong;
  static double lat;
  static double long;
  Set<Marker> _createMarker() {
    return <Marker>[
      Marker(
          markerId: MarkerId('Home'),
          position: LatLng(lastgeolat==0.0||lastgeolat==null?position.latitude:lastgeolat,lastegeolong==0.0||lastegeolong==null? position.longitude:lastegeolong),
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

 
  

  Widget mapWidget() {
     Set<Circle> circles = Set.from([
    Circle(
      circleId: CircleId('${DateTime.now()}'),
      center:  LatLng(lastgeolat??100, lastegeolong??100),
      radius: 15,
      fillColor: Colors.redAccent.withOpacity(0.4),
      visible: true,
      //strokeColor: Colors.red,
      strokeWidth: 1
    ),
  ]);
    return GoogleMap(
      markers: _createMarker(),
      mapType: MapType.normal,
      initialCameraPosition: CameraPosition(
          target: LatLng(lastgeolat==0.0||lastgeolat==null?lat:lastgeolat,lastegeolong==0.0||lastegeolong==null?long:lastegeolong), zoom: 19.0),
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
  updateGeofence()async{
 SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('userId');
    _config = _configure.serverURL();
    var apiUrl = Uri.parse(_config.postman + '/updategeofence');
    // '/api/check?userName=$_username&checkName=$checkname&category=$category&description=$description&frequency=$frequency');
    var client = HttpClient(); // `new` keyword optional
    // 1. Create request
    try {
      HttpClientRequest request = await client.postUrl(apiUrl);
      request.headers.set('api-key', _config.apikey);
      request.headers.set('content-type', 'application/json; charset=utf-8');
      var payload = {
       
    "patientId":userId,
    "latitude":lat,
    "longitude":long,
    "geoFenceSet": true,
    "radius":ENV.RADIUS_GEOFENCE,
    "startDate":"${DateFormat('yyyy-MM-dd').format(DateTime.now())}",
    "endDate":"${DateFormat('yyyy-MM-dd').format(DateTime.now())}"

      };
      request.write(JSON.jsonEncode(payload));
      print(JSON.jsonEncode(payload));
      // 3. Send the request
      HttpClientResponse response = await request.close();
      // 4. Handle the response
      var resStream = response.transform(Utf8Decoder());

      await for (var data in resStream) {
        print('Received data: $data');
      }
    } catch (ex) {
      print('error $ex');
    }

  }
  Future<String> getJsondata() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('userId');
    _config = _configure.serverURL();
    String homeurl = _config.postman + "/homedetails?userId=$userId";
    String getgeolocationurl = _config.postman + "/getgeofence?patientId=$userId";
    var homedetailsresponse;
    var getgeolocationresponse;
    try {
      homedetailsresponse = await http.get(Uri.encodeFull(homeurl), headers: {
        "Accept": "*/*",
      });
      getgeolocationresponse = await http.get(Uri.encodeFull(getgeolocationurl), headers: {
        "Accept": "*/*",
      });
    } catch (ex) {
      print('error $ex');
    }
    if(homedetailsresponse.statusCode==200){
      setState(() {
      homeDetails = homedetailsModelFromJson(homedetailsresponse.body);
      geoFenceLocationModel=getGeoLocationModelFromJson(getgeolocationresponse.body);
      try{
      issetlocationenabled=geoFenceLocationModel.geoFenceData.first.geoFenceSet;
      lastgeolat=geoFenceLocationModel.geoFenceData.first.geoFenceLatitude;
      lastegeolong=geoFenceLocationModel.geoFenceData.first.geoFenceLongitude;
      }catch(ex){
       lastgeolat=position.latitude;
      lastegeolong=position.longitude;
      }
      
      healthofficer = homeDetails.homeDetails.firstname;
      officerno = homeDetails.homeDetails.emergencycontact1;
      healthupdate =
     homeDetails.homeDetails.requestdatetime!=null?DateFormat('yyyy-MM-dd h:mm a').format(DateTime.parse(homeDetails.homeDetails.requestdatetime).toLocal()):null;
      emergencycontactno = homeDetails.homeDetails.emergencycontact1;
    });
    }
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
                                          const EdgeInsets.only(bottom: 0),
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
                                      child: healthofficer != null 
                                          ? Text(
                                              '$healthofficer\n$officerno',
                                              style:
                                                  styletext.placeholderStyle(),
                                            )
                                          : Text('Not assigned',style: styletext
                                                    .placeholderStyle()),
                                    ),
                                  ),
                                  // ButtonBar(
                                  //   buttonPadding:
                                  //       EdgeInsets.only(top: 0, right: 8),
                                  //   children: <Widget>[
                                  //     FlatButton(
                                  //       child: Text(
                                  //         AppLocalizations.of(context)
                                  //             .translate('contact'),
                                  //         style: styletext.labelfont(),
                                  //       ),
                                  //       onPressed: () {/* ... */},
                                  //     ),
                                  //   ],
                                  // ),
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
                                                '$healthupdate',
                                                style: styletext
                                                    .placeholderStyle(),
                                              )
                                            : Text('No last update',style: styletext
                                                    .placeholderStyle()),
                                      ),
                                    ),
                                    // ButtonBar(
                                    //   buttonPadding: EdgeInsets.only(
                                    //       top: 0, right: 8, bottom: 0),
                                    //   children: <Widget>[
                                    //     FlatButton(
                                    //       child: Text(
                                    //           AppLocalizations.of(context)
                                    //               .translate('now-update'),
                                    //           style: styletext.labelfont()),
                                    //       onPressed: () {
                                    //         Navigator.pushReplacement(
                                    //             context,
                                    //             MaterialPageRoute(
                                    //               builder: (context) =>
                                    //                   HomePage(
                                    //                 type:
                                    //                     BottomNavigationDemoType
                                    //                         .withLabels,
                                    //                 navigationIndex: 1,
                                    //               ),
                                    //             ));
                                    //         /* ... */
                                    //       },
                                    //     ),
                                    //   ],
                                    // ),
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
                                        Text( AppLocalizations.of(context)
                                            .translate('em_contact')),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(top: 5),
                                      child: emergencycontactno != null
                                          ? new Text('$emergencycontactno')
                                          : new Text('-',style: styletext
                                                    .placeholderStyle()),
                                    ),
                                  ),
                                  // ButtonBar(
                                  //   buttonPadding:
                                  //       EdgeInsets.only(top: 0, right: 8),
                                  //   children: <Widget>[
                                  //     FlatButton(
                                  //       child: Text(
                                  //         AppLocalizations.of(context)
                                  //             .translate('contact'),
                                  //         style: styletext.labelfont(),
                                  //       ),
                                  //       onPressed: () {/* ... */},
                                  //     ),
                                  //   ],
                                  // ),
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
                                   issetlocationenabled==false?FlatButton(
                                       // disabledTextColor: Colors.grey,
                                        //color: Colors.grey,
                                       // textColor: Colors.grey,
                                        child: Text(
                                          AppLocalizations.of(context)
                                              .translate('location_button'),
                                          //style: styletext.labelfont()
                                          style: styletext.labelfont(),
                                        ),
                                        onPressed: ()async{
                                        await  updateGeofence();
                                        dialogBox.information(context, AppLocalizations.of(context).translate('setlocationpopuptitle'), AppLocalizations.of(context).translate('setlocationpopupmessage'));
                                        getJsondata();
                                        },
                                        // () {
                                        //   getCurrentLocation();
                                        //   /* ... */
                                        // },
                                      ):FlatButton(
                                         disabledTextColor: Colors.grey,
                                       // color: Colors.grey,
                                       textColor: Colors.grey,
                                       onPressed: (){},
                                       child: Text(
                                          AppLocalizations.of(context)
                                              .translate('location_button'),
                                              style: TextStyle(fontSize: 17),
                                          //style: styletext.labelfont()
                                         // style: styletext.labelfont(),
                                          
                                        ),
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
