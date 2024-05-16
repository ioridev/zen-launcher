import 'package:flutter/material.dart';
import 'package:flutter_analog_clock/flutter_analog_clock.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:installed_apps/app_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

final installedAppsProvider = FutureProvider<List<AppInfo>>((ref) async {
  return await InstalledApps.getInstalledApps();
});

final favoriteAppsProvider = FutureProvider<List<String>>((ref) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getStringList('favoriteApps') ?? [];
});

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final installedApps = ref.watch(installedAppsProvider);
    final favoriteApps = ref.watch(favoriteAppsProvider);

    String getAppName(String packageName) {
      return installedApps.maybeWhen(
        data: (apps) {
          AppInfo? appInfo = apps.firstWhere(
            (app) => app.packageName == packageName,
          );
          return appInfo.name;
        },
        orElse: () => packageName,
      );
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
            child: favoriteApps.when(
              data: (favorites) {
                return ListView.builder(
                  itemCount: favorites.length,
                  itemBuilder: (context, index) {
                    String packageName = favorites[index];
                    String appName = getAppName(packageName);
                    return ListTile(
                      title: Text(appName),
                      onTap: () {
                        InstalledApps.startApp(packageName);
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => const Center(child: Text('Error')),
            ),
          ),
        ],
      ),
    );
  }
}
