import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class CustomCacheManager extends CacheManager {
  static const _key = 'customCachedImageData';

  CustomCacheManager._() : super(Config(_key));

  factory CustomCacheManager.create() => CustomCacheManager._();
}
