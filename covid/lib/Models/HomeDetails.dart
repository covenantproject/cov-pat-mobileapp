// To parse this JSON data, do
//
//     final homeDetails = homeDetailsFromJson(jsonString);

import 'dart:convert';

HomeDetails homeDetailsFromJson(String str) => HomeDetails.fromJson(json.decode(str));

String homeDetailsToJson(HomeDetails data) => json.encode(data.toJson());

class HomeDetails {
    int userid;
    String healthofficername;
    String healthofficerno;
    String emergencyno;
    DateTime lasthealthupdate;
    String currentlatitude;
    String currentlongitutude;

    HomeDetails({
        this.userid,
        this.healthofficername,
        this.healthofficerno,
        this.emergencyno,
        this.lasthealthupdate,
        this.currentlatitude,
        this.currentlongitutude,
    });

    factory HomeDetails.fromJson(Map<String, dynamic> json) => HomeDetails(
        userid: json["userid"],
        healthofficername: json["healthofficername"],
        healthofficerno: json["healthofficerno"],
        emergencyno: json["emergencyno"],
        lasthealthupdate: DateTime.parse(json["lasthealthupdate"]),
        currentlatitude: json["currentlatitude"],
        currentlongitutude: json["currentlongitutude"],
    );

    Map<String, dynamic> toJson() => {
        "userid": userid,
        "healthofficername": healthofficername,
        "healthofficerno": healthofficerno,
        "emergencyno": emergencyno,
        "lasthealthupdate": lasthealthupdate.toIso8601String(),
        "currentlatitude": currentlatitude,
        "currentlongitutude": currentlongitutude,
    };
}
