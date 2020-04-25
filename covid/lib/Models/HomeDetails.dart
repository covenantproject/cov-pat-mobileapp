// To parse this JSON data, do
//
//     final homedetailsModel = homedetailsModelFromJson(jsonString);

import 'dart:convert';

HomedetailsModel homedetailsModelFromJson(String str) => HomedetailsModel.fromJson(json.decode(str));

String homedetailsModelToJson(HomedetailsModel data) => json.encode(data.toJson());

class HomedetailsModel {
    String status;
    HomeDetails homeDetails;

    HomedetailsModel({
        this.status,
        this.homeDetails,
    });

    factory HomedetailsModel.fromJson(Map<String, dynamic> json) => HomedetailsModel(
        status: json["status"],
        homeDetails: HomeDetails.fromJson(json["homeDetails"]),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "homeDetails": homeDetails.toJson(),
    };
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

    factory HomeDetails.fromJson(Map<String, dynamic> json) => HomeDetails(
        patientid: json["patientid"],
        firstname: json["firstname"],
        lastname: json["lastname"],
        latitude: json["latitude"],
        longitude: json["longitude"],
        emergencycontact1: json["emergencycontact1"],
        requestdatetime: json["requestdatetime"],
    );

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
