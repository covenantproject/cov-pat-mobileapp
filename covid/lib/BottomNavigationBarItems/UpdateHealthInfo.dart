import 'dart:convert';
import 'dart:io';
import 'package:covid/App_localizations.dart';
import 'package:covid/Models/TextStyle.dart';
import 'package:covid/Models/config/Configure.dart';
import 'package:covid/Models/util/DialogBox.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  bool isSwitchedcough = true;
  bool isSwitchedfever = true;
  bool isSwitchedbreathing = true;
  int id = 1;
  var _config;
  final TextEditingController tempController=TextEditingController();
  final TextEditingController heartrateController=TextEditingController();
  final TextEditingController respiratoryrateController=TextEditingController();
  final TextEditingController spo2Controller=TextEditingController();
  Configure _configure = new Configure();
  String radioItem = 'Getting better';
  final formKey = new GlobalKey<FormState>();
  DialogBox dialogBox = DialogBox();
  int userId;
  bool autoValidatorTemp;
  bool autoValidatorHeartrate;
  bool autoValidatorRespiratory;
  bool autoValidatorSpo2;
  String temp;
  String heartrate;
  String respiratoryrate;
  String spo2;

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
    autoValidatorTemp = false;
    autoValidatorHeartrate = false;
    autoValidatorRespiratory = false;
    autoValidatorSpo2 = false;
   
  }

  bool validateAndSave() {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    } else {
      return false;
    }
  }

  submit() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('userId');
    _config = _configure.serverURL();
    var apiUrl = Uri.parse(_config.postman + '/updateHealth');
    // '/api/check?userName=$_username&checkName=$checkname&category=$category&description=$description&frequency=$frequency');
    var client = HttpClient(); // `new` keyword optional
    // 1. Create request
    try {
      HttpClientRequest request = await client.postUrl(apiUrl);
      request.headers.set('x-api-key', _config.apikey);
      request.headers.set('content-type', 'application/json; charset=utf-8');
      var payload = {
        "userid": userId,
        "coughpresent": isSwitchedcough==true?false:true,
        "feverpresent": isSwitchedfever==true?false:true,
        "breathingdifficultypresent": isSwitchedbreathing==true?false:true,
        "progressstatus": "$radioItem",
        "temperature": tempController.text,
        "heartrate": heartrateController.text,
        "respiratoryrate": respiratoryrateController.text,
        "spo2": spo2Controller.text
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
      onTap: () {
        FocusScope.of(context).unfocus();
        autoValidatorHeartrate = false;
        autoValidatorRespiratory = false;
        autoValidatorSpo2 = false;
        autoValidatorSpo2 = false;
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
                          AppLocalizations.of(context).translate('qus1'),
                          style: styletext.cardfont(),
                        ),
                      ),
                      subtitle: Padding(
                        padding:
                            const EdgeInsets.only(top: 5, right: 0, bottom: 10),
                        child: Column(
                          children: <Widget>[
                            Wrap(
                              alignment: WrapAlignment.spaceBetween,
                              //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  AppLocalizations.of(context)
                                      .translate('cough'),
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
                                        value: isSwitchedcough,
                                        onChanged: (value) {
                                          setState(() {
                                            isSwitchedcough = value;
                                            print(isSwitchedcough);
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
                            Wrap(
                              alignment: WrapAlignment.spaceBetween,
                              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  AppLocalizations.of(context)
                                      .translate('fever'),
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
                                      value: isSwitchedfever,
                                      onChanged: (value) {
                                        setState(() {
                                          isSwitchedfever = value;
                                          print(isSwitchedfever);
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
                            Wrap(
                              alignment: WrapAlignment.spaceBetween,
                              //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  AppLocalizations.of(context)
                                      .translate('breath'),
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
                                        value: isSwitchedbreathing,
                                        onChanged: (value) {
                                          setState(() {
                                            isSwitchedbreathing = value;
                                            print(isSwitchedbreathing);
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
                          AppLocalizations.of(context).translate('qus2'),
                          style: styletext.cardfont(),
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(
                            top: 5, right: 30, bottom: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: fList
                              .map((data) => RadioListTile(
                                    title: Text(
                                      "${data.name}",
                                      style: styletext.placeholderStyle(),
                                    ),
                                    //selected: true,
                                    groupValue: id,
                                    value: data.index,
                                    onChanged: (val) {
                                      FocusScope.of(context).unfocus();
                                      setState(() {
                                        radioItem = data.name;
                                        id = data.index;
                                      });
                                    },
                                  ))
                              .toList(),
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
                    Form(
                      key: formKey,
                      child: ListTile(
                        dense: true,
                        title: Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                            AppLocalizations.of(context).translate('qus3'),
                            style: styletext.cardfont(),
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(
                              top: 5, right: 0, bottom: 10),
                          child: Column(
                            children: <Widget>[
                              SizedBox(
                                height: 15,
                              ),
                              TextFormField(
                                controller: tempController,
                                keyboardType: TextInputType.number,
                                onSaved: (value) {
                                  setState(() {
                                    temp = value;
                                  });
                                },
                                onTap: () {
                                  setState(() {
                                    autoValidatorTemp = true;
                                  });
                                },
                               // autovalidate: autoValidatorTemp,
                                decoration: InputDecoration(
                                    icon: Icon(Icons.ac_unit),
                                    hintText: AppLocalizations.of(context)
                                        .translate('temp'),
                                    filled: true,
                                    fillColor: Colors.grey[200]),
                                validator: (value) {
                                  return value.isEmpty
                                      ? 'Temperature is required!'
                                      : null;
                                },
                              ),
                              SizedBox(
                                height: 27,
                              ),
                              TextFormField(
                                controller: heartrateController,
                                keyboardType: TextInputType.number,
                                onSaved: (value) {
                                  setState(() {
                                    heartrate = value;
                                  });
                                },
                                onTap: () {
                                  setState(() {
                                    autoValidatorHeartrate = true;
                                  });
                                },
                               // autovalidate: autoValidatorHeartrate,
                                decoration: InputDecoration(
                                    icon: Icon(Icons.loyalty),
                                    hintText: AppLocalizations.of(context)
                                        .translate('heart-rate'),
                                    filled: true,
                                    fillColor: Colors.grey[200]),
                                validator: (value) {
                                  return value.isEmpty
                                      ? 'Heart rate is required!'
                                      : null;
                                },
                              ),
                              SizedBox(
                                height: 27,
                              ),
                              TextFormField(
                                controller: respiratoryrateController,
                                keyboardType: TextInputType.number,
                                onSaved: (value) {
                                  setState(() {
                                    respiratoryrate = value;
                                  });
                                },
                                onTap: () {
                                  setState(() {
                                    autoValidatorRespiratory = true;
                                  });
                                },
                               // autovalidate: autoValidatorRespiratory,
                                decoration: InputDecoration(
                                    icon: Icon(Icons.record_voice_over),
                                    hintText: AppLocalizations.of(context)
                                        .translate('respiratory'),
                                    filled: true,
                                    fillColor: Colors.grey[200]),
                                validator: (value) {
                                  return value.isEmpty
                                      ? 'Respiratory rate is required!'
                                      : null;
                                },
                              ),
                              SizedBox(
                                height: 27,
                              ),
                              TextFormField(
                                controller: spo2Controller,
                                keyboardType: TextInputType.number,
                               // autovalidate: autoValidatorSpo2,
                                decoration: InputDecoration(
                                    icon: Icon(Icons.whatshot),
                                    hintText: AppLocalizations.of(context)
                                        .translate('spo2'),
                                    filled: true,
                                    fillColor: Colors.grey[200]),
                                onSaved: (value) {
                                  setState(() {
                                    spo2 = value;
                                  });
                                },
                                onTap: () {
                                  setState(() {
                                    autoValidatorSpo2 = true;
                                  });
                                },
                                validator: (value) {
                                  return value.isEmpty
                                      ? 'Spo2 is required!'
                                      : null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Center(
                  child: RaisedButton(
                      elevation: 5.0,
                      child: Text(
                          AppLocalizations.of(context)
                              .translate('update_button'),
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 17)),
                      textColor: Colors.white,
                      //color: Colors.blue,
                      onPressed: () async {
                        FocusScope.of(context).unfocus();
                             
                            await submit();
                            formKey.currentState.reset();
                            dialogBox.information(context, 'Update health info',
                                'Update successfull');
                                setState(() {
                                   tempController.text='';
                              heartrateController.text='';
                              respiratoryrateController.text='';
                              spo2Controller.text='';
                                });
                             
                            isSwitchedcough = true;
                            isSwitchedfever = true;
                            isSwitchedbreathing = true;
                            // autoValidatorHeartrate = false;
                            // autoValidatorRespiratory = false;
                            // autoValidatorSpo2 = false;
                            // autoValidatorTemp = false;
                            id=1;
                           

                        //   }
                        // }
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
