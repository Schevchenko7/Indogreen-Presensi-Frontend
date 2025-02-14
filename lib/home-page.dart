import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:indogreen_presensi/login-page.dart';
import 'package:indogreen_presensi/models/home-response.dart' as home;
import 'package:indogreen_presensi/models/hadirHariini-response.dart' as hadirHariIni;
import 'package:indogreen_presensi/models/get-izin-hariini.dart' as izinHariIni;
import 'package:indogreen_presensi/simpan-page.dart';
import 'package:indogreen_presensi/profile-page.dart';
import 'package:indogreen_presensi/daftar-izin-page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late Future<String> _name, _token;
  home.HomeResponseModel? homeResponseModel;
  home.Datum? hariIni;
  List<home.Datum> riwayat = [];
  List<hadirHariIni.Datum> karyawanHadirHariIni = [];
  List<izinHariIni.Datum> izinHariIniList = [];
  String errorMessage = "";
  bool isLoading = true;
  // Pagination settings
  int currentPageKaryawan = 0;
  int currentPageIzin = 0;
  static const int itemsPerPage = 7;

  @override
  void initState() {
    super.initState();
    _token = _prefs.then((SharedPreferences prefs) {
      return prefs.getString("token") ?? "";
    });

    _name = _prefs.then((SharedPreferences prefs) {
      return prefs.getString("name") ?? "";
    });

    getData();
  }

  void logout(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.remove('token');
    await prefs.remove('name');

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  Future<void> getData() async {
    final Map<String, String> headers = {
      'Authorization': 'Bearer ${await _token}',
    };

    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    try {
      var response = await http.get(
        Uri.parse('http://192.168.182.161:8001/api/get-presensi'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        var responseBody = json.decode(response.body);
        homeResponseModel = home.HomeResponseModel.fromJson(responseBody);

        riwayat.clear();
        karyawanHadirHariIni.clear();
        hariIni = null;

        for (var element in homeResponseModel!.data) {
          if (element.isHariIni) {
            hariIni = element;
          } else {
            riwayat.add(element);
          }
        }

        var hariIniResponse = await http.get(
          Uri.parse('http://192.168.182.161:8001/api/get-presensi-hari-ini'),
          headers: headers,
        );

        if (hariIniResponse.statusCode == 200) {
          var hariIniData = json.decode(hariIniResponse.body);

          if (hariIniData['data'] is List) {
            if (mounted) {
              setState(() {
                karyawanHadirHariIni = hariIniData['data']
                    .map<hadirHariIni.Datum>(
                        (data) => hadirHariIni.Datum.fromJson(data))
                    .toList();
              });
            }
          } else {
            print("Format data tidak sesuai: $hariIniData");
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text("Gagal memuat data presensi hari ini.")));
          }
        }

        // Fetch izin hari ini
        var izinResponse = await http.get(
          Uri.parse('http://192.168.182.161:8001/api/get-izin-hari-ini'),
          headers: headers,
        );

        if (izinResponse.statusCode == 200) {
          var izinData = json.decode(izinResponse.body);

          if (izinData['data'] is List) {
            if (mounted) {
              setState(() {
                izinHariIniList = izinData['data']
                    .map<izinHariIni.Datum>(
                        (data) => izinHariIni.Datum.fromJson(data))
                    .toList();
              });
            }
          } else {
            print("Format data tidak sesuai: $izinData");
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text("Gagal memuat data izin hari ini.")));
          }
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
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    var padding = MediaQuery.of(context).padding;
    var safeHeight = screenHeight - padding.top - padding.bottom;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FutureBuilder(
              future: _name,
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text("Memuat...");
                } else if (snapshot.hasData) {
                  return Text(
                    "Halo, ${snapshot.data}",
                    style: TextStyle(fontSize: screenHeight * 0.03),
                  );
                } else {
                  return Text(
                    "Pengguna",
                    style: TextStyle(fontSize: screenHeight * 0.03),
                  );
                }
              },
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'Logout') {
                  logout(context);
                } else if (value == 'Presensi') {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const SimpanPage()),
                  );
                } else if (value == 'Daftar Izin') {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => DaftarIzinPage()),
                  );
                } else if (value == 'Profile') {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const ProfilePage()),
                  );
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'Profile',
                  child: Text('Profile'),
                ),
                const PopupMenuItem(
                  value: 'Presensi',
                  child: Text('Presensi'),
                ),
                const PopupMenuItem(
                  value: 'Daftar Izin',
                  child: Text('Daftar Izin'),
                ),
                const PopupMenuItem(
                  value: 'Logout',
                  child: Text('Logout'),
                ),
              ],
              icon: const Icon(Icons.menu),
            ),
          ],
        ),
        backgroundColor: Colors.green[700],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Padding(
                padding: EdgeInsets.all(screenWidth * 0.05),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSummaryCard(screenHeight),
                    SizedBox(height: safeHeight * 0.05),
                    _buildSectionTitle("Karyawan Hadir Hari Ini", screenHeight),
                    SizedBox(height: screenHeight * 0.02),
                    _buildKaryawanHadirList(screenHeight, screenWidth),
                    SizedBox(height: screenHeight * 0.05),
                    _buildSectionTitle("Izin Hari Ini", screenHeight),
                    SizedBox(height: screenHeight * 0.02),
                    _buildIzinList(screenHeight, screenWidth),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSummaryCard(double screenHeight) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(screenHeight * 0.02),
      decoration: BoxDecoration(
        color: Colors.green[700],
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            hariIni?.tanggal ?? '-',
            style: TextStyle(
              color: Colors.white,
              fontSize: screenHeight * 0.025,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: screenHeight * 0.02),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTimeColumn(hariIni?.masuk != null ? hariIni!.masuk : '-', "Masuk", screenHeight),
              _buildTimeColumn(hariIni?.pulang != null ? hariIni!.pulang : '-', "Pulang", screenHeight),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeColumn(String time, String label, double screenHeight) {
    return Column(
      children: [
        Text(
          time,
          style: TextStyle(
            color: Colors.white,
            fontSize: screenHeight * 0.04,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: screenHeight * 0.02,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, double screenHeight) {
    return Text(
      title,
      style: TextStyle(
        fontSize: screenHeight * 0.03,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildKaryawanHadirList(double screenHeight, double screenWidth) {
    return Expanded(
      child: karyawanHadirHariIni.isNotEmpty
          ? Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: _getCurrentPageItems(karyawanHadirHariIni).length,
                    itemBuilder: (context, index) => _buildKaryawanCard(
                        _getCurrentPageItems(karyawanHadirHariIni)[index],
                        screenHeight,
                        screenWidth),
                  ),
                ),
                if (_hasMoreItems(karyawanHadirHariIni)) _buildLoadMoreButton()
              ],
            )
          : Center(
              child: Text(
                "Tidak ada karyawan yang hadir hari ini.",
                style: TextStyle(
                  fontSize: screenHeight * 0.02,
                  color: Colors.grey,
                ),
              ),
            ),
    );
  }

  Widget _buildKaryawanCard(hadirHariIni.Datum karyawan, double screenHeight,
      double screenWidth) {
    return Card(
      margin: EdgeInsets.only(bottom: screenHeight * 0.02),
      elevation: 3,
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
              karyawan.name,
              style: TextStyle(
                fontSize: screenHeight * 0.025,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Masuk: ${karyawan.masuk}",
                      style: TextStyle(
                        fontSize: screenHeight * 0.02,
                      ),
                    ),
                    Text(
                      "Pulang: ${karyawan.pulang ?? '-'}",
                      style: TextStyle(
                        fontSize: screenHeight * 0.02,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIzinList(double screenHeight, double screenWidth) {
    return Expanded(
      child: izinHariIniList.isNotEmpty
          ? Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: _getCurrentPageItems(izinHariIniList).length,
                    itemBuilder: (context, index) => _buildIzinCard(
                        _getCurrentPageItems(izinHariIniList)[index],
                        screenHeight,
                        screenWidth),
                  ),
                ),
                if (_hasMoreItems(izinHariIniList)) _buildLoadMoreButton()
              ],
            )
          : Center(
              child: Text(
                "Tidak ada izin yang diajukan hari ini.",
                style: TextStyle(
                  fontSize: screenHeight * 0.02,
                  color: Colors.grey,
                ),
              ),
            ),
    );
  }

  Widget _buildIzinCard(izinHariIni.Datum izin, double screenHeight,
    double screenWidth) {
  return Card(
    margin: EdgeInsets.only(bottom: screenHeight * 0.02),
    elevation: 3,
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
          // Nama Pegawai
          Text(
            izin.name,
            style: TextStyle(
              fontSize: screenHeight * 0.025,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: screenHeight * 0.01),

          // Alasan
          Text(
            "Alasan: ${izin.alasan}",
            style: TextStyle(fontSize: screenHeight * 0.02),
          ),

          // Deskripsi
          Text(
            "Deskripsi: ${izin.deskripsi}",
            style: TextStyle(fontSize: screenHeight * 0.02),
          ),

          // Tanggal
          Text(
            "Tanggal: ${izin.tanggal}",
            style: TextStyle(fontSize: screenHeight * 0.02),
          ),

          SizedBox(height: screenHeight * 0.02),

          // Nama File
          Text(
            "File: ${izin.gambar.split('/').last}",
            style: TextStyle(
              fontStyle: FontStyle.italic,
              color: Colors.blueGrey,
              fontSize: screenHeight * 0.02,
            ),
          ),

          SizedBox(height: screenHeight * 0.01),

          // Tombol Klik untuk Melihat Gambar
          GestureDetector(
            onTap: () {
              _showFullImage(context, izin.gambar);
            },
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                vertical: screenHeight * 0.01,
              ),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.green, width: 1.5),
              ),
              child: Center(
                child: Text(
                  "Klik untuk melihat gambar",
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: screenHeight * 0.02,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

void _showFullImage(BuildContext context, String imageUrl) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: InteractiveViewer(
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(child: CircularProgressIndicator());
            },
            errorBuilder: (context, error, stackTrace) {
              return const Center(child: Text("Gambar tidak tersedia"));
            },
          ),
        ),
      );
    },
  );
}

  Widget _buildLoadMoreButton() {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          currentPageKaryawan++;
          currentPageIzin++;
        });
      },
      child: const Text("Muat lebih banyak"),
    );
  }

  List<T> _getCurrentPageItems<T>(List<T> dataList) {
    int start = currentPageKaryawan * itemsPerPage;
    int end = start + itemsPerPage;
    return dataList.sublist(
        start, end > dataList.length ? dataList.length : end);
  }

  bool _hasMoreItems<T>(List<T> dataList) {
    int start = (currentPageKaryawan + 1) * itemsPerPage;
    return start < dataList.length;
  }
}
