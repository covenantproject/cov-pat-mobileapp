// To parse this JSON data, do
//
//     final locationHierarchy = locationHierarchyFromJson(jsonString);

import 'dart:convert';

LocationHierarchy locationHierarchyFromJson(String str) => LocationHierarchy.fromJson(json.decode(str));

String locationHierarchyToJson(LocationHierarchy data) => json.encode(data.toJson());

class LocationHierarchy {
    List<LocationHierarchyElement> locationHierarchy;

    LocationHierarchy({
        this.locationHierarchy,
    });

    factory LocationHierarchy.fromJson(Map<String, dynamic> json) => LocationHierarchy(
        locationHierarchy: List<LocationHierarchyElement>.from(json["locationHierarchy"].map((x) => LocationHierarchyElement.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "locationHierarchy": List<dynamic>.from(locationHierarchy.map((x) => x.toJson())),
    };
}

class LocationHierarchyElement {
    int locationId;
    String locationName;
    LocationAbbreviation locationAbbreviation;
    bool assignPatients;
    int parentLocationId;
    CountryCode countryCode;

    LocationHierarchyElement({
        this.locationId,
        this.locationName,
        this.locationAbbreviation,
        this.assignPatients,
        this.parentLocationId,
        this.countryCode,
    });

    factory LocationHierarchyElement.fromJson(Map<String, dynamic> json) => LocationHierarchyElement(
        locationId: json["locationId"],
        locationName: json["locationName"],
        locationAbbreviation: locationAbbreviationValues.map[json["locationAbbreviation"]],
        assignPatients: json["assignPatients"],
        parentLocationId: json["parentLocationId"],
        countryCode: countryCodeValues.map[json["countryCode"]],
    );

    Map<String, dynamic> toJson() => {
        "locationId": locationId,
        "locationName": locationNameValues.reverse[locationName],
        "locationAbbreviation": locationAbbreviationValues.reverse[locationAbbreviation],
        "assignPatients": assignPatients,
        "parentLocationId": parentLocationId,
        "countryCode": countryCodeValues.reverse[countryCode],
    };
}

enum CountryCode { IN }

final countryCodeValues = EnumValues({
    "IN": CountryCode.IN
});

enum LocationAbbreviation { IN_WB }

final locationAbbreviationValues = EnumValues({
    "IN-WB": LocationAbbreviation.IN_WB
});

enum LocationName { WEST_BENGAL }

final locationNameValues = EnumValues({
    "West Bengal": LocationName.WEST_BENGAL
});

class EnumValues<T> {
    Map<String, T> map;
    Map<T, String> reverseMap;

    EnumValues(this.map);

    Map<T, String> get reverse {
        if (reverseMap == null) {
            reverseMap = map.map((k, v) => new MapEntry(v, k));
        }
        return reverseMap;
    }
}
