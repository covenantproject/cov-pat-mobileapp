import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:covid/Models/config/Configure.dart';
import 'package:covid/App_localizations.dart';
import 'package:covid/Login.dart';
import 'package:covid/OtpPage.dart';
import 'package:covid/Models/util/DialogBox.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'dart:convert' as JSON;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterPage extends StatefulWidget {
  RegisterPage({
    Key key,
  }) : super(key: key);
  State<StatefulWidget> createState() {
    return _RegisterPageState();
  }
}

class _RegisterPageState extends State<RegisterPage> {
  //frequency data
  int _currentIndex = 1;
  bool _isAdmin;
  bool _isManager;
  bool _passwordObscureText = true;
  String _idProof;
  //status dropdown data
  String _networkStatus2;
  File sampleImage;
  String _name;
  String _dob;
  String _gender;
  String _username;
  String _idproofno;
  String _department;
  String _roleDescription;
  String _address;
  bool autoValidatorFirstName;
  bool autoValidatorLastName;
  bool autoValidatorPassword;
  bool autoValidatorDepartment;
  bool autoValidatorRole;
  bool autoValidatorEmail;
  bool _ismanager = false;
  bool _isadmin = false;
  Configure _configure = new Configure();
   TextEditingController dobcontroller;
  String url;
  var _config;
  final formKey = new GlobalKey<FormState>();
  String _admintoken = ' ';
  String _identitytoken = ' ';
  bool _isButtonTapped;
  DialogBox dialogBox =DialogBox();
  String mobileno;
  int statusCode;
  int _radioValue = 0;
  DateTime date;
//init
  @override
  void initState() {
    super.initState();
    dobcontroller=TextEditingController();
    autoValidatorFirstName = false;
    autoValidatorLastName = false;
    autoValidatorPassword = false;
    autoValidatorDepartment = false;
    autoValidatorRole = false;
    autoValidatorEmail = false;
    _isButtonTapped = false;
    _loadUserInfo();

    // _department = ' ';
  }
  _loadUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      mobileno=  prefs.getString('mobileno');
    });
  
   
  }

   String _genderResult ='Male';
  
  void _handleRadioValueChange(int value) {
    setState(() {
      _radioValue = value;
  
      switch (_radioValue) {
        case 0:
          _genderResult ='Male';
          break;
        case 1:
          _genderResult = 'Female';
          break;
        case 2:
          _genderResult = 'Other';
          break;
      }
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
                Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => LoginPage(),
              ));
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
   Future sendOtp() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
   var mobilenumber= prefs.getString('mobileno');
    _config = _configure.serverURL();
    var apiUrl = Uri.parse(_config.postman + '/otp?mobileNo=$mobilenumber');
    var client = HttpClient();
    // `new` keyword optional
    // 1. Create request
    try {
      HttpClientRequest request = await client.postUrl(apiUrl);
     // request.headers.set('x-api-key', _config.apikey);
      request.headers.set('content-type', 'application/json; charset=utf-8');
      var payload = {};
      request.write(JSON.jsonEncode(payload));
      print(JSON.jsonEncode(payload));
      // 3. Send the request
      HttpClientResponse response = await request.close();
      // 4. Handle the response
      var resStream = response.transform(Utf8Decoder());
      await for (var data in resStream) {
       
        print('Received data: $data');
        setState(() {
       // statusCode = response.statusCode;
        if(statusCode==500){
        //   loginjson=JSON.jsonDecode(data);
        // isregisteredno= loginjson['message'];
        }
        if(statusCode==200){
         // isregisteredno= data;
        }
      });
      }
      
    } catch (ex) {
      print('error $ex');
    }
  }

 void validateandsubmit() async {
    if (validateAndSave()) {
      FocusScope.of(context).unfocus();
      await register();
      if(statusCode==200){
        await sendOtp();
       // dialogBox.information(context, 'Self registration', 'Registration successfull');
        Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => OtpPage(),
              ));
      }else{
         dialogBox.information(context, 'Self registration', 'An error occured');
      }

    }
  }

  register() async {
    _config = _configure.serverURL();
    var apiUrl = Uri.parse(_config.postman + '/register');

    String formattedDate = DateFormat("yyyy-MM-dd").format(date);
    // '/api/check?userName=$_username&checkName=$checkname&category=$category&description=$description&frequency=$frequency');
    var client = HttpClient(); // `new` keyword optional
    // 1. Create request
    try {
      HttpClientRequest request = await client.postUrl(apiUrl);
      // request.headers.set('x-api-key', _config.apikey);
      request.headers.set('content-type', 'application/json; charset=utf-8');
      var payload = {
        "title": "Mr",
        "firstName": "$_name",
        "middleName": "middlename",
        "lastName": "$_name",
        "preferredName": "$_name",
        "shortName": "$_name",
        "suffix": "$_name",
        "dob": "$formattedDate",
        "address": "$_address",
        "gender": "$_genderResult",
        "mobileNo": "$mobileno",
        "photoId": "1"
      };
      request.write(JSON.jsonEncode(payload));
      print(JSON.jsonEncode(payload));
      // 3. Send the request
      HttpClientResponse response = await request.close();
      // 4. Handle the response
      var resStream = response.transform(Utf8Decoder());
       setState(() {
        statusCode = response.statusCode;
         // loginjson=JSON.jsonDecode(data);
         
      });
      await for (var data in resStream) {
        print('Received data: $data');
      }
    } catch (ex) {
      print('error $ex');
    }
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
      appBar: new AppBar(
        // leading: IconButton(
        //     iconSize: 24.0,
        //     onPressed: () {
        //       Navigator.pushReplacement(
        //       context,
        //       MaterialPageRoute(
        //         builder: (context) => LoginPage(),
        //       ));
        //     },
        //     color: Colors.blue,
        //     icon: Icon(
        //       Icons.arrow_back,
        //       color: Colors.white,
        //     )),
        title:
            new Text(AppLocalizations.of(context).translate('self_register')),
        //centerTitle: true,
      ),
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
                      // inputFormatters: [
                      //   WhitelistingTextInputFormatter(RegExp("[a-zA-Z]")),
                      // ],
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
                          hintText: AppLocalizations.of(context)
                              .translate('username'),
                          filled: true,
                          fillColor: Colors.grey[200]),
                      validator: (value) {
                        return value.isEmpty ? 'Full Name is Required' : null;
                      },
                      onSaved: (value) {
                        setState(() {
                          this._name = value;
                        });
                        return _name = value;
                      },
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    // Text(
                    //   'DOB',
                    // ),
                    TextFormField(
                      controller: dobcontroller,
                      keyboardType: TextInputType.text,
                      toolbarOptions:
                          ToolbarOptions(copy: true, cut: true, paste: true),
                      autovalidate: autoValidatorLastName,
                      onTap: () async {
                        date = DateTime(1900);
                        FocusScope.of(context).requestFocus(new FocusNode());
                        date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now());
                             dobcontroller.text =
                             "${DateFormat("yyyy-MM-dd").format(date)}"
                                                          .toString();
                      },
                      decoration: new InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[200],
                        icon: Icon(Icons.calendar_today),
                        hintText:
                            AppLocalizations.of(context).translate('user_dob'),
                      ),
                      validator: (value) {
                        return value.isEmpty ? 'Dob is Required' : null;
                      },
                      onChanged: (value){
                        setState(() {
                          this._dob = value;
                          dobcontroller.text=value;
                        });
                      },
                      onSaved: (value) {
                        setState(() {
                          this._dob = value;
                           dobcontroller.text=value;
                        });
                        return _dob = value;
                      },
                    ),
                    SizedBox(
                      height: 25,
                    ),

                    Padding(
                      padding: const EdgeInsets.only(right: 100),
                      child: Container(
                        child: new Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          // mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Icon(
                              Icons.supervisor_account,
                              color: Colors.grey,
                            ),
                            new Radio(
                              value: 0,
                              groupValue: _radioValue,
                              onChanged:_handleRadioValueChange,
                              
                            ),
                            new Text(
                                AppLocalizations.of(context).translate('male')),
                            new Radio(
                              value: 1,
                              groupValue:_radioValue,
                              onChanged:_handleRadioValueChange,
                            ),
                            new Text(AppLocalizations.of(context)
                                .translate('female')),
                            new Radio(
                              value: 2,
                              groupValue: _radioValue,
                              onChanged:_handleRadioValueChange
                            ),
                            new Text(AppLocalizations.of(context)
                                .translate('other')),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 25,
                    ),
                    Stack(children: <Widget>[
                      Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 35),
                          child: Container(
                            width: 340,
                            child: DropdownButtonFormField<String>(
                              value: _idProof,
                              decoration: InputDecoration(
                                  filled: true, fillColor: Colors.grey[200]),
                              hint: Text(
                                AppLocalizations.of(context)
                                    .translate('IdName'),
                              ),
                              isDense: true,

                              validator: (String value) {
                                if (value?.isEmpty ?? true) {
                                  return 'Select Identification Proof';
                                }
                              },
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
                              items: [
                                'Aadhaar',
                                'Driving License',
                                'PAN Card'
                              ].map<DropdownMenuItem<String>>((String value) {
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
                        padding: const EdgeInsets.only(top: 10),
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
                        hintText:
                            AppLocalizations.of(context).translate('idNo'),
                      ),

                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Proof id is required';
                        }
                      },
                      onSaved: (value) {
                        setState(() {
                          this._idproofno = value;
                        });
                        return _idproofno = value;
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
                        hintText: AppLocalizations.of(context)
                            .translate('user_address'),
                      ),
                      validator: (value) {
                        return value.isEmpty ? 'Address is required!' : null;
                      },
                      onSaved: (value) {
                        setState(() {
                          this._address = value;
                        });
                        return _address = value;
                      },
                    ),
                    SizedBox(
                      height: 25,
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        // RaisedButton(
                        //     elevation: 5.0,
                        //     child: Text(
                        //         AppLocalizations.of(context)
                        //             .translate('cancel_button'),
                        //         style: TextStyle(
                        //             fontWeight: FontWeight.bold, fontSize: 17)),
                        //     textColor: Colors.white,
                        //     // color: Colors.blue,
                        //     onPressed: _showPopUp1,
                        //     shape: RoundedRectangleBorder(
                        //         borderRadius: new BorderRadius.circular(80.0))),
                        // SizedBox(
                        //   width: 50,
                        // ),
                        RaisedButton(
                            elevation: 5.0,
                            child: Text(
                                AppLocalizations.of(context)
                                    .translate('register_button'),
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 17)),
                            textColor: Colors.white,
                            //color: Colors.blue,
                            onPressed: _isButtonTapped ? null :validateandsubmit,
                            shape: RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(80.0))),
                      ],
                    ),
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
            onPressed: register,
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
