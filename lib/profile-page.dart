import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:indogreen_presensi/models/home-response.dart' as home;
import 'package:indogreen_presensi/models/get-izin-pengguna.dart' as izin;

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ImagePicker _picker = ImagePicker();
  XFile? _profileImage;
  String _motto = "Ini adalah moto hidup saya";
  final String _jabatan = "Karyawan";
  List<home.Datum> riwayat = [];
  List<izin.Datum> izinList = [];
  bool isLoading = true;
  int _riwayatPage = 1;
  int _izinPage = 1;
  late Future<String> _token;
  late Future<String> _name;

  @override
  void initState() {
    super.initState();
    final Future<SharedPreferences> prefs = SharedPreferences.getInstance();

    _token = prefs.then((SharedPreferences prefs) {
      return prefs.getString("token") ?? "";
    });

    _name = prefs.then((SharedPreferences prefs) {
      return prefs.getString("name") ?? "";
    });

    getRiwayatAbsen();
    getIzinPengguna(); // Fetch izin data
  }

  // Mendapatkan data riwayat absen dari API berdasarkan tahun dan bulan yang dipilih
  Future<void> getRiwayatAbsen() async {
    final Map<String, String> headers = {
      'Authorization': 'Bearer ${await _token}',
    };

    try {
      var response = await http.get(
        Uri.parse('http://192.168.182.161:8001/api/get-presensi'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        var responseBody = json.decode(response.body);
        var homeResponseModel = home.HomeResponseModel.fromJson(responseBody);

        if (mounted) {
          setState(() {
            riwayat = homeResponseModel.data;
            isLoading = false;
          });
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Gagal memuat data presensi.")));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
      }
    }
  }

  // Mendapatkan data izin pengguna dari API
  Future<void> getIzinPengguna() async {
    final Map<String, String> headers = {
      'Authorization': 'Bearer ${await _token}',
    };

    try {
      var response = await http.get(
        Uri.parse('http://192.168.182.161:8001/api/get-izin'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        var responseBody = json.decode(response.body);
        var izinResponse = izin.GetIzinPenggunaResponse.fromJson(responseBody);

        if (mounted) {
          setState(() {
            izinList = izinResponse.data;
            isLoading = false;
          });
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Gagal memuat data izin.")));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedImage = await _picker.pickImage(source: source);
    if (pickedImage != null) {
      setState(() {
        _profileImage = pickedImage;
      });
    }
  }

  void _editMotto() {
    TextEditingController controller = TextEditingController(text: _motto);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Moto Hidup"),
          content: TextField(
            controller: controller,
            maxLines: 2,
            decoration: const InputDecoration(hintText: "Masukkan moto hidup Anda"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _motto = controller.text;
                });
                Navigator.of(context).pop();
              },
              child: const Text("Simpan"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profil Pengguna"),
        backgroundColor: Colors.green[700],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundImage: _profileImage != null
                              ? FileImage(File(_profileImage!.path))
                              : const AssetImage("lib/assets/default-profile.jpg")
                                  as ImageProvider,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: IconButton(
                            icon: const Icon(Icons.camera_alt, color: Colors.green),
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                builder: (_) => Wrap(
                                  children: [
                                    ListTile(
                                      leading: const Icon(Icons.camera),
                                      title: const Text("Ambil dari Kamera"),
                                      onTap: () {
                                        _pickImage(ImageSource.camera);
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    ListTile(
                                      leading: const Icon(Icons.photo_library),
                                      title: const Text("Ambil dari Galeri"),
                                      onTap: () {
                                        _pickImage(ImageSource.gallery);
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Jabatan: $_jabatan",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  ListTile(
                    title: const Text("Moto Hidup"),
                    subtitle: Text(_motto),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit, color: Colors.green),
                      onPressed: _editMotto,
                    ),
                  ),

                  const SizedBox(height: 20),
                  const Text(
                    "Riwayat Presensi",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(),
                  _buildRiwayatList(screenHeight, screenWidth),
                  const SizedBox(height: 20),
                  const Text(
                    "Riwayat Izin",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(),
                  _buildIzinList(screenHeight, screenWidth),
                ],
              ),
            ),
    );
  }

  // Widget untuk menampilkan riwayat presensi
  Widget _buildRiwayatList(double screenHeight, double screenWidth) {
    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _getPageItemsCount(riwayat.length, _riwayatPage),
          itemBuilder: (context, index) {
            int dataIndex = (_riwayatPage - 1) * 7 + index;
            return Card(
              margin: EdgeInsets.only(bottom: screenHeight * 0.02),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.05,
                  vertical: screenHeight * 0.01,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      riwayat[dataIndex].tanggal,
                      style: TextStyle(
                        fontSize: screenHeight * 0.025,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Text("Masuk: ${riwayat[dataIndex].masuk}"),
                    Text("Pulang: ${riwayat[dataIndex].pulang}"),
                  ],
                ),
              ),
            );
          },
        ),
        if (riwayat.length > 7)
          _buildPaginationControls(
            totalItems: riwayat.length,
            currentPage: _riwayatPage,
            onPageChange: (newPage) {
              setState(() {
                _riwayatPage = newPage;
              });
            },
          ),
      ],
    );
  }

  // Widget untuk menampilkan daftar izin
  Widget _buildIzinList(double screenHeight, double screenWidth) {
    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _getPageItemsCount(izinList.length, _izinPage),
          itemBuilder: (context, index) {
            int dataIndex = (_izinPage - 1) * 7 + index;
            return Card(
              margin: EdgeInsets.only(bottom: screenHeight * 0.02),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.05,
                  vertical: screenHeight * 0.02,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      izinList[dataIndex].name,
                      style: TextStyle(
                        fontSize: screenHeight * 0.025,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text("Alasan: ${izinList[dataIndex].alasan}"),
                    Text("Deskripsi: ${izinList[dataIndex].deskripsi}"),
                    Text("Tanggal: ${izinList[dataIndex].tanggal}"),
                    const SizedBox(height: 8),
                    izinList[dataIndex].gambar.isNotEmpty
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Tampilkan nama file gambar
                            Text(
                              'File: ${izinList[dataIndex].gambar.split('/').last}', // Hanya nama file
                              style: const TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Colors.blueGrey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Klik untuk melihat gambar
                            InkWell(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => Dialog(
                                    child: InteractiveViewer(
                                      child: Image.network(
                                        izinList[dataIndex].gambar,
                                        fit: BoxFit.contain,
                                        loadingBuilder: (context, child, loadingProgress) {
                                          if (loadingProgress == null) return child;
                                          return const Center(child: CircularProgressIndicator());
                                        },
                                        errorBuilder: (context, error, stackTrace) {
                                          return const Center(child: Text('Gambar tidak dapat dimuat'));
                                        },
                                      ),
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.all(8.0),
                                child: const Center(
                                  child: Text(
                                    'Klik untuk melihat gambar',
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : const Text('Tidak ada gambar tersedia'),
                  ],
                ),
              ),
            );
          },
        ),
        if (izinList.length > 7)
          _buildPaginationControls(
            totalItems: izinList.length,
            currentPage: _izinPage,
            onPageChange: (newPage) {
              setState(() {
                _izinPage = newPage;
              });
            },
          ),
      ],
    );
  }

  int _getPageItemsCount(int totalItems, int currentPage) {
    int start = (currentPage - 1) * 7;
    return (totalItems - start > 7) ? 7 : totalItems - start;
  }

  Widget _buildPaginationControls({
    required int totalItems,
    required int currentPage,
    required Function(int) onPageChange,
  }) {
    int totalPages = (totalItems / 7).ceil();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (currentPage > 1)
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => onPageChange(currentPage - 1),
          ),
        Text("$currentPage dari $totalPages"),
        if (currentPage < totalPages)
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: () => onPageChange(currentPage + 1),
          ),
      ],
    );
  }
}
