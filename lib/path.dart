import 'package:feature_home/feature_home.dart' as home;

class MainPath {
  static const main = '/';
  static const mainScreen = '/:screen(${home.RoutePath.home}|favourite|collection|setting|profile)';
}