import '../common/enum.dart';
import 'entry.dart';

class NavigationEntry extends Entry {
  final NavigationAction action;
  final String? route;
  final String? previousRoute;

  NavigationEntry({
    String? id,
    DateTime? timestamp,
    required this.action,
    this.route,
    this.previousRoute,
  }) : super(id: id, timestamp: timestamp);

  NavigationEntry copyWith({String? route, String? previousRoute}) {
    return NavigationEntry(
      id: id,
      timestamp: timestamp,
      action: action,
      previousRoute: previousRoute ?? this.previousRoute,
      route: route ?? this.route,
    );
  }
}
