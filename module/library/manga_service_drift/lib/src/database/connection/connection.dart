// We use a conditional export to expose the right connection factory depending
// on the platform.
export 'unsupported.dart'
if (dart.library.js_interop) 'web.dart'
if (dart.library.ffi) 'native.dart';