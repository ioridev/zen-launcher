import 'package:flutter/material.dart';
import 'package:flutter_analog_clock/flutter_analog_clock.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    Future<List<String>> getFavoriteApps() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getStringList('favoriteApps') ?? [];
    }

    return Container(
        color: Colors.black,
        child: Column(children: [
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
                      return ListTile(
                        title: Text(packageName),
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
        ]));
  }
}
