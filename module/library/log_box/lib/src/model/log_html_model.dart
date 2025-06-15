import 'log_model.dart';

class LogHtmlModel extends LogModel {
  final String html;

  final Uri uri;

  final List<String> scripts;

  LogHtmlModel({
    required this.html,
    required this.uri,
    this.scripts = const [],
    super.time,
    super.sequenceNumber,
    super.level,
    super.name,
    super.zone,
    super.error,
    super.stackTrace,
  }) : super(message: 'Url: $uri', extra: {'scripts': scripts});

  @override
  List<Object?> get props => [...super.props, html, uri, scripts];
}
