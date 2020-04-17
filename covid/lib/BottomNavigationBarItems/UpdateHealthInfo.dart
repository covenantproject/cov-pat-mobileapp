import 'dart:convert';
import 'dart:io';

import 'package:covid/Models/TextStyle.dart';
import 'package:covid/Models/config/Configure.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert' as JSON;

class UpdateHealthInfo extends StatefulWidget {
  const UpdateHealthInfo({Key key}) : super(key: key);

  @override
  _UpdateHealthInfoState createState() => _UpdateHealthInfoState();
}

class _UpdateHealthInfoState extends State<UpdateHealthInfo>
    with TickerProviderStateMixin {
  TextStyleFormate styletext = TextStyleFormate();
  GoogleMapController _googleMapController;
  bool isSwitched = true;
   int id ;
   var _config;
   Configure _configure = new Configure();
   String radioItem = '';
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
  }
submit()async{

   _config = _configure.serverURL();
var apiUrl = Uri.parse(_config.postman + '/updatehealthinfo');
    // '/api/check?userName=$_username&checkName=$checkname&category=$category&description=$description&frequency=$frequency');
    var client = HttpClient(); // `new` keyword optional
    // 1. Create request
    try {
      HttpClientRequest request = await client.postUrl(apiUrl);
      request.headers.set('x-api-key', _config.apikey);
      request.headers.set('content-type', 'application/json; charset=utf-8');
      var payload = {
        "mobileno": "",
    "hascough": "false",
    "hasfever": "false",
    "haschills": "false",
    "hasbreathingissue": "false",
    "currenthealthstatus": "",
    "temperature": "",
    "heartrate": "",
    "respiratoryrate": "",
    "spo2": ""
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
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
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
                        child: Text(
                          'How are you ?',
                          style: styletext.cardfont(),
                        ),
                      ),
                      subtitle: Padding(
                        padding:
                            const EdgeInsets.only(top: 5, right: 0, bottom: 10),
                        child: Column(
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  'Do you have cough ?',
                                  style: styletext.placeholderStyle(),
                                ),
                                SizedBox(
                                  width: 19,
                                ),
                                Container(
                                  child: Row(
                                    children: <Widget>[
                                      Text(
                                        'Yes',
                                        style: styletext.labelfont(),
                                      ),
                                      Switch(
                                        value: isSwitched,
                                        onChanged: (value) {
                                          setState(() {
                                            isSwitched = value;
                                            print(isSwitched);
                                          });
                                        },
                                        activeTrackColor: Colors.grey[400],
                                        activeColor: Colors.grey[100],
                                        inactiveTrackColor: Colors.grey[400],
                                      ),
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
                                  'Do you have fever ?',
                                  style: styletext.placeholderStyle(),
                                ),
                                SizedBox(
                                  width: 29,
                                ),
                                Container(
                                    child: Row(
                                  children: <Widget>[
                                    Text(
                                      'Yes',
                                      style: styletext.labelfont(),
                                    ),
                                    Switch(
                                      value: isSwitched,
                                      onChanged: (value) {
                                        setState(() {
                                          isSwitched = value;
                                          print(isSwitched);
                                        });
                                      },
                                      activeTrackColor: Colors.grey[400],
                                      activeColor: Colors.grey[100],
                                      inactiveTrackColor: Colors.grey[400],
                                    ),
                                    Text('No', style: styletext.labelfont()),
                                  ],
                                )),
                              ],
                            ),
                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            //   children: <Widget>[
                            //     Text(
                            //       'Do you have chills ?',
                            //       style: styletext.placeholderStyle(),
                            //     ),
                            //     SizedBox(
                            //       width: 27,
                            //     ),
                            //     Container(
                            //       child: Row(
                            //         children: <Widget>[
                            //           Text(
                            //             'Yes',
                            //             style: styletext.labelfont(),
                            //           ),
                            //           Switch(
                            //             value: isSwitched,
                            //             onChanged: (value) {
                            //               setState(() {
                            //                 isSwitched = value;
                            //                 print(isSwitched);
                            //               });
                            //             },
                            //             activeTrackColor: Colors.grey[400],
                            //             activeColor: Colors.grey[100],
                            //             inactiveTrackColor: Colors.grey[400],
                            //           ),
                            //           Text('No', style: styletext.labelfont()),
                            //         ],
                            //       ),
                            //     ),
                            //   ],
                            // ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  'Do you have breathing difficulty ?',
                                  style: styletext.placeholderStyle(),
                                ),
                                SizedBox(
                                  width: 27,
                                ),
                                Container(
                                  child: Row(
                                    children: <Widget>[
                                      Text(
                                        'Yes',
                                        style: styletext.labelfont(),
                                      ),
                                      Switch(
                                        value: isSwitched,
                                        onChanged: (value) {
                                          setState(() {
                                            isSwitched = value;
                                            print(isSwitched);
                                          });
                                        },
                                        activeTrackColor: Colors.grey[400],
                                        activeColor: Colors.grey[100],
                                        inactiveTrackColor: Colors.grey[400],
                                      ),
                                      Text('No', style: styletext.labelfont()),
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
                        child: Text(
                          'How do you feel ?',
                          style: styletext.cardfont(),
                        ),
                      ),
                      subtitle: Padding(
                        padding:
                            const EdgeInsets.only(top: 5, right: 30, bottom: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: fList.map((data) => RadioListTile(
                    title: Text("${data.name}",style: styletext.placeholderStyle(),),
                    groupValue: id,
                    value: data.index,
                    onChanged: (val) {
                      FocusScope.of(context).unfocus();
                      setState(() {
                        radioItem = data.name ;
                        id = data.index;
                      });
                    },
                  )).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Card(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    ListTile(
                      dense: true,
                      title: Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          'Some more info:',
                          style: styletext.cardfont(),
                        ),
                      ),
                      subtitle: Padding(
                        padding:
                            const EdgeInsets.only(top: 5, right: 0, bottom: 10),
                        child: Column(
                          children: <Widget>[
                            SizedBox(
                              height: 15,
                            ),
                            TextField(
                              decoration: InputDecoration(
                                  icon: Icon(Icons.ac_unit),
                                  hintText: 'Temperature',
                                  filled: true,
                                  fillColor: Colors.grey[200]),
                            ),
                            SizedBox(
                              height: 27,
                            ),
                            TextField(
                              decoration: InputDecoration(
                                  icon: Icon(Icons.loyalty),
                                  hintText: 'heart rate/pulse rate',
                                  filled: true,
                                  fillColor: Colors.grey[200]),
                            ),
                            SizedBox(
                              height: 27,
                            ),
                            TextField(
                              decoration: InputDecoration(
                                  icon: Icon(Icons.record_voice_over),
                                  hintText: 'Respiratory rate',
                                  filled: true,
                                  fillColor: Colors.grey[200]),
                            ),
                            SizedBox(
                              height: 27,
                            ),
                            TextField(
                              decoration: InputDecoration(
                                  icon: Icon(Icons.whatshot),
                                  hintText: 'SPO2',
                                  filled: true,
                                  fillColor: Colors.grey[200]),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10,),
              Center(
                  child: RaisedButton(
                      elevation: 5.0,
                      child: Text('Update',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 17)),
                      textColor: Colors.white,
                      //color: Colors.blue,
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        submit();
                      },
                      shape: RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(80.0))))
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