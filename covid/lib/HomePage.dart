// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'dart:async';
import 'package:covid/App_localizations.dart';
import 'package:covid/Models/GetGeoLocationModel.dart';
import 'package:covid/ui/dashboard/dashboard_view.dart';
import 'dart:convert';
import 'dart:io';
import 'package:vector_math/vector_math.dart' as math;
import 'dart:math';
import 'package:tuple/tuple.dart';
import 'dart:convert' as JSON;
import 'package:background_fetch/background_fetch.dart';
import 'package:covid/BottomNavigationBarItems/DashBoard.dart';
import 'package:covid/BottomNavigationBarItems/HistoryPage.dart';
import 'package:covid/BottomNavigationBarItems/RaiseHands.dart';
import 'package:covid/BottomNavigationBarItems/Profile.dart';
import 'package:covid/Models/HomeDetails.dart';
import 'package:covid/Models/TextStyle.dart';
import 'package:covid/Models/config/Configure.dart';
import 'package:covid/BottomNavigationBarItems/UpdateHealthInfo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:covid/Models/config/shared_events.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
//     as bg;

enum BottomNavigationDemoType {
  withLabels,
  withoutLabels,
}

class HomePage extends StatefulWidget {
  const HomePage({Key key, @required this.type, this.navigationIndex}) : super(key: key);

  final BottomNavigationDemoType type;
  final int navigationIndex;

  @override
  State createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin, TickerProviderStateMixin<HomePage>, WidgetsBindingObserver {
  LatLng center;
  String _identifier;
  double _radius = 15.0;
  int userId;
  int _status;
  GetGeoLocationModel geoFenceLocationModel = GetGeoLocationModel();
  bool _notifyOnEntry = true;
  bool _notifyOnExit = true;
  bool _notifyOnDwell = true;
  var _config;
  double lastgeolat;
  double lastgeolong;
  int _loiteringDelay = 10000;
  int _currentIndex = 0;
  TextStyleFormate styletext = TextStyleFormate();
  TabController _tabController;
  List<_NavigationIconView> _navigationViews;
  List<Event> events = new List<Event>();
  bool _isMoving;
  bool _enabled;
  String _motionActivity;
  Configure _configure = new Configure();
  String _odometer;
  String orgname;
  String username;
  HomeDetails homeDetails;
  Position position = Position();
  double currentlat;
  double currentlong;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  Future getCurrentLocation() async {
    Position res = await Geolocator().getCurrentPosition();
    SharedPreferences prefs = await _prefs;
    setState(() {
      prefs.setDouble('lat', position.latitude);
      prefs.setDouble('long', position.longitude);
      position = res;
      currentlat = position.latitude;
      currentlong = position.longitude;
    });
    //_addgeofence();
  }

  checkinorout() async {
    await getCurrentLocation();
    await getquarantinelocationdata();
    final result = distance(lastgeolat, currentlat, lastgeolong, currentlong, 15);
    print('${result.item1} Meters');
    if (result.item2) {
      print('IN');
      if (lastgeolat != 0.0) {
        updatelocation(1, currentlat, currentlong, "GEOFENCE_ENTER");
      }
      //ongeofencecross('ENTER');

    } else {
      if (lastgeolat != 0.0) {
        print('OUT');
        ongeofencecross('EXIT');
        updatelocation(1, currentlat, currentlong, "GEOFENCE_EXIT");
      }
    }
    if (result.item1 >= 1000) {
      updatelocation(1, currentlat, currentlong, "GEOFENCE_FAR");
    }
  }

  Tuple2<double, bool> distance(double quarantineLatitude, double currentLatitude, double quarantineLongitude, double currentLongitude, int radius) {
    // The math module contains a function
    // named radians which converts from
    // degrees to radians.
    quarantineLongitude = math.radians(quarantineLongitude);
    currentLongitude = math.radians(currentLongitude);
    quarantineLatitude = math.radians(quarantineLatitude);
    currentLatitude = math.radians(currentLatitude);

    // Haversine formula
    double dlon = currentLongitude - quarantineLongitude;
    double dlat = currentLatitude - quarantineLatitude;

    double a = pow(sin(dlat / 2), 2) + cos(quarantineLatitude) * cos(currentLatitude) * pow(sin(dlon / 2), 2);

    double c = 2 * asin(sqrt(a));

    // Radius of earth in kilometers. Use 3956
    // for miles
    double r = 6371;

    // calculate the result in meters
    double distance = (c * r) * 1000;

    bool isIn = false;
    if (distance <= radius) {
      isIn = true;
    }

    return new Tuple2(distance, isIn);
  }

  Future<String> getquarantinelocationdata() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('userId');
    _config = _configure.serverURL();
    String getgeolocationurl = _config.postman + "/getgeofence?patientId=$userId";
    // var homedetailsresponse;
    var getgeolocationresponse;
    try {
      getgeolocationresponse = await http.get(Uri.encodeFull(getgeolocationurl), headers: {"Accept": "*/*", "api-key": _config.apikey});
    } catch (ex) {
      print('error $ex');
    }
    if (getgeolocationresponse.statusCode == 200) {
      setState(() {
        geoFenceLocationModel = getGeoLocationModelFromJson(getgeolocationresponse.body);
        try {
          // issetlocationenabled=geoFenceLocationModel.geoFenceData.first.geoFenceSet;
          lastgeolat = geoFenceLocationModel.geoFenceData.first.geoFenceLatitude;
          lastgeolong = geoFenceLocationModel.geoFenceData.first.geoFenceLongitude;
        } catch (ex) {}
      });
    }
    return "Success";
  }

