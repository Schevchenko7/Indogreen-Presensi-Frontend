// To parse this JSON data, do
//
//     final saveResponseModel = saveResponseModelFromJson(jsonString);

import 'dart:convert';

// Fungsi untuk mengubah JSON string menjadi objek SaveResponseModel
SaveResponseModel saveResponseModelFromJson(String str) =>
    SaveResponseModel.fromJson(json.decode(str));

// Fungsi untuk mengubah objek SaveResponseModel menjadi JSON string
String saveResponseModelToJson(SaveResponseModel data) =>
    json.encode(data.toJson());

class SaveResponseModel {
  bool success;
  String message;
  Data data;

  SaveResponseModel({
    required this.success,
    required this.message,
    required this.data,
  });

  // Factory method untuk membuat objek SaveResponseModel dari JSON
  factory SaveResponseModel.fromJson(Map<String, dynamic> json) =>
      SaveResponseModel(
        success: json["success"] ?? false,  // Default ke false jika success null
        message: json["message"] ?? 'Tidak ada pesan',  // Default ke string jika null
        // Cek apakah 'data' null, jika null panggil Data.empty()
        data: json["data"] != null ? Data.fromJson(json["data"]) : Data.empty(),
      );

  // Fungsi untuk mengubah objek SaveResponseModel menjadi Map
  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data.toJson(),
      };
}

class Data {
  int id;
  String name;
  String latitude;
  String longitude;
  DateTime tanggal;
  String masuk;
  String pulang;
  DateTime createdAt;
  DateTime updatedAt;

  Data({
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

  // Constructor empty untuk menangani kasus null
  factory Data.empty() => Data(
        id: 0,  // Default id ke 0 jika null
        name: '',  // Default name ke string kosong jika null
        latitude: '',  // Default latitude ke string kosong jika null
        longitude: '',  // Default longitude ke string kosong jika null
        tanggal: DateTime.now(),  // Default ke tanggal saat ini jika null
        masuk: '',  // Default masuk ke string kosong jika null
        pulang: '',  // Default pulang ke string kosong jika null
        createdAt: DateTime.now(),  // Default ke tanggal saat ini jika null
        updatedAt: DateTime.now(),  // Default ke tanggal saat ini jika null
      );

  // Factory method untuk membuat objek Data dari JSON
  factory Data.fromJson(Map<String, dynamic> json) => Data(
        id: json["id"] != null ? json["id"] : 0,  // Tangani null dengan memberikan nilai default
        name: json["name"] ?? '',                 // Default ke string kosong jika null
        latitude: json["latitude"] ?? '',         // Default ke string kosong jika null
        longitude: json["longitude"] ?? '',       // Default ke string kosong jika null
        tanggal: json["tanggal"] != null ? DateTime.parse(json["tanggal"]) : DateTime.now(),
        masuk: json["masuk"] ?? '',               // Default ke string kosong jika null
        pulang: json["pulang"] ?? '',             // Default ke string kosong jika null
        createdAt: json["created_at"] != null ? DateTime.parse(json["created_at"]) : DateTime.now(),
        updatedAt: json["updated_at"] != null ? DateTime.parse(json["updated_at"]) : DateTime.now(),
      );

  // Fungsi untuk mengubah objek Data menjadi Map
  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "latitude": latitude,
        "longitude": longitude,
        "tanggal":
            "${tanggal.year.toString().padLeft(4, '0')}-${tanggal.month.toString().padLeft(2, '0')}-${tanggal.day.toString().padLeft(2, '0')}",
        "masuk": masuk,
        "pulang": pulang,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
      };
}

