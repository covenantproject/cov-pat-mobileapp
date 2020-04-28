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
    String addressType;
    String addressLine1;
    String addressLine2;
    String addressLine3;
    String city;
    String district;
    String pinCode;
    String state;
    String gender;
    int mobileNo;
    String proofType;
    String proofNumber;
    String proofAuthority;
    String photoPath;

    ProfileModel({
        this.title,
        this.firstName,
        this.middleName,
        this.lastName,
        this.preferredName,
        this.shortName,
        this.suffix,
        this.dob,
        this.addressType,
        this.addressLine1,
        this.addressLine2,
        this.addressLine3,
        this.city,
        this.district,
        this.pinCode,
        this.state,
        this.gender,
        this.mobileNo,
        this.proofType,
        this.proofNumber,
        this.proofAuthority,
        this.photoPath,
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
        addressType: json["addressType"],
        addressLine1: json["addressLine1"],
        addressLine2: json["addressLine2"],
        addressLine3: json["addressLine3"],
        city: json["city"],
        district: json["district"],
        pinCode: json["pinCode"],
        state: json["state"],
        gender: json["gender"],
        mobileNo: json["mobileNo"],
        proofType: json["proofType"],
        proofNumber: json["proofNumber"],
        proofAuthority: json["proofAuthority"],
        photoPath: json["photoPath"],
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
        "addressType": addressType,
        "addressLine1": addressLine1,
        "addressLine2": addressLine2,
        "addressLine3": addressLine3,
        "city": city,
        "district": district,
        "pinCode": pinCode,
        "state": state,
        "gender": gender,
        "mobileNo": mobileNo,
        "proofType": proofType,
        "proofNumber": proofNumber,
        "proofAuthority": proofAuthority,
        "photoPath": photoPath,
    };
}
