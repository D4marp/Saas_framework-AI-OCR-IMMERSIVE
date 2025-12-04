import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'face_recognition_provider.dart';
import 'enrolled_faces_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FaceRecognitionApp());
}

/// Aplikasi Face Recognition lengkap dengan Registrasi dan Absen
class FaceRecognitionApp extends StatelessWidget {
  const FaceRecognitionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Face Recognition SaaS',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const FaceRecognitionHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

/// Home page dengan navigation ke 3 screen utama
class FaceRecognitionHomePage extends StatefulWidget {
  const FaceRecognitionHomePage({super.key});

  @override
  State<FaceRecognitionHomePage> createState() =>
      _FaceRecognitionHomePageState();
}

class _FaceRecognitionHomePageState extends State<FaceRecognitionHomePage> {
  int _selectedIndex = 0;
  late FaceRecognitionProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = FaceRecognitionProvider();
    _provider.initialize();
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Face Recognition System'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: _buildBody(_provider),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.app_registration),
            label: 'Registrasi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.face_retouching_natural),
            label: 'Absen',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Manage',
          ),
        ],
      ),
    );
  }

  Widget _buildBody(FaceRecognitionProvider provider) {
    switch (_selectedIndex) {
      case 0:
        // Registrasi screen
        return _RegistrasiScreen(provider: provider);
      case 1:
        // Absen screen
        return _AbsenScreen(provider: provider);
      case 2:
        // Management screen
        return EnrolledFacesScreen(faceProvider: provider);
      default:
        return const SizedBox.shrink();
    }
  }
}

/// Screen untuk Registrasi/Enrollment wajah baru
class _RegistrasiScreen extends StatefulWidget {
  final FaceRecognitionProvider provider;

  const _RegistrasiScreen({required this.provider});

  @override
  State<_RegistrasiScreen> createState() => _RegistrasiScreenState();
}

