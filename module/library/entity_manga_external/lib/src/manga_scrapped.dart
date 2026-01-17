import 'package:equatable/equatable.dart';
import 'package:eval_annotation/eval_annotation.dart';

@Bind()
class MangaScrapped extends Equatable {
  final String? id;
  final String? title;
  final String? coverUrl;
  final String? author;
  final String? status;
  final String? description;
  final List<String>? tags;
  final String? webUrl;
  final String? createdAt;
  final String? updatedAt;

  const MangaScrapped({
    this.id,
    this.title,
    this.coverUrl,
    this.author,
    this.status,
    this.description,
    this.tags,
    this.webUrl,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props {
    return [
      id,
      title,
      coverUrl,
      author,
      status,
      description,
      tags,
      webUrl,
      createdAt,
      updatedAt,
    ];
  }
}
