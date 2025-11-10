import 'package:json_annotation/json_annotation.dart';

part 'title.g.dart';

///@nodoc
@JsonSerializable()
class Title {
  final String? en;
  final String? fr;
  final String? it;
  final String? zh;
  @JsonKey(name: 'ja-ro')
  final String? jaRo;
  final String? ru;
  @JsonKey(name: 'zh-ro')
  final String? zhRo;

  const Title(
    this.en,
    this.fr,
    this.it,
    this.zh,
    this.jaRo,
    this.ru,
    this.zhRo,
  );

  factory Title.fromJson(Map<String, dynamic> json) => _$TitleFromJson(json);

  Map<String, dynamic> toJson() => _$TitleToJson(this);

  Title copyWith({
    String? en,
    String? fr,
    String? it,
    String? zh,
    String? jaRo,
    String? ru,
    String? zhRo,
  }) {
    return Title(
      en ?? this.en,
      fr ?? this.fr,
      it ?? this.it,
      zh ?? this.zh,
      jaRo ?? this.jaRo,
      ru ?? this.ru,
      zhRo ?? this.zhRo,
    );
  }
}

extension TitleExtension on Iterable<Title> {
  Title? get filled {
    final element = firstOrNull;
    if (element == null) return null;
    if (length == 1) return element;

    var value = element.copyWith();

    for (final data in this) {
      value = value.copyWith(
        en: value.en ?? data.en,
        fr: value.fr ?? data.fr,
        it: value.it ?? data.it,
        zh: value.zh ?? data.zh,
        jaRo: value.jaRo ?? data.jaRo,
        ru: value.ru ?? data.ru,
        zhRo: value.zh ?? data.zhRo,
      );
    }

    return value;
  }
}
