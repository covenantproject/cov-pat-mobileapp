import 'dart:convert';
import 'dart:io';
import 'dart:convert' as JSON;
import 'package:intl/intl.dart';
import 'package:covid/App_localizations.dart';
import 'package:covid/Models/TextStyle.dart';
import 'package:covid/Models/config/Configure.dart';
import 'package:covid/Models/util/DialogBox.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RaiseHands extends StatefulWidget {
  const RaiseHands({Key key}) : super(key: key);

  @override
  _RaiseHandsState createState() => _RaiseHandsState();
}

class _RaiseHandsState extends State<RaiseHands> with TickerProviderStateMixin {
  TextStyleFormate styletext = TextStyleFormate();
  GoogleMapController _googleMapController;
  TextEditingController commentController;
  bool isSwitched = true;
  var _config;
  final formKey = new GlobalKey<FormState>();
  int id;
  int userId;
  bool autoValidatorComments;
  Configure _configure = new Configure();
  String radioItem = '';
  DialogBox dialogBox = DialogBox();
  String _comments;
  List<RadioList> fList = [
    RadioList(
      index: 1,
      name: "Contact your quarantine officer",
    ),
    RadioList(
      index: 2,
      name: "Contact your medical officer",
    ),
    RadioList(
      index: 3,
      name: "Request food / water / medicines",
    ),
  ];
  @override
  void initState() {
    super.initState();
    commentController=TextEditingController();
    autoValidatorComments = false;
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

  void validateandsubmit() async {
    if (validateAndSave()) {}
  }

  submit() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('userId');
    _config = _configure.serverURL();
    var apiUrl = Uri.parse(_config.postman + '/raiseyourhand');
    // '/api/check?userName=$_username&checkName=$checkname&category=$category&description=$description&frequency=$frequency');
    var client = HttpClient(); // `new` keyword optional
    // 1. Create request
    try {
      HttpClientRequest request = await client.postUrl(apiUrl);
      // request.headers.set('x-api-key', _config.apikey);
      request.headers.set('content-type', 'application/json; charset=utf-8');
      var payload = {
        "userId": userId,
        "requestType": "$radioItem",
        "requestStatus": "$radioItem",
        "requestDateTime":"${DateFormat('yyyy-MM-dd').format(DateTime.now())}",
        "requestComments": commentController.text
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
                      title: Padding(
                        padding: const EdgeInsets.only(top: 10),
                        // child: Text(
                        //   'How do you feel ?',
                        //   style: styletext.cardfont(),
                        // ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(
                            top: 3, right: 30, bottom: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: fList
                              .map((data) => RadioListTile(
                                    title: data.name ==
                                            'Contact your quarantine officer'
                                        ? Text(
                                            AppLocalizations.of(context)
                                                .translate(
                                                    'quarantine-officer'),
                                            style: styletext.placeholderStyle(),
                                          )
                                        : (data.name ==
                                                'Contact your medical officer')
                                            ? Text(AppLocalizations.of(context)
                                                .translate('medical-officer'))
                                            : (data.name ==
                                                    'Request food / water / medicines')
                                                ? Text(
                                                    AppLocalizations.of(context)
                                                        .translate('food'))
                                                : null,
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
              id != null
                  ? Card(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Form(
                            key: formKey,
                            child: ListTile(
                              dense: true,
                              title: Padding(
                                padding: const EdgeInsets.only(top: 10),
                                // child: Text(
                                //   'Some more info:',
                                //   style: styletext.cardfont(),
                                // ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(
                                    top: 0, right: 0, bottom: 10),
                                child: Column(
                                  children: <Widget>[
                                    TextFormField(
                                      controller:commentController ,
                                      maxLines: 3,
                                     // autovalidate: autoValidatorComments,
                                      onTap: () {
                                        setState(() {
                                          autoValidatorComments = true;
                                        });
                                      },
                                      validator: (value) {
                                        return value.isEmpty
                                            ? 'Comments is required!'
                                            : null;
                                      },
                                      decoration: InputDecoration(
                                          icon: Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 35),
                                            child: Icon(Icons.comment),
                                          ),
                                          hintText: AppLocalizations.of(context)
                                              .translate('comments'),
                                          filled: true,
                                          fillColor: Colors.grey[200]),
                                      onSaved: (String value) {
                                        setState(() {
                                          this._comments = value;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    )
                  : Container(),
              SizedBox(
                height: 10,
              ),
              Center(
                  child: id != null
                      ? RaisedButton(
                          elevation: 5.0,
                          child: Text(
                              AppLocalizations.of(context).translate('submit'),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 17)),
                          textColor: Colors.white,
                          //color: Colors.blue,
                          onPressed: () async {
                            FocusScope.of(context).unfocus();
                          
                              
                              await submit();
                               dialogBox.information(context, 'Raise your hand',
                                'Raise hand Submitted');
                                formKey.currentState.reset();
                            setState(() {
                              id = null;
                            });
                           
                           
                          },
                          shape: RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(80.0)))
                      : Container())
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
