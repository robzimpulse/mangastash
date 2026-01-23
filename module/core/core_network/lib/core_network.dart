library;

export 'package:dio/dio.dart';
export 'package:flutter_inappwebview/flutter_inappwebview.dart';

export 'src/adapter/ignore_bad_certificate_adapter.dart'
if (dart.library.js_interop) 'src/adapter/ignore_bad_certificate_adapter_io.dart'
if (dart.library.io) 'src/adapter/ignore_bad_certificate_adapter_web.dart';
export 'src/core_network_registrar.dart';
export 'src/exception/data_not_found_exception.dart';
export 'src/exception/failed_parsing_html_exception.dart';
export 'src/mixin/user_agent_mixin.dart';
export 'src/provider/dio_image_provider.dart';
export 'src/response/error.dart';
export 'src/response/result.dart';
export 'src/response/success.dart';
export 'src/usecase/headless_webview_use_case.dart';
