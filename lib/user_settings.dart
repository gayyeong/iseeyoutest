import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:iseeyou_final/home_page.dart';

class UserSettingsPage extends StatefulWidget {
  const UserSettingsPage({super.key});

  @override
  State<UserSettingsPage> createState() => _UserSettingsPageState();
}

class _UserSettingsPageState extends State<UserSettingsPage> {
  final nicknameController = TextEditingController();
  final emailController = TextEditingController();
  bool isLoading = true;
  bool isModified = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final data = doc.data();

    if (data != null) {
      nicknameController.text = data['nickname'] ?? '';
      emailController.text = data['email'] ?? '';
    }

    setState(() {
      isLoading = false;
    });

    nicknameController.addListener(() => setState(() => isModified = true));
    emailController.addListener(() => setState(() => isModified = true));
  }

  Future<void> _saveUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'nickname': nicknameController.text.trim(),
      'email': emailController.text.trim(),
    });

    setState(() => isModified = false);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('저장되었습니다.')));
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    bool readOnly = false,
  }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          padding: EdgeInsets.all(20),
          onPressed:
              () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => ProjectHomePage()),
              ),
          icon: Icon(Icons.arrow_back, size: 35,),
        ),
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 500,
                  vertical: 50,
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.account_circle_rounded,
                      size: 250,
                      color: const Color.fromARGB(255, 224, 222, 230),
                    ),
                    SizedBox(height: 50),
                    _buildField(label: "닉네임", controller: nicknameController),
                    const SizedBox(height: 20),
                    _buildField(
                      label: "이메일",
                      controller: emailController,
                      readOnly: true,
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: isModified ? _saveUserData : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF867FED),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('저장'),
                    ),
                  ],
                ),
              ),
    );
  }
}
