import 'package:ui_common/ui_common.dart';

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

  final Map<String, IconData> _menus = const {
    'Library': Icons.collections_bookmark_sharp,
    'Updates': Icons.sync,
    'History': Icons.history,
    'Browse': Icons.search,
    'More': Icons.more_horiz,
  };

  @override
  Widget build(BuildContext context) {
    return ScaffoldScreen(
      onWillPop: () => Future.value(false),
      bottomNavigationBar: _bottomNavigationBar(context: context),
      body: _sideNavigationBar(context: context),
    );
  }

  Widget _sideNavigationBar({required BuildContext context}) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final isPhone = ResponsiveBreakpoints.of(context).isPhone;
    if (isMobile || isPhone) return child;
    final menus = _menus.entries.map(
      (e) => NavigationRailDestination(
        icon: Icon(e.value),
        label: Text(e.key),
      ),
    );
    return Row(
      children: [
        NavigationRail(
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
      (e) => BottomNavigationBarItem(
        icon: Icon(e.value),
        label: e.key,
      ),
    );
    return BottomNavigationBar(
      currentIndex: index,
      type: BottomNavigationBarType.fixed,
      showUnselectedLabels: true,
      items: menus.toList(),
      onTap: onTapMenu,
    );
  }
}
