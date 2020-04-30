// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'dart:async';
import 'package:covid/App_localizations.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:convert' as JSON;
import 'package:background_fetch/background_fetch.dart';
import 'package:covid/BottomNavigationBarItems/DashBoard.dart';
import 'package:covid/BottomNavigationBarItems/HistoryPage.dart';
import 'package:covid/BottomNavigationBarItems/RaiseHands.dart';
import 'package:covid/BottomNavigationBarItems/event_list.dart';
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
import 'package:covid/Models/util/dialog.dart' as util;
import 'package:covid/Models/config/env.dart';
import 'package:covid/main.dart';
import 'package:covid/Models/config/shared_events.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;

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

class _HomePageState extends State<HomePage>
    with
        SingleTickerProviderStateMixin,
        TickerProviderStateMixin<HomePage>,
        WidgetsBindingObserver {
  LatLng center;
  String _identifier;
  double _radius = 15.0;
  int userId;
  bool _notifyOnEntry = true;
  bool _notifyOnExit = true;
  bool _notifyOnDwell = true;
  var _config;
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
   // _addgeofence();
  }

  /// Receive events from BackgroundGeolocation in Headless state.
  void _onClickEnable(enabled) async {
   // showNotification();
  // runApp(MyApp());
    bg.BackgroundGeolocation.playSound(util.Dialog.getSoundId("BUTTON_CLICK"));
    if (enabled) {
      dynamic callback = (bg.State state) {
        print('[start] success: $state');
        setState(() {
          _enabled = state.enabled;
          _isMoving = state.isMoving;
        });
      };
      bg.State state = await bg.BackgroundGeolocation.state;
      if (state.trackingMode == 1) {
        bg.BackgroundGeolocation.start().then(callback);
        updatelocation(1, currentlat, currentlong, "LOCATION_SERVICE_START");
      } else {
        bg.BackgroundGeolocation.startGeofences().then(callback);
      }
    } else {
      dynamic callback = (bg.State state) {
        print('[stop] success: $state');
        setState(() {
          _enabled = state.enabled;
          _isMoving = state.isMoving;
        });
      };
      bg.BackgroundGeolocation.stop().then(callback);
      updatelocation(1, currentlat, currentlong, "LOCATION_SERVICE_STOP");
    }
  }
  void backgroundGeolocationHeadlessTask(bg.HeadlessEvent headlessEvent) async 
  { print('[BackgroundGeolocation] headless task $headlessEvent');
   Map<String, dynamic> data = <String, dynamic>{}; 
   data['message'] = '[providerchange] - $headlessEvent';
    }

  Future _configureBackgroundGeolocation(orgname, username) async {
    // 1.  Listen to events (See docs for all 13 available events).
    bg.BackgroundGeolocation.onLocation(_onLocation, _onLocationError);
    bg.BackgroundGeolocation.onMotionChange(_onMotionChange);
    bg.BackgroundGeolocation.onActivityChange(_onActivityChange);
    bg.BackgroundGeolocation.onProviderChange(_onProviderChange);
    bg.BackgroundGeolocation.onHttp(_onHttp);
    bg.BackgroundGeolocation.onConnectivityChange(_onConnectivityChange);
    bg.BackgroundGeolocation.onHeartbeat(_onHeartbeat);
    bg.BackgroundGeolocation.onGeofence(_onGeofence);
    bg.BackgroundGeolocation.onSchedule(_onSchedule);
    bg.BackgroundGeolocation.onPowerSaveChange(_onPowerSaveChange);
    bg.BackgroundGeolocation.onEnabledChange(_onEnabledChange);
    bg.BackgroundGeolocation.onNotificationAction(_onNotificationAction);

    bg.TransistorAuthorizationToken token =
        await bg.TransistorAuthorizationToken.findOrCreate(
            orgname, username, ENV.TRACKER_HOST);

    // 2.  Configure the plugin
    bg.BackgroundGeolocation.ready(bg.Config(
            // Convenience option to automatically configure the SDK to post to Transistor Demo server.
            transistorAuthorizationToken: token,
            
            // Logging & Debug
            reset: false,
            debug: true,
            logLevel: bg.Config.LOG_LEVEL_VERBOSE,
            // Geolocation options
            desiredAccuracy: bg.Config.DESIRED_ACCURACY_NAVIGATION,
            distanceFilter: 10.0,
            stopTimeout: 1,
            // HTTP & Persistence
            autoSync: true,
            // Application options
            stopOnTerminate: false,
            startOnBoot: true,
            enableHeadless: true,
            heartbeatInterval: 60))
        .then((bg.State state) {
      print('[ready] ${state.toMap()}');
       
      if (state.schedule.isNotEmpty) {
        bg.BackgroundGeolocation.startSchedule();
      }
      setState(() {
        _enabled = state.enabled;
        _isMoving = state.isMoving;
      });
    }).catchError((error) {
      print('[ready] ERROR: $error');
    });

    // Fetch currently selected tab.
    SharedPreferences prefs = await _prefs;
    int tabIndex = prefs.getInt("tabIndex");

    // Which tab to view?  MapView || EventList.   Must wait until after build before switching tab or bad things happen.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (tabIndex != null) {
        _tabController.animateTo(tabIndex);
      }
    });
  }

  Future updatelocation(
      int patientid, double lat, double long, String code) async {
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
      var payload = {
        "userId": userId,
        "latitude": "$lat",
        "longitude": "$long",
        "code": "$code"
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
        BackgroundFetchConfig(
            minimumFetchInterval: 5,
            startOnBoot: true,
            stopOnTerminate: false,
            enableHeadless: true,
            requiresStorageNotLow: false,
            requiresBatteryNotLow: false,
            requiresCharging: false,
            requiresDeviceIdle: false,
            requiredNetworkType: NetworkType.NONE), (String taskId) async {
      print("[BackgroundFetch] received event $taskId");
       updatelocation(1, currentlat, currentlong, "ON_HEART_BEAT_10mins");
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int count = 0;
      if (prefs.get("fetch-count") != null) {
        count = prefs.getInt("fetch-count");
      }
      prefs.setInt("fetch-count", ++count);
      print('[BackgroundFetch] count: $count');

      if (taskId == 'flutter_background_fetch') {
        // Test scheduling a custom-task in fetch event.
        BackgroundFetch.scheduleTask(TaskConfig(
            taskId: "com.transistorsoft.customtask",
            delay: 5000,
            periodic: false,
            forceAlarmManager: true,
            stopOnTerminate: false,
            enableHeadless: true));
      }
     
      BackgroundFetch.finish(taskId);
    });

    // Test scheduling a custom-task.
    // BackgroundFetch.scheduleTask(TaskConfig(
    //     taskId: "com.transistorsoft.customtask",
    //     delay: 10000,
    //     periodic: false,
    //     forceAlarmManager: true,
    //     stopOnTerminate: false,
    //     enableHeadless: true));
  }

  void _onLocation(bg.Location location) {
    print('[${bg.Event.LOCATION}] - $location');

    setState(() {
      events.insert(0,
          Event(bg.Event.LOCATION, location, location.toString(compact: true)));
      _odometer = (location.odometer / 1000.0).toStringAsFixed(1);
    });
  }

  void _onLocationError(bg.LocationError error) {
    print('[${bg.Event.LOCATION}] ERROR - $error');
    setState(() {
      events.insert(
          0, Event(bg.Event.LOCATION + " error", error, error.toString()));
    });
  }

  void _onMotionChange(bg.Location location) {
    print('[${bg.Event.MOTIONCHANGE}] - $location');
    //updatelocation(1, currentlat, currentlong, "ON_LOCATION_CHANGE");
    setState(() {
      events.insert(
          0,
          Event(bg.Event.MOTIONCHANGE, location,
              location.toString(compact: true)));
      _isMoving = location.isMoving;
    });
  }

  void _onActivityChange(bg.ActivityChangeEvent event) {
    print('[${bg.Event.ACTIVITYCHANGE}] - $event');
    setState(() {
      events.insert(0, Event(bg.Event.ACTIVITYCHANGE, event, event.toString()));
      _motionActivity = event.activity;
    });
  }

  void _onProviderChange(bg.ProviderChangeEvent event) {
    print('[${bg.Event.PROVIDERCHANGE}] - $event');
    setState(() {
      events.insert(0, Event(bg.Event.PROVIDERCHANGE, event, event.toString()));
    });
  }

  void _onHttp(bg.HttpEvent event) async {
    print('[${bg.Event.HTTP}] - $event');

    setState(() {
      events.insert(0, Event(bg.Event.HTTP, event, event.toString()));
    });
  }

  void _onConnectivityChange(bg.ConnectivityChangeEvent event) {
    print('[${bg.Event.CONNECTIVITYCHANGE}] - $event');
    setState(() {
      events.insert(
          0, Event(bg.Event.CONNECTIVITYCHANGE, event, event.toString()));
    });
  }

  void _onHeartbeat(bg.HeartbeatEvent event) {
    print('[${bg.Event.HEARTBEAT}] - $event');
   // updatelocation(1, currentlat, currentlong, 'ON_IDLE');
    setState(() {
      events.insert(0, Event(bg.Event.HEARTBEAT, event, event.toString()));
    });
  }

  void _onGeofence(bg.GeofenceEvent event) async {
    print('[${bg.Event.GEOFENCE}] - $event');
    if(event.action=='EXIT'){
       ongeofencecross(event.action);
       updatelocation(1, currentlat, currentlong, "ON_GEOFENCECROSS $event");
    } else if(event.action=='ENTER'){
      ongeofencecross(event.action);
      updatelocation(1, currentlat, currentlong, "ON_GEOFENCECROSS $event");
    }
    else{
      ongeofencecross(event.action);
    }
    //updatelocation(1, currentlat, currentlong, "ON_GEOFENCECROSS");
    
    
    bg.BackgroundGeolocation.startBackgroundTask().then((int taskId) async {
      // Execute an HTTP request to test an async operation completes.
      String url = "${ENV.TRACKER_HOST}/api/devices";
      bg.State state = await bg.BackgroundGeolocation.state;
      http.read(url, headers: {
        "Authorization": "Bearer ${state.authorization.accessToken}"
      }).then((String result) {
        print("[http test] success: $result");
        bg.BackgroundGeolocation.playSound(
            util.Dialog.getSoundId("TEST_MODE_CLICK"));
        bg.BackgroundGeolocation.stopBackgroundTask(taskId);
      }).catchError((dynamic error) {
        print("[http test] failed: $error");
        bg.BackgroundGeolocation.stopBackgroundTask(taskId);
      });
    });

    setState(() {
      events.insert(
          0, Event(bg.Event.GEOFENCE, event, event.toString(compact: false)));
    });
  }

  void _onSchedule(bg.State state) {
    print('[${bg.Event.SCHEDULE}] - $state');
    setState(() {
      events.insert(
          0, Event(bg.Event.SCHEDULE, state, "enabled: ${state.enabled}"));
    });
  }

  void _onEnabledChange(bool enabled) {
    print('[${bg.Event.ENABLEDCHANGE}] - $enabled');
    setState(() {
      _enabled = enabled;
      events.clear();
      events.insert(
          0,
          Event(bg.Event.ENABLEDCHANGE, enabled,
              '[EnabledChangeEvent enabled: $enabled]'));
    });
  }

  void _onNotificationAction(String action) {
    print('[onNotificationAction] $action');
    switch (action) {
      case 'notificationButtonFoo':
        bg.BackgroundGeolocation.changePace(false);
        break;
      case 'notificationButtonBar':
        break;
    }
  }

  void _onPowerSaveChange(bool enabled) {
    print('[${bg.Event.POWERSAVECHANGE}] - $enabled');
    setState(() {
      events.insert(
          0,
          Event(bg.Event.POWERSAVECHANGE, enabled,
              'Power-saving enabled: $enabled'));
    });
  }

  Future _autoRegister() async {
    //Navigator.of(context).pop();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("orgname", 'qantler');
    await prefs.setString("username", 'username');
// orgname=prefs.getString("orgname");
// username=prefs.getString("username");
    await bg.TransistorAuthorizationToken.destroy(ENV.TRACKER_HOST);
    bg.TransistorAuthorizationToken token =
        await bg.TransistorAuthorizationToken.findOrCreate(
            'qantler', 'username', ENV.TRACKER_HOST);

    bg.BackgroundGeolocation.setConfig(
        bg.Config(transistorAuthorizationToken: token));
  }

  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   print("[home_view didChangeAppLifecycleState] : $state");
  //   if (state == AppLifecycleState.paused) {

  //   } else if (state == AppLifecycleState.resumed) {

  //   }
  // }

  void initPlatformState() async {
    
    SharedPreferences prefs = await _prefs;
    // String orgname = prefs.getString("orgname");
    // String username = prefs.getString("username");
   
    // // Sanity check orgname & username:  if invalid, go back to HomeApp to re-register device.
    // if (orgname == null || username == null) {
    //   return runApp(MyApp());
    // }
    // bg.BackgroundGeolocation.registerHeadlessTask(backgroundGeolocationHeadlessTask);
    var flag=prefs.getString("platforminit");
    if(flag==""||flag==null)
    {
    await _autoRegister();
    await _configureBackgroundGeolocation('qantler', 'username');
    await _configureBackgroundFetch();
    _onClickEnable(_enabled);
    prefs.setString('platforminit',"true");
    _addgeofence();
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
    flutterLocalNotificationsPlugin.initialize(initSetttings,
        onSelectNotification: onSelectNotification);
    //getJsondata();
    _identifier = DateTime.now().toString();
    
    Future.delayed(const Duration(seconds:0), ()async {
      try
      {
      await getCurrentLocation();
      initPlatformState();
      }catch(ex){
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
      //HistoryPage(),
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
    var android = new AndroidNotificationDetails(
        'channel id', 'channel NAME', 'CHANNEL DESCRIPTION',
        priority: Priority.High, importance: Importance.Max);
    var iOS = new IOSNotificationDetails();
    var platform = new NotificationDetails(android, iOS);
    await flutterLocalNotificationsPlugin.show(0, 'Update health status',
        'Update your health status at everyday 8 AM and 10 PM', platform,
        payload:
            'You need to update your health status everyday at 8 AM and 10 PM');
  }
  ongeofencecross(event) async {
    var android = new AndroidNotificationDetails(
        'channel id', 'channel NAME', 'CHANNEL DESCRIPTION',
        priority: Priority.High, importance: Importance.Max);
    var iOS = new IOSNotificationDetails();
    var platform = new NotificationDetails(android, iOS);
    await flutterLocalNotificationsPlugin.show(0, 'Geofence',
        'Alert! $event event on geofence', platform,
        payload:
            'Alert! $event event on geofence');
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

  void _addgeofence() {
    bg.BackgroundGeolocation.addGeofence(bg.Geofence(
        identifier: _identifier,
        radius: ENV.RADIUS_GEOFENCE,
        latitude: currentlat,
        longitude: currentlong,
        notifyOnEntry: _notifyOnEntry,
        notifyOnExit: _notifyOnExit,
        notifyOnDwell: _notifyOnDwell,
        loiteringDelay: _loiteringDelay,
        extras: {
          'radius': _radius,
          'center': {'latitude': currentlat, 'longitude': currentlong}
        } // meta-data for tracker.transistorsoft.com
        )).then((bool success) {
      bg.BackgroundGeolocation.playSound(
          util.Dialog.getSoundId('ADD_GEOFENCE'));
    }).catchError((error) {
      print('[addGeofence] ERROR: $error');
    });
  }

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
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
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
          title:  AppLocalizations.of(context).translate('RaiseHand_title'),
          vsync: this,
        ),
        // _NavigationIconView(
        //   icon: const Icon(Icons.calendar_today),
        //   title: 'History',
        //   vsync: this,
        // ),
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
    if (today.hour == 8 &&today.second==0|| today.hour == 22&&today.second==0) {
      showNotification();
    }
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    var bottomNavigationBarItems = _navigationViews
        .map<BottomNavigationBarItem>((navigationView) => navigationView.item)
        .toList();
    if (widget.type == BottomNavigationDemoType.withLabels) {
      bottomNavigationBarItems =
          bottomNavigationBarItems.sublist(0, _navigationViews.length);
      _currentIndex =
          _currentIndex.clamp(0, bottomNavigationBarItems.length - 1).toInt();
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
        actions: <Widget>[
          Switch(value: _enabled, onChanged: _onClickEnable),
        ],
      ),
      body: Center(
        child: 
            // ? Center(
            //     child: Container(
            //         padding: EdgeInsets.all(0),
            //         child: Container(
            //             child: const CircularProgressIndicator(
            //           strokeWidth: 3,
            //         ))),
            //   )
            // : RefreshIndicator(
            //     onRefresh: getJsondata,
            //     child: homeDetails == null
            //         ? ListView(
            //             children: <Widget>[
            //               Container(
            //                 // color: Colors.red,
            //                 height: MediaQuery.of(context).size.height / 1.4,
            //                 child: Align(
            //                   alignment: Alignment.center,
            //                   child:
            //                       Text('Loading', style: styletext.emptylist()),
            //                 ),
            //               ),
            //             ],
            //           )
            //         :
                    
                     _widgetOptions.elementAt(_currentIndex),
                //_buildTransitionsStack(),
             
      ),
      bottomNavigationBar: BottomNavigationBar(
        showUnselectedLabels:
            widget.type == BottomNavigationDemoType.withLabels,
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
