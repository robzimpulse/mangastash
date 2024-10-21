import 'package:json_annotation/json_annotation.dart';

import 'attribute.dart';

@JsonSerializable()
class GeneralAttributes extends Attribute {

  final String? name;
  final List<String>? altNames;
  final bool? locked;
  final String? website;
  final String? ircServer;
  final String? ircChannel;
  final String? discord;
  final String? contactEmail;
  final String? description;
  final String? twitter;
  final String? mangaUpdates;
  final List<String>? focusedLanguages;
  final bool? official;
  final bool? verified;
  final bool? inactive;
  final String? publishDelay;
  final bool? exLicensed;

  GeneralAttributes(
      this.name,
      this.altNames,
      this.locked,
      this.website,
      this.ircServer,
      this.ircChannel,
      this.discord,
      this.contactEmail,
      this.description,
      this.twitter,
      this.mangaUpdates,
      this.focusedLanguages,
      this.official,
      this.verified,
      this.inactive,
      this.publishDelay,
      this.exLicensed,
      super.createdAt,
      super.updatedAt,
      super.version,
      );

}