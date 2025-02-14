// To parse this JSON data, do
//
//     final hadirHariiniResponse = hadirHariiniResponseFromJson(jsonString);

import 'dart:convert';

HadirHariiniResponse hadirHariiniResponseFromJson(String str) => HadirHariiniResponse.fromJson(json.decode(str));

String hadirHariiniResponseToJson(HadirHariiniResponse data) => json.encode(data.toJson());

class HadirHariiniResponse {
    bool success;
    String message;
    List<Datum> data;

    HadirHariiniResponse({
        required this.success,
        required this.message,
        required this.data,
    });

    factory HadirHariiniResponse.fromJson(Map<String, dynamic> json) => HadirHariiniResponse(
        success: json["success"],
        message: json["message"],
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
    };
}

class Datum {
    int id;
    String name;
    String latitude;
    String longitude;
    DateTime tanggal;
    String masuk;
    String? pulang;
    DateTime createdAt;
    DateTime updatedAt;

  var checkOut;

    Datum({
        required this.id,
        required this.name,
        required this.latitude,
        required this.longitude,
        required this.tanggal,
        required this.masuk,
        required this.pulang,
        required this.createdAt,
        required this.updatedAt,
    });

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["id"],
        name: json["name"],
        latitude: json["latitude"],
        longitude: json["longitude"],
        tanggal: DateTime.parse(json["tanggal"]),
        masuk: json["masuk"],
        pulang: json["pulang"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
    );

  get checkIn => null;

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "latitude": latitude,
        "longitude": longitude,
        "tanggal": "${tanggal.year.toString().padLeft(4, '0')}-${tanggal.month.toString().padLeft(2, '0')}-${tanggal.day.toString().padLeft(2, '0')}",
        "masuk": masuk,
        "pulang": pulang,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
    };
}