class _RegistrasiScreenState extends State<_RegistrasiScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _userIdController;
  late final TextEditingController _emailController;
  Uint8List? _selectedImage;
  bool _isEnrolling = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _userIdController = TextEditingController();
    _emailController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _userIdController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    // Simplified - dalam praktik bisa gunakan image_picker
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Implement image picker untuk platform')),
    );
  }

  Future<void> _enrollFace() async {
    // Validasi
    if (_nameController.text.isEmpty) {
      _showError('Nama harus diisi');
      return;
    }
    if (_userIdController.text.isEmpty) {
      _showError('User ID harus diisi');
      return;
    }
    if (_emailController.text.isEmpty) {
      _showError('Email harus diisi');
      return;
    }
    if (_selectedImage == null) {
      _showError('Foto harus dipilih');
      return;
    }

    setState(() => _isEnrolling = true);

    try {
      await widget.provider.enrollFace(
        _selectedImage!,
        userId: _userIdController.text,
        name: _nameController.text,
      );

      if (mounted) {
        _showSuccess('Registrasi berhasil! ${_nameController.text} terdaftar.');
        _clearForm();
      }
    } catch (e) {
      _showError('Gagal registrasi: $e');
    } finally {
      if (mounted) setState(() => _isEnrolling = false);
    }
  }

  void _showError(String message) {
    setState(() => _errorMessage = message);
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _clearForm() {
    _nameController.clear();
    _userIdController.clear();
    _emailController.clear();
    setState(() => _selectedImage = null);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Card(
            color: Colors.blue[50],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(Icons.how_to_reg, size: 48, color: Colors.blue),
                  const SizedBox(height: 12),
                  const Text(
                    'Registrasi Wajah Baru',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Daftarkan wajah Anda untuk sistem absensi',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Error message
          if (_errorMessage != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                border: Border.all(color: Colors.red[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.error, color: Colors.red[700]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red[700]),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.red[700]),
                    onPressed: () => setState(() => _errorMessage = null),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          if (_errorMessage != null) const SizedBox(height: 16),

          // Photo section
          Card(
            elevation: 2,
            child: Column(
              children: [
                Container(
                  height: 200,
                  color: Colors.grey[100],
                  child: _selectedImage != null
                      ? Image.memory(_selectedImage!, fit: BoxFit.cover)
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.photo_camera,
                                size: 48, color: Colors.grey[400]),
                            const SizedBox(height: 8),
                            Text(
                              'Foto belum dipilih',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: ElevatedButton.icon(
                    onPressed: _isEnrolling ? null : _pickImage,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Ambil/Pilih Foto'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(44),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Form section
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Data Pribadi',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _nameController,
                    enabled: !_isEnrolling,
                    decoration: InputDecoration(
                      labelText: 'Nama Lengkap',
                      hintText: 'Contoh: John Doe',
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _userIdController,
                    enabled: !_isEnrolling,
                    decoration: InputDecoration(
                      labelText: 'User ID / NIP',
                      hintText: 'Contoh: EMP001',
                      prefixIcon: const Icon(Icons.badge),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _emailController,
                    enabled: !_isEnrolling,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      hintText: 'Contoh: john@example.com',
                      prefixIcon: const Icon(Icons.email),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Tombol registrasi
          ElevatedButton.icon(
            onPressed: _isEnrolling ? null : _enrollFace,
            icon: _isEnrolling
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check_circle),
            label: Text(_isEnrolling ? 'Mendaftar...' : 'Daftar Sekarang'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),

          const SizedBox(height: 16),

          // Tips card
          Card(
            color: Colors.blue[50],
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tips Registrasi',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '✓ Pastikan pencahayaan cukup terang\n'
                    '✓ Wajah terlihat jelas dan frontal\n'
                    '✓ Hindari bayangan di wajah\n'
                    '✓ Gunakan foto terbaru Anda',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Screen untuk Absen menggunakan wajah
class _AbsenScreen extends StatefulWidget {
  final FaceRecognitionProvider provider;

  const _AbsenScreen({required this.provider});

  @override
  State<_AbsenScreen> createState() => _AbsenScreenState();
}

class _AbsenScreenState extends State<_AbsenScreen> {
  Uint8List? _capturedImage;
  bool _isScanning = false;
  String? _scanResult;
  String? _scanStatus;
  DateTime? _lastAbsenTime;

  Future<void> _captureImage() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Implement camera capture untuk platform')),
    );
  }

  Future<void> _scanFace() async {
    if (_capturedImage == null) {
      _showError('Foto harus diambil terlebih dahulu');
      return;
    }

    setState(() => _isScanning = true);

    try {
      await widget.provider.recognizeFace(_capturedImage!);

      final result = widget.provider.lastMatchResult;
      if (result != null && result.isMatch) {
        setState(() {
          _scanResult = result.enrolledFaceId;
          _scanStatus = 'match';
          _lastAbsenTime = DateTime.now();
        });
        _showSuccess('Absen berhasil! ${result.enrolledFaceId}');
      } else {
        setState(() {
          _scanStatus = 'no_match';
          _scanResult = null;
        });
        _showError('Wajah tidak terkenali');
      }
    } catch (e) {
      _showError('Gagal scan: $e');
    } finally {
      if (mounted) setState(() => _isScanning = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _resetScan() {
    setState(() {
      _capturedImage = null;
      _scanResult = null;
      _scanStatus = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Card(
            color: Colors.orange[50],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(Icons.check_circle, size: 48, color: Colors.orange),
                  const SizedBox(height: 12),
                  const Text(
                    'Sistem Absensi Wajah',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Absen dengan pengenalan wajah',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Camera preview
          Card(
            elevation: 2,
            child: Column(
              children: [
                Container(
                  height: 250,
                  color: Colors.grey[100],
                  child: _capturedImage != null
                      ? Image.memory(_capturedImage!, fit: BoxFit.cover)
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera,
                                size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 12),
                            Text(
                              'Belum ada foto',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _isScanning ? null : _captureImage,
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Ambil Foto'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(44),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed:
                            _isScanning || _capturedImage == null ? null : _scanFace,
                        icon: _isScanning
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.face_retouching_natural),
                        label: Text(_isScanning ? 'Scanning...' : 'Absen Sekarang'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(44),
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Scan result
          if (_scanStatus != null)
            Card(
              elevation: 2,
              color: _scanStatus == 'match' ? Colors.green[50] : Colors.red[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(
                      _scanStatus == 'match'
                          ? Icons.check_circle
                          : Icons.cancel,
                      size: 48,
                      color:
                          _scanStatus == 'match' ? Colors.green : Colors.red,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _scanStatus == 'match' ? 'Absen Berhasil!' : 'Absen Gagal',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _scanStatus == 'match'
                            ? Colors.green[900]
                            : Colors.red[900],
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_scanResult != null)
                      Text(
                        'ID: $_scanResult',
                        style: const TextStyle(fontSize: 14),
                      ),
                    if (_lastAbsenTime != null)
                      Text(
                        _lastAbsenTime!.toLocal().toString().split('.')[0],
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _resetScan,
                      child: const Text('Scan Ulang'),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 24),

          // Info card
          Card(
            color: Colors.blue[50],
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Informasi Sistem',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _InfoRow('Sistem Operasi', _getOSInfo()),
                  _InfoRow(
                    'Status Service',
                    widget.provider.isInitialized ? 'Siap' : 'Tidak siap',
                  ),
                  _InfoRow(
                    'Data Terdaftar',
                    '${widget.provider.enrolledFaces.length} orang',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getOSInfo() {
    // Simplified - dalam praktik deteksi platform yang sebenarnya
    return 'Android / iOS / Web';
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12)),
          Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
