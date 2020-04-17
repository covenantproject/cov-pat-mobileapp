import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Landing extends StatefulWidget {
  @override
  _LandingState createState() => _LandingState();
}

class _LandingState extends State<Landing> {
 String isLoggedin;
  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  _loadUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
  isLoggedin=  prefs.getString('isloggedin');
    if (isLoggedin == "true") {
      Navigator.pushNamedAndRemoveUntil(
          context, '/homepage', ModalRoute.withName('/homepage'));
    } else {
        Navigator.pushNamedAndRemoveUntil(
            context, '/login', ModalRoute.withName('/login'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        child: Scaffold(body: Center(child: CircularProgressIndicator())));
  }
}
