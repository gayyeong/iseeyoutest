import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key, required this.title});
  final String title;

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final leftPanelWidth = screenWidth / 15 * 7;
    final rightPanelWidth = screenWidth / 15 * 8;

    return Scaffold(
      body: Row(
        children: [
          Container(
            width: leftPanelWidth,
            height: double.infinity,
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 206, 206, 245),
              border: Border(
                top: BorderSide(
                  color: Color.fromARGB(255, 219, 219, 247),
                  width: 40,
                ),
                right: BorderSide(
                  color: Color.fromARGB(255, 219, 219, 247),
                  width: 40,
                ),
              ),
              borderRadius: BorderRadius.only(topRight: Radius.circular(180)),
            ),
            child: Center(
              child: Transform.scale(
                scale: 1.3,
                child: Image.asset('assets/images/iseeyoulogo.png'),
              ),
            ),
          ),
          Container(
            width: rightPanelWidth,
            padding: const EdgeInsets.symmetric(horizontal: 100),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.chevron_left,
                            size: 60,
                            color: Colors.grey,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          '회원가입',
                          style: TextStyle(
                            fontSize: 70,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF867FED),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),

                    Padding(
                      padding: const EdgeInsets.only(left: 60),
                      child: _buildInputField(
                        label: '이메일',
                        icon: Icons.mail,
                        controller: _emailController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '이메일을 입력하세요.';
                          }
                          if (!value.contains('@')) {
                            return '올바른 이메일 형식이 아닙니다.';
                          }
                          return null;
                        },
                      ),
                    ),

                    const SizedBox(height: 15),

                    Padding(
                      padding: const EdgeInsets.only(left: 60),
                      child: _buildInputField(
                        label: '비밀번호',
                        icon: Icons.lock,
                        controller: _passwordController,
                        obscure: _obscurePassword,
                        toggleObscure: (value) {
                          setState(() {
                            _obscurePassword = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '비밀번호를 입력하세요.';
                          }
                          if (value.length < 8) {
                            return '비밀번호는 최소 8자 이상이어야 합니다.';
                          }
                          return null;
                        },
                      ),
                    ),

                    const SizedBox(height: 15),

                    Padding(
                      padding: const EdgeInsets.only(left: 60),
                      child: _buildInputField(
                        label: '비밀번호 확인',
                        icon: Icons.lock,
                        controller: _confirmPasswordController,
                        obscure: _obscureConfirm,
                        toggleObscure: (value) {
                          setState(() {
                            _obscureConfirm = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '비밀번호 확인을 입력하세요.';
                          }
                          if (value != _passwordController.text) {
                            return '비밀번호가 일치하지 않습니다.';
                          }
                          return null;
                        },
                      ),
                    ),

                    const SizedBox(height: 50),

                    Padding(
                      padding: const EdgeInsets.only(left: 60),
                      child: SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (!_formKey.currentState!.validate()) return;

                            final email = _emailController.text.trim();
                            final password = _passwordController.text.trim();

                            try {
                              final userCredential = await FirebaseAuth.instance
                                  .createUserWithEmailAndPassword(
                                    email: email,
                                    password: password,
                                  );

                              final user = userCredential.user;

                              if (user != null) {
                                await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(user.uid)
                                    .set({
                                      'email': email,
                                      'nickname': email, 
                                      'createdAt': FieldValue.serverTimestamp(),
                                    });
                              }

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('회원가입 성공!')),
                              );
                              Navigator.pop(context);
                            } on FirebaseAuthException catch (e) {
                              String message = '';
                              if (e.code == 'email-already-in-use') {
                                message = '이미 가입된 이메일입니다.';
                              } else if (e.code == 'invalid-email') {
                                message = '유효하지 않은 이메일 형식입니다.';
                              } else if (e.code == 'weak-password') {
                                message = '비밀번호가 너무 약합니다.';
                              } else {
                                message = '회원가입 실패: ${e.message}';
                              }

                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(SnackBar(content: Text(message)));
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF867FED),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            '회원가입',
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Padding(
                      padding: EdgeInsets.only(left: 60),
                      child: Text(
                        '회원가입 약관에 동의하는 것으로 간주됩니다.',
                        style: TextStyle(fontSize: 15, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    bool obscure = false,
    void Function(bool)? toggleObscure,
    String? Function(String?)? validator,
  }) {
    return SizedBox(
      height: 60,
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        validator: validator,
        style: const TextStyle(fontSize: 18),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey, fontSize: 18),
          errorStyle: const TextStyle(fontSize: 13, color: Colors.red),
          prefixIcon: Icon(icon, size: 25, color: Colors.grey),
          suffixIcon:
              toggleObscure != null
                  ? GestureDetector(
                    onTapDown: (_) => toggleObscure(false),
                    onTapUp: (_) => toggleObscure(true),
                    onTapCancel: () => toggleObscure(true),
                    child: const Icon(
                      Icons.visibility,
                      size: 20,
                      color: Colors.grey,
                    ),
                  )
                  : null,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Color.fromARGB(255, 134, 132, 221)),
          ),
          errorBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red),
          ),
          floatingLabelStyle: const TextStyle(
            color: Color.fromARGB(255, 134, 132, 221),
            fontSize: 15,
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 0,
            horizontal: 8,
          ),
          isDense: true,
        ),
      ),
    );
  }
}
