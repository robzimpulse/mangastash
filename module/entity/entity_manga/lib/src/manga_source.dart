import 'package:equatable/equatable.dart';

class MangaSource extends Equatable {

  final String iconUrl;

  final String name;

  final String url;

  final String id;

  const MangaSource({
    this.iconUrl = '',
    required this.name,
    required this.url,
    required this.id,
  });

  @override
  List<Object?> get props => [iconUrl, name, url, id];
}