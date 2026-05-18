import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_energy_controller/providers/auth_provider.dart';
import 'package:smart_energy_controller/utils/theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _username = 'User';
  String _email = 'user@example.com';
  String _phoneNumber = '+923001234567';
  String _wifiName = 'Home_WiFi';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    setState(() {
      _username = prefs.getString('username') ?? user?.name ?? 'User';
      _email = prefs.getString('email') ?? user?.email ?? 'user@example.com';
      _phoneNumber = prefs.getString('phone_number') ?? user?.phoneNumber ?? '+923001234567';
      _wifiName = prefs.getString('wifi_name') ?? 'Home_WiFi';
    });
  }

  Future<void> _saveSetting(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.lightBg,
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _email.isNotEmpty ? _email[0].toUpperCase() : 'U',
                    style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: AppTheme.primary),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              _buildTextFieldTile(
                title: 'Username',
                subtitle: 'Edit your username',
                value: _username,
                icon: Icons.person,
                onChanged: (v) {
                  setState(() => _username = v);
                  _saveSetting('username', v);
                },
              ),
              const SizedBox(height: 16),
              _buildTextFieldTile(
                title: 'Email',
                subtitle: 'Edit your email',
                value: _email,
                icon: Icons.email,
                onChanged: (v) {
                  setState(() => _email = v);
                  _saveSetting('email', v);
                },
              ),
              const SizedBox(height: 16),
              _buildTextFieldTile(
                title: 'Phone Number',
                subtitle: 'Edit your phone number',
                value: _phoneNumber,
                icon: Icons.phone,
                onChanged: (v) {
                  setState(() => _phoneNumber = v);
                  _saveSetting('phone_number', v);
                },
              ),
              const SizedBox(height: 16),
              _buildTextFieldTile(
                title: 'WiFi',
                subtitle: 'Edit WiFi name',
                value: _wifiName,
                icon: Icons.wifi,
                onChanged: (v) {
                  setState(() => _wifiName = v);
                  _saveSetting('wifi_name', v);
                },
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context); // Close screen
                    authProvider.logout();
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFieldTile({
    required String title,
    required String subtitle,
    required String value,
    required IconData icon,
    required Function(String) onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.cardShadow,
        border: Border.all(
          color: isDark
              ? AppTheme.primaryLight.withValues(alpha: 0.12)
              : Colors.white,
          width: 1.5,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        leading: Icon(icon, color: AppTheme.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        trailing: IconButton(
          icon: const Icon(Icons.edit, color: AppTheme.primary),
          onPressed: () => _showEditDialog(title, value, onChanged),
        ),
      ),
    );
  }

  void _showEditDialog(
      String title, String currentValue, Function(String) onSave) {
    final controller = TextEditingController(text: currentValue);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit $title'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: 'Enter $title'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              onSave(controller.text.trim());
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$title updated'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
