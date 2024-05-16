import 'package:flutter/material.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppListPage extends StatefulWidget {
  const AppListPage({super.key});

  @override
  State<AppListPage> createState() => _AppListPageState();
}

class _AppListPageState extends State<AppListPage> {
  List<AppInfo> _appList = [];
  List<AppInfo> _filteredAppList = [];
  List<String> _favoriteApps = [];
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _getInstalledApps();
  }

  Future<void> _loadFavoriteApps() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _favoriteApps = prefs.getStringList('favoriteApps') ?? [];
    });
  }

  Future<void> _saveFavoriteApps() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favoriteApps', _favoriteApps);
  }

  void _toggleFavorite(String packageName) {
    setState(() {
      if (_favoriteApps.contains(packageName)) {
        _favoriteApps.remove(packageName);
      } else {
        _favoriteApps.add(packageName);
      }
    });
    _saveFavoriteApps();
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

  void _scrollToIndex(int index) {
    _scrollController.animateTo(
      index * 56.0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    Future<void> showAppOptionsDialog(AppInfo app) async {
      void showAppInfo(AppInfo app) {
        // TODO: Implement app info display logic
        // You can use the `app` object to access app information
        // and display it in a new screen or dialog
      }

      void uninstallApp(AppInfo app) {
        // TODO: Implement app uninstallation logic
        // You can use the `app` object to get the package name
        // and perform the uninstallation process
      }
      return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(app.name),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  GestureDetector(
                    child: Text(
                      _favoriteApps.contains(app.packageName)
                          ? 'Remove from Favorites'
                          : 'Add to Favorites',
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      _toggleFavorite(app.packageName);
                    },
                  ),
                  const Divider(),
                  GestureDetector(
                    child: const Text('App Info'),
                    onTap: () {
                      Navigator.of(context).pop();
                      showAppInfo(app);
                    },
                  ),
                  const Divider(),
                  GestureDetector(
                    child: const Text('Uninstall'),
                    onTap: () {
                      Navigator.of(context).pop();
                      uninstallApp(app);
                    },
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Close'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.black,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48.0),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                AppInfo app = _filteredAppList[index];
                return ListTile(
                  title: Text(app.name),
                  onLongPress: () => showAppOptionsDialog(app),
                  onTap: () {
                    InstalledApps.startApp(app.packageName);
                  },
                );
              },
              childCount: _filteredAppList.length,
            ),
          ),
        ],
      ),
      floatingActionButton: AlphabetScrollBar(
        onTap: _scrollToIndex,
        filteredAppList: _filteredAppList,
      ),
    );
  }
}

class AlphabetScrollBar extends StatelessWidget {
  final Function(int) onTap;
  final List<AppInfo> filteredAppList;

  const AlphabetScrollBar({
    Key? key,
    required this.onTap,
    required this.filteredAppList,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var letter in 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split(''))
            GestureDetector(
              onTap: () {
                int index = filteredAppList.indexWhere(
                  (app) => app.name.toUpperCase().startsWith(letter),
                );
                if (index != -1) {
                  onTap(index);
                }
              },
              child: Text(
                letter,
                style: const TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
