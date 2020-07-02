import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget{

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool foundLink = false;
  String link ="";
  StreamSubscription _intentDataStreamSubscription;
  String _sharedText;

  WebViewController controller ;
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      home: Scaffold(
      appBar: AppBar(
        title: Text("Medium Article Reader"),
      ),
      body: foundLink ? WebView(
        onWebViewCreated: (c)async {
          controller =c; 
         await  controller.clearCache();
          final cookieManager = CookieManager();
         await  cookieManager.clearCookies();
         controller.loadUrl(link);
        },
        javascriptMode: JavascriptMode.unrestricted,

      ) : Center(child: CircularProgressIndicator()),
      ),

    );
  }
  @override
  void dispose() {
    _intentDataStreamSubscription.cancel();
    super.dispose();
  }
  @override
  void initState() {
    super.initState();

   ReceiveSharingIntent.getInitialText().then((String value) {
      if(value!=null)

      setState(() {
        _sharedText = value;

        findLink(_sharedText);
      });
    });
  }

  Future<void> findLink(String s) async {
    setState(() {
      foundLink =false;
    });

    final regExpression = r'https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)';
    final  exp = RegExp(regExpression);
    RegExpMatch match = exp.firstMatch(s);
    s = match.group(0);
    print(s);

    //final res = await
    Dio dio = Dio();

    final res = await  dio.get(s);
    match = exp.firstMatch(res.data);
      setState(() {
        link = match.group(0);
        foundLink  = true;
      });

  }

}