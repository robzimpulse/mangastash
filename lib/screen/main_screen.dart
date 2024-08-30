import 'package:core_route/core_route.dart';
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

  void _onPopInvoked(BuildContext context, bool didPop) async {
    if (didPop) return;
    final result = await context.showBottomSheet<bool>(
      builder: (context) => const ConfirmationBottomSheet(
        content: 'Are you sure want to quit?',
        positiveButtonText: 'Yes',
        negativeButtonText: 'No',
      ),
    );

    if (context.mounted && result == true) context.pop();
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
      (e) => NavigationRailDestination(
        icon: Icon(e.value),
        label: Text(e.key),
      ),
    );
    return Row(
      children: [
        NavigationRail(
          key: const Key('left-navigation-rail'),
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
      key: const Key('bottom-navigation-bar'),
      currentIndex: index,
      type: BottomNavigationBarType.fixed,
      showUnselectedLabels: true,
      items: menus.toList(),
      onTap: onTapMenu,
    );
  }
}
