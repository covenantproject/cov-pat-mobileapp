// To parse this JSON data, do
//
//     final profileModel = profileModelFromJson(jsonString);

import 'dart:convert';

ProfileModel profileModelFromJson(String str) => ProfileModel.fromJson(json.decode(str));

String profileModelToJson(ProfileModel data) => json.encode(data.toJson());

class ProfileModel {
    String title;
    String firstName;
    String middleName;
    String lastName;
    String preferredName;
    String shortName;
    String suffix;
    DateTime dob;
    String gender;
    dynamic idType;
    dynamic idProofNo;
    String address;
    int mobileNo;
    int photoId;

    ProfileModel({
        this.title,
        this.firstName,
        this.middleName,
        this.lastName,
        this.preferredName,
        this.shortName,
        this.suffix,
        this.dob,
        this.gender,
        this.idType,
        this.idProofNo,
        this.address,
        this.mobileNo,
        this.photoId,
    });

    factory ProfileModel.fromJson(Map<String, dynamic> json) => ProfileModel(
        title: json["title"],
        firstName: json["firstName"],
        middleName: json["middleName"],
        lastName: json["lastName"],
        preferredName: json["preferredName"],
        shortName: json["shortName"],
        suffix: json["suffix"],
        dob: DateTime.parse(json["dob"]),
        gender: json["gender"],
        idType: json["idType"],
        idProofNo: json["idProofNo"],
        address: json["address"],
        mobileNo: json["mobileNo"],
        photoId: json["photoId"],
    );

    Map<String, dynamic> toJson() => {
        "title": title,
        "firstName": firstName,
        "middleName": middleName,
        "lastName": lastName,
        "preferredName": preferredName,
        "shortName": shortName,
        "suffix": suffix,
        "dob": "${dob.year.toString().padLeft(4, '0')}-${dob.month.toString().padLeft(2, '0')}-${dob.day.toString().padLeft(2, '0')}",
        "gender": gender,
        "idType": idType,
        "idProofNo": idProofNo,
        "address": address,
        "mobileNo": mobileNo,
        "photoId": photoId,
    };
}
