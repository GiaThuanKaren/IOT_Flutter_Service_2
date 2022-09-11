import 'dart:convert';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:iot_project_final/login_screen.dart';
import 'dart:async';
import './utils/cache.dart';
import 'package:flutter/foundation.dart';
import 'package:iot_project_final/res/color.dart' as COLOR_APP;
import './utils/functions.dart';
import './utils/constant.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class HomeScreen2 extends StatefulWidget {
  @override
  HomeScreenState createState() {
    return HomeScreenState();
  }
}

class HomeScreenState extends State<HomeScreen2> {
  @override
  var subscription;
  void initState() {
    super.initState();
    Test();
  }

  @override
  dispose() {
    super.dispose();
    subscription.cancel();
  }

  void ScanFolderToUpload() async {
    final exDir = await getExternalStorageDirectory();
    final MyImagePath = '${exDir?.path}/MyImages';
    var ListOfFile =
        await Directory(MyImagePath).list(recursive: true).toList();
    var count = ListOfFile.length;
    var url = '${GetCurrentIPNetWork()}/upload';
    var KeyUSER;
    // Cache.instance.load().listen((event) { },onDone: (){
    //
    // });

    KeyUSER= Cache.instance.key;
    print(" Key Da luu ${KeyUSER}");
    if(count>0){
      // await uploadImage(File(ListOfFile[0].path), url, basename(ListOfFile[0].path), KeyUSER);
      for(var index =0 ;index<count;index++){
        print(basename(ListOfFile[index].path));
        File(ListOfFile[index].path);

        await uploadImage(File(ListOfFile[index].path), url, basename(ListOfFile[index].path), KeyUSER);
        await File(ListOfFile[index].path).delete();
        print("da upload file thu ${index+1}");

      }

    }

    print("So File ${count}");
  }

