import 'package:flutter/material.dart';
import 'package:frontend/gptchat.dart';
import 'package:frontend/signUp_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // 추가

class LoginPage extends StatelessWidget {
  LoginPage({super.key});
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final storage = const FlutterSecureStorage(); // SecureStorage 객체 생성

  void loginUser(BuildContext context) async {
    String userName = _userNameController.text;
    String password = _passwordController.text;

    if (userName.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('유저네임과 비밀번호를 입력하세요.')),
      );
      return; // 입력이 없으면 로그인 요청을 보내지 않음
    }
    // 로그인 요청을 보낼 URL
    Uri url = Uri.parse('https://apayo.kro.kr/api/login');

    try {
      var request = http.MultipartRequest('POST', url);
      request.fields['username'] = userName;
      request.fields['password'] = password;

      var response = await request.send();

      if (response.statusCode == 200) {
        var responseBody = await http.Response.fromStream(response);
        Map<String, dynamic> responseBodyJson = jsonDecode(responseBody.body);
        String accessToken = responseBodyJson['access_token']; // 응답 토큰 추출

        await storage.write(
            key: 'access_token', value: accessToken); // SecureStorage에 토큰 저장

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const GptPage()),
        );
      } else {
        // 로그인 실패
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('로그인에 실패했습니다.')),
        );
      }
    } catch (e) {
      // 요청 실패
      print('Error during login: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인에 오류가 발생했습니다. 다시 시도해주세요.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width; //넓이
    double screenHeight = MediaQuery.of(context).size.height; //높이 가져옴

    // 화면 크기에 따라 폰트 크기와 패딩을 동적으로 설정

    double fontSize = screenWidth < 850 ? 18 : 18;
    double paddingSize = screenWidth < 850 ? 20 : 50;

    double formFieldWidth =
        screenWidth < 800 ? screenWidth * 0.8 : screenWidth * 0.3;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Text(
              'APAYO TEAM 6',
              style: TextStyle(
                color: Color.fromARGB(255, 94, 94, 94),
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 10),
            Text(
              '          RYU SOOJUNG         LEE SANGYUN         HYUN SOYOUNG',
              style: TextStyle(
                color: Color.fromARGB(255, 94, 94, 94),
                fontSize: 10,
              ),
            ),
            Spacer(), // 로고 오른쪽 이동
            Image(
              image: AssetImage('assets/logo.png'),
              width: 50,
              height: 50,
            ),
          ],
        ),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        toolbarHeight: 70,
        titleSpacing: 0,
      ), // 앱바 *************************************************
      backgroundColor: const Color(0xFFF1F1F1),
      body: SingleChildScrollView(
        // SingleChildScrollView 추가
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: formFieldWidth, // 폼 필드 동적 조절
                    child: Container(
                      padding: EdgeInsets.all(paddingSize), // 패딩 동적 조절
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20), // 박스 각도 추가
                      ),

                      //height: screenHeight * 0.7, //박스크기
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Log In APAYO",
                            style: TextStyle(
                                fontSize: fontSize * 1.4,
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                          //유저이름 *********************************
                          SizedBox(height: screenHeight * 0.06),
                          TextFormField(
                            controller: _userNameController,
                            decoration: const InputDecoration(
                              labelText: 'User Name',
                            ),
                            obscureText: false,
                          ),
                          //비번 *************************************
                          SizedBox(height: screenHeight * 0.04),
                          TextFormField(
                            controller: _passwordController,
                            decoration:
                                const InputDecoration(labelText: 'Password'),
                            obscureText: true, // 비번 가리기
                          ),
                          // 로그인 버튼 *******************************
                          SizedBox(height: screenHeight * 0.07),
                          SizedBox(
                            width: formFieldWidth,
                            child: ElevatedButton(
                              onPressed: () => loginUser(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 55, 207, 207),
                                fixedSize: const Size.fromHeight(50),
                              ),
                              child: Text(
                                'Login',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: fontSize,
                                    fontWeight: FontWeight.w200),
                              ),
                            ),
                          ),

                          // or 사진 *************************************

                          SizedBox(height: screenHeight * 0.02),
                          Image.asset(
                            'assets/or.png',
                            width: 300,
                            height: 40,
                          ),

                          //read policy***************************************
                          SizedBox(height: screenHeight * 0.02),
                          TextButton(
                              onPressed: () {},
                              style: ButtonStyle(
                                overlayColor:
                                    WidgetStateProperty.all(Colors.transparent),
                              ),
                              child: const Text(
                                "Click here to read APAYO's policy",
                                style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w100,
                                ),
                              )),

                          // 회원가입 버튼 ******************************
                          SizedBox(height: screenHeight * 0.03),
                          SizedBox(
                            width: formFieldWidth,
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SignUpPage(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  fixedSize: const Size.fromHeight(50),
                                  side: const BorderSide(
                                      color: Colors.black, width: 0.1),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30))),
                              child: Text(
                                "don't have account? Sign Up",
                                style: TextStyle(
                                  color: const Color.fromARGB(255, 0, 0, 0),
                                  fontSize: fontSize * 0.7,
                                  fontWeight: FontWeight.w200,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ), // 컨테이너 높이 동적 조절
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.9), // 이미지 상단 간격 조정
            MediaQuery.of(context).size.width >= 850
                ? Expanded(
                    child: Center(
                      child: Visibility(
                        visible: MediaQuery.of(context).size.width >= 400,
                        child: Image.asset(
                          'assets/loginPagePic.png',
                          width: 650,
                          height: 650,
                        ),
                      ),
                    ),
                  )
                : const SizedBox(),
          ],
        ),
      ), // SingleChildScrollView 닫기
    );
  }
}
