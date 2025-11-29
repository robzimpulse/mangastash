import 'package:flutter/foundation.dart';
import 'package:ui_common/ui_common.dart';
import 'package:universal_io/io.dart';

class MainScreen extends StatelessWidget {
  final Widget child;
  final int index;
  final ValueSetter<int>? onTapMenu;
  final AsyncValueGetter<bool?>? onTapClosedApps;

  const MainScreen({
    super.key,
    required this.child,
    required this.index,
    this.onTapMenu,
    this.onTapClosedApps,
  });

  final Map<String, IconData> _menus = const {
    'Library': Icons.collections_bookmark_sharp,
    'Updates': Icons.sync,
    'History': Icons.history,
    'Browse': Icons.search,
    'More': Icons.more_horiz,
  };

  void _onPopInvoked(BuildContext context, bool didPop) async {
    if (didPop) return;
    final result = await onTapClosedApps?.call();
    if (context.mounted && result == true) exit(0);
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldScreen(
      canPop: false,
      onPopInvoked: (didPop) => _onPopInvoked(context, didPop),
      bottomNavigationBar: _bottomNavigationBar(context: context),
      body: _sideNavigationBar(context: context),
    );
  }

  Widget _sideNavigationBar({required BuildContext context}) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final isPhone = ResponsiveBreakpoints.of(context).isPhone;
    if (isMobile || isPhone) return child;
    final menus = _menus.entries.map(
      (e) => NavigationRailDestination(icon: Icon(e.value), label: Text(e.key)),
    );
    return Row(
      children: [
        NavigationRail(
          key: const Key('left_navigation_rail'),
          labelType: NavigationRailLabelType.all,
          elevation: 8,
          destinations: menus.toList(),
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
    final menus = _menus.entries.map(
      (e) => BottomNavigationBarItem(icon: Icon(e.value), label: e.key),
    );
    return BottomNavigationBar(
      key: const Key('bottom_navigation_bar'),
      currentIndex: index,
      type: BottomNavigationBarType.fixed,
      showUnselectedLabels: true,
      items: menus.toList(),
      onTap: onTapMenu,
    );
  }
}
