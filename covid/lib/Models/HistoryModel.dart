// To parse this JSON data, do
//
//     final historyModel = historyModelFromJson(jsonString);

import 'dart:convert';

HistoryModel historyModelFromJson(String str) => HistoryModel.fromJson(json.decode(str));

String historyModelToJson(HistoryModel data) => json.encode(data.toJson());

class HistoryModel {
    List<History> history;

    HistoryModel({
        this.history,
    });

    factory HistoryModel.fromJson(Map<String, dynamic> json) => HistoryModel(
        history: List<History>.from(json["history"].map((x) => History.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "history": List<dynamic>.from(history.map((x) => x.toJson())),
    };
}

class History {
    bool ishealthupdated;
    bool israiseyourhand;
    bool hascough;
    bool hasfever;
    bool haschills;
    bool hasbreathingissue;
    String currenthealthstatus;
    String temperature;
    String heartrate;
    String respiratoryrate;
    String spo2;
    String requesttype;
    DateTime timestamp;

    History({
        this.ishealthupdated,
        this.israiseyourhand,
        this.hascough,
        this.hasfever,
        this.haschills,
        this.hasbreathingissue,
        this.currenthealthstatus,
        this.temperature,
        this.heartrate,
        this.respiratoryrate,
        this.spo2,
        this.requesttype,
        this.timestamp,
    });

    factory History.fromJson(Map<String, dynamic> json) => History(
        ishealthupdated: json["ishealthupdated"],
        israiseyourhand: json["israiseyourhand"],
        hascough: json["hascough"],
        hasfever: json["hasfever"],
        haschills: json["haschills"],
        hasbreathingissue: json["hasbreathingissue"],
        currenthealthstatus: json["currenthealthstatus"],
        temperature: json["temperature"],
        heartrate: json["heartrate"],
        respiratoryrate: json["respiratoryrate"],
        spo2: json["spo2"],
        requesttype: json["requesttype"],
        timestamp: DateTime.parse(json["timestamp"]),
    );

    Map<String, dynamic> toJson() => {
        "ishealthupdated": ishealthupdated,
        "israiseyourhand": israiseyourhand,
        "hascough": hascough,
        "hasfever": hasfever,
        "haschills": haschills,
        "hasbreathingissue": hasbreathingissue,
        "currenthealthstatus": currenthealthstatus,
        "temperature": temperature,
        "heartrate": heartrate,
        "respiratoryrate": respiratoryrate,
        "spo2": spo2,
        "requesttype": requesttype,
        "timestamp": timestamp.toIso8601String(),
    };
}
