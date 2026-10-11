/// Public API of core_network: Dio/webview networking, typed network
/// exceptions, `Result` wrappers, the JS source script harness and the
/// `RunSourceScriptUseCase` runner contract.
///
/// Usage: `import 'package:core_network/core_network.dart';` and resolve
/// services from the locator after `CoreNetworkRegistrar` has run.
library;

export 'package:dio/dio.dart';
export 'package:flutter_inappwebview/flutter_inappwebview.dart';

export 'src/adapter/ignore_bad_certificate_adapter.dart'
if (dart.library.js_interop) 'src/adapter/ignore_bad_certificate_web.dart'
if (dart.library.io) 'src/adapter/ignore_bad_certificate_io.dart';
export 'src/core_network_registrar.dart';
export 'src/exception/cloudflare_challenge_exception.dart';
export 'src/exception/data_not_found_exception.dart';
export 'src/exception/failed_parsing_html_exception.dart';
export 'src/exception/http_status_exception.dart';
export 'src/exception/map_dio_error.dart';
export 'src/exception/network_exception.dart';
export 'src/exception/rate_limit_exception.dart';
export 'src/manager/user_agent_manager.dart';
export 'src/manager/visible_webview_guard.dart';
export 'src/mixin/user_agent_mixin.dart';
export 'src/provider/dio_image_provider.dart';
export 'src/response/error.dart';
export 'src/response/result.dart';
export 'src/response/success.dart';
export 'src/script/source_script_exception.dart';
export 'src/script/source_script_harness.dart';
export 'src/usecase/headless_webview_use_case.dart';
export 'src/usecase/run_source_script_use_case.dart';
