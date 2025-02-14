// To parse this JSON data, do
//
//     final saveIzinResponse = saveIzinResponseFromJson(jsonString);

import 'dart:convert';

SaveIzinResponse saveIzinResponseFromJson(String str) => SaveIzinResponse.fromJson(json.decode(str));

String saveIzinResponseToJson(SaveIzinResponse data) => json.encode(data.toJson());

class SaveIzinResponse {
    bool success;
    String message;
    String data;

    SaveIzinResponse({
        required this.success,
        required this.message,
        required this.data,
    });

    factory SaveIzinResponse.fromJson(Map<String, dynamic> json) => SaveIzinResponse(
        success: json["success"],
        message: json["message"],
        data: json["data"],
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data,
    };
}
