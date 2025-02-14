import 'log_model.dart';

class LogHtmlModel extends LogModel {
  final String html;

  final String url;

  const LogHtmlModel({
    required this.html,
    required this.url,
    super.time,
    super.sequenceNumber,
    super.level,
    super.name,
    super.zone,
    super.error,
    super.stackTrace,
  }) : super(message: 'Url: $url');

  @override
  List<Object?> get props => [...super.props, html, url];
}