  Future updatelocation(int patientid, double lat, double long, String code) async {
    _config = _configure.serverURL();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('userId');
    var apiUrl = Uri.parse(_config.postman + '/locationHistory');
    var client = HttpClient();
    // `new` keyword optional
    // 1. Create request
    try {
      HttpClientRequest request = await client.postUrl(apiUrl);
      request.headers.set('api-key', _config.apikey);
      request.headers.set('content-type', 'application/json; charset=utf-8');
      var payload = {"userId": userId, "latitude": "$lat", "longitude": "$long", "code": "$code"};
      request.write(JSON.jsonEncode(payload));
      print(JSON.jsonEncode(payload));
      // 3. Send the request
      HttpClientResponse response = await request.close();
      // 4. Handle the response
      var resStream = response.transform(Utf8Decoder());
      await for (var data in resStream) {
        print('Received data: $data');
      }
      setState(() {
        // statusCode = response.statusCode;
      });
    } catch (ex) {
      print('error $ex');
    }
  }

  // Configure BackgroundFetch (not required by BackgroundGeolocation).
  Future _configureBackgroundFetch() async {
    BackgroundFetch.configure(
        BackgroundFetchConfig(minimumFetchInterval: 10, startOnBoot: true, stopOnTerminate: false, enableHeadless: true, requiresStorageNotLow: false, requiresBatteryNotLow: false, requiresCharging: false, requiresDeviceIdle: false, requiredNetworkType: NetworkType.NONE),
        (String taskId) async {
      print("[BackgroundFetch] received event $taskId");
      updatelocation(1, currentlat, currentlong, "HEARTBEAT");
      checkinorout();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int count = 0;
      if (prefs.get("fetch-count") != null) {
        count = prefs.getInt("fetch-count");
      }
      prefs.setInt("fetch-count", ++count);
      print('[BackgroundFetch] count: $count');

      if (taskId == 'flutter_background_fetch') {
        // Test scheduling a custom-task in fetch event.
        // BackgroundFetch.scheduleTask(TaskConfig(
        //     taskId: "com.transistorsoft.customtask",
        //     delay: 5000,
        //     periodic: false,
        //     forceAlarmManager: true,
        //     stopOnTerminate: false,
        //     enableHeadless: true));
      }

      BackgroundFetch.finish(taskId);
    }).then((int status) {
      print('[BackgroundFetch] configure success: $status');
      setState(() {
        // _status = status;
        //print('');
      });
    }).catchError((e) {
      print('[BackgroundFetch] configure ERROR: $e');
      setState(() {
        //  _status = e;
        // print(e);
      });
    });
    // Optionally query the current BackgroundFetch status.
    int status = await BackgroundFetch.status;
    setState(() {
      _status = status;
    });

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
  }

