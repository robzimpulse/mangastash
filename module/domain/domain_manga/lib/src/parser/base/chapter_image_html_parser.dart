import 'base_html_parser.dart';

abstract class ChapterImageHtmlParser extends BaseHtmlParser {
  List<String> get images;
  ChapterImageHtmlParser({required super.root});
}