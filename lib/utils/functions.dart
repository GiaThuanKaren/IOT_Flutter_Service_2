import 'dart:convert';
// import 'package:';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';

dynamic ConvertStringToJson(String chuoi){
  dynamic jsonConv = jsonDecode(chuoi);
  return jsonConv;
}
Future<String?> getId() async {
  var deviceInfo = DeviceInfoPlugin();

  if (Platform.isIOS) { // import 'dart:io'
    var iosDeviceInfo = await deviceInfo.iosInfo;
    return iosDeviceInfo.identifierForVendor; // unique ID on iOS
  } else if(Platform.isAndroid) {
    var androidDeviceInfo = await deviceInfo.androidInfo;
    return androidDeviceInfo.androidId; // unique ID on Android
  }
  return null;
}

Future<Response> uploadImage(
    File file, String url, String FileName, String KeyUSER) async {
  // var request = http.MultipartRequest('POST', Uri.parse(url));
  // request.files.add(await http.MultipartFile.fromPath('image', filepath));
  // var res = await request.send();
  // return res.reasonPhrase;

  var dio = Dio();
  var formData = FormData.fromMap({
    'name': 'wendux',
    'age': 25,
    'key': KeyUSER,
    'tenfile': await MultipartFile.fromFile(file.path, filename: FileName),
    // 'file': await MultipartFile.fromFile('./text.txt', filename: 'upload.txt'),
    // 'files': [
    //   await MultipartFile.fromFile('./text1.txt', filename: 'text1.txt'),
    //   await MultipartFile.fromFile('./text2.txt', filename: 'text2.txt'),
    // ]
  });
  var response = await dio.post(
    url,
    data: formData,
    onSendProgress: (int sent, int total) {
      var percent = (sent / total) * 100;
      print('$percent%');
    },
  );
  return response;
}