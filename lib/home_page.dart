import 'package:flutter/material.dart';
import 'package:flutter_analog_clock/flutter_analog_clock.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:installed_apps/app_info.dart';
import 'package:zen_launcher/app_list_page.dart';

final installedAppsProvider = FutureProvider<List<AppInfo>>((ref) async {
  return await InstalledApps.getInstalledApps();
});

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final installedApps = ref.watch(installedAppsProvider);

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
            child: Consumer(
              builder: (context, ref, _) {
                final favorites = ref.watch(favoriteAppsProvider);
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
            ),
          ),
        ],
      ),
    );
  }
}