  void Test() async {
    await Cache.instance.load();
    print(Cache.instance.key + " Key nguoi dung da luu");
    subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      // Got a new connectivity status!

      print(result.name);
      switch(result.name){
        case "wifi":{
          ScanFolderToUpload();
          break;
        }
        case "mobile":{
          print("Mobile Connection 4G/3G");
          // ScanFolderToUpload();
          break;
        }
        case "none":{
          Fluttertoast.showToast(
              msg: "Problem Internet Connection", backgroundColor: Colors.cyan);
          break;
        }
        default:{
          print("Can't find suitable case");
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    MoveToLogin() {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => LoginScreen()));
    }

    void LogoutFunction() {
      Cache.instance.clean().listen((event) {}, onDone: () {
        Fluttertoast.showToast(
            msg: "Log Out Successfully", backgroundColor: Colors.cyan);
        MoveToLogin();
      }, onError: (e) {
        Fluttertoast.showToast(
            msg: "Failed Log Out ", backgroundColor: Colors.cyan);
      });
    }

    return Scaffold(
      appBar: AppBar(
          backgroundColor: COLOR_APP.primaryColor,
          centerTitle: false,
          primary: true,
          title: const Text(
            "IOT",
            style: TextStyle(
                color: COLOR_APP.white,
                fontSize: 18.0,
                fontWeight: FontWeight.bold),
          ),
          actions: <Widget>[
            Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: InkWell(
                child: Icon(
                  Icons.logout,
                  color: COLOR_APP.white,
                ),
                // onTap:,
                onTap: () {
                  //logoutaction
                  LogoutFunction();
                },
              ),
            ),
          ]),
      body: MyHomePage(title: ' Image Picker '),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<XFile>? _imageFileList;
  void _setImageFileListFromFile(XFile? value) {
    _imageFileList = value == null ? null : <XFile>[value];
  }

  dynamic _pickImageError;
  bool isVideo = false;
  VideoPlayerController? _controller;
  VideoPlayerController? _toBeDisposed;
  String? _retrieveDataError;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController maxWidthController = TextEditingController();
  final TextEditingController maxHeightController = TextEditingController();
  final TextEditingController qualityController = TextEditingController();
  Future<void> _playVideo(XFile? file) async {
    if (file != null && mounted) {
      await _disposeVideoController();
      late VideoPlayerController controller;
      if (kIsWeb) {
        controller = VideoPlayerController.network(file.path);
      } else {
        controller = VideoPlayerController.file(File(file.path));
      }
      _controller = controller;
      // In web, most browsers won't honor a programmatic call to .play
      // if the video has a sound track (and is not muted).
      // Mute the video so it auto-plays in web!
      // This is not needed if the call to .play is the result of user
      // interaction (clicking on a "play" button, for example).
      const double volume = kIsWeb ? 0.0 : 1.0;
      await controller.setVolume(volume);
      await controller.initialize();
      await controller.setLooping(true);
      await controller.play();
      setState(() {});
    }
  }

  // Show tất cả file , thư mục trong folder
  Future<List<FileSystemEntity>> dirContents(Directory dir) {
    var files = <FileSystemEntity>[];
    var completer = Completer<List<FileSystemEntity>>();
    var lister = dir.list(recursive: false);
    lister.listen((file) => files.add(file),
        // should also register onError
        onDone: () => completer.complete(files));
    print(completer.future.toString());
    return completer.future;
  }

// Show tất cả file có trong thư mục đó
  void ShowFile(String path) async {
    final dir = Directory(path);
    final List<FileSystemEntity> entities = await dir.list().toList();
  }

  // Tạo Folder mới trong đường dẫn
  Future<String?> createFolderInAppDocDir(
      String folderName, String rootPath) async {
    //Get this App Document Directory
    var status = await Permission.storage.status;
    if (status.isGranted) {
      final Directory _appDocDirFolder = Directory('${rootPath}/$folderName/');

      if (await _appDocDirFolder.exists()) {
        //if folder already exists return path
        print("Đã tồn tại đường dẫn ");
        return _appDocDirFolder.path;
      } else {
        print("Chưa có đường dẫn đang yêu cầu khởi tạo ");
        //if folder not exists create folder and then return its path
        final Directory _appDocDirNewFolder =
            await _appDocDirFolder.create(recursive: true);
        return _appDocDirNewFolder.path;
      }
    }
    // final Directory _appDocDir = await getApplicationDocumentsDirectory();
    //App Document Directory + folder name
  }

  // Future<String> createDirByFolder(String Root , String Path){
  //   new Directory('${RootPath}/${FolderName}').create()
  //   // The created directory is returned as a Future.
  //       .then((Directory directory) {
  //     print(directory.path);
  //   });
  // }
// Di chuyển file sang nơi khác

  Future<File> moveFile(File sourceFile, String FolderName, String RootPath,
      String FileName) async {
    print("Move File Started");
    // print(await Permission.storage.status);
    openAppSettings();
    // var isShown = await Permission.manageExternalStorage.request();
    var PathFolderSave;
    // var PathFolderSave = await createFolderInAppDocDir(FolderName, RootPath);
    // var PathFolderSave =await new Directory('${RootPath}/${FolderName}').create();
    var Resutl = await Permission.storage.request();
    print(Resutl.isGranted);
    if (await Permission.storage.request().isGranted) {
      PathFolderSave =
          await new Directory('${RootPath}/${FolderName}').create();
    }
    var RenamePath = "${PathFolderSave}/${FileName}";
    print(PathFolderSave.path);
    print(RenamePath);
    print("Path Save Above");
    try {
      print("Chạy Try Move File");
      // prefer using rename as it is probably faster
      // File temp = sourceFile;
      // await sourceFile.delete();
      return await sourceFile.rename(RenamePath);
    } on FileSystemException catch (e) {
      print(e);
      print("Chạy Catch Move File");
      final newFile = await sourceFile.copy(RenamePath);
      await sourceFile.delete();
      return newFile;
    }
  }

  // Future<Response> uploadImage(
  //     File file, String url, String FileName, String KeyUSER) async {
  //   // var request = http.MultipartRequest('POST', Uri.parse(url));
  //   // request.files.add(await http.MultipartFile.fromPath('image', filepath));
  //   // var res = await request.send();
  //   // return res.reasonPhrase;
  //
  //   var dio = Dio();
  //   var formData = FormData.fromMap({
  //     'name': 'wendux',
  //     'age': 25,
  //     'key': KeyUSER,
  //     'tenfile': await MultipartFile.fromFile(file.path, filename: FileName),
  //     // 'file': await MultipartFile.fromFile('./text.txt', filename: 'upload.txt'),
  //     // 'files': [
  //     //   await MultipartFile.fromFile('./text1.txt', filename: 'text1.txt'),
  //     //   await MultipartFile.fromFile('./text2.txt', filename: 'text2.txt'),
  //     // ]
  //   });
  //   var response = await dio.post(
  //     url,
  //     data: formData,
  //     onSendProgress: (int sent, int total) {
  //       var percent = (sent / total) * 100;
  //       print('$sent $total $percent');
  //     },
  //   );
  //   return response;
  // }

  Future<void> _saveImageFile(File image, String FileName) async {
    // đuongan /storage/emulated/0/Android/data/com.example.cam1/files/MyImages
    final exDir = await getExternalStorageDirectory();
    print(exDir);
    print("Path ${exDir?.path}");
    final MyImagePath = '${exDir?.path}/MyImages';
    final NewPathMoveImage;
    if (await Directory(MyImagePath).exists()) {
      print("Folder Existed");
      NewPathMoveImage = MyImagePath;
    } else {
      print("No Folder Existed");
      final NewFolderPath = await Directory(MyImagePath).create();
      NewPathMoveImage = NewFolderPath.path;
    }
    Cache.instance.load().listen((event) {}, onDone: () {
      print("Key Da Luu Trong Preference 123 ");
    });
    // Copy Section
    var Network = GetCurrentIPNetWork();
    Response response_upload = await uploadImage(
        image, "${Network}/upload", FileName, Cache.instance.key);
    dynamic jsonConv = jsonDecode(response_upload.toString());
    print(
        "Respone After Upload  ${jsonConv["text"]} ${jsonConv["statusCode"]}");
    switch (jsonConv['statusCode']) {
      case 200:
        {
          print(jsonConv['text'] +
              "gui file thanh cong , khong luu tru trong foler ");
          Fluttertoast.showToast(
              msg: jsonConv["text"], backgroundColor: Colors.cyan);
          break;
        }
      case 404:
        {
          print(jsonConv['text'] +
              "gui file that bai , tien hanh luu trong bo nho");
          Fluttertoast.showToast(
              msg: jsonConv["text"], backgroundColor: Colors.red);
          var NewPlace = await image.copy("${NewPathMoveImage}/${FileName}");
          print(NewPlace.path);
          var ListOfFile =
              await Directory(MyImagePath).list(recursive: true).toList();
          var count = ListOfFile.length;
          print("So File ${count}");
          break;
        }
      default:
        {
          print("Can't find a suitable case , Error");
        }
    }
    // var NewPlace = await image.copy("${NewPathMoveImage}/${FileName}");
    // print(NewPlace.path);
    var ListOfFile =
        await Directory(MyImagePath).list(recursive: true).toList();
    var count = ListOfFile.length;
    print("So File ${count}");
  }

  Future<void> _onImageButtonPressed(ImageSource source,
      {BuildContext? context, bool isMultiImage = false}) async {
    // Directory directory = await getApplicationDocumentsDirectory();
    // print(directory.path);
    // final dir = Directory("/storage/emulated/0");
    // final List<FileSystemEntity> entities = await dir.list().toList();
    // final Iterable<File> files = entities.whereType<File>();
    // entities.forEach(print);
    if (_controller != null) {
      await _controller!.setVolume(0.0);
    }
    if (isVideo) {
      final XFile? file = await _picker.pickVideo(
          source: source, maxDuration: const Duration(seconds: 10));
      await _playVideo(file);
    } else if (isMultiImage) {
      await _displayPickImageDialog(context!,
          (double? maxWidth, double? maxHeight, int? quality) async {
        try {
          final List<XFile>? pickedFileList = await _picker.pickMultiImage(
            maxWidth: maxWidth,
            maxHeight: maxHeight,
            imageQuality: quality,
          );
          setState(() {
            _imageFileList = pickedFileList;
          });
        } catch (e) {
          setState(() {
            _pickImageError = e;
          });
        }
      });
    } else {
      await _displayPickImageDialog(context!,
          (double? maxWidth, double? maxHeight, int? quality) async {
        try {
          final XFile? pickedFile = await _picker.pickImage(
            source: source,
            maxWidth: maxWidth,
            maxHeight: maxHeight,
            imageQuality: quality,
          );

          if (source.name == "camera") {
            print("Yes it is camera");
            _saveImageFile(File(pickedFile!.path), pickedFile.name);
            setState(() {
              _setImageFileListFromFile(pickedFile);
            });
          } else {
            print("Source Ảnh 123");
            setState(() {
              _setImageFileListFromFile(pickedFile);
            });
          }
        } catch (e) {
          setState(() {
            _pickImageError = e;
          });
        }
      });
    }
  }

  @override
  void deactivate() {
    if (_controller != null) {
      _controller!.setVolume(0.0);
      _controller!.pause();
    }
    super.deactivate();
  }

  @override
  void dispose() {
    _disposeVideoController();
    maxWidthController.dispose();
    maxHeightController.dispose();
    qualityController.dispose();

    super.dispose();
  }

  Future<void> _disposeVideoController() async {
    if (_toBeDisposed != null) {
      await _toBeDisposed!.dispose();
    }
    _toBeDisposed = _controller;
    _controller = null;
  }

  Widget _previewVideo() {
    final Text? retrieveError = _getRetrieveErrorWidget();
    if (retrieveError != null) {
      return retrieveError;
    }
    if (_controller == null) {
      return const Text(
        'You have not yet picked a video',
        textAlign: TextAlign.center,
      );
    }
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: AspectRatioVideo(_controller),
    );
  }

