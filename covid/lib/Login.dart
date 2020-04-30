import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:convert' as JSON;
import 'package:covid/App_localizations.dart';
import 'package:covid/Models/config/Configure.dart';
import 'package:covid/Models/util/DialogBox.dart';
import 'package:covid/OtpPage.dart';
import 'package:covid/RegisterPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  LoginPage();
  State<StatefulWidget> createState() {
    return _LoginPageState();
  }
}

enum FormType { login, register }

class _LoginPageState extends State<LoginPage> {
  final formKey = new GlobalKey<FormState>();
  FormType _formType = FormType.login;
  String _email = "";
  String _password = "";
  String _button = "login";
  String _username = '';
  int statusCode=0;
  bool isLoading = false;
  int code;
  String isregisteredno;
  bool ismanager;
  bool isAdmin;
  var _config;
  var loginjson;
  String _apitoken;
  bool loading = false;
  bool _isButtonTapped;
  bool _passwordObscureText = true;
  Configure _configure = new Configure();
  DialogBox dialogBox =DialogBox();

  @override
  void initState() {
    super.initState();
    _isButtonTapped = false;
     isLoading = false;
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      //DeviceOrientation.portraitDown,
    ]);
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

    Future login(mobilenumber) async {
    _config = _configure.serverURL();
    var apiUrl = Uri.parse(_config.postman + '/otp?mobileNo=$mobilenumber');
    var client = HttpClient();
    // `new` keyword optional
    // 1. Create request
    try {
      HttpClientRequest request = await client.postUrl(apiUrl);
      //request.headers.set('api-key', _config.apikey);
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
        statusCode = response.statusCode;
        if(statusCode==500){
          loginjson=JSON.jsonDecode(data);
        isregisteredno= loginjson['message'];
        }
        if(statusCode==200){
          isregisteredno= data;
        }
      });
      }
      
    } catch (ex) {
      print('error $ex');
    }
  }

//Submit
  void validateAndSubmit() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    
    if (validateAndSave()) {
      isLoading = true;
      setState(() => _isButtonTapped = !_isButtonTapped);
      if (_formType == FormType.login) {
        FocusScope.of(context).unfocus();
        await login(mobilenumbercontroller.text);
        if (statusCode ==200&&isregisteredno=='SUCCESS') {
         // prefs.setString('isloggedin', "true");
          prefs.setString('mobileno', mobilenumbercontroller.text);
         // Navigator.pop(context);
          //dialogBox.information(context, "Login", "Otp sent");
          setState(() {
            isLoading=false;
          });
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => OtpPage(),
              ));
        } else if(statusCode==500&&isregisteredno=='REC_NOT_FOUND'){
           prefs.setString('mobileno', mobilenumbercontroller.text);
           //dialogBox.information(context, "Login", "Not a registred mobile number");
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => RegisterPage(),
              ));
          // dialogBox.information(context, "Login", "An error occured");
         setState(() {
           isLoading=false;
         });
        }else if(statusCode==500){
          dialogBox.information(context, "Login", "An error occured");
           setState(() {
           isLoading=false;
         });
        }
      }
    }
    setState(() {
      _isButtonTapped=false;
    });
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
        maxLength: 10,
        decoration: new InputDecoration(
            icon: Icon(
              Icons.phone,
              size: 22.0,
              // color: Colors.blue,
            ),
            labelText:  AppLocalizations.of(context).translate('login_number')),
        validator: (value) {
          String returnValue;
           if (value.isEmpty) {
            returnValue =AppLocalizations.of(context).translate('mobilenumberrequired');
          }
          else if(value.length<10){
             returnValue =AppLocalizations.of(context).translate('invalidmobilenumber');

          }
          return returnValue;
          //else return'';
         
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
       isLoading==true?CircularProgressIndicator(): new RaisedButton(
            child: new Text(AppLocalizations.of(context).translate('login_button'), style: new TextStyle(fontSize: 20.0)),
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
