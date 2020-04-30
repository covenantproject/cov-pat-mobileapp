import 'package:background_fetch/background_fetch.dart';
import 'package:covid/App_localizations.dart';
import 'package:covid/HomePage.dart';
import 'package:covid/Landing.dart';
import 'package:covid/Login.dart';
import 'package:covid/Models/config/Configure.dart';
import 'package:covid/Models/config/env.dart';
import 'package:covid/Models/config/transistor_auth.dart';
import 'package:covid/OtpPage.dart';
import 'package:covid/RegisterPage.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:convert' as JSON;
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;

 var _config;
 int userId;
 FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
 
 Configure _configure = new Configure();
void backgroundGeolocationHeadlessTask(bg.HeadlessEvent headlessEvent) async {
  print('📬 --> $headlessEvent');

  switch (headlessEvent.name) {
    case bg.Event.TERMINATE:
      try {
        //bg.Location location = await bg.BackgroundGeolocation.getCurrentPosition(samples: 1);
        print('[getCurrentPosition] Headless: $headlessEvent');
      } catch (error) {
        print('[getCurrentPosition] Headless ERROR: $error');
      }
      break;
    case bg.Event.HEARTBEAT:
      /* DISABLED getCurrentPosition on heartbeat
      try {
        bg.Location location = await bg.BackgroundGeolocation.getCurrentPosition(samples: 1);
        print('[getCurrentPosition] Headless: $location');
      } catch (error) {
        print('[getCurrentPosition] Headless ERROR: $error');
      }
      */
      break;
    case bg.Event.LOCATION:
      bg.Location location = headlessEvent.event;
      print(location);
      break;
    case bg.Event.MOTIONCHANGE:
      bg.Location location = headlessEvent.event;
      print(location);
      break;
    case bg.Event.GEOFENCE:
      bg.GeofenceEvent geofenceEvent = headlessEvent.event;
    //  if(geofenceEvent.action=='ENTER'){
    //    ongeofencecross(geofenceEvent.action);
    //  }
    //  else if(geofenceEvent.action=='EXIT'){
    //    ongeofencecross(geofenceEvent.action);
    //  }
      print(geofenceEvent);
      break;
    case bg.Event.GEOFENCESCHANGE:
      bg.GeofencesChangeEvent event = headlessEvent.event;
      print(event);
      break;
    case bg.Event.SCHEDULE:
      bg.State state = headlessEvent.event;
      print(state);
      break;
    case bg.Event.ACTIVITYCHANGE:
      bg.ActivityChangeEvent event = headlessEvent.event;
      print(event);
      break;
    case bg.Event.HTTP:
      bg.HttpEvent response = headlessEvent.event;
      print(response);
      break;
    case bg.Event.POWERSAVECHANGE:
      bool enabled = headlessEvent.event;
      print(enabled);
      break;
    case bg.Event.CONNECTIVITYCHANGE:
      bg.ConnectivityChangeEvent event = headlessEvent.event;
      print(event);
      break;
    case bg.Event.ENABLEDCHANGE:
      bool enabled = headlessEvent.event;
      print(enabled);
      break;
    case bg.Event.AUTHORIZATION:
      bg.AuthorizationEvent event = headlessEvent.event;
      print(event);
      bg.BackgroundGeolocation.setConfig(
          bg.Config(url: "${ENV.TRACKER_HOST}/api/locations"));
      break;
  }
}

 void _configureBackgroundFetch() async {
    BackgroundFetch.configure(
        BackgroundFetchConfig(
            minimumFetchInterval: 10,
            startOnBoot: true,
            stopOnTerminate: false,
            enableHeadless: true,
            requiresStorageNotLow: false,
            requiresBatteryNotLow: false,
            requiresCharging: false,
            requiresDeviceIdle: false,
            requiredNetworkType: NetworkType.NONE), (String taskId) async {
      print("[BackgroundFetch] received event $taskId");

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
      updatelocation(1, 0, 0, "ON_HEART_BEAT_10mins");
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

  Future updatelocation(
      int patientid, double lat, double long, String code) async {
    _config = _configure.serverURL();
     SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('userId');
    lat = prefs.getDouble('lat');
    long = prefs.getDouble('long');
    var apiUrl = Uri.parse(_config.postman + '/locationHistory');
    var client = HttpClient();
    // `new` keyword optional
    // 1. Create request
    if(lat!=null){
    try {
      HttpClientRequest request = await client.postUrl(apiUrl);
      //request.headers.set('x-api-key', _config.apikey);
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
     
    } catch (ex) {
      print('error $ex');
    }
    }
  }

/// Receive events from BackgroundFetch in Headless state.
void backgroundFetchHeadlessTask(String taskId) async {
  // Get current-position from BackgroundGeolocation in headless mode.
  //bg.Location location = await bg.BackgroundGeolocation.getCurrentPosition(samples: 1);
  print("[BackgroundFetch] HeadlessTask: $taskId");

  // SharedPreferences prefs = await SharedPreferences.getInstance();
  // int count = 0;
  // if (prefs.get("fetch-count") != null) {
  //   count = prefs.getInt("fetch-count");
  // }
  // prefs.setInt("fetch-count", ++count);
  // print('[BackgroundFetch] count: $count');

  BackgroundFetch.finish(taskId);
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
  TransistorAuth.registerErrorHandler();
  /// Register BackgroundGeolocation headless-task.
  bg.BackgroundGeolocation.registerHeadlessTask(
      backgroundGeolocationHeadlessTask);
  /// Register BackgroundFetch headless-task.
  BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
  _configureBackgroundFetch();
  //localnotification
  
  
  //_autoRegister();
  
}

class MyApp extends StatelessWidget {
  
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Covenant',
       supportedLocales: [
        Locale('en', 'US'),
        Locale('ta', 'IN'),
      ],
       localizationsDelegates: [
        // THIS CLASS WILL BE ADDED LATER
        // A class which loads the translations from JSON files
        AppLocalizations.delegate,
        // Built-in localization of basic text for Material widgets
        GlobalMaterialLocalizations.delegate,
        // Built-in localization for text direction LTR/RTL
        GlobalWidgetsLocalizations.delegate,
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        // Check if the current device locale is supported
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale.languageCode &&
              supportedLocale.countryCode == locale.countryCode) {
            return supportedLocale;
          }
        }
        // If the locale of the device is not supported, use the first one
        // from the list (English, in this case).
        return supportedLocales.first;
      },
      // initialRoute: '/',
      routes: {
        // '/': (context) => Landing(),
        '/login': (context) => LoginPage(),
        '/homepage': (context) => HomePage(
              type: BottomNavigationDemoType.withLabels,
            ),
        '/otp': (context) => OtpPage(),
        '/register': (context) => RegisterPage(),
      },
      theme: new ThemeData(
          buttonColor: Colors.purple,
          canvasColor: Colors.white,
          brightness: Brightness.light,
          fontFamily: 'Schyler',
          primarySwatch: Colors.purple),
      home: Landing(),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
