/// Public API of domain_manga: use cases, managers' use-case interfaces, the
/// SourceRegistry of scripted sources (issue #115) with its SourceEntry model,
/// the SourceExternal implementations, the static `Sources` facade and the
/// fix-source prompt helpers (FixPromptBuilder, trimPageHtml,
/// extractScriptFromReply).
///
/// Usage: `import 'package:domain_manga/domain_manga.dart';` and resolve
/// services from the locator after `DomainMangaRegistrar` has run.
library;

export 'package:manga_dex_api/manga_dex_api.dart';

export 'src/domain_manga_registrar.dart';
export 'src/extension/language_code_converter.dart';
export 'src/extension/uri_source_extension.dart';
export 'src/manager/source_registry.dart';
export 'src/mixin/sort_chapters_mixin.dart';
export 'src/model/source_entry.dart';
export 'src/prompt/fix_prompt_builder.dart';
export 'src/sources/manga_dex_source_external.dart';
export 'src/sources/script_source_external.dart';
export 'src/sources/sources.dart';
export 'src/use_case/cancel_job_use_case.dart';
export 'src/use_case/chapter/get_all_chapter_use_case.dart';
export 'src/use_case/chapter/get_chapter_use_case.dart';
export 'src/use_case/chapter/get_neighbour_chapter_use_case.dart';
export 'src/use_case/chapter/listen_downloaded_chapter_use_case.dart';
export 'src/use_case/chapter/search_chapter_use_case.dart';
export 'src/use_case/chapter/update_chapter_use_case.dart';
export 'src/use_case/download/resolve_download_chapters.dart';
export 'src/use_case/history/listen_read_history_use_case.dart';
export 'src/use_case/history/listen_unread_history_use_case.dart';
export 'src/use_case/library/add_to_library_use_case.dart';
export 'src/use_case/library/listen_manga_from_library_use_case.dart';
export 'src/use_case/library/remove_from_library_use_case.dart';
export 'src/use_case/manga/get_manga_from_url_use_case.dart';
export 'src/use_case/manga/get_manga_use_case.dart';
export 'src/use_case/manga/search_manga_use_case.dart';
export 'src/use_case/parameter/listen_search_parameter_use_case.dart';
export 'src/use_case/parameter/listen_setting_downloaded_only_use_case.dart';
export 'src/use_case/parameter/listen_setting_incognito_use_case.dart';
export 'src/use_case/parameter/update_search_parameter_use_case.dart';
export 'src/use_case/parameter/update_setting_downloaded_only_use_case.dart';
export 'src/use_case/parameter/update_setting_incognito_use_case.dart';
export 'src/use_case/prefetch/listen_job_use_case.dart';
export 'src/use_case/prefetch/listen_prefetch_chapter_config.dart';
export 'src/use_case/prefetch/listen_prefetch_use_case.dart';
export 'src/use_case/prefetch/prefetch_chapter_use_case.dart';
export 'src/use_case/prefetch/prefetch_manga_use_case.dart';
export 'src/use_case/recrawl_use_case.dart';
export 'src/use_case/source/listen_sources_use_case.dart';
export 'src/use_case/source/update_sources_use_case.dart';
export 'src/use_case/tags/get_tags_use_case.dart';
