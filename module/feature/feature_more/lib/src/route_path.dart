// MoreRoutePath: path constants of the More/Settings routes. Use them with
// `context.push(MoreRoutePath.x)`; the matching GoRoutes live in
// MoreRouteBuilder (route_builder.dart).
class MoreRoutePath {

  static const aboutUs = '$setting/about_us';
  static const advanced = '$setting/advanced';
  static const appearance = '$setting/appearance';
  static const dataStorage = '$setting/data_storage';
  static const browse = '$setting/browse';
  static const sources = '$setting/sources';
  // Query params: `id` (required), `function` and `url` (optional). The
  // editor screen and its GoRoute are added by the editor task (#115 Task 13);
  // nothing pushes this path yet.
  static const sourceEditor = '$setting/sources/editor';
  static const queue = '$setting/queue';
  static const general = '$setting/general';
  static const library = '$setting/library';
  static const reader = '$setting/reader';
  static const security = '$setting/security';
  static const statistic = '$setting/statistic';
  static const tracking = '$setting/tracking';
  static const more = '/more';
  static const setting = '/setting';
  static const languagePicker = '$setting/language';
  static const countryPicker = '$setting/country';
}
