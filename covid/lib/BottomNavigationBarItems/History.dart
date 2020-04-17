import 'package:background_fetch/background_fetch.dart';
import 'package:covid/Models/TextStyle.dart';
import 'package:covid/Models/config/env.dart';
import 'package:covid/Models/config/shared_events.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:covid/Models/util/dialog.dart' as util;
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class History extends StatefulWidget {
  const History({Key key}) : super(key: key);

  @override
  _HistoryState createState() => _HistoryState();
}

class _HistoryState extends State<History> with TickerProviderStateMixin {
  TextStyleFormate styletext = TextStyleFormate();
  GoogleMapController _googleMapController;
  bool isSwitched = true;
  int id;
  String radioItem = '';
  List<Event> events = [];
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  bool _isMoving;
  bool _enabled;
  String _motionActivity;
  String _odometer;
  String orgname;
  String username;
  List<Event> list;
  List<RadioList> fList = [
    RadioList(
      index: 1,
      name: "Getting better",
    ),
    RadioList(
      index: 2,
      name: "Getting worse",
    ),
    RadioList(
      index: 3,
      name: "Remaining same",
    ),
  ];
  @override
  void initState() {
    super.initState();
    
    //_autoRegister();
    _isMoving = false;
    _enabled = false;
    _odometer = '0';
    //initPlatformState();
  }


 
  @override
  Widget build(BuildContext context) {
    
     final events = SharedEvents.of(context);
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 350),
            child: Column(children: <Widget>[
              Card(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ListTile(
                      dense: true,
                      // leading: Padding(
                      //   padding: const EdgeInsets.only(bottom: 30),
                      //   child: Icon(Icons.album),
                      // ),
                      title: Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Wrap(children: <Widget>[
                          Text(
                            '09/Mar/20:01 08 PM: Health Info Updated',
                            style: styletext.cardfont(),
                          ),
                        ]),
                      ),
                      subtitle: Padding(
                        padding:
                            const EdgeInsets.only(top: 5, right: 0, bottom: 10),
                        child: Column(
                          children: <Widget>[
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  'Do you have cough ?',
                                  style: styletext.placeholderStyle(),
                                ),
                                SizedBox(
                                  height: 30,
                                ),
                                Container(
                                  child: Row(
                                    children: <Widget>[
                                      Text(
                                        'Yes',
                                        style: styletext.labelfont(),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  'Do you have fever ?',
                                  style: styletext.placeholderStyle(),
                                ),
                                SizedBox(
                                  height: 30,
                                ),
                                Container(
                                    child: Row(
                                  children: <Widget>[
                                    Text('No', style: styletext.labelfont()),
                                  ],
                                )),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  'Do you have chills ?',
                                  style: styletext.placeholderStyle(),
                                ),
                                SizedBox(
                                  height: 30,
                                ),
                                Container(
                                  child: Row(
                                    children: <Widget>[
                                      Text('No', style: styletext.labelfont()),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  'Do you have breathing difficulty ?',
                                  style: styletext.placeholderStyle(),
                                ),
                                SizedBox(
                                  height: 30,
                                ),
                                Container(
                                  child: Row(
                                    children: <Widget>[
                                      Text(
                                        'Yes',
                                        style: styletext.labelfont(),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  'Timestamp',
                                  style: styletext.placeholderStyle(),
                                ),
                                SizedBox(
                                  height: 30,
                                ),
                                Container(
                                  child: Row(
                                    children: <Widget>[
                                      Text(
                                        '09/Mar/20:01 08 PM',
                                        style: styletext.labelfont(),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
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
                      title: Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Wrap(children: <Widget>[
                          Text(
                            '08/Mar/20:11 18 AM: Raise Your Hand',
                            style: styletext.cardfont(),
                          ),
                        ]),
                      ),
                      subtitle: Padding(
                        padding:
                            const EdgeInsets.only(top: 5, right: 0, bottom: 10),
                        child: Column(
                          children: <Widget>[
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  'Contact your quarantine officer',
                                  style: styletext.placeholderStyle(),
                                ),
                                SizedBox(
                                  height: 30,
                                ),
                                Container(
                                  child: Row(
                                    children: <Widget>[
                                      Text(
                                        'Yes',
                                        style: styletext.labelfont(),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  'Timestamp',
                                  style: styletext.placeholderStyle(),
                                ),
                                SizedBox(
                                  height: 30,
                                ),
                                Container(
                                  child: Row(
                                    children: <Widget>[
                                      Text(
                                        '08/Mar/20:11 18 AM',
                                        style: styletext.labelfont(),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
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
                      // leading: Padding(
                      //   padding: const EdgeInsets.only(bottom: 30),
                      //   child: Icon(Icons.album),
                      // ),
                      title: Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Wrap(children: <Widget>[
                          Text(
                            '07/Mar/18:01 07 PM: Health Info Updated',
                            style: styletext.cardfont(),
                          ),
                        ]),
                      ),
                      subtitle: Padding(
                        padding:
                            const EdgeInsets.only(top: 5, right: 0, bottom: 10),
                        child: Column(
                          children: <Widget>[
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  'Do you have cough ?',
                                  style: styletext.placeholderStyle(),
                                ),
                                SizedBox(
                                  height: 30,
                                ),
                                Container(
                                  child: Row(
                                    children: <Widget>[
                                      Text(
                                        'No',
                                        style: styletext.labelfont(),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  'Do you have fever ?',
                                  style: styletext.placeholderStyle(),
                                ),
                                SizedBox(
                                  height: 30,
                                ),
                                Container(
                                    child: Row(
                                  children: <Widget>[
                                    Text('No', style: styletext.labelfont()),
                                  ],
                                )),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  'Heart rate/pulse rate',
                                  style: styletext.placeholderStyle(),
                                ),
                                SizedBox(
                                  height: 30,
                                ),
                                Container(
                                  child: Row(
                                    children: <Widget>[
                                      Text('68 BPM',
                                          style: styletext.labelfont()),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  'Temperature',
                                  style: styletext.placeholderStyle(),
                                ),
                                SizedBox(
                                  height: 30,
                                ),
                                Container(
                                  child: Row(
                                    children: <Widget>[
                                      Text(
                                        '33 °C',
                                        style: styletext.labelfont(),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  'Timestamp',
                                  style: styletext.placeholderStyle(),
                                ),
                                SizedBox(
                                  height: 30,
                                ),
                                Container(
                                  child: Row(
                                    children: <Widget>[
                                      Text(
                                        '07/Mar/18:01 07 AM',
                                        style: styletext.labelfont(),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
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
                      title: Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Wrap(children: <Widget>[
                          Text(
                            '04/Mar/20:11 18 AM: Raise Your Hand',
                            style: styletext.cardfont(),
                          ),
                        ]),
                      ),
                      subtitle: Padding(
                        padding:
                            const EdgeInsets.only(top: 5, right: 0, bottom: 10),
                        child: Column(
                          children: <Widget>[
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  'Contact your medical officer',
                                  style: styletext.placeholderStyle(),
                                ),
                                SizedBox(
                                  height: 30,
                                ),
                                Container(
                                  child: Row(
                                    children: <Widget>[
                                      Text(
                                        'Yes',
                                        style: styletext.labelfont(),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  'Timestamp',
                                  style: styletext.placeholderStyle(),
                                ),
                                SizedBox(
                                  height: 30,
                                ),
                                Container(
                                  child: Row(
                                    children: <Widget>[
                                      Text(
                                        '04/Mar/20:11 18 AM',
                                        style: styletext.labelfont(),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // SizedBox(height: 10,),
            ]),
          ),
        ),
      ),
    );
  }
}

class RadioList {
  String name;
  int index;
  RadioList({this.name, this.index});
}
