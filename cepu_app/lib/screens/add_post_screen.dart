import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cepu_app/services/post_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final TextEditingController _descriptionController =
      TextEditingController();

  String? _base64Image;
  String? _latitude;
  String? _longitude;
  String? _category;

  bool _isSubmitting = false;
  bool _isGettingLocation = false;

  List<String> get categories {
    return [
      'Jalan Rusak',
      'Lampu Jalan Mati',
      'Lawan Arah',
      'Merokok di Jalan',
      'Tidak Pakai Helm',
    ];
  }

  // 1. Fungsi pick, compress dan convert image
  Future<void> pickImageAndConvert() async {
    final ImagePicker picker = ImagePicker();

    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (image != null) {
      // Tambahkan proses convert ke base64 jika diperlukan
      setState(() {
        _base64Image = image.path;
      });
    }
  }

  // 2. Fungsi ambil lokasi
  Future<void> getCurrentLocation() async {
    setState(() {
      _isGettingLocation = true;
    });

    bool serviceEnabled;
    LocationPermission permission;

    // Cek apakah GPS aktif
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _isGettingLocation = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Layanan lokasi tidak aktif'),
        ),
      );
      return;
    }

    // Cek izin lokasi
    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        setState(() {
          _isGettingLocation = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Izin lokasi ditolak'),
          ),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _isGettingLocation = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Izin lokasi ditolak permanen'),
        ),
      );
      return;
    }

    // Ambil posisi
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _latitude = position.latitude.toString();
      _longitude = position.longitude.toString();
      _isGettingLocation = false;
    });
  } 
  // Widget build image tampil gambar
Widget buildImagePreview() {
  if (_base64Image == null) {
    return Container(
      height: 200,
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade400,
        ),
      ),
      child: const Text('Belum ada gambar dipilih'),
    );
  }

  return ClipRRect(
    borderRadius: BorderRadius.circular(12),
    child: Image.memory(
      base64Decode(_base64Image!),
      height: 200,
      width: double.infinity,
      fit: BoxFit.cover,
    ),
  );
}

// Fungsi widget tampil lokasi
Widget buildLocationInfo() {
  if (_latitude == null || _longitude == null) {
    return const Text('Lokasi belum diambil');
  }

  return Text(
    'Lat: $_latitude, Long: $_longitude',
    textAlign: TextAlign.center,
  );
}

// Fungsi validasi form
Future<void> validateAndSubmit() async {
  if (_base64Image == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pilih gambar terlebih dahulu'),
      ),
    );
    return;
  }

  if (_category == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pilih kategori terlebih dahulu'),
      ),
    );
    return;
  }

  if (_descriptionController.text.trim().isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Deskripsi tidak boleh kosong'),
      ),
    );
    return;
  }

  setState(() => _isSubmitting = true);

  try {
    await FirebaseFirestore.instance.collection('posts').add({
      'description': _descriptionController.text.trim(),
      'category': _category,
      'imageBase64': _base64Image,
      'latitude': _latitude,
      'longitude': _longitude,
      'createdAt': Timestamp.now(),
      'userId': FirebaseAuth.instance.currentUser?.uid,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Postingan berhasil ditambahkan'),
      ),
    );

    Navigator.pop(context);
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Terjadi kesalahan: $e'),
      ),
    );
  } finally {
    setState(() => _isSubmitting = false);
  }
}

 
    }
  
