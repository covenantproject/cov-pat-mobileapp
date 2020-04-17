import 'dart:convert';
import 'dart:io';
import 'dart:convert' as JSON;
import 'package:covid/Models/TextStyle.dart';
import 'package:covid/Models/config/Configure.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RaiseHands extends StatefulWidget {
  const RaiseHands({Key key}) : super(key: key);

  @override
  _RaiseHandsState createState() => _RaiseHandsState();
}

class _RaiseHandsState extends State<RaiseHands> with TickerProviderStateMixin {
  TextStyleFormate styletext = TextStyleFormate();
  GoogleMapController _googleMapController;
  bool isSwitched = true;
   var _config;
  int id ;
  Configure _configure = new Configure();
   String radioItem = '';
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
  }
 submit()async{

   _config = _configure.serverURL();
var apiUrl = Uri.parse(_config.postman + '/raiseyourhand');
    // '/api/check?userName=$_username&checkName=$checkname&category=$category&description=$description&frequency=$frequency');
    var client = HttpClient(); // `new` keyword optional
    // 1. Create request
    try {
      HttpClientRequest request = await client.postUrl(apiUrl);
      request.headers.set('x-api-key', _config.apikey);
      request.headers.set('content-type', 'application/json; charset=utf-8');
      var payload = {
        "userid": 12,
    "requesttype": "",
    "requeststatus": "",
    "comments": ""
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
    return GestureDetector(onTap: () {
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
                        padding:
                            const EdgeInsets.only(top: 3, right: 30, bottom: 10),
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
             id!=null? Card(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    ListTile(
                      dense: true,
                      title: Padding(
                        padding: const EdgeInsets.only(top: 10),
                        // child: Text(
                        //   'Some more info:',
                        //   style: styletext.cardfont(),
                        // ),
                      ),
                      subtitle: Padding(
                        padding:
                            const EdgeInsets.only(top: 0, right: 0, bottom: 10),
                        child: Column(
                          children: <Widget>[
                            
                            TextFormField(
                              maxLines: 3,
                              decoration: InputDecoration(
                                  icon: Padding(
                                    padding: const EdgeInsets.only(bottom:35),
                                    child: Icon(Icons.comment),
                                  ),
                                  hintText: 'Comments',
                                  filled: true,
                                  fillColor: Colors.grey[200]),
                            ),
                           
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ):Container(),
              SizedBox(
                height: 10,
              ),
              Center(
                  child:id!=null? RaisedButton(
                      elevation: 5.0,
                      child: Text('Submit',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 17)),
                      textColor: Colors.white,
                      //color: Colors.blue,
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        submit();
                      },
                      shape: RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(80.0))):Container())
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