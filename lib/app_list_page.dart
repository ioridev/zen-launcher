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
  List<AppInfo> _filteredAppList = [];
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

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

  void _scrollToIndex(int index) {
    _scrollController.animateTo(
      index * 56.0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
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
