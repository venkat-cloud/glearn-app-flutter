import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'fileOperations.dart';
import 'API.dart';
import 'package:share/share.dart';
import 'package:clipboard/clipboard.dart';
import 'package:url_launcher/url_launcher.dart';



FileOperations obj = new FileOperations();
ApiOperations api = new ApiOperations();

void main() {
  runApp(
    MaterialApp(
      title: 'Student Glearn',
      home: StartPage()),
    );
}

class StartPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.purple,
      // appBar: AppBar(
      //   title: Text('Login',style: TextStyle(fontSize: 20.0,color: Colors.white),),
      //   backgroundColor: Colors.purple,
      // ),
      body: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  // final FileOperations details = new FileOperations();
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final _passwordController = new TextEditingController();
  final _usernameController = new TextEditingController();


  createFileThenNavigate(username,password) async {
    startLoad = false;
    obj.writeContent({"txtusername":username,"password":password}).then((value) => navigate(true));
  }

  navigate(from) {
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => HomePage(fromLogin: from)), ModalRoute.withName("/Home"));
  }

  bool _isInitialized = false;




  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    api.isConnectedToInternet().then((value) => value ?
    obj.isCredentialsAvailable().then((value) => value ? navigate(false) : _initializeAsyncDependencies())
        :
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => NoInternet()), ModalRoute.withName('/Home'))
    );

    api.fillLoginData().then((value)=>{ });
  }
  Future<void> _initializeAsyncDependencies() async {
    // do initialization
    setState(() {
      _isInitialized = true;
    });
  }
  void handleInvalidCredentials(BuildContext context) {
    setState(() {
      startLoad=false;
    });
    _passwordController.clear();
    Scaffold.of(context).showSnackBar(SnackBar(content: Text('Invalid Credentials',style: TextStyle(fontSize: 15.0,letterSpacing: 1.5,color: Colors.white),),backgroundColor: Colors.black,));
  }

  bool obscured = true;
  FocusNode nodeOne = FocusNode();
  FocusNode nodeTwo = FocusNode();
  bool startLoad = false;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: !_isInitialized ? Center(child: CircularProgressIndicator()) :Container(
          //color: Colors.purple,
          alignment: Alignment.center,
          padding: const EdgeInsets.all(8),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom:20.0),
                  child: Text('Login to Glearn',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 40.0,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'NotoSans',
                        letterSpacing:1.5,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    focusNode: nodeOne,
                    style: TextStyle(color: Colors.white,fontWeight: FontWeight.w500,letterSpacing: 1.5),
                    controller: _usernameController,
                    decoration: InputDecoration(
                      hintText: "Gitam Registration Number",
                      labelStyle: TextStyle(color:Colors.white),
                        prefixIcon: Icon(Icons.person,color: Colors.white,),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: BorderSide(color: Colors.black)
                      ),
                      labelText: "Username"
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    focusNode: nodeTwo,
                    style: TextStyle(color: Colors.white,fontWeight: FontWeight.w500,letterSpacing: 1.5),
                    obscureText: obscured,
                    autocorrect: false,
                    controller: _passwordController,
                    decoration: InputDecoration(
                      hintText: "Glearn password",
                      labelStyle: TextStyle(color: Colors.white),
                      prefixIcon: Icon(Icons.security,color: Colors.white,),
                        suffixIcon: IconButton(icon: Icon(Icons.remove_red_eye,color: this.obscured ? Colors.white : Colors.grey,
                        ), onPressed: (){
                          setState(() {
                            obscured = !obscured;
                          });
                        }),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.0)
                        ),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: BorderSide(color: Colors.black)
                      ),
                      labelText: "Password",
                    ),
                  ),
                ),
                Align(
                  alignment: FractionalOffset.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: startLoad ? CircularProgressIndicator(
                      valueColor:new AlwaysStoppedAnimation<Color>(Colors.white),
                    ):
                    RaisedButton(
                      shape: RoundedRectangleBorder(
                          side: BorderSide(color: Colors.black),
                          borderRadius:BorderRadius.circular(25.0)
                      ),
                      color: Colors.purple,
                      child: Text(
                          "Login",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.0,
                            letterSpacing: 1.5,
                          )
                      ),
                      //icon: Icon(Icons.arrow_forward),
                      onPressed: (){
                        api.isConnectedToInternet()
                            .then((value) => !value ?
                        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => NoInternet()), ModalRoute.withName('/Home'))
                            :null );
                        if(_usernameController.text.isEmpty){
                          FocusScope.of(context).requestFocus(nodeOne);
                        }
                        else if(_passwordController.text.isEmpty){
                          FocusScope.of(context).requestFocus(nodeTwo);
                        }
                        else{
                          setState(() {
                            startLoad = true;
                          });
                          api.checkLoginCredentials({'txtusername':_usernameController.text,'password': _passwordController.text})
                              .then((value) => value  ?  createFileThenNavigate(_usernameController.text, _passwordController.text) : handleInvalidCredentials(context)
                          );
                        }
                      },

                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
    );
  }
}

