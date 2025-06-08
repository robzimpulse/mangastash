import 'package:core_environment/core_environment.dart';
import 'package:flutter/material.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

class MangaParameterWidget extends StatelessWidget {
  const MangaParameterWidget({
    super.key,
    required this.parameter,
    this.onChanged,
  });

  final SearchMangaParameter parameter;

  final ValueSetter<SearchMangaParameter>? onChanged;

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
      ],
    );
  }
}
