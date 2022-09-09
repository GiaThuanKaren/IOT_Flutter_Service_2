import 'package:shared_preferences/shared_preferences.dart';


class Cache {
  Cache._();
  static final instance = Cache._();

  static const _KEY = "iot_key";
static const _IDKEY = "id_key";
  String key = "";
  String deviceId = "";

  Stream save() async* {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    if (key != null && key.isNotEmpty) {
      await pref.setString(_KEY, key);
    }

    yield true;
  }
  Stream saveDeviceId() async* {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    if (key != null && key.isNotEmpty) {
      await pref.setString(_KEY, key);
    }

    yield true;
  }
  Stream<bool> load() async* {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    key = pref.get(_KEY);
    deviceId = pref.get(_IDKEY);
    yield true;
  }

  Stream clean() async* {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    pref.remove(_KEY);
    pref.remove(_IDKEY);
    yield true;
  }
}
