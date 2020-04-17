import 'dart:io';
import 'package:covid/Models/ProfileModel.dart';
import 'package:covid/Models/config/Configure.dart';
import 'package:http/http.dart' as http;
import 'package:covid/Models/TextStyle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Profile extends StatefulWidget {
  const Profile({Key key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile>
    with TickerProviderStateMixin {
 //frequency data
  int _currentIndex = 1;
  bool _isAdmin;
  bool _isManager;
  bool _passwordObscureText = true;
  String _idProof;
  TextStyleFormate styletext = TextStyleFormate();
  //status dropdown data
  String _networkStatus2;
  File sampleImage;
  String _firstname;
  String _lastName;
  String _username;
  String _password;
  String _department;
  String _roleDescription;
  String _email;
  bool autoValidatorFirstName;
  bool autoValidatorLastName;
  bool autoValidatorPassword;
  bool autoValidatorDepartment;
  bool autoValidatorRole;
  bool autoValidatorEmail;
  bool _ismanager = false;
  bool _isadmin = false;
  Configure _configure = new Configure();
  String url;
  var _config;
  final formKey = new GlobalKey<FormState>();
  String _admintoken = ' ';
  String _identitytoken = ' ';
  bool _isButtonTapped;
  ProfileModel profileModel;
//init
  @override
  void initState() {
    super.initState();
    autoValidatorFirstName = false;
    autoValidatorLastName = false;
    autoValidatorPassword = false;
    autoValidatorDepartment = false;
    autoValidatorRole = false;
    autoValidatorEmail = false;
    _isButtonTapped = false;
    _loadUserInfo();
    getJsondata();
    // _department = ' ';
  }
Future<String> getJsondata() async { 
  _config = _configure.serverURL();
    String profileurl = _config.sit +
        "/profile?userId=2";
    var profileresponse;
    try {
      profileresponse =
          await http.get(Uri.encodeFull(profileurl), headers: {
        "Accept": "*/*",
        //'Authorization': 'Bearer ',
        //'x-api-key':_config.apikey
      });
    } catch (ex) {
      print('error $ex');
    }
    setState(() {
      profileModel = profileModelFromJson(profileresponse.body);
    });
    return "Success";
  }
  _loadUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // SharedPreferences prefs2 = await SharedPreferences.getInstance();
    _isAdmin = (prefs.getBool('Admin') ?? false);
    _isManager = (prefs.getBool('Manager') ?? false);
    _admintoken = (prefs.getString('admintoken') ?? "");
    _username = (prefs.getString('useremail') ?? "");
    _identitytoken = (prefs.getString('identitytoken') ?? "");
    setState(() {
      _admintoken = prefs.getString('admintoken');
      _username = prefs.getString('useremail');
      _identitytoken = (prefs.getString('identitytoken') ?? "");
      _isAdmin = prefs.getBool('Admin');
      _isManager = prefs.getBool('Manager');
    });
  }

  void _showPopUp() {
    showDialog<Null>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return new AlertDialog(
          titlePadding: EdgeInsets.fromLTRB(30, 20, 0, 10),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: new Text(
            'Are you sure to create this user?',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: <Widget>[
            new FlatButton(
              child: new Text(
                'Yes',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: () async {
                // Navigator.of(context).pop();
                // Navigator.of(context).pop();
                //  formKey.currentState.reset();
                Navigator.pop(context);
                Navigator.pop(context);

                // Navigator.pushNamed(context, '/admin');
                setState(() {
                  _department = null;
                });
              },
            ),
            new FlatButton(
              child: new Text(
                'No',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                //formKey.currentState.reset();
              },
            ),
          ],
        );
      },
    );
  }

  void _showPopUp1() {
    showDialog<Null>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return new AlertDialog(
          titlePadding: EdgeInsets.fromLTRB(30, 20, 0, 10),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: new Text(
            'Are You Sure Want to Cancel?',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: <Widget>[
            new FlatButton(
              child: new Text(
                'Yes',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                formKey.currentState.reset();
              },
            ),
            new FlatButton(
              child: new Text(
                'No',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

//validate form
  bool validateAndSave() {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    } else {
      return false;
    }
  }

  void uploadCheck() async {
    Navigator.pushNamedAndRemoveUntil(
        context, '/home', ModalRoute.withName('/home'));
  }

  String dropdownValue = ' ';
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitUp,
      // DeviceOrientation.portraitDown,
    ]);

    return Scaffold(
      resizeToAvoidBottomPadding: true,
      // appBar: new AppBar(
      //   leading: IconButton(
      //       iconSize: 24.0,
      //       onPressed: () {
      //         Navigator.of(context).pop();
      //       },
      //       color: Colors.blue,
      //       icon: Icon(
      //         Icons.arrow_back,
      //         color: Colors.white,
      //       )),
      //   title: new Text("Self Registration"),
      //   //centerTitle: true,
      // ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: ListView(
          children: <Widget>[
            new Form(
              key: formKey,
              child: Container(
                margin: EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    TextFormField(
                      initialValue: '${profileModel.preferredName}'??' ',
                      readOnly: true,
                      inputFormatters: [
                        WhitelistingTextInputFormatter(RegExp("[a-zA-Z]")),
                      ],
                      keyboardType: TextInputType.text,
                      toolbarOptions:
                          ToolbarOptions(copy: true, cut: true, paste: true),
                      // autovalidate: autoValidatorFirstName,
                      onTap: () {
                        setState(() {
                          autoValidatorFirstName = true;
                        });
                      },
                      decoration: new InputDecoration(
                          icon: Icon(Icons.account_circle),
                          hintText: 'Full Name',

                          filled: true,
                          fillColor: Colors.grey[200]),
                      validator: (value) {
                        return value.isEmpty ? 'Full Name is Required' : null;
                      },
                      onSaved: (value) {
                        setState(() {
                          this._firstname = value;
                        });
                        return _firstname = value;
                      },
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    // Text(
                    //   'DOB',
                    // ),
                    TextFormField(
                      initialValue: '${profileModel.dob}'??' ',
                      readOnly: true,
                      keyboardType: TextInputType.text,
                      toolbarOptions:
                          ToolbarOptions(copy: true, cut: true, paste: true),
                      autovalidate: autoValidatorLastName,
                      onTap: () async {
                       
                      },
                      decoration: new InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[200],
                        icon: Icon(Icons.calendar_today),
                        hintText: 'DOB (DD/MM/YYYY)',
                      ),
                      validator: (value) {
                        return value.isEmpty ? 'Last Name is Required' : null;
                      },
                      onSaved: (value) {
                        setState(() {
                          this._lastName = value;
                        });
                        return _lastName = value;
                      },
                    ),
                    SizedBox(
                      height: 40,
                    ),

                   TextFormField(
                      initialValue: '${profileModel.gender}'??'',
                      readOnly: true,
                      inputFormatters: [
                        WhitelistingTextInputFormatter(RegExp("[a-zA-Z]")),
                      ],
                      keyboardType: TextInputType.text,
                      toolbarOptions:
                          ToolbarOptions(copy: true, cut: true, paste: true),
                      // autovalidate: autoValidatorFirstName,
                      onTap: () {
                        setState(() {
                          autoValidatorFirstName = true;
                        });
                      },
                      decoration: new InputDecoration(
                          icon: Icon(Icons.supervisor_account),
                          hintText: 'Full Name',

                          filled: true,
                          fillColor: Colors.grey[200]),
                      validator: (value) {
                        return value.isEmpty ? 'Full Name is Required' : null;
                      },
                      onSaved: (value) {
                        setState(() {
                          this._firstname = value;
                        });
                        return _firstname = value;
                      },
                    ),
                    SizedBox(
                      height: 35,
                    ),
                    Stack(children: <Widget>[
                      Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.only(left:35),
                          child: Container(width: 340,
                            child: DropdownButtonFormField<String>(
                              value: _idProof,
                              icon:
                              Icon(Icons.done),
                                decoration: InputDecoration(filled: true,fillColor: Colors.grey[200]),
                              hint: Text(
                                'Select Identification Proof',
                              ),
                              isDense: true,
                              
                              
                              // validator: (String value) {
                              //   if (value?.isEmpty ?? true) {
                              //     return 'Select Identification Proof';
                              //   }
                              // },
                              //icon: Icon(Icons.arrow_drop_down),
                              //isExpanded: true,
                              iconSize: 24,
                              elevation: 16,
                              // style: TextStyle(
                              //     color: Colors.black, fontWeight: FontWeight.w600),
                              // // underline: Container(
                              //   height: 1,
                              //   color: Colors.grey.shade400,
                              // ),
                              onChanged: (String newValue) {
                                FocusScope.of(context)
                                    .requestFocus(new FocusNode());
                                setState(() {
                                  this._idProof = newValue;
                                });
                              },
                              items: ['Aadhaar', 'Driving License', 'PAN Card']
                                  .map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                      Container(
                          child: Padding(
                            padding: const EdgeInsets.only(top:10),
                            child: Icon(
                        Icons.perm_identity,
                        color: Colors.grey,
                      ),
                          )),
                    ]),

                    SizedBox(
                      height: 40,
                    ),
                    TextFormField(
                       initialValue: '77362 77327 32983',
                      readOnly: true,
                      toolbarOptions:
                          ToolbarOptions(copy: true, cut: true, paste: true),
                      //obscureText: true,
                      autovalidate: autoValidatorPassword,
                     // obscureText: _passwordObscureText,
                      onTap: () {
                        setState(() {
                          autoValidatorPassword = true;
                        });
                      },
                      decoration: new InputDecoration(
                        icon: Icon(Icons.assignment_ind),
                        filled: true,
                        fillColor: Colors.grey[200],
                        hintText: 'Proof Id (Optional)',
                      ),

                      validator: (newpassword) {},
                      onSaved: (value) {
                        setState(() {
                          this._password = value;
                        });
                        return _password = value;
                      },
                    ),

                    SizedBox(
                      height: 25,
                    ),
                    // Text(
                    //   'Photo (Optional)',
                    //  style: TextStyle(fontWeight: FontWeight.bold)
                    // ),
                    // SizedBox(
                    //   height: 15,
                    // ),
                    // FlatButton(color: Colors.grey[200],
                    //   onPressed: (){}, child: Text('Pick Image')),

                    // SizedBox(
                    //   height: 10,
                    // ),
                    SizedBox(
                      height: 20,
                    ),
                    // Text(
                    //   'Address',
                    // ),
                    TextFormField(
                       initialValue: '${profileModel.address}'??' ',
                      readOnly: true,
                      maxLines: 3,
                      toolbarOptions:
                          ToolbarOptions(copy: true, cut: true, paste: true),
                      autovalidate: autoValidatorEmail,
                      onTap: () {
                        setState(() {
                          autoValidatorEmail = true;
                        });
                      },
                      decoration: new InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[200],
                        icon: Padding(
                          padding: const EdgeInsets.only(bottom: 35),
                          child: Icon(Icons.home),
                        ),
                        hintText: 'Address (Optional)',
                      ),
                      validator: (value) {
                        // return value.isEmpty ? 'Email is required!' : null;
                      },
                      onSaved: (value) {
                        setState(() {
                          this._email = value;
                        });
                        return _email = value;
                      },
                    ),
                    SizedBox(
                      height: 25,
                    ),

                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.center,
                    //   children: <Widget>[
                    //     RaisedButton(
                    //         elevation: 5.0,
                    //         child: Text('Cancel',
                    //             style: TextStyle(
                    //                 fontWeight: FontWeight.bold, fontSize: 17)),
                    //         textColor: Colors.white,
                    //         // color: Colors.blue,
                    //         onPressed: _showPopUp1,
                    //         shape: RoundedRectangleBorder(
                    //             borderRadius: new BorderRadius.circular(80.0))),
                    //     SizedBox(
                    //       width: 50,
                    //     ),
                    //     RaisedButton(
                    //         elevation: 5.0,
                    //         child: Text('Register',
                    //             style: TextStyle(
                    //                 fontWeight: FontWeight.bold, fontSize: 17)),
                    //         textColor: Colors.white,
                    //         //color: Colors.blue,
                    //         onPressed: _isButtonTapped ? null : uploadCheck,
                    //         shape: RoundedRectangleBorder(
                    //             borderRadius: new BorderRadius.circular(80.0))),
                    //   ],
                    // ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget enableCheck() {
    return Container(
        child: new Form(
      key: formKey,
      child: Column(
        children: <Widget>[
          Image.file(
            sampleImage,
            height: 310.0,
            width: 630.0,
          ),
          SizedBox(
            height: 15.0,
          ),
          SizedBox(
            height: 15.0,
          ),
          RaisedButton(
            elevation: 10.0,
            child: Text('Add a new Check' ?? ''),
            textColor: Colors.white,
            color: Colors.blue,
            onPressed: uploadCheck,
          )
        ],
      ),
    ));
  }
}
class GroupModel {
  String text;
  int index;
  GroupModel({this.text, this.index});
}