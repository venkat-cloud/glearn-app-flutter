import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';

class FileOperations {
  
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    print(directory.path);
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/glearn_user_credentials.txt');
  }


  Future<String> readContent() async {
      final file = await _localFile;
      String contents = await file.readAsString();
      return contents;
  }
  Future<File> writeContent(Map<String,String> details) async {
    final file = await _localFile;
    return file.writeAsString(jsonEncode(details));
  }
  
  void deleteFile() async {
    try{
         final file = await _localFile;
         await file.delete();
    }
    catch(e){
      print("file not there");
    }
  }

  Future<bool> isCredentialsAvailable() async {
    final file = await _localFile;
    return Future<bool>.value(file.exists());
    //return Future<bool>.value(true);
  }
}