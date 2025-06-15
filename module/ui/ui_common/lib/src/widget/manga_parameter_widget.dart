import 'package:collection/collection.dart';
import 'package:core_environment/core_environment.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:flutter/material.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

import 'checkbox_with_text_widget.dart';

class MangaParameterWidget extends StatelessWidget {
  const MangaParameterWidget({
    super.key,
    required this.parameter,
    this.availableTags = const {},
    this.onChanged,
  });

  final SearchMangaParameter parameter;

  final Set<Tag> availableTags;

  final ValueSetter<SearchMangaParameter>? onChanged;

  List<String> get includedTags => [...?parameter.includedTags];

  List<String> get excludedTags => [...?parameter.excludedTags];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ExpansionTile(
          title: const Text('Status'),
          children: [
            ...MangaStatus.values.map(
              (key) => CheckboxListTile(
                title: Text(key.label),
                value: parameter.status?.contains(key) == true,
                onChanged: (value) {
                  if (value == null) return;
                  final values = [...?parameter.status];
                  value ? values.add(key) : values.remove(key);
                  onChanged?.call(parameter.copyWith(status: values));
                },
              ),
            ),
          ],
        ),
        ExpansionTile(
          title: const Text('Content Rating'),
          children: [
            ...ContentRating.values.map(
              (key) => CheckboxListTile(
                title: Text(key.label),
                value: parameter.contentRating?.contains(key) == true,
                onChanged: (value) {
                  if (value == null) return;
                  final values = [...?parameter.contentRating];
                  value ? values.add(key) : values.remove(key);
                  onChanged?.call(parameter.copyWith(contentRating: values));
                },
              ),
            ),
          ],
        ),
        ExpansionTile(
          title: const Text('Original Language'),
          children: [
            ...LanguageCodes.values.map(
              (key) {
                final included = parameter.originalLanguage;
                final excluded = parameter.excludedOriginalLanguages;

                return CheckboxListTile(
                  title: Text(key.label),
                  tristate: true,
                  value: (included?.contains(key) ?? false)
                      ? true
                      : (excluded?.contains(key) ?? false)
                          ? null
                          : false,
                  onChanged: (value) {
                    final originalLanguage = (value == true)
                        ? ([...?included, key])
                        : ([...?included]..remove(key));

                    final excludedOriginalLanguages = (value == null)
                        ? ([...?excluded, key])
                        : ([...?excluded]..remove(key));

                    onChanged?.call(
                      parameter.copyWith(
                        originalLanguage: originalLanguage,
                        excludedOriginalLanguages: excludedOriginalLanguages,
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
        ExpansionTile(
          title: const Text('Available Translated Language'),
          children: [
            ...LanguageCodes.values.map(
              (key) {
                final param = parameter.availableTranslatedLanguage;
                return CheckboxListTile(
                  title: Text(key.label),
                  value: param?.contains(key) == true,
                  onChanged: (value) {
                    if (value == null) return;
                    final values = [...?param];
                    value ? values.add(key) : values.remove(key);
                    onChanged?.call(
                      parameter.copyWith(availableTranslatedLanguage: values),
                    );
                  },
                );
              },
            ),
          ],
        ),
        ExpansionTile(
          title: const Text('Publication Demographic'),
          children: [
            ...PublicDemographic.values.map(
              (key) {
                final param = parameter.publicationDemographic;
                return CheckboxListTile(
                  title: Text(key.label),
                  value: param?.contains(key) == true,
                  onChanged: (value) {
                    if (value == null) return;
                    final values = [...?param];
                    value ? values.add(key) : values.remove(key);
                    onChanged?.call(
                      parameter.copyWith(publicationDemographic: values),
                    );
                  },
                );
              },
            ),
          ],
        ),
        if (availableTags.isNotEmpty)
          ExpansionTile(
            title: const Text('Tags'),
            children: [
              SwitchListTile(
                title: const Text('Included Tags Mode'),
                subtitle: Text(parameter.includedTagsMode.label),
                value: parameter.includedTagsMode == TagsMode.or,
                onChanged: (value) => onChanged?.call(
                  parameter.copyWith(
                    includedTagsMode: value ? TagsMode.or : TagsMode.and,
                  ),
                ),
              ),
              SwitchListTile(
                title: const Text('Excluded Tags Mode'),
                subtitle: Text(parameter.excludedTagsMode.label),
                value: parameter.excludedTagsMode == TagsMode.or,
                onChanged: (value) => onChanged?.call(
                  parameter.copyWith(
                    excludedTagsMode: value ? TagsMode.or : TagsMode.and,
                  ),
                ),
              ),
              Table(
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                columnWidths: const {
                  0: FlexColumnWidth(),
                  1: FlexColumnWidth(),
                },
                children: [
                  for (final pair in availableTags.slices(2))
                    TableRow(
                      children: [
                        for (final (index, tag) in pair.indexed) ...[
                          TableCell(
                            child: CheckboxWithTextWidget(
                              tristate: true,
                              reversed: index.isEven,
                              value: includedTags.contains(tag.id)
                                  ? true
                                  : excludedTags.contains(tag.id)
                                  ? null
                                  : false,
                              onChanged: (value) {
                                final include = [...includedTags];
                                final exclude = [...excludedTags];

                                tag.id?.let((id) {
                                  if (value == true) {
                                    include.add(id);
                                    exclude.remove(id);
                                  } else if (value == false) {
                                    include.remove(id);
                                    exclude.remove(id);
                                  } else {
                                    include.remove(id);
                                    exclude.add(id);
                                  }
                                });

                                onChanged?.call(
                                  parameter.copyWith(
                                    includedTags: include,
                                    excludedTags: exclude,
                                  ),
                                );
                              },
                              text: Expanded(
                                child: Text(
                                  tag.name ?? '',
                                  textAlign: index.isEven
                                      ? TextAlign.end
                                      : TextAlign.start,
                                ),
                              ),
                            ),
                          ),
                          if (pair.length < 2)
                            const TableCell(child: SizedBox()),
                        ],
                      ],
                    ),
                ],
              ),
            ],
          ),
      ],
    );
  }
}
