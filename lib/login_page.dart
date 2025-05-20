import 'package:flutter/material.dart';
import 'singup_page.dart';
import 'home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool autoLogin = true;

  Future<void> _loginWithFirebase() async {
    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ProjectHomePage()),
      );
    } on FirebaseAuthException catch (e) {
      String message = '';
      if (e.code == 'user-not-found') {
        message = '이메일 또는 비밀번호가 틀렸습니다.';
      } else if (e.code == 'wrong-password') {
        message = '이메일 또는 비밀번호가 틀렸습니다.';
      } else {
        // message = '오류: ${e.message}';
        message = '이메일 또는 비밀번호가 틀렸습니다.';
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 페이지로 복귀할 때마다 초기화
    _emailController.clear();
    _passwordController.clear();
  }

  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Row(
        children: [
          Container(
            width: screenWidth / 15 * 7,
            height: screenHeight,
            decoration: BoxDecoration(
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
            child: Transform.scale(
              scale: 1.3,
              child: Image.asset('assets/images/iseeyoulogo.png'),
            ),
          ),
          Container(
            width: screenWidth / 15 * 8,
            padding: const EdgeInsets.all(120),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: constraints.maxHeight),
                  child: SingleChildScrollView(
                    physics:
                        constraints.maxHeight < 500
                            ? const AlwaysScrollableScrollPhysics()
                            : const NeverScrollableScrollPhysics(),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Log in',
                            style: TextStyle(
                              fontSize: 80,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF867FED),
                            ),
                          ),
                          const SizedBox(height: 70),
                          SizedBox(
                            height: 60,
                            child: TextFormField(
                              controller: _emailController,
                              style: TextStyle(fontSize: 18),
                              decoration: InputDecoration(
                                labelText: '이메일',
                                labelStyle: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 18,
                                ),
                                prefixIcon: Icon(
                                  Icons.mail,
                                  size: 25,
                                  color: Colors.grey,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color(0xFF867FED),
                                  ),
                                ),
                                floatingLabelStyle: TextStyle(
                                  color: Color(0xFF867FED),
                                  fontSize: 15,
                                ),
                                errorStyle: TextStyle(fontSize: 13),
                              ),
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
                          const SizedBox(height: 20),
                          SizedBox(
                            height: 60,
                            child: TextFormField(
                              controller: _passwordController,
                              style: TextStyle(fontSize: 18),
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                labelText: '비밀번호',
                                labelStyle: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 18,
                                ),
                                prefixIcon: Icon(
                                  Icons.lock,
                                  size: 25,
                                  color: Colors.grey,
                                ),
                                suffixIcon: GestureDetector(
                                  onTapDown:
                                      (_) => setState(
                                        () => _obscurePassword = false,
                                      ),
                                  onTapUp:
                                      (_) => setState(
                                        () => _obscurePassword = true,
                                      ),
                                  child: Icon(
                                    Icons.visibility,
                                    size: 25,
                                    color: Colors.grey,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color(0xFF867FED),
                                  ),
                                ),
                                floatingLabelStyle: TextStyle(
                                  color: Color(0xFF867FED),
                                  fontSize: 15,
                                ),
                                errorStyle: TextStyle(fontSize: 13),
                              ),
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
                          const SizedBox(height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Transform.scale(
                                scale: 1,
                                child: Checkbox(
                                  value: autoLogin,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      autoLogin = value!;
                                    });
                                  },
                                  activeColor: Color(0xFF867FED),
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  // visualDensity:
                                  //     VisualDensity(horizontal: -4, vertical: -4),
                                ),
                              ),
                              Text(
                                '로그인 유지',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              Spacer(),
                              SizedBox(
                                height: 30,
                                child: TextButton(
                                  onPressed: () {},
                                  style: TextButton.styleFrom(
                                    minimumSize: Size.zero,
                                    padding: EdgeInsets.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    '비밀번호 찾기',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Color(0xFF867FED),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  _loginWithFirebase();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF867FED),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                elevation: 2,
                              ),
                              child: Text(
                                '로그인',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 23,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 60),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 20,
                                width: 200,
                                child: Divider(
                                  color: Colors.grey.shade300,
                                  thickness: 2,
                                ),
                              ),
                              Spacer(),
                              Text(
                                '간편 로그인',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                              Spacer(),
                              SizedBox(
                                height: 20,
                                width: 200,
                                child: Divider(
                                  color: Colors.grey.shade300,
                                  thickness: 2,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 60),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              for (var asset in [
                                'kakaoIcon.png',
                                'naverIcon.png',
                                'googleIcon.png',
                              ])
                                SizedBox(
                                  height: 60,
                                  width: 150,
                                  child: ElevatedButton(
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color.fromARGB(
                                        255,
                                        219,
                                        219,
                                        247,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                    child: Transform.scale(
                                      scale: 0.5,
                                      child: Image.asset(
                                        'assets/images/$asset',
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 60),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => SignUpPage(title: '회원가입'),
                                ),
                              ).then((_) {
                                // 회원가입 페이지에서 돌아왔을 때 입력값 초기화
                                _emailController.clear();
                                _passwordController.clear();
                              });
                            },
                            style: TextButton.styleFrom(
                              minimumSize: Size.zero,
                              padding: EdgeInsets.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              '회원가입',
                              style: TextStyle(
                                fontSize: 20,
                                color: Color(0xFF867FED),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
