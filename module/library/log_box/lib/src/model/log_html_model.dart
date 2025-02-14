import 'log_model.dart';

class LogHtmlModel extends LogModel {
  final String html;

  final Uri uri;

  const LogHtmlModel({
    required this.html,
    required this.uri,
    super.time,
    super.sequenceNumber,
    super.level,
    super.name,
    super.zone,
    super.error,
    super.stackTrace,
  }) : super(message: 'Url: $uri');

  @override
  List<Object?> get props => [...super.props, html, uri];
}
