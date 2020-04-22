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
    dynamic healthofficername;
    dynamic healthofficerno;
    dynamic emergencyno;
    dynamic lasthealthupdate;
    int currentlatitude;
    int currentlongitutude;

    HomeDetails({
        this.healthofficername,
        this.healthofficerno,
        this.emergencyno,
        this.lasthealthupdate,
        this.currentlatitude,
        this.currentlongitutude,
    });

    factory HomeDetails.fromJson(Map<String, dynamic> json) => HomeDetails(
        healthofficername: json["healthofficername"],
        healthofficerno: json["healthofficerno"],
        emergencyno: json["emergencyno"],
        lasthealthupdate: json["lasthealthupdate"],
        currentlatitude: json["currentlatitude"],
        currentlongitutude: json["currentlongitutude"],
    );

    Map<String, dynamic> toJson() => {
        "healthofficername": healthofficername,
        "healthofficerno": healthofficerno,
        "emergencyno": emergencyno,
        "lasthealthupdate": lasthealthupdate,
        "currentlatitude": currentlatitude,
        "currentlongitutude": currentlongitutude,
    };
}
