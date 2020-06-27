// To parse this JSON data, do
//
//     final homedetailsModel = homedetailsModelFromJson(jsonString);

import 'dart:convert';

class HomedetailsModel {
  String status;
  HomeDetails homeDetails;

  HomedetailsModel({
    this.status,
    this.homeDetails,
  });

  HomedetailsModel.fromJson(Map<String, dynamic> json) {
    status = json["status"];
    homeDetails = HomeDetails.fromJson(json["homeDetails"]);
  }
}

class HomeDetails {
  int patientid;
  String firstname;
  String lastname;
  double latitude;
  double longitude;
  String emergencycontact1;
  dynamic requestdatetime;

  HomeDetails({
    this.patientid,
    this.firstname,
    this.lastname,
    this.latitude,
    this.longitude,
    this.emergencycontact1,
    this.requestdatetime,
  });

  HomeDetails.fromJson(Map<String, dynamic> json) {
    patientid = json["patientid"];
    firstname = json["firstname"];
    lastname = json["lastname"];
    latitude = json["latitude"];
    longitude = json["longitude"];
    emergencycontact1 = json["emergencycontact1"];
    requestdatetime = json["requestdatetime"];
  }

  Map<String, dynamic> toJson() => {
        "patientid": patientid,
        "firstname": firstname,
        "lastname": lastname,
        "latitude": latitude,
        "longitude": longitude,
        "emergencycontact1": emergencycontact1,
        "requestdatetime": requestdatetime,
      };
}
