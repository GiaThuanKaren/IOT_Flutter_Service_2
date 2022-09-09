import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:iot_project_final/register_screen.dart';
import 'package:iot_project_final/res/color.dart' as COLOR_APP;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:dio/dio.dart';
import 'package:iot_project_final/utils/constant.dart';
import 'home_screen.dart';
import './utils/cache.dart';
import './utils/functions.dart';
class LoginScreen extends StatefulWidget {
  @override
  LoginScreenState createState() {
    return LoginScreenState();
  }
}

class LoginScreenState extends State<LoginScreen> {
  TextEditingController emailTextEdit = TextEditingController();
  TextEditingController passwordTextEdit = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  Future<String> loginApis(email, password) async {
    // isloading:true;
    var Network =GetCurrentIPNetWork();
    var apiURL = '${Network}/login';

    Dio dio = Dio();
    Response responce;
    var IDDevice = await getId();
    try {
      var formData = FormData.fromMap(
          {'email': email, 'password': password,"deviceID":IDDevice});
      //final prefs = await SharedPreferences.getInstance();
      print(formData.toString());
      print(" Form Respone");
      responce = await dio.post(
        apiURL,
        data: formData,
      );
      print(responce.toString());
      dynamic jsonConv = jsonDecode(responce.toString());

      // Cache.instance.save().listen((event) {}, onError: (e) {
      //   print("Loi khi luu vao preference");
      //   print(e);
      // }, onDone: () {
      //   print(" Đã save key vào preference");
      // });

      // print(responce);
      // print("response data " + jsonDecode(responce.data));

      // if (responce.data['error'] == false) {
      //   // Navigator.push(
      //   //   context,
      //   //   MaterialPageRoute(builder: (context) => Navbar()),
      //   // );
      //   Fluttertoast.showToast(
      //       msg: "Login Successfull", backgroundColor: Colors.cyan);
      // } else {
      //   Fluttertoast.showToast(
      //       msg: "Login Failed", backgroundColor: Colors.cyan);
      // }
      switch (jsonConv['statusCode']) {
        case 200:
          {
            Fluttertoast.showToast(
                msg: jsonConv["text"], backgroundColor: Colors.cyan);
            var _key = jsonConv["data"]["key_user"];
            print("Key người dùng trả về " + _key);
            Cache.instance.key = _key;
            Cache.instance.save().listen((event) {}, onError: (e) {
              print("Loi khi luu vao preference");
              print(e);
            }, onDone: () {

              print(" Đã save key vào preference");
              MoveToHome();
            });
            break;
          }
        case 404:
          {
            Fluttertoast.showToast(
                msg: jsonConv["text"], backgroundColor: Colors.cyan);
            break;
          }
        default:{
          print("Can't not find a suitable case ");
        }
      }
    } on Exception catch(e){
      print(e);
    };
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: COLOR_APP.primaryColor,
      body: Container(
        padding: const EdgeInsets.only(top: 46, left: 16, right: 16),
        margin: const EdgeInsets.fromLTRB(16, 100, 16, 80),
        decoration: const BoxDecoration(
            color: COLOR_APP.white,
            borderRadius: BorderRadius.all(Radius.circular(32))),
        child: SingleChildScrollView(
          child: Column(
//                  mainAxisAlignment: MainAxisAlignment.center,
//                  crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "LOGIN",
                style: TextStyle(
                    color: COLOR_APP.primaryColor,
                    fontSize: 28,
                    fontWeight: FontWeight.bold),
              ),
              Container(
                height: 16,
              ),
              getTextEdit(
                  emailTextEdit, "abc@example.com", const Icon(Icons.email),
                  inputType: TextInputType.text),
              Container(
                height: 16,
              ),
              getTextEdit(
                  passwordTextEdit, "*********", const Icon(Icons.lock_outline),
                  isPassword: true, inputType: TextInputType.number),
              Container(
                height: 32,
              ),
              getLoginButton(),
              getRegisterWidget(),
            ],
          ),
        ),
      ),
    );
  }

  Widget getTextEdit(
      TextEditingController controller, String hint, Icon leftIcon,
      {TextInputType inputType = TextInputType.text, bool isPassword = false}) {
    return TextField(
      controller: controller,
      keyboardType: inputType,
      obscureText: isPassword,
      style: const TextStyle(color: COLOR_APP.colorPrimaryDark, fontSize: 18),
      decoration: InputDecoration(
          filled: false,
          prefixIcon: leftIcon,
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: COLOR_APP.hintText, width: 2),
          ),
          hintText: hint,
          hintStyle: const TextStyle(color: COLOR_APP.hintText, fontSize: 18)),
    );
  }

  Widget getRegisterWidget() {
    return Padding(
      padding: const EdgeInsets.only(top: 28.0),
      child: InkWell(
        onTap: register,
        child: const Text(
          "Register",
          style: TextStyle(
              color: COLOR_APP.primaryColor,
              fontSize: 18.0,
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget getLoginButton() {
    return Stack(
      children: <Widget>[
        SizedBox(
          height: 45.0,
          child: RaisedButton(
            onPressed: () {
              // print(emailTextEdit.value.text + " " + passwordTextEdit.value.text);
              login();
            },
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0))),
            color: COLOR_APP.primaryColor,
            splashColor: COLOR_APP.accentColor,
            child: const Center(
              child: Text(
                "Continue",
                style: TextStyle(color: COLOR_APP.white, fontSize: 18.0),
              ),
            ),
          ),
        ),
//        isLoading
//            ? SpinKitFadingCircle(
//          color: ColorApp.whiteText,
//          size: 45.0,
//        )
//            : Container()
      ],
    );
  }

  login() {
    print(emailTextEdit.value.text + " " + passwordTextEdit.value.text);
    loginApis(emailTextEdit.value.text, passwordTextEdit.value.text);
    // Navigator.of(context).pushAndRemoveUntil(
    //     MaterialPageRoute(builder: (context) => HomeScreen()),
    //     (route) => false);
  }

  register() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => RegisterScreen()));
  }

  MoveToHome() {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => HomeScreen()),
        (route) => false);
  }

  MoveToRegister() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => RegisterScreen()));
  }
}
