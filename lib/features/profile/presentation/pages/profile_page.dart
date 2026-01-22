import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/models/profile_model.dart';
import '../../data/profile_service.dart';
import '../../../auth/presentation/pages/login_page.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import '../../../subscription/presentation/pages/transaction_history_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/presentation/widgets/app_image.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ProfileService _service = ProfileService();
  bool _isLoading = true;
  ProfileData? _profileData;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  String _selectedGender = 'Male';
  String? _photoProfile;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final String targetPath =
          '${image.path.substring(0, image.path.lastIndexOf('.'))}_compressed.jpg';

      final XFile? compressedImage =
          await FlutterImageCompress.compressAndGetFile(
            image.path,
            targetPath,
            quality: 50,
          );

      if (compressedImage != null) {
        setState(() {
          _photoProfile = compressedImage.path;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final data = await _service.getProfile();
      setState(() {
        _profileData = data;
        _nameController.text = data.fullName;

        // Convert YYYY-MM-DD to DD/MM/YYYY
        if (data.dateOfBirth.isNotEmpty) {
          final parts = data.dateOfBirth.split('-');
          if (parts.length == 3) {
            _dobController.text = "${parts[2]}/${parts[1]}/${parts[0]}";
          } else {
            _dobController.text = data.dateOfBirth;
          }
        } else {
          _dobController.text = '';
        }

        _selectedGender = data.gender;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updateProfile() async {
    if (_nameController.text.trim().isEmpty ||
        _dobController.text.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Semua kolom harus diisi!'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    // Convert DD/MM/YYYY back to YYYY-MM-DD for API
    String apiDob = _dobController.text;
    if (apiDob.contains('/')) {
      final parts = apiDob.split('/');
      if (parts.length == 3) {
        apiDob = "${parts[2]}-${parts[1]}-${parts[0]}";
      }
    }

    final data = {
      'full_name': _nameController.text,
      'gender': _selectedGender,
      'date_of_birth': apiDob,
      if (_photoProfile != null) 'photo_profile': _photoProfile,
    };

    try {
      await _service.updateProfile(data);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Berhasil memperbaharui'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    await _service.logout();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('session');

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    // Parse initial date from DD/MM/YYYY if possible
    DateTime initialDate = DateTime(2000);
    if (_dobController.text.contains('/')) {
      final parts = _dobController.text.split('/');
      if (parts.length == 3) {
        initialDate = DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
      }
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        // Format: DD/MM/YYYY
        _dobController.text =
            "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _profileData == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      // backgroundColor: Colors.grey[50], // Removed to show background
      appBar: AppBar(
        title: const Text(
          'Profil',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent, // Transparent for background
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      extendBodyBehindAppBar: true, // Make body extend behind AppBar
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Profile Photo
                  _buildPhotoSection(),
                  const SizedBox(height: 20),

                  // Add-in Code
                  _buildAddInCodeSection(),
                  const SizedBox(height: 20),

                  // Name
                  _buildLabel('Nama Lengkap'),
                  _buildTextField(
                    controller: _nameController,
                    hint: 'Nama Lengkap',
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 16),

                  // Gender
                  _buildLabel('Jenis Kelamin'),
                  Row(
                    children: [
                      Expanded(
                        child: _buildGenderSelector(
                          'Male',
                          'Laki-laki',
                          Icons.male,
                          Colors.blue, // Active color for Male
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildGenderSelector(
                          'Female',
                          'Perempuan',
                          Icons.female,
                          Colors.pink, // Active color for Female
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Date of Birth
                  _buildLabel('Tanggal Lahir'),
                  GestureDetector(
                    onTap: () => _selectDate(context),
                    child: AbsorbPointer(
                      child: _buildTextField(
                        controller: _dobController,
                        hint: 'dd/MM/yyyy',
                        icon: Icons.calendar_today_outlined,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Transaction History (Navigation Item)
                  _buildMenuItem(
                    icon: Icons.receipt_long,
                    title: 'Riwayat Transaksi',
                    subtitle: 'Lihat semua transaksi',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TransactionHistoryPage(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 40),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: _isLoading
                        ? ElevatedButton(
                            onPressed: null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              disabledBackgroundColor: Colors.teal.withOpacity(
                                0.6,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            ),
                          )
                        : ElevatedButton.icon(
                            onPressed: _updateProfile,
                            icon: const Icon(Icons.save, color: Colors.white),
                            label: const Text(
                              'Simpan Perubahan',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                          ),
                  ),
                  const SizedBox(height: 16),

                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _logout,
                      icon: const Icon(Icons.logout, color: Colors.white),
                      label: const Text(
                        'Keluar',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddInCodeSection() {
    if (_profileData?.addInCode == null || _profileData!.addInCode.isEmpty) {
      return const SizedBox.shrink();
    }
    return Center(
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.teal.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.teal.withOpacity(0.2)),
        ),
        child: InkWell(
          onTap: () {
            Clipboard.setData(ClipboardData(text: _profileData!.addInCode));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Add-in Code disalin!'),
                backgroundColor: Colors.blue,
                duration: Duration(seconds: 1),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.qr_code, size: 20, color: Colors.teal),
              const SizedBox(width: 8),
              SelectableText(
                _profileData!.addInCode,
                style: const TextStyle(
                  color: Colors.teal,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.copy, size: 18, color: Colors.teal),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoSection() {
    Widget imageWidget;
    bool isNetwork = false;
    String? networkUrl;
    File? localFile;

    if (_photoProfile != null && _photoProfile!.isNotEmpty) {
      if (_photoProfile!.startsWith('http')) {
        isNetwork = true;
        networkUrl = _photoProfile;
      } else {
        localFile = File(_photoProfile!);
      }
    } else if (_profileData?.photoProfile != null &&
        _profileData!.photoProfile.isNotEmpty) {
      isNetwork = true;
      networkUrl = _profileData!.photoProfile;
    }

    if (localFile != null) {
      imageWidget = Image.file(
        localFile,
        fit: BoxFit.cover,
        width: 100,
        height: 100,
      );
    } else if (isNetwork && networkUrl != null) {
      imageWidget = AppImage(
        imageUrl: networkUrl,
        fit: BoxFit.cover,
        width: 100,
        height: 100,
      );
    } else {
      imageWidget = const Icon(Icons.person, size: 50, color: Colors.grey);
    }

    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.teal.withOpacity(0.2),
                      width: 4,
                    ),
                  ),
                  child: ClipOval(child: imageWidget),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.grey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildGenderSelector(
    String value,
    String label,
    IconData icon,
    Color activeColor,
  ) {
    final isSelected = _selectedGender == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedGender = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withOpacity(0.1)
              : Colors.white, // Tint for selected
          border: Border.all(
            color: isSelected ? activeColor : Colors.grey[200]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? activeColor : Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? activeColor : Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.purple[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.purple),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildBackground() {
    return Stack(
      children: [
        // Base Gradient
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.amber[50]!, Colors.white, Colors.teal[50]!],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        ),
        // Abstract Shapes
        Positioned(
          top: -100,
          right: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.amber[100]!.withOpacity(0.3),
            ),
          ),
        ),
        Positioned(
          bottom: -50,
          left: -50,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.teal[100]!.withOpacity(0.3),
            ),
          ),
        ),
      ],
    );
  }
}
