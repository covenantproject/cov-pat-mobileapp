import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:convert' as JSON;
import 'package:covid/App_localizations.dart';
import 'package:covid/HomePage.dart';
import 'package:covid/main.dart';
import 'package:covid/Models/config/Configure.dart';
import 'package:covid/Models/util/DialogBox.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OtpPage extends StatefulWidget {
  OtpPage();
  State<StatefulWidget> createState() {
    return _OtpPageState();
  }
}

enum FormType { login, register }

class _OtpPageState extends State<OtpPage> {
  final formKey = new GlobalKey<FormState>();
  FormType _formType = FormType.login;
  String _email = "";
  String _password = "";
  String _button = "login";
  String _username = '';
  int statusCode = 0;
  bool isLoading = false;
  int code;
  bool ismanager;
  bool isAdmin;
  var _config;
  String _apitoken;
  int userId;
  bool loading = false;
  String mobileno;
  bool _isButtonTapped;
  bool _passwordObscureText = true;
  Configure _configure = new Configure();
 DialogBox dialogBox =DialogBox();
  @override
  void initState() {
    super.initState();
    _isButtonTapped = false;
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      //DeviceOrientation.portraitDown,
    ]);
    _loadUserInfo();
  }
  _loadUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    mobileno=prefs.getString('mobileno');
  }
  //Functions
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController mobilenumbercontroller = new TextEditingController();
  TextEditingController passwordcontroller = new TextEditingController();
  void showInSnackBar(String value) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(value)));
  }

  bool validateAndSave() {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      //_handleSubmit();
      return true;
    } else {
      return false;
    }
  }

  Future validateotp(otpcode) async {
    _config = _configure.serverURL();
    var apiUrl =
        Uri.parse(_config.postman + '/validateOtp?mobileNo=$mobileno&otpCode=$otpcode');
    var client = HttpClient(); // `new` keyword optional
    try {
      HttpClientRequest request = await client.postUrl(apiUrl);
      request.headers.set('api-key', _config.apikey);
      request.headers.set('content-type', 'application/json; charset=utf-8');
      var payload = {};
      request.write(JSON.jsonEncode(payload));
      print(JSON.jsonEncode(payload));
      // 3. Send the request
      HttpClientResponse response = await request.close();
      // 4. Handle the response
      var resStream = response.transform(Utf8Decoder());
      setState(() {
        statusCode = response.statusCode;
      });
      await for (var data in resStream) {
        setState(() {
          userId=int.parse(data);
        });
        print('Received data: $data');
      }
    } catch (ex) {
      print('error $ex');
    }
  }

//Submit
  void validateAndSubmit() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isLoading = true;
    if (validateAndSave()) {
      setState(() => _isButtonTapped = !_isButtonTapped);
      if (_formType == FormType.login) {
        FocusScope.of(context).unfocus();
      await validateotp(mobilenumbercontroller.text);
      if(statusCode==200){
        prefs.setInt('userId', userId);
        prefs.setString('isloggedin', "true");
        // Navigator.pop(context);
       // runApp(MyApp());
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(
                type: BottomNavigationDemoType.withLabels,
              ),
            ));
            setState(() {
              _isButtonTapped=false;
            });
      }else{
        dialogBox.information(context, AppLocalizations.of(context).translate('validate_otp'), AppLocalizations.of(context).translate('invalid_otp_number'));
        setState(() {
          _isButtonTapped=false;
        });
      }
       
      }
    }
  }

  //Login
  void moveToLogin() {
    formKey.currentState.reset();
    setState(() {});
  }

  @override
  void dispose() {
    mobilenumbercontroller.dispose();
    //subscription.cancel();
    super.dispose();
  }

  //Design
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitUp,
    ]);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      resizeToAvoidBottomPadding: false,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: ListView(
          children: <Widget>[
            new Container(
                color: Colors.white,
                margin: EdgeInsets.all(15.0),
                child: new Form(
                    key: formKey,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 50),
                      child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: createInputs() + createButtons(),
                      ),
                    )))
          ],
        ),
      ),
    );
  }

  //Login Input fields
  List<Widget> createInputs() {
    return [
      SizedBox(height: 20.0),
      Container(
        padding: EdgeInsets.only(right: 18),
        child: logo(),
      ),
      SizedBox(height: 45.0),
      new TextFormField(
        onEditingComplete: () {
          FocusScope.of(context).unfocus();
        },
        controller: mobilenumbercontroller,
        cursorColor: Colors.blue,
        keyboardType: TextInputType.number,
        maxLength: 4,
        decoration: new InputDecoration(
            icon: Icon(
              Icons.security,
              size: 22.0,
              // color: Colors.blue,
            ),
            labelText: AppLocalizations.of(context).translate('enter_otp')),
        validator: (value) {
          //  if (value.isEmpty) {
          //   return 'Mobile Number is Required';
          // }
          // return 'Invalid Mobile Number';

          // return value.isEmpty ? 'Email is required!' : null;
        },
        onSaved: (value) {
          return _email = value;
        },
      ),
      SizedBox(height: 25),
      //_username==null? Text('Invalid Username or Password'):Text('')
    ];
  }

  //My Logo
  Widget logo() {
    return SafeArea(
      child: new Column(
        children: <Widget>[
          Image.asset('assets/image1.png',height: 120,width: 120,),
          SizedBox(
            height: 20,
          ),
          Text(
            AppLocalizations.of(context).translate('title'),
            style: TextStyle(fontSize: 30),
          )
        ],
      ),
    );
  }

  //Login and forgot Password Buttons
  List<Widget> createButtons() {
    if (_formType == FormType.login) {
      //Login
      return [
        new RaisedButton(
            child: new Text(AppLocalizations.of(context).translate('otp_button'), style: new TextStyle(fontSize: 20.0)),
            textColor: Colors.white,
            // color: Colors.blueAccent,
            onPressed: _isButtonTapped ? () {} : validateAndSubmit,
            shape: RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(10.0))),
      ];
    } else {
      //Register
      return [
        new RaisedButton(
            child: new Text("Create Account",
                style: new TextStyle(fontSize: 20.0)),
            textColor: Colors.white,
            color: Colors.blueAccent,
            onPressed: validateAndSubmit,
            shape: RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(10.0))),
        new FlatButton(
          child: new Text("Already have an Account? Login now",
              style: new TextStyle(fontSize: 14.0)),
          textColor: Colors.red,
          color: Colors.transparent,
          onPressed: moveToLogin,
        )
      ];
    }
  }
}
