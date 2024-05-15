import 'package:flutter/material.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';

class AppListPage extends StatefulWidget {
  const AppListPage({super.key});

  @override
  State<AppListPage> createState() => _AppListPageState();
}

class _AppListPageState extends State<AppListPage> {
  List<AppInfo> _appList = [];
  List<AppInfo> _filteredAppList = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getInstalledApps();
  }

  Future<void> _getInstalledApps() async {
    List<AppInfo> apps = await InstalledApps.getInstalledApps();
    setState(() {
      _appList = apps;
      _filteredAppList = apps;
    });
  }

  void _filterApps(String query) {
    List<AppInfo> filteredApps = _appList
        .where((app) => app.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
    setState(() {
      _filteredAppList = filteredApps;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search apps...',
                ),
                onChanged: (value) {
                  _filterApps(value);
                },
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredAppList.length,
                itemBuilder: (context, index) {
                  AppInfo app = _filteredAppList[index];
                  return ListTile(
                    title: Text(app.name),
                    onTap: () {
                      InstalledApps.startApp(app.packageName);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
