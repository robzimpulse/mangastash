import 'package:core_route/core_route.dart';
import 'package:feature_collection/feature_collection.dart';
import 'package:feature_home/feature_home.dart';
import 'package:feature_profile/feature_profile.dart';
import 'package:feature_setting/feature_setting.dart';
import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

class MainScreen extends StatelessWidget {
  final Widget child;

  final int index;

  final void Function(int)? onTapMenu;

  const MainScreen({
    super.key,
    required this.child,
    required this.index,
    required this.onTapMenu,
  });

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: Scaffold(
        backgroundColor: Colors.white,
        bottomNavigationBar: _bottomNavigationBar(context: context),
        body: _sideNavigationBar(context: context),
      ),
    );
  }

  Widget _sideNavigationBar({required BuildContext context}) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final isPhone = ResponsiveBreakpoints.of(context).isPhone;
    if (isMobile || isPhone) return child;
    return Row(
      children: [
        NavigationRail(
          labelType: NavigationRailLabelType.all,
          elevation: 8,
          destinations: const [
            NavigationRailDestination(
              icon: Icon(Icons.home_outlined),
              label: Text('Home'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.collections),
              label: Text('Collection'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.settings),
              label: Text('Setting'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.person_outline),
              label: Text('Profile'),
            ),
          ],
          onDestinationSelected: onTapMenu,
          selectedIndex: index,
        ),
        Expanded(child: child),
      ],
    );
  }

  Widget? _bottomNavigationBar({required BuildContext context}) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final isPhone = ResponsiveBreakpoints.of(context).isPhone;
    if (!(isMobile || isPhone)) return null;
    return BottomNavigationBar(
      currentIndex: index,
      type: BottomNavigationBarType.fixed,
      showUnselectedLabels: true,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.collections),
          label: 'Collection',
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
      onTap: onTapMenu,
    );
  }
}