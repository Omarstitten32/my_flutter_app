import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/permission_service.dart';
import '../utils/constants.dart';
import 'file_browser_screen.dart';
import 'favorites_screen.dart';
import 'storage_screen.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int index = 0;

  @override
  void initState() {
    super.initState();
    PermissionService.requestAll();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      const FileBrowserScreen(),
      const SearchScreen(),
      const FavoritesScreen(),
      const StorageScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.folder_open),
            onPressed: () {},
          ),
        ],
      ),
      body: pages[index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (v) => setState(() => index = v),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.folder), label: 'Files'),
          NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
          NavigationDestination(icon: Icon(Icons.star), label: 'Fav'),
          NavigationDestination(icon: Icon(Icons.storage), label: 'Storage'),
        ],
      ),
    );
  }
}