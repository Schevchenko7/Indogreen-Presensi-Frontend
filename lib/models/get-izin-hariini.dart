// To parse this JSON data, do
//
//     final getIzinHariiniResponse = getIzinHariiniResponseFromJson(jsonString);

import 'dart:convert';

GetIzinHariiniResponse getIzinHariiniResponseFromJson(String str) => GetIzinHariiniResponse.fromJson(json.decode(str));

String getIzinHariiniResponseToJson(GetIzinHariiniResponse data) => json.encode(data.toJson());

class GetIzinHariiniResponse {
    bool success;
    String message;
    List<Datum> data;

    GetIzinHariiniResponse({
        required this.success,
        required this.message,
        required this.data,
    });

    factory GetIzinHariiniResponse.fromJson(Map<String, dynamic> json) => GetIzinHariiniResponse(
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
    String name;
    String alasan;
    String gambar;
    String deskripsi;
    String tanggal;

    Datum({
        required this.name,
        required this.alasan,
        required this.gambar,
        required this.deskripsi,
        required this.tanggal,
    });

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        name: json["name"],
        alasan: json["alasan"],
        gambar: json["gambar"],
        deskripsi: json["deskripsi"],
        tanggal: json["tanggal"],
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "alasan": alasan,
        "gambar": gambar,
        "deskripsi": deskripsi,
        "tanggal": tanggal,
    };
}
