import 'dart:io';

import 'package:web_scraper/web_scraper.dart';
import 'package:http/http.dart' as http;

class ApiOperations {

  Map<String,String> __loginData = {};
  final __loginURL = 'https://login.gitam.edu' ;
  final __glearnURL = 'http://glearn.gitam.edu/student' ;
  Map<String,String> __header={};

  fillLoginData() async{
    __loginData.clear();
    __loginData['submit']      = 'login';
    final webScraper = WebScraper('https://login.gitam.edu');
    await webScraper.loadWebPage('/login.aspx').then((value) => {
      webScraper.getElement('input[type=\'hidden\'] ',['name','value'])
          .forEach((element) {
        __loginData[element['attributes']['name']] = element['attributes']['value'];
      })
    });
    //print(__loginData);
  }

  ApiOperations() ;
  
  final __client = http.Client();
  Future<bool> checkLoginCredentials(details) async {
    __loginData['txtusername']    = details['txtusername'];
    __loginData['password']    = details['password'];
    var code;
    await __client.get('$__loginURL/login.aspx') // to get sessionId
        .then((value) => {
      __header = {'cookie':value.headers['set-cookie'].split(';')[0]}
    });
    await __client.post('$__loginURL/login.aspx',body: __loginData,headers: __header)
        .then((value) => {
      code = value.statusCode
    });
    //print(__header);
    return Future<bool>.value( code == 302) ;
  }

  Future<void> loginToGlearn() async{
    await __client.get(
        '$__loginURL/route.aspx?id=GLEARN&type=S', headers: __header)
        .then((value) => __header = value.request.headers);
  }
  Future<String> fetchAttendancePage() async{
      final response = await __client.get('$__glearnURL/Attendance.aspx',headers: __header);
      return response.body;
  }
  Future<String> fetchZoomLinksPage() async{
    final response = await __client.get('$__glearnURL/welcome.aspx',headers: __header);
    return response.body;
  }

  Future<bool> isConnectedToInternet() async{
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return Future.value(true);
      }
      else {
        return Future.value(false);
      }
    } on SocketException catch (_) {
      return Future.value(false);
    }
  }
}