  Widget _previewImages() {
    // if(_imageFileList != null){
    //   for(var i=0;i<_imageFileList!.length;i++){
    //     print(i);
    //     moveFile(File(_imageFileList![i].path),"/storage/emulated/0/DCIM/"+_imageFileList![i].name);
    //
    //   }
    // }

    final Text? retrieveError = _getRetrieveErrorWidget();
    if (retrieveError != null) {
      return retrieveError;
    }
    if (_imageFileList != null) {
      return Semantics(
        label: 'image_picker_example_picked_images',
        child: ListView.builder(
          key: UniqueKey(),
          itemBuilder: (BuildContext context, int index) {
            // Why network for web?
            // See https://pub.dev/packages/image_picker#getting-ready-for-the-web-platform
            return Semantics(
              label: 'image_picker_example_picked_image',
              child: kIsWeb
                  ? Image.network(_imageFileList![index].path)
                  : Image.file(File(_imageFileList![index].path)),
            );
          },
          itemCount: _imageFileList!.length,
        ),
      );

      // moveFile(sourceFile, newPath)
    } else if (_pickImageError != null) {
      return Text(
        'Pick image error: $_pickImageError',
        textAlign: TextAlign.center,
      );
    } else {
      return Text(
        'You have not yet picked an image.',
        textAlign: TextAlign.center,
      );
    }
  }

