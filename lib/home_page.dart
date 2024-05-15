import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_analog_clock/flutter_analog_clock.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:installed_apps/app_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<AppInfo> _installedApps = [];

  @override
  void initState() {
    super.initState();
    _getInstalledApps();
  }

  Future<void> _getInstalledApps() async {
    List<AppInfo> installedApps = await InstalledApps.getInstalledApps();
    setState(() {
      _installedApps = installedApps;
    });
  }

  String _getAppName(String packageName) {
    AppInfo? appInfo = _installedApps.firstWhere(
      (app) => app.packageName == packageName,
    );
    return appInfo.name;
  }

  @override
  Widget build(BuildContext context) {
    Future<List<String>> getFavoriteApps() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getStringList('favoriteApps') ?? [];
    }

    return Container(
      color: Colors.black,
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(50),
            child: AnalogClock.dark(),
          ),
          Expanded(
            child: FutureBuilder<List<String>>(
              future: getFavoriteApps(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<String> favoriteApps = snapshot.data!;
                  return ListView.builder(
                    itemCount: favoriteApps.length,
                    itemBuilder: (context, index) {
                      String packageName = favoriteApps[index];
                      String appName = _getAppName(packageName);
                      return ListTile(
                        title: Text(appName),
                        onTap: () {
                          InstalledApps.startApp(packageName);
                        },
                      );
                    },
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
