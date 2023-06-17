import 'package:core_route/core_route.dart';
import 'package:feature_collection/feature_collection.dart';
import 'package:feature_favourite/feature_favourite.dart';
import 'package:feature_home/feature_home.dart';
import 'package:feature_profile/feature_profile.dart';
import 'package:feature_setting/feature_setting.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  final Widget child;
  final int index;

  const MainScreen({
    super.key,
    required this.child,
    required this.index,
  });

  @override
  State<StatefulWidget> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  int index = 0;
  Color get selectedItemColor => Colors.red;
  Color get unselectedItemColor => Colors.black;

  @override
  void didUpdateWidget(covariant MainScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    index = widget.index;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future.value(true),
      child: Scaffold(
        backgroundColor: Colors.white,
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: index,
          type: BottomNavigationBarType.fixed,
          showUnselectedLabels: true,
          selectedItemColor: selectedItemColor,
          unselectedItemColor: unselectedItemColor,
          selectedFontSize: 12.0,
          unselectedFontSize: 12.0,
          backgroundColor: Colors.white,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.collections),
              label: 'Collection'
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: 'Favourite',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Setting',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: 'Profile',
            ),
          ],
          onTap: (index) => context.go(_route(index)),
        ),
        body: widget.child,
      ),
    );
  }

  String _route(int index) {
    switch (index) {
      case 0: return HomeRoutePath.main;
      case 1: return CollectionRoutePath.main;
      case 2: return FavouriteRoutePath.main;
      case 3: return SettingRoutePath.main;
      case 4: return ProfileRoutePath.main;
      default: return HomeRoutePath.main;
    }
  }

}