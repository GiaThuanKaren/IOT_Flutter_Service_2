import 'package:flutter/material.dart';
import 'package:iot_project_final/home_screen.dart';
import 'package:iot_project_final/login_screen.dart';
import 'package:iot_project_final/res/color.dart' as COLOR_APP;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import './utils/constant.dart';
import 'package:dio/dio.dart';
import './utils/cache.dart';
import './utils/functions.dart';
class RegisterScreen extends StatefulWidget {

  @override
  RegisterScreenState createState() {
    return RegisterScreenState();
  }
}

class RegisterScreenState extends State<RegisterScreen> {

  TextEditingController nameTextEdit = TextEditingController();
  TextEditingController emailTextEdit = TextEditingController();
  TextEditingController passwordTextEdit = TextEditingController();
  TextEditingController confirmPassTextEdit = TextEditingController();

  @override
  void initState() {
    super.initState();
  }
  Future<String?> _getId() async {
    var deviceInfo = DeviceInfoPlugin();

    if (Platform.isIOS) { // import 'dart:io'
      var iosDeviceInfo = await deviceInfo.iosInfo;
      return iosDeviceInfo.identifierForVendor; // unique ID on iOS
    } else if(Platform.isAndroid) {
      var androidDeviceInfo = await deviceInfo.androidInfo;
      return androidDeviceInfo.androidId; // unique ID on Android
    }
  }
  Future<String> loginApis(name,email, password,deviceID) async {
    // isloading:true;
    var Network = GetCurrentIPNetWork();
    var apiURL = '${Network}/register';

    Dio dio = Dio();
    Response responce;

    try {
      var formData = FormData.fromMap(
          {'name':name,'email': email, 'password': password, "deviceID": deviceID});
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
            MoveToLogin();
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
  MoveToHome() {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => HomeScreen()),
            (route) => false);
  }

  MoveToLogin() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => LoginScreen()));
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
                "REGISTER",
                style:  TextStyle(
                    color: COLOR_APP.primaryColor,
                    fontSize: 28,
                    fontWeight: FontWeight.bold),
              ),
              Container(
                height: 16,
              ),
              getTextEdit(nameTextEdit, "Username",
                  const Icon(Icons.person),
                  inputType: TextInputType.text),
              Container(
                height: 16,
              ),
              getTextEdit(emailTextEdit, "Email",
                  const Icon(Icons.email),
                  inputType: TextInputType.emailAddress),
              Container(
                height: 16,
              ),
              getTextEdit(passwordTextEdit, "Password",
                  const Icon(Icons.lock_outline),
                  isPassword: true),
              Container(
                height: 16,
              ),
              getTextEdit(confirmPassTextEdit, "Confirm Password",
                  const Icon(Icons.lock_outline),
                  isPassword: true),
              Container(
                height: 32,
              ),
              getRegisterButton(),
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

  Widget getRegisterButton() {
    return Stack(
      children: <Widget>[
        SizedBox(
          height: 45.0,
          child: RaisedButton(
            onPressed: register,
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

  register()async {
    print(nameTextEdit.text+" "+emailTextEdit.text+" "+passwordTextEdit.text+ " "+confirmPassTextEdit.text);
    var IDDevice = await _getId();
    print(IDDevice);

    loginApis(nameTextEdit.text,emailTextEdit.text,passwordTextEdit.text,IDDevice);
    // Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) =>  HomeScreen()), (route) => false);
  }

}