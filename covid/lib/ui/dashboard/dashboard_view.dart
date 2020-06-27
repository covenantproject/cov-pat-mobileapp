import 'dart:collection';

import 'package:covid/App_localizations.dart';
import 'package:covid/Models/TextStyle.dart';
import 'package:covid/Models/user_location.dart';
import 'package:covid/core/services/api_services.dart';
import 'package:covid/core/services/location_services.dart';
import 'package:covid/locator.dart';
import 'package:covid/ui/dashboard/dashboard_viewmodel.dart';
import 'package:covid/ui/shared/debouncer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:stacked/stacked.dart';

class DashboardView extends StatefulWidget {
  @override
  _DashboardViewState createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  GoogleMapController mapController;
  TextStyleFormate styletext = TextStyleFormate();
  List<Marker> markers = <Marker>[];
  Set<Circle> circles = HashSet<Circle>();

  LatLng currentLatLng;
  UserLocation userLocation;
  bool loadedOnce = false;
  bool isAddressFetched = false;
  String healthofficer;
  String officerno;
  String healthupdate;
  String emergencycontactno;

  ApiService apiService = locator<ApiService>();
  LocationService locationService = locator<LocationService>();
  final _debouncer = Debouncer(delay: Duration(milliseconds: 300));

  @override
  void initState() {
    super.initState();
    checkLocationPermission();
  }

