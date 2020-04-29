import 'dart:io';
import 'package:intl/intl.dart';
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
  String _idProof='Aadhaar';
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
  int userId;
  TextEditingController namecontroller=TextEditingController();
  TextEditingController surnamecontroller=TextEditingController();
  TextEditingController titlecontroller=TextEditingController();
  TextEditingController dobcontroller=TextEditingController();
  TextEditingController gendercontroller=TextEditingController();
  TextEditingController proofidnocontroller=TextEditingController();
  TextEditingController addresstypecontroller=TextEditingController();
  TextEditingController proofcontroller=TextEditingController();
   TextEditingController proofauthcontroller=TextEditingController();
  TextEditingController countrystatecontroller=TextEditingController();
  TextEditingController addresscontroller=TextEditingController();
  TextEditingController addresscontroller2=TextEditingController();
  TextEditingController addresscontroller3=TextEditingController();
  TextEditingController citytownvilagecontroller=TextEditingController();
  TextEditingController districtcontroller=TextEditingController();
  TextEditingController pincodecontroller=TextEditingController();
  TextEditingController statecontroller=TextEditingController();
  String name;
  String dob;
  String gender;
  String proofidno;
  String address;
  ProfileModel profileModel;
  String addressLine2;
  String addressLine3;
//init
  @override
  void initState() {
    super.initState();
     getJsondata();
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
Future<String> getJsondata() async { 
   SharedPreferences prefs = await SharedPreferences.getInstance();
    userId=prefs.getInt('userId');
  _config = _configure.serverURL();
    String profileurl = _config.postman +
        "/profile?userId=$userId";
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
      namecontroller.text=profileModel.firstName;
      titlecontroller.text=profileModel.title;
      surnamecontroller.text=profileModel.lastName;
      addresstypecontroller.text=profileModel.addressType;
      proofcontroller.text=profileModel.proofType;
      addresscontroller.text=profileModel.addressLine1;
      addresscontroller2.text=profileModel.addressLine2;
      addresscontroller3.text=profileModel.addressLine3;
      citytownvilagecontroller.text=profileModel.city;
      districtcontroller.text=profileModel.district;
      pincodecontroller.text=profileModel.pinCode;
      statecontroller.text=profileModel.state;
      dobcontroller.text=DateFormat.yMMMd().format(profileModel.dob);
      proofidnocontroller.text=profileModel.proofNumber;
      addresscontroller.text=profileModel.addressLine1;
      gendercontroller.text=profileModel.gender;
      proofidnocontroller.text=profileModel.proofNumber;
      try{
        proofauthcontroller.text=profileModel.proofAuthority;
        } catch(ex){
          proofauthcontroller.text="";
        }
      
        if(addresscontroller2.text == null || addresscontroller2.text==""){
          addressLine2 = "";
        }else{
          addressLine2 = addresscontroller2.text +"," + "\n";
        }

        if(addresscontroller3.text == null || addresscontroller3.text==""){
          addressLine3 = "";
        }else{
          addressLine3 = addresscontroller3.text +"," + "\n";
        }

      proofcontroller.text=profileModel.proofType;
      addresstypecontroller.text = addresstypecontroller.text + ":" +"\n"+ addresscontroller.text + "\n" +
                                   addressLine2 + addressLine3 +
                                  citytownvilagecontroller.text + ", " + districtcontroller.text + "\n" +
                                  statecontroller.text +" "+pincodecontroller.text;

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
        child:profileModel == null
                                  ? Center(
                                      child: Container(
                                          padding: EdgeInsets.all(0),
                                          child: Container(
                                              child:
                                                  const CircularProgressIndicator(
                                            strokeWidth: 3,
                                          ))),
                      
                                    )
                                  : RefreshIndicator(
                                      onRefresh: getJsondata,
                                      child: profileModel ==null
                                          ? ListView(
                                              children: <Widget>[
                                                Container(
                                                  // color: Colors.red,
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height /
                                                      1.4,
                                                  child: Align(
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                        'Loading',
                                                        style: styletext
                                                            .emptylist()),
                                                  ),
                                                ),
                                              ],
                                            ): ListView(
          children: <Widget>[
            new Form(
              key: formKey,
              child: Container(
                margin: EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    TextField(
                      controller:titlecontroller ,
                     // initialValue: '$name'??'-',
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
                          hintText: 'Title',

                          filled: true,
                          fillColor: Colors.grey[200]),
                      // validator: (value) {
                      //   return value.isEmpty ? 'Full Name is Required' : null;
                      // },
                      // onSaved: (value) {
                      //   setState(() {
                      //     this._firstname = value;
                      //   });
                      //   return _firstname = value;
                      // },
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    TextField(
                      controller:namecontroller ,
                     // initialValue: '$name'??'-',
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
                      // validator: (value) {
                      //   return value.isEmpty ? 'Full Name is Required' : null;
                      // },
                      // onSaved: (value) {
                      //   setState(() {
                      //     this._firstname = value;
                      //   });
                      //   return _firstname = value;
                      // },
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    TextField(
                      controller:surnamecontroller ,
                     // initialValue: '$name'??'-',
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
                          hintText: 'Surname',

                          filled: true,
                          fillColor: Colors.grey[200]),
                      // validator: (value) {
                      //   return value.isEmpty ? 'Full Name is Required' : null;
                      // },
                      // onSaved: (value) {
                      //   setState(() {
                      //     this._firstname = value;
                      //   });
                      //   return _firstname = value;
                      // },
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    // Text(
                    //   'DOB',
                    // ),
                    TextField(
                     // initialValue: '$dob',
                     controller: dobcontroller,
                      readOnly: true,
                      keyboardType: TextInputType.text,
                      toolbarOptions:
                          ToolbarOptions(copy: true, cut: true, paste: true),
                      // autovalidate: autoValidatorLastName,
                      // onTap: () async {
                       
                      // },
                      decoration: new InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[200],
                        icon: Icon(Icons.calendar_today),
                        hintText: 'DOB (DD/MM/YYYY)',
                      ),
                   
                    ),
                    SizedBox(
                      height: 40,
                    ),

                   TextField(
                     // initialValue: '$gender'??'-',
                     controller: gendercontroller,
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
                     
                    ),
                    SizedBox(
                      height: 35,
                    ),
                    Container(
                      child: TextField(
                    controller: proofcontroller,
                
                    readOnly: true,
                    toolbarOptions:
                    ToolbarOptions(copy: true, cut: true, paste: true),
                    
                    onTap: () {
                    setState(() {
                    autoValidatorPassword = true;
                    });
                    },
                    decoration: new InputDecoration(
                    icon: Icon(Icons.perm_identity),
                    filled: true,
                    fillColor: Colors.grey[200],
                    hintText: 'Proof type',
                    ),
                    ),
                    ),
                    proofcontroller.text=="Driving License"||proofcontroller.text=="Passport"?SizedBox(
                      height: 40,
                    ):Container(),
                   proofcontroller.text=="Driving License"||proofcontroller.text=="Passport"? Container(
                      child: TextField(
                    controller:proofauthcontroller ,
                    
                    readOnly: true,
                    toolbarOptions:
                    ToolbarOptions(copy: true, cut: true, paste: true),
                   
                    onTap: () {
                    setState(() {
                    autoValidatorPassword = true;
                    });
                    },
                    decoration: new InputDecoration(
                    icon: Icon(Icons.perm_identity),
                    filled: true,
                    fillColor: Colors.grey[200],
                    hintText: 'Proof type',
                    ),
                    ),
                    ):Container(),
                

                    SizedBox(
                      height: 40,
                    ),
                    TextField(
                      controller: proofidnocontroller,
                      // initialValue: '77362 77327 32983',
                      readOnly: true,
                      toolbarOptions:
                          ToolbarOptions(copy: true, cut: true, paste: true),
                      //obscureText: true,
                     // autovalidate: autoValidatorPassword,
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
                        hintText: 'Proof no',
                      )
                    ),

                    SizedBox(
                      height: 30,
                    ),
                     TextField(
                      controller: addresstypecontroller,
                      maxLines: 8,
                      // initialValue: '77362 77327 32983',
                      readOnly: true,
                      toolbarOptions:
                          ToolbarOptions(copy: true, cut: true, paste: true),
                      //obscureText: true,
                     // autovalidate: autoValidatorPassword,
                     // obscureText: _passwordObscureText,
                      onTap: () {
                        setState(() {
                          autoValidatorPassword = true;
                        });
                      },
                      decoration: new InputDecoration(
                        icon: Icon(Icons.home),
                        filled: true,
                        fillColor: Colors.grey[200],
                        hintText: 'Address type',
                        
                      )
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
                    // SizedBox(
                    //   height: 30,
                    // ),
                   
                    // TextField(
                    //    controller: addresscontroller,
                    //   readOnly: true,
                    //   // maxLines: 1,
                    //   toolbarOptions:
                    //       ToolbarOptions(copy: true, cut: true, paste: true),
                    //  // autovalidate: autoValidatorEmail,
                    //   onTap: () {
                    //     setState(() {
                    //       autoValidatorEmail = true;
                    //     });
                    //   },
                    //   decoration: new InputDecoration(
                    //     filled: true,
                    //     fillColor: Colors.grey[200],
                    //     icon: Padding(
                    //       padding: const EdgeInsets.only(),
                    //       child: Icon(Icons.home),
                    //     ),
                    //     hintText: 'Address Line 1',
                    //   ),
                     
                    // ),
                    // SizedBox(
                    //   height: 25,
                    // ),
                    // TextField(
                    //    controller: addresscontroller2,
                    //   readOnly: true,
                    //   // maxLines: 1,
                    //   toolbarOptions:
                    //       ToolbarOptions(copy: true, cut: true, paste: true),
                    //  // autovalidate: autoValidatorEmail,
                    //   onTap: () {
                    //     setState(() {
                    //       autoValidatorEmail = true;
                    //     });
                    //   },
                    //   decoration: new InputDecoration(
                    //     filled: true,
                    //     fillColor: Colors.grey[200],
                    //     icon: Padding(
                    //       padding: const EdgeInsets.only(),
                    //       child: Icon(Icons.home),
                    //     ),
                    //     hintText: 'Address Line 2',
                    //   ),
                     
                    // ),
                    // SizedBox(
                    //   height: 25,
                    // ),
                    // TextField(
                    //    controller: addresscontroller3,
                    //   readOnly: true,
                    //   // maxLines: 1,
                    //   toolbarOptions:
                    //       ToolbarOptions(copy: true, cut: true, paste: true),
                    //  // autovalidate: autoValidatorEmail,
                    //   onTap: () {
                    //     setState(() {
                    //       autoValidatorEmail = true;
                    //     });
                    //   },
                    //   decoration: new InputDecoration(
                    //     filled: true,
                    //     fillColor: Colors.grey[200],
                    //     icon: Padding(
                    //       padding: const EdgeInsets.only(),
                    //       child: Icon(Icons.home),
                    //     ),
                    //     hintText: 'Address Line 3',
                    //   ),
                     
                    // ),
                    // SizedBox(
                    //   height: 25,
                    // ),
                    // TextField(
                    //    controller: citytownvilagecontroller,
                    //   readOnly: true,
                    //   // maxLines: 1,
                    //   toolbarOptions:
                    //       ToolbarOptions(copy: true, cut: true, paste: true),
                    //  // autovalidate: autoValidatorEmail,
                    //   onTap: () {
                    //     setState(() {
                    //       autoValidatorEmail = true;
                    //     });
                    //   },
                    //   decoration: new InputDecoration(
                    //     filled: true,
                    //     fillColor: Colors.grey[200],
                    //     icon: Padding(
                    //       padding: const EdgeInsets.only(),
                    //       child: Icon(Icons.home),
                    //     ),
                    //     hintText: 'City/town/village',
                    //   ),
                     
                    // ),
                    // SizedBox(
                    //   height: 25,
                    // ),
                    // TextField(
                    //    controller: districtcontroller,
                    //   readOnly: true,
                    //   // maxLines: 1,
                    //   toolbarOptions:
                    //       ToolbarOptions(copy: true, cut: true, paste: true),
                    //  // autovalidate: autoValidatorEmail,
                    //   onTap: () {
                    //     setState(() {
                    //       autoValidatorEmail = true;
                    //     });
                    //   },
                    //   decoration: new InputDecoration(
                    //     filled: true,
                    //     fillColor: Colors.grey[200],
                    //     icon: Padding(
                    //       padding: const EdgeInsets.only(),
                    //       child: Icon(Icons.home),
                    //     ),
                    //     hintText: 'District',
                    //   ),
                     
                    // ),
                    // SizedBox(
                    //   height: 25,
                    // ),TextField(
                    //    controller: pincodecontroller,
                    //   readOnly: true,
                    //   // maxLines: 1,
                    //   toolbarOptions:
                    //       ToolbarOptions(copy: true, cut: true, paste: true),
                    //  // autovalidate: autoValidatorEmail,
                    //   onTap: () {
                    //     setState(() {
                    //       autoValidatorEmail = true;
                    //     });
                    //   },
                    //   decoration: new InputDecoration(
                    //     filled: true,
                    //     fillColor: Colors.grey[200],
                    //     icon: Padding(
                    //       padding: const EdgeInsets.only(),
                    //       child: Icon(Icons.home),
                    //     ),
                    //     hintText: 'PIN code',
                    //   ),
                     
                    // ),
                    // SizedBox(
                    //   height: 25,
                    // ),
                    // TextField(
                    //    controller: statecontroller,
                    //   readOnly: true,
                    //   // maxLines: 1,
                    //   toolbarOptions:
                    //       ToolbarOptions(copy: true, cut: true, paste: true),
                    //  // autovalidate: autoValidatorEmail,
                    //   onTap: () {
                    //     setState(() {
                    //       autoValidatorEmail = true;
                    //     });
                    //   },
                    //   decoration: new InputDecoration(
                    //     filled: true,
                    //     fillColor: Colors.grey[200],
                    //     icon: Padding(
                    //       padding: const EdgeInsets.only(),
                    //       child: Icon(Icons.home),
                    //     ),
                    //     hintText: 'State',
                    //   ),
                     
                    // ),
                    SizedBox(
                      height: 25,
                    ),


                  
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ));
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