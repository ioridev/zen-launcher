import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:shared_preferences/shared_preferences.dart';

final favoriteAppsProvider =
    StateNotifierProvider<FavoriteAppsNotifier, List<String>>((ref) {
  return FavoriteAppsNotifier();
});

class FavoriteAppsNotifier extends StateNotifier<List<String>> {
  FavoriteAppsNotifier() : super([]) {
    _loadFavoriteApps();
  }

  Future<void> _loadFavoriteApps() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    state = prefs.getStringList('favoriteApps') ?? [];
  }

  Future<void> _saveFavoriteApps() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favoriteApps', state);
  }

  void toggleFavorite(String packageName) {
    if (state.contains(packageName)) {
      state = state.where((app) => app != packageName).toList();
    } else {
      state = [...state, packageName];
    }
    _saveFavoriteApps();
  }
}

class AppListPage extends ConsumerStatefulWidget {
  const AppListPage({super.key});

  @override
  ConsumerState<AppListPage> createState() => _AppListPageState();
}

class _AppListPageState extends ConsumerState<AppListPage> {
  List<AppInfo> appList = [];
  List<AppInfo> filteredAppList = [];
  List<String> favoriteApps = [];
  final TextEditingController searchController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    getInstalledApps();
  }

  Future<void> loadFavoriteApps() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      favoriteApps = prefs.getStringList('favoriteApps') ?? [];
    });
  }

  Future<void> saveFavoriteApps() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favoriteApps', favoriteApps);
  }

  void toggleFavorite(String packageName) {
    setState(() {
      if (favoriteApps.contains(packageName)) {
        favoriteApps.remove(packageName);
      } else {
        favoriteApps.add(packageName);
      }
    });
    saveFavoriteApps();
  }

  Future<void> getInstalledApps() async {
    List<AppInfo> apps = await InstalledApps.getInstalledApps();
    setState(() {
      appList = apps;
      filteredAppList = apps;
    });
  }

  void filterApps(String query) {
    List<AppInfo> filteredApps = appList
        .where((app) => app.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
    setState(() {
      filteredAppList = filteredApps;
    });
  }

  void scrollToIndex(int index) {
    scrollController.animateTo(
      index * 56.0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final favoriteApps = ref.watch(favoriteAppsProvider);
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
                      favoriteApps.contains(app.packageName)
                          ? 'Remove from Favorites'
                          : 'Add to Favorites',
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      ref
                          .read(favoriteAppsProvider.notifier)
                          .toggleFavorite(app.packageName);
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
        controller: scrollController,
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.black,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48.0),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: TextField(
                  controller: searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search apps...',
                  ),
                  onChanged: (value) {
                    filterApps(value);
                  },
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                AppInfo app = filteredAppList[index];
                return ListTile(
                  title: Text(app.name),
                  onLongPress: () => showAppOptionsDialog(app),
                  onTap: () {
                    InstalledApps.startApp(app.packageName);
                  },
                );
              },
              childCount: filteredAppList.length,
            ),
          ),
        ],
      ),
      floatingActionButton: AlphabetScrollBar(
        onTap: scrollToIndex,
        filteredAppList: filteredAppList,
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