  void checkLocationPermission() async {
    Location location = new Location();
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        setState(() {
          loadedOnce = true;
        });
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.denied) {
        setState(() {
          loadedOnce = true;
        });
        return;
      }
    }

    _locationData = await location.getLocation();

    print(_locationData.toString());
    setState(() {
      userLocation = UserLocation(latitude: _locationData.latitude, longitude: _locationData.longitude);
      loadedOnce = true;
    });

    locationService.locationStream.listen((event) {
      setState(() {
        userLocation = UserLocation(latitude: event.latitude, longitude: event.longitude);
        markers.clear();
        LatLng latLng = LatLng(userLocation.latitude, userLocation.longitude);
        Marker marker = Marker(position: latLng, markerId: MarkerId('23'));
        markers.add(marker);
        mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: latLng, zoom: 17)));
      });
    });
  }

  Widget getMapWidget(BuildContext context) {
    return Container(
      child: !loadedOnce
          ? Container()
          : userLocation == null
              ? Container(
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text('Location Service Not Enabled'),
                      RaisedButton(
                        child: Text('Would you like to enable?'),
                        onPressed: () {
                          checkLocationPermission();
                        },
                      )
                    ],
                  ),
                )
              : Container(
                  height: 300,
                  width: MediaQuery.of(context).size.width,
                  child: GoogleMap(
                    gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
                      new Factory<OneSequenceGestureRecognizer>(
                        () => new EagerGestureRecognizer(),
                      ),
                    ].toSet(),
                    initialCameraPosition: CameraPosition(target: LatLng(userLocation.latitude, userLocation.longitude), zoom: 15.0),
                    onMapCreated: (GoogleMapController controller) {
                      mapController = controller;
                      LatLng latLng = LatLng(userLocation.latitude, userLocation.longitude);
                      Marker marker = Marker(position: latLng, markerId: MarkerId('23'));
                      markers.add(marker);
                      updateGoogleMapCircles();
                      //updateUserLocation(latLng, locationService, context);
                    },
                    circles: circles,
                    markers: Set<Marker>.of(markers),
                    // onCameraMove: (position) {
                    //   _debouncer.run(() async {
                    //     // updateUserLocation(LatLng(position.target.latitude, position.target.longitude), locationService, context);
                    //     setState(() {
                    //       markers.clear();
                    //       Marker marker = Marker(position: position.target, markerId: MarkerId('23'));
                    //       markers.add(marker);
                    //     });
                    //   });
                    // },
                  ),
                ),
    );
  }

  updateGeoFenceDetail(DashboardViewModel model) {
    var alertContext;
    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text(AppLocalizations.of(context).translate('cancel_button')),
      onPressed: () {
        Navigator.pop(alertContext);
      },
    );
    Widget confirmButton = FlatButton(
      child: Text(AppLocalizations.of(context).translate('confirmbutton')),
      onPressed: () async {
        Navigator.pop(alertContext);
        await model.updateFenceData(userLocation.latitude, userLocation.longitude);
        updateGoogleMapCircles();
        //await updateGeofence();
        //getCurrentLocation();
        //dialogBox.information(context, AppLocalizations.of(context).translate('setlocationpopuptitle'), AppLocalizations.of(context).translate('setlocationpopupmessage'));
        //getJsondata();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(AppLocalizations.of(context).translate('setlocationalertdialogTitle')),
      content: Text(AppLocalizations.of(context).translate('setlocationconfirmationmessage')),
      actions: [
        cancelButton,
        confirmButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        alertContext = dialogContext;
        return alert;
      },
    );
  }

  void updateGoogleMapCircles() {
    LatLng latLng = LatLng(userLocation.latitude, userLocation.longitude);
    setState(() {
      circles = Set.from([Circle(circleId: CircleId('${DateTime.now()}'), center: latLng, radius: 150, fillColor: Colors.redAccent.withOpacity(0.4), visible: true, strokeWidth: 1)]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<DashboardViewModel>.reactive(
        onModelReady: (DashboardViewModel model) async {
          print('Model Ready..');
          await model.getHomeScreenDetail();
          //updateGoogleMapCircles();
        },
        builder: (context, model, child) {
          return model.isBusy
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : SingleChildScrollView(
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
                                  padding: const EdgeInsets.only(bottom: 0),
                                  child: Icon(Icons.album),
                                ),
                                title: Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Text(
                                    AppLocalizations.of(context).translate('health_officer'),
                                    style: styletext.placeholderStyle(),
                                  ),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 5, right: 0),
                                  child: healthofficer != null
                                      ? Text(
                                          '$healthofficer\n$officerno',
                                          style: styletext.placeholderStyle(),
                                        )
                                      : Text('Not assigned', style: styletext.placeholderStyle()),
                                ),
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
                                  contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
                                  leading: Icon(Icons.album),
                                  title: Text(
                                    AppLocalizations.of(context).translate('last_health'),
                                    style: styletext.placeholderStyle(),
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 5, bottom: 0),
                                    child: healthupdate != null
                                        ? Text(
                                            '$healthupdate',
                                            style: styletext.placeholderStyle(),
                                          )
                                        : Text('No last update', style: styletext.placeholderStyle()),
                                  ),
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
                                title: Text(AppLocalizations.of(context).translate('em_contact')),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 5),
                                  child: emergencycontactno != null ? new Text('$emergencycontactno') : new Text('-', style: styletext.placeholderStyle()),
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
                                    AppLocalizations.of(context).translate('location'),
                                    style: styletext.placeholderStyle(),
                                  ),
                                ),
                                subtitle: Padding(padding: const EdgeInsets.only(top: 10, right: 10), child: getMapWidget(context)),
                              ),
                              ButtonBar(
                                children: <Widget>[
                                  model.issetlocationenabled == false
                                      ? FlatButton(
                                          // disabledTextColor: Colors.grey,
                                          //color: Colors.grey,
                                          // textColor: Colors.grey,
                                          child: Text(
                                            AppLocalizations.of(context).translate('location_button'),
                                            //style: styletext.labelfont()
                                            style: styletext.labelfont(),
                                          ),
                                          onPressed: () {
                                            updateGeoFenceDetail(model);
                                          },
                                          // () {
                                          //   getCurrentLocation();
                                          //   /* ... */
                                          // },
                                        )
                                      : FlatButton(
                                          disabledTextColor: Colors.grey,
                                          // color: Colors.grey,
                                          textColor: Colors.grey,
                                          onPressed: () {
                                            updateGeoFenceDetail(model);
                                          },
                                          child: Text(
                                            AppLocalizations.of(context).translate('location_button'),
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
                      ])),
                );
        },
        viewModelBuilder: () => DashboardViewModel());
  }
}
