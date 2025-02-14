// To parse this JSON data, do
//
//     final getIzinPenggunaResponse = getIzinPenggunaResponseFromJson(jsonString);

import 'dart:convert';

GetIzinPenggunaResponse getIzinPenggunaResponseFromJson(String str) => GetIzinPenggunaResponse.fromJson(json.decode(str));

String getIzinPenggunaResponseToJson(GetIzinPenggunaResponse data) => json.encode(data.toJson());

class GetIzinPenggunaResponse {
    bool success;
    String message;
    List<Datum> data;

    GetIzinPenggunaResponse({
        required this.success,
        required this.message,
        required this.data,
    });

    factory GetIzinPenggunaResponse.fromJson(Map<String, dynamic> json) => GetIzinPenggunaResponse(
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
