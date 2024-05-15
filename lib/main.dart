import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zen_launcher/app_list_page.dart';
import 'package:zen_launcher/home_page.dart';
import 'package:zen_launcher/widgets_page.dart';

const methodChannel = MethodChannel('zen_launcher');

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(brightness: Brightness.dark, useMaterial3: false),
      home: const MyWidget(),
    );
  }
}

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  final PageController _pageController = PageController(initialPage: 1);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: const [
          WidgetsPage(),
          HomePage(),
          AppListPage(),
        ],
      ),
    );
  }
}

Future<void> blockApps() async {
  var result = 'approved';
  if (Platform.isAndroid) {
    result = await methodChannel.invokeMethod('checkPermission') as String;
  }
  debugPrint('[DEBUG]result: $result');
  if (result == 'approved') {
    await methodChannel.invokeMethod('blockApp');
  } else {
    debugPrint('[DEBUG]Permission not granted');
    await methodChannel.invokeMethod('requestAuthorization');
  }
}

Future<void> unblockApps() async {
  await methodChannel.invokeMethod('unblockApp');
}
