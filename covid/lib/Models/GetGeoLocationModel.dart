// To parse this JSON data, do
//
//     final getGeoLocationModel = getGeoLocationModelFromJson(jsonString);

import 'dart:convert';

GetGeoLocationModel getGeoLocationModelFromJson(String str) => GetGeoLocationModel.fromJson(json.decode(str));

String getGeoLocationModelToJson(GetGeoLocationModel data) => json.encode(data.toJson());

class GetGeoLocationModel {
    List<GeoFenceDatum> geoFenceData;

    GetGeoLocationModel({
        this.geoFenceData,
    });

    factory GetGeoLocationModel.fromJson(Map<String, dynamic> json) => GetGeoLocationModel(
        geoFenceData: List<GeoFenceDatum>.from(json["geoFenceData"].map((x) => GeoFenceDatum.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "geoFenceData": List<dynamic>.from(geoFenceData.map((x) => x.toJson())),
    };
}

class GeoFenceDatum {
    bool geoFenceSet;
    String geoFenceEndDate;
    double geoFenceLongitude;
    double geoFenceRadiusMetres;
    int geofenceLocationId;
    double geoFenceLatitude;
    String geoFenceStartDate;
    int patientId;

    GeoFenceDatum({
        this.geoFenceSet,
        this.geoFenceEndDate,
        this.geoFenceLongitude,
        this.geoFenceRadiusMetres,
        this.geofenceLocationId,
        this.geoFenceLatitude,
        this.geoFenceStartDate,
        this.patientId,
    });

    factory GeoFenceDatum.fromJson(Map<String, dynamic> json) => GeoFenceDatum(
        geoFenceSet: json["geoFenceSet"],
        geoFenceEndDate: json["geoFenceEndDate"],
        geoFenceLongitude: json["geoFenceLongitude"].toDouble(),
        geoFenceRadiusMetres: json["geoFenceRadiusMetres"].toDouble(),
        geofenceLocationId: json["geofenceLocationId"],
        geoFenceLatitude: json["geoFenceLatitude"].toDouble(),
        geoFenceStartDate: json["geoFenceStartDate"],
        patientId: json["patientId"],
    );

    Map<String, dynamic> toJson() => {
        "geoFenceSet": geoFenceSet,
        "geoFenceEndDate": geoFenceEndDate,
        "geoFenceLongitude": geoFenceLongitude,
        "geoFenceRadiusMetres": geoFenceRadiusMetres,
        "geofenceLocationId": geofenceLocationId,
        "geoFenceLatitude": geoFenceLatitude,
        "geoFenceStartDate": geoFenceStartDate,
        "patientId": patientId,
    };
}
