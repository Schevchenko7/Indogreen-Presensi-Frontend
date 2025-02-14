import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // Untuk SharedPreferences

class DaftarIzinPage extends StatefulWidget {
  const DaftarIzinPage({super.key});

  @override
  _DaftarIzinPageState createState() => _DaftarIzinPageState();
}

class _DaftarIzinPageState extends State<DaftarIzinPage> {
  String? selectedReason; // Alasan izin yang dipilih
  XFile? selectedImage; // Gambar yang dipilih
  final ImagePicker _picker = ImagePicker(); // Untuk memilih gambar
  final TextEditingController descriptionController = TextEditingController(); // Input deskripsi
  String? bearerToken; // Menyimpan token yang diambil dari SharedPreferences

  @override
  void initState() {
    super.initState();
    loadToken(); // Muat token saat halaman dibuka
  }

  // Fungsi untuk memuat token dari SharedPreferences
  Future<void> loadToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      bearerToken = prefs.getString('token'); // Ambil token dari SharedPreferences
    });
  }

  // Fungsi untuk memilih gambar dari galeri
  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      selectedImage = image;
    });
  }

  // Daftar alasan izin
  final List<String> reasons = ['Sakit', 'Izin'];

  // Fungsi untuk mengirim data ke API
  Future<void> submitIzin() async {
    if (selectedReason == null || descriptionController.text.isEmpty) {
      // Jika data tidak lengkap
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Alasan dan deskripsi harus diisi.')),
      );
      return;
    }

    if (bearerToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Token tidak ditemukan. Silakan login ulang.')),
      );
      return;
    }

    try {
      // Buat request multipart untuk mengirim data izin
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://192.168.182.161:8001/api/save-izin'), // Sesuaikan URL API
      );

      // Tambahkan field teks
      request.fields['alasan'] = selectedReason!;
      request.fields['deskripsi'] = descriptionController.text;

      // Tambahkan file gambar jika ada
      if (selectedImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'gambar',
          selectedImage!.path,
        ));
      }

      // Tambahkan header Authorization dengan Bearer Token
      request.headers['Authorization'] = 'Bearer $bearerToken';

      // Kirim request
      var response = await request.send();

      // Ubah stream response menjadi http.Response
      var responseData = await http.Response.fromStream(response);

      // Cek status code dari response
      if (response.statusCode == 200) {
        final izinResponse = jsonDecode(responseData.body);

        if (izinResponse['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(izinResponse['message'])),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(izinResponse['message'])),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengirim data. Status: ${response.statusCode}')),
        );
      }
    } catch (e) {
      // Handle error jika terjadi kesalahan saat mengirim request
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Izin'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(screenWidth * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Pilih Alasan',
                border: const OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.03,
                  vertical: screenHeight * 0.015,
                ),
              ),
              value: selectedReason,
              items: reasons.map((reason) {
                return DropdownMenuItem(
                  value: reason,
                  child: Text(reason),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedReason = value;
                });
              },
            ),
            SizedBox(height: screenHeight * 0.02),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: 'Deskripsi Alasan',
                border: const OutlineInputBorder(),
                hintText: 'Masukkan deskripsi alasan izin Anda...',
                contentPadding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.03,
                  vertical: screenHeight * 0.015,
                ),
              ),
              maxLines: 3,
            ),
            SizedBox(height: screenHeight * 0.03),
            ElevatedButton.icon(
              onPressed: pickImage,
              icon: Icon(Icons.upload_file, size: screenHeight * 0.03),
              label: Text(
                'Upload Gambar',
                style: TextStyle(fontSize: screenHeight * 0.022),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: EdgeInsets.symmetric(
                  vertical: screenHeight * 0.015,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.03),
            ElevatedButton(
              onPressed: submitIzin,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  vertical: screenHeight * 0.02,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                backgroundColor: Colors.green,
              ),
              child: Center(
                child: Text(
                  'Submit',
                  style: TextStyle(
                    fontSize: screenHeight * 0.025,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.03),
            if (selectedImage != null)
              Container(
                margin: EdgeInsets.only(top: screenHeight * 0.01),
                width: screenWidth * 0.8,
                height: screenHeight * 0.4,
                child: Image.file(File(selectedImage!.path)),
              ),
          ],
        ),
      ),
    );
  }
}
