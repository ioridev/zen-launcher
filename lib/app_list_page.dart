import 'package:flutter/material.dart';

import 'main.dart';

class AppListPage extends StatefulWidget {
  const AppListPage({super.key});

  @override
  State<AppListPage> createState() => _AppListPageState();
}

class _AppListPageState extends State<AppListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextButton(
              onPressed: () async {
                await blockApps();
              },
              child: const Text('blockApp'),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('unblockApp'),
            ),
          ],
        ),
      ),
    );
  }
}