  void initPlatformState() async {
    SharedPreferences prefs = await _prefs;

    var flag = prefs.getString("platforminit");
    if (flag == "" || flag == null) {
      //await _autoRegister();
      //await _configureBackgroundGeolocation('qantler', 'username');
      await _configureBackgroundFetch();
      //  _onClickEnable(_enabled);
      prefs.setString('platforminit', "true");
      //_addgeofence();
      // _onClickEnable(_enabled);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // runApp(HomePage(type: BottomNavigationDemoType.withLabels));
    _enabled = true;
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    var android = new AndroidInitializationSettings('@mipmap/ic_launcher');
    var iOS = new IOSInitializationSettings();
    var initSetttings = new InitializationSettings(android, iOS);
    flutterLocalNotificationsPlugin.initialize(initSetttings, onSelectNotification: onSelectNotification);
    //getJsondata();
    _identifier = 'MYQUARANTINELOCATION';

    Future.delayed(const Duration(seconds: 0), () async {
      try {
        await getCurrentLocation();
        initPlatformState();
      } catch (ex) {
        initPlatformState();
      }
    });

    _tabController = TabController(length: 1, initialIndex: 0, vsync: this);
    _tabController.addListener(_handleTabChange);
    _widgetOptions = <Widget>[
      DashBoard(),
      UpdateHealthInfo(),
      // SharedEvents(events: events, child: EventList()),
      RaiseHands(),
      HistoryPage(),
      Profile()
    ];
    _isMoving = false;
    _odometer = '0';
  }

  Future onSelectNotification(String payload) {
    debugPrint("payload : $payload");
    showDialog(
      context: context,
      builder: (_) => new AlertDialog(
        title: new Text('Notification'),
        content: new Text('$payload'),
      ),
    );
  }

  showNotification() async {
    var android = new AndroidNotificationDetails('channel id', 'channel NAME', 'CHANNEL DESCRIPTION', priority: Priority.High, importance: Importance.Max);
    var iOS = new IOSNotificationDetails();
    var platform = new NotificationDetails(android, iOS);
    await flutterLocalNotificationsPlugin.show(0, AppLocalizations.of(context).translate('update_health_title'), AppLocalizations.of(context).translate('update_health_status_notification'), platform,
        payload: AppLocalizations.of(context).translate('update_health_status_notification'));
  }

//update_health_status_notification
  ongeofencecross(String event) async {
    var android = new AndroidNotificationDetails('channel id', 'channel NAME', 'CHANNEL DESCRIPTION', priority: Priority.High, importance: Importance.Max);
    var iOS = new IOSNotificationDetails();
    var platform = new NotificationDetails(android, iOS);
    await flutterLocalNotificationsPlugin.show(0, AppLocalizations.of(context).translate('alert_title'), event == 'EXIT' ? AppLocalizations.of(context).translate('geofenceoutnotificationmessage') : '', platform,
        payload: event == 'EXIT' ? AppLocalizations.of(context).translate('geofenceoutnotificationmessage') : '');
  }

  // Future<String> getJsondata() async {
  //   _config = _configure.serverURL();
  //   String homeurl = _config.postman + "/homedetails?userId=";
  //   var homedetailsresponse;
  //   try {
  //     homedetailsresponse = await http.get(Uri.encodeFull(homeurl), headers: {
  //       "Accept": "applicaton/json",
  //       'Authorization': 'Bearer ',
  //     });
  //   } catch (ex) {
  //     print('error $ex');
  //   }
  //   setState(() {
  //      //homeDetails = homedetailsModelFromJson(homedetailsresponse.body);
  //   });
  //   return "Success";
  // }

  SharedEvents list;
  String _title(BuildContext context) {
    switch (widget.type) {
      case BottomNavigationDemoType.withLabels:
        return 'Covenant';
      case BottomNavigationDemoType.withoutLabels:
        return 'Covenant';
    }
    return '';
  }

  void _handleTabChange() async {
    if (!_tabController.indexIsChanging) {
      return;
    }
    final SharedPreferences prefs = await _prefs;
    prefs.setInt("tabIndex", _tabController.index);
  }

  int _selectedIndex = 0;
  static const TextStyle optionStyle = TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  List<Widget> _widgetOptions;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_navigationViews == null) {
      _navigationViews = <_NavigationIconView>[
        _NavigationIconView(
          icon: const Icon(Icons.home),
          title: AppLocalizations.of(context).translate('home_title'),
          vsync: this,
        ),
        _NavigationIconView(
          icon: const Icon(Icons.alarm_on),
          title: AppLocalizations.of(context).translate('update_health_title'),
          vsync: this,
        ),
        _NavigationIconView(
          icon: const Icon(Icons.view_headline),
          title: AppLocalizations.of(context).translate('RaiseHand_title'),
          vsync: this,
        ),
        _NavigationIconView(
          icon: const Icon(Icons.calendar_today),
          title: AppLocalizations.of(context).translate('history_title'),
          vsync: this,
        ),
        _NavigationIconView(
          icon: const Icon(Icons.account_box),
          title: AppLocalizations.of(context).translate('profile_title'),
          vsync: this,
        ),
      ];

      _navigationViews[_currentIndex].controller.value = 1;
    }
  }

  @override
  void dispose() {
    for (_NavigationIconView view in _navigationViews) {
      view.controller.dispose();
    }
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildTransitionsStack() {
    final List<FadeTransition> transitions = <FadeTransition>[];

    for (_NavigationIconView view in _navigationViews) {
      transitions.add(view.transition(context));
    }

    // We want to have the newly animating (fading in) views on top.
    transitions.sort((a, b) {
      final aAnimation = a.opacity;
      final bAnimation = b.opacity;
      final aValue = aAnimation.value;
      final bValue = bAnimation.value;
      return aValue.compareTo(bValue);
    });

    return Stack(children: transitions);
  }

  @override
  Widget build(BuildContext context) {
    final DateTime today = DateTime.now();
    if (today.hour == 8 && today.second == 0 || today.hour == 22 && today.second == 0) {
      showNotification();
    }
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    var bottomNavigationBarItems = _navigationViews.map<BottomNavigationBarItem>((navigationView) => navigationView.item).toList();
    if (widget.type == BottomNavigationDemoType.withLabels) {
      bottomNavigationBarItems = bottomNavigationBarItems.sublist(0, _navigationViews.length);
      _currentIndex = _currentIndex.clamp(0, bottomNavigationBarItems.length - 1).toInt();
    }
    //  if(widget.navigationIndex==1){

    //   // _navigationViews[_currentIndex].controller.reverse();
    //   //         _currentIndex = 1;
    //   //         _navigationViews[_currentIndex].controller.forward();
    //   //         _currentIndex =
    //   //       _currentIndex.clamp(0, bottomNavigationBarItems.length - 1).toInt();
    //  }
    return Scaffold(
      appBar: AppBar(
        // bottom:TabBar(
        //       controller: _tabController,
        //       indicatorColor: Colors.red,
        //       tabs: [
        //         Tab(icon: Icon(Icons.map)),

        //       ]
        //   ),
        automaticallyImplyLeading: false,
        // title: Text(_title(context)),
        title: Text(_navigationViews[_currentIndex].title),
        // actions: <Widget>[
        //   Switch(value: _enabled, onChanged: null),
        // ],
      ),
      body: Center(
        child: IndexedStack(
          children: <Widget>[DashboardView(), UpdateHealthInfo(), RaiseHands(), HistoryPage(), Profile()],
          index: _currentIndex,
        ),
        //_widgetOptions.elementAt(_currentIndex),
        //_buildTransitionsStack(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        showUnselectedLabels: widget.type == BottomNavigationDemoType.withLabels,
        items: bottomNavigationBarItems,
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: textTheme.caption.fontSize,
        unselectedFontSize: textTheme.caption.fontSize,
        onTap: (index) {
          setState(() {
            _navigationViews[_currentIndex].controller.reverse();
            _currentIndex = index;
            _navigationViews[_currentIndex].controller.forward();
          });
        },
        selectedItemColor: colorScheme.onPrimary,
        unselectedItemColor: colorScheme.onPrimary.withOpacity(0.38),
        backgroundColor: colorScheme.primary,
      ),
    );
  }
}

class _NavigationIconView {
  _NavigationIconView({
    this.title,
    this.icon,
    TickerProvider vsync,
  })  : item = BottomNavigationBarItem(
          icon: icon,
          title: Text(title),
        ),
        controller = AnimationController(
          duration: kThemeAnimationDuration,
          vsync: vsync,
        ) {
    _animation = controller.drive(CurveTween(
      curve: const Interval(0.5, 1.0, curve: Curves.fastOutSlowIn),
    ));
  }

  final String title;
  final Widget icon;
  final BottomNavigationBarItem item;
  final AnimationController controller;
  Animation<double> _animation;

  FadeTransition transition(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Stack(
        children: [
          ExcludeSemantics(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/demos/bottom_navigation_background.png',
                  ),
                ),
              ),
            ),
          ),
          Center(
            child: IconTheme(
              data: const IconThemeData(
                color: Colors.white,
                size: 80,
              ),
              child: Semantics(
                label: 'title',
                child: icon,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