  Widget _handlePreview() {
    if (isVideo) {
      return _previewVideo();
    } else {
      return _previewImages();
    }
  }

  Future<void> retrieveLostData() async {
    final LostDataResponse response = await _picker.retrieveLostData();
    if (response.isEmpty) {
      return;
    }
    if (response.file != null) {
      if (response.type == RetrieveType.video) {
        isVideo = true;
        await _playVideo(response.file);
      } else {
        isVideo = false;
        setState(() {
          if (response.files == null) {
            _setImageFileListFromFile(response.file);
          } else {
            _imageFileList = response.files;
          }
        });
      }
    } else {
      _retrieveDataError = response.exception!.code;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title!),
      ),
      body: Center(
        child: !kIsWeb && defaultTargetPlatform == TargetPlatform.android
            ? FutureBuilder<void>(
                future: retrieveLostData(),
                builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                    case ConnectionState.waiting:
                      return const Text(
                        'You have not yet picked an image.',
                        textAlign: TextAlign.center,
                      );
                    case ConnectionState.done:
                      return _handlePreview();
                    default:
                      if (snapshot.hasError) {
                        return Text(
                          'Pick image/video error: ${snapshot.error}}',
                          textAlign: TextAlign.center,
                        );
                      } else {
                        return const Text(
                          'You have not yet picked an image.',
                          textAlign: TextAlign.center,
                        );
                      }
                  }
                },
              )
            : _handlePreview(),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Semantics(
            label: 'image_picker_example_from_gallery',
            child: FloatingActionButton(
              onPressed: () {
                isVideo = false;
                _onImageButtonPressed(ImageSource.gallery, context: context);
              },
              heroTag: 'image3',
              tooltip: 'Pick Image from gallery',
              child: const Icon(Icons.photo_album),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: FloatingActionButton(
              onPressed: () {
                isVideo = false;  
                var a=5;
                var b=6;
                print(a<b);
                // _onImageButtonPressed(
                //   ImageSource.gallery,
                //   context: context,
                //   isMultiImage: true,
                // );
                // ImageSource.values.
                // _onImageButtonPressed(ImageSource.gallery, context: context);
                print("Upload Image From Current Folder");
              },
              heroTag: 'image0',
              tooltip: 'Upload Image from gallery',
              child: const Icon(Icons.upload_file),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: FloatingActionButton(
              onPressed: () {
                isVideo = false;
                _onImageButtonPressed(
                  ImageSource.gallery,
                  context: context,
                  isMultiImage: true,
                );
              },
              heroTag: 'image1',
              tooltip: 'Pick Multiple Image from gallery',
              child: const Icon(Icons.photo_library),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: FloatingActionButton(
              onPressed: () {
                isVideo = false;
                _onImageButtonPressed(ImageSource.camera, context: context);
                // _saveImageFile();
              },
              heroTag: 'image2',
              tooltip: 'Take a Photo',
              child: const Icon(Icons.camera_alt),
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.only(top: 16.0),
          //   child: FloatingActionButton(
          //     backgroundColor: Colors.red,
          //     onPressed: () {
          //       isVideo = true;
          //       _onImageButtonPressed(ImageSource.gallery);
          //     },
          //     heroTag: 'video0',
          //     tooltip: 'Pick Video from gallery',
          //     child: const Icon(Icons.video_library),
          //   ),
          // ),
          // Padding(
          //   padding: const EdgeInsets.only(top: 16.0),
          //   child: FloatingActionButton(
          //     backgroundColor: Colors.red,
          //     onPressed: () {
          //       isVideo = true;
          //       _onImageButtonPressed(ImageSource.camera);
          //     },
          //     heroTag: 'video1',
          //     tooltip: 'Take a Video',
          //     child: const Icon(Icons.videocam),
          //   ),
          // ),
        ],
      ),
    );
  }

  Text? _getRetrieveErrorWidget() {
    if (_retrieveDataError != null) {
      final Text result = Text(_retrieveDataError!);
      _retrieveDataError = null;
      return result;
    }
    return null;
  }

  Future<void> _displayPickImageDialog(
      BuildContext context, OnPickImageCallback onPick) async {
    // return Text("data");
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Add optional parameters'),
            content: Column(
              children: <Widget>[
                TextField(
                  controller: maxWidthController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                      hintText: 'Enter maxWidth if desired'),
                ),
                TextField(
                  controller: maxHeightController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                      hintText: 'Enter maxHeight if desired'),
                ),
                TextField(
                  controller: qualityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      hintText: 'Enter quality if desired'),
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('CANCEL'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                  child: const Text('PICK'),
                  onPressed: () {
                    final double? width = maxWidthController.text.isNotEmpty
                        ? double.parse(maxWidthController.text)
                        : null;
                    final double? height = maxHeightController.text.isNotEmpty
                        ? double.parse(maxHeightController.text)
                        : null;
                    final int? quality = qualityController.text.isNotEmpty
                        ? int.parse(qualityController.text)
                        : null;
                    onPick(width, height, quality);
                    Navigator.of(context).pop();
                  }),
            ],
          );
        });
  }
}

typedef OnPickImageCallback = void Function(
    double? maxWidth, double? maxHeight, int? quality);

class AspectRatioVideo extends StatefulWidget {
  const AspectRatioVideo(this.controller, {Key? key}) : super(key: key);

  final VideoPlayerController? controller;

  @override
  AspectRatioVideoState createState() => AspectRatioVideoState();
}

class AspectRatioVideoState extends State<AspectRatioVideo> {
  VideoPlayerController? get controller => widget.controller;
  bool initialized = false;
  void _onVideoControllerUpdate() {
    if (!mounted) {
      return;
    }
    if (initialized != controller!.value.isInitialized) {
      initialized = controller!.value.isInitialized;
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    controller!.addListener(_onVideoControllerUpdate);
  }

  @override
  void dispose() {
    controller!.removeListener(_onVideoControllerUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (initialized) {
      return Center(
        child: AspectRatio(
          aspectRatio: controller!.value.aspectRatio,
          child: VideoPlayer(controller!),
        ),
      );
    } else {
      return Container();
    }
  }
}
