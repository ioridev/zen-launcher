import 'package:flutter/material.dart';
import 'package:installed_apps/app_info.dart';
import 'main.dart';
import 'package:installed_apps/installed_apps.dart';

class AppListPage extends StatefulWidget {
  const AppListPage({super.key});

  @override
  State<AppListPage> createState() => _AppListPageState();
}

class _AppListPageState extends State<AppListPage> {
  List<AppInfo> _appList = [];

  @override
  void initState() {
    super.initState();
    _getInstalledApps();
  }

  Future<void> _getInstalledApps() async {
    List<AppInfo> apps = await InstalledApps.getInstalledApps();
    setState(() {
      _appList = apps;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: ListView.builder(
        itemCount: _appList.length,
        itemBuilder: (context, index) {
          AppInfo app = _appList[index];
          return ListTile(
            title: Text(app.name),
            onTap: () async {
              InstalledApps.startApp(app.packageName);
            },
          );
        },
      ),
    );
  }
}