class HomePage extends StatefulWidget {

  final bool fromLogin;
  HomePage({this.fromLogin}){print(fromLogin);}

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  PageController _myPage = PageController(initialPage: 0);
  navigateBack()
  {
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=> StartPage()), ModalRoute.withName("/Home"));
  }

  deleteFile()
  {
    obj.deleteFile();
    navigateBack();
  }

  getDetailsFromFile(check) async{
    print("getDetailsFromFile");
    if(widget.fromLogin && check)
    {
       await api.loginToGlearn().then((value) => afterLogin()) ;
    }
    else
      {
        await api.fillLoginData();
        obj.readContent().
        then((value) => {
          api.checkLoginCredentials(json.decode(value))
              .then((value) => value ? api.loginToGlearn().then((value)=>afterLogin()) : deleteFile())
        }
        );
      }
  }

  final List<Map<String, String>> attendance = [];
  //final Map<String, String> zoomLinks = {};
  var overallAttendance;
  final List<Map<String,String>> zoomLinks =[] ;

  String name;

  void fetchAttendance(attendancePageBody) {
    setState(() {
      name = parse(attendancePageBody).getElementById('lblname').innerHtml;
      var ele = parse(attendancePageBody).body.getElementsByClassName('circle')[0];
      overallAttendance = ele.children[0].children[0].innerHtml;
      //attendance[ele.parent.children[0].children[0].innerHtml]=ele.children[0].children[0].innerHtml;
      parse(attendancePageBody).getElementById("ContentPlaceHolder1_GridView4").children[0].children.skip(1).forEach((element) {
        attendance.add(
            {'course':element.children[2].innerHtml,
              'total':element.children[3].innerHtml,
              'present':element.children[4].innerHtml,
              'absent':element.children[5].innerHtml,
              'attendance':element.children[6].innerHtml,
            }
            );
        //attendance[element.children[2].innerHtml] = element.children[6].innerHtml;
      });
    });
    // print(attendance);
  }

  bool noZoomLinks = false;

  void fetchZoomLinks(zoomLinksPageBody) {
    setState(() {
      var ele = parse(zoomLinksPageBody).getElementById('ContentPlaceHolder1_GridViewonline').children[0];//tBody
      ele.children.forEach((element) { //table rows
        var td = element.children[0];
        var a = td.children[0];
        var href = a.attributes['href'];
        var div = a.children[0];
        var sessionName = div.children[0].innerHtml;
        var dateTime = div.children[1].innerHtml;
        zoomLinks.add({'session':sessionName,'link':href,'time':dateTime});
        //print(href+" "+sessionName+" "+dateTime);
      });
      noZoomLinks = (zoomLinks.length == 0);
      //zoomLinks.add({'session':'NA','link':'NA','time':'NA'});
      //print(zoomLinks);
    });
    
    //zoomLinks['gg']='jjk';
  }

  void afterLogin() async{
    await api.fetchAttendancePage().then((responseBody) => fetchAttendance(responseBody));
    await api.fetchZoomLinksPage().then((responseBody) => fetchZoomLinks(responseBody));
  }



  // void download() async
  // {
  //   print("fghj");
  //   http.get('http://glearn.gitam.edu/student/file.aspx?id=129907',headers: header).then((response) {
  //     new File().writeAsBytes(response.bodyBytes);
  //   });
  // }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    api.isConnectedToInternet().then((value) => value ?
    obj.isCredentialsAvailable().then((value) => value ? getDetailsFromFile(true) : navigateBack())
        :
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => NoInternet()), ModalRoute.withName('/Home'))
    );

  }

  Future<void> _launchInBrowser(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: false,
        forceWebView: false,
      );
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> refreshAttendance() async {
    await api.fillLoginData();
    obj.readContent().
    then((value) => {
      api.checkLoginCredentials(json.decode(value))
          .then((value) => value ? api.loginToGlearn().then((value)=>api.fetchAttendancePage().then((responseBody) => fetchAttendance(responseBody))) : deleteFile())
    }
    );
  }

  Future<void> refreshZoomLinks() async {
    await api.fillLoginData();
    obj.readContent().
    then((value) => {
      api.checkLoginCredentials(json.decode(value))
          .then((value) => value ? api.loginToGlearn().then((value)=>api.fetchZoomLinksPage().then((responseBody) => fetchZoomLinks(responseBody))) : deleteFile())
    }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.green,
          onPressed: () {
            print(_myPage.page);
            api.isConnectedToInternet().then((value) => !value ?
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => NoInternet()),
                ModalRoute.withName('/Home'))
                : null);
            if(_myPage.page == 0.0 && attendance.length > 0)
              {
                //attendance
                setState(() {
                  attendance.clear();
                });
                refreshAttendance();

              }
            else if(_myPage.page == 1.0 && zoomLinks.length>0)
              {
                //Zoom links
                setState(() {
                  zoomLinks.clear();
                });
                refreshZoomLinks();
              }
            // if(attendance.length > 0 || zoomLinks.length>0){
            //   setState(() {
            //     attendance.clear();
            //     zoomLinks.clear();
            //   });
            //   getDetailsFromFile(false);
            // }
          },
          tooltip: 'refresh',
          child: Icon(Icons.refresh,size: 30.0,),
          elevation: 5.0,
        ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.purple,
        shape: CircularNotchedRectangle(),
        child: Container(
          height: 75,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            //mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
            IconButton(
            iconSize: 40.0,
            color: Colors.white,
            padding: EdgeInsets.only(left: 40.0,right: 40.0),
            icon: Icon(Icons.home),
              tooltip: 'Attendance',
            onPressed: (){
              setState(() {
                _myPage.jumpToPage(0);
              });},
          ),
          IconButton(
            iconSize: 40.0,
              color: Colors.white,
            icon: Icon(Icons.videocam),
            tooltip: 'Zoom links',
            onPressed: (){
              setState(() {
                _myPage.jumpToPage(1);
              });}
          ),
          IconButton(
              color: Colors.white,
              iconSize: 40.0,
            padding: EdgeInsets.only(right: 40.0,left: 40.0),
            icon: Icon(Icons.menu),
            tooltip: 'Functions',
            onPressed: (){
              setState(() {
                _myPage.jumpToPage(2);
              });
              }
              ),
            ],
          ),
        ),
      ),
      body:
      SafeArea(
        child: PageView(
          controller: _myPage,
          onPageChanged: (index){
            // print("page $index");
          },
          children: <Widget>[
            attendance.length == 0 || overallAttendance==null || name == null ? Center(
              child: CircularProgressIndicator(
                valueColor:new AlwaysStoppedAnimation<Color>(Colors.purpleAccent),
              )
            ):
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Welcome,\n$name',
                    style: TextStyle(
                      color: Colors.purple,
                      fontSize: 25.0,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'NotoSans',
                      letterSpacing:1.5,
                    ),
                  ),
                ),
                Row(
                  children: [Expanded(
                    child: Container(
                      color: Colors.purple,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text('Overall Attendance : $overallAttendance%',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'NotoSans',
                            letterSpacing:1.5,
                          ),
                        ),
                      ),
                    ),
                  ),]
                ),
                Padding(
                  padding:EdgeInsets.symmetric(horizontal:0.0),
                  child:Container(
                    height:1.0,
                    width:double.infinity,
                    color:Colors.black,),),
                Expanded(
                child: ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8.0,0.0,8.0,8.0),
                      child: ExpansionTile(
                        initiallyExpanded: true,
                        title: Text('Course wise attendance',
                          style: TextStyle(
                            color: Colors.purple,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            letterSpacing:1.5,
                          ),
                        ),
                        children: attendance.map((e) =>
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical:8.0),
                              child: ExpansionTile(
                                title: Text(e['course']+' : '+e['attendance']+'%',style: TextStyle(fontSize: 18.0),),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text('Total: '+e['total']+', Present: '+e['present']+', Absent: '+e['absent'],
                                    style: TextStyle(fontSize: 16.0),),
                                  ),
                                ],
                              ),
                            )
                        ).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              ]
            ),
            zoomLinks.length == 0 ? Center(
                child: CircularProgressIndicator(
                  valueColor:new AlwaysStoppedAnimation<Color>(Colors.purpleAccent),
                )
            ): Center(
              child:noZoomLinks ? Text("No zoom links are found")
                  :
              Column(
                children: [
                  Row(
                    children: [Expanded(
                      child: Container(
                        color: Colors.purple,
                        child: Align(
                          alignment: Alignment.center,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text("Zoom Links",style: TextStyle(fontSize: 25.0,color: Colors.white),),
                          ),
                        ),
                      ),
                    ),]
                  ),
                  Padding(
                    padding:EdgeInsets.symmetric(horizontal:10.0),
                    child:Container(
                      height:1.0,
                      width:double.infinity,
                      color:Colors.black,),),
                  Expanded(
                  child: ListView.builder(
                    itemCount: zoomLinks.length,
                    itemBuilder: (BuildContext ctxt,int index){
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(10.0,8.0,10.0,8.0),
                        child: Card(
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ListTile(
                                  leading: Icon(Icons.label),
                                  title: Text(zoomLinks[index]['time']),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(zoomLinks[index]['session'],
                                  style: TextStyle(color: Colors.black,letterSpacing: 1.5,fontWeight: FontWeight.w600),
                                ),
                              ),
                              ButtonBar(
                                children: [
                                  FlatButton(
                                    child: Text("Open link",style: TextStyle(color: Colors.purple),),
                                    onPressed: (){
                                      _launchInBrowser(zoomLinks[index]['link']).then((value) => print('launched'));
                                    },
                                  ),
                                  FlatButton(
                                    child: Text("Share link",style: TextStyle(color: Colors.purple)),
                                    onPressed: (){
                                      Share.share(zoomLinks[index]['link']);
                                      print(zoomLinks[index]['link']+" shared");
                                    },
                                  ),
                                  FlatButton(
                                    child: Text("Copy link",style: TextStyle(color: Colors.purple)),
                                    onPressed: (){
                                      FlutterClipboard.copy(zoomLinks[index]['link']).then((value) =>
                                      {
                                        Scaffold.of(ctxt).showSnackBar(
                                            SnackBar(content: Text('Link Copied to Clipboard'),
                                              action: SnackBarAction(
                                                label: 'ok',
                                                onPressed: () {},),
                                        )
                                      )}
                                      );
                                      print(zoomLinks[index]['link']+" copied");
                                    },
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                ]
              ),
            ),
            Center(
              child: Container(
                child: RaisedButton(
                  color: Colors.purple,
                  child: Text('Logout',style: TextStyle(color: Colors.white,fontSize: 18.0),),
                  onPressed: deleteFile,
                ),
              ),
            ),
          ],
        ),
      )
    );
  }
}


// await c.post('http://glearn.gitam.edu/student/welcome.aspx',body: {
//   '__EVENTTARGET':'ctl00\$ContentPlaceHolder1\$GridView2\$ctl02\$linCourse',
//   '__EVENTARGUMENT':''
// },headers: header)
//
//   .then((value) => print(value.body));

class NoInternet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("No Internet Connection"),
              RaisedButton(
                child: Text('Try again'),
                onPressed: (){
                  api.isConnectedToInternet().then((value) =>
                  value ? Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => StartPage()), ModalRoute.withName("/Home"))
                  :
                  null
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
