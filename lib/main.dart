import 'package:flutter/services.dart';
import 'package:flutter/material.dart' hide Router;
import 'package:fluro/fluro.dart';
import 'package:iot_project_final/splash_creen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './utils/functions.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  //SharedPreferences.setMockInitialValues({});
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final router = Router();

  MyApp () {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light
        .copyWith(statusBarColor: Colors.transparent));
    SystemChrome.setPreferredOrientations(
        <DeviceOrientation>[DeviceOrientation.portraitUp]);

    router.define("/",
        handler: Handler(
            type: HandlerType.route,
            handlerFunc: (context, params) => SplashScreen()));

  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Iot",
      theme: ThemeData(
        primaryColor: Color(0xFF00bca5),
        accentColor: Color(0xFF5cefd6),
      ),
      onGenerateRoute: router.generator,
    );
  }

}
