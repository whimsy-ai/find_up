import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import 'dio_cache_interceptor_file_store_io.dart';

abstract class Http {
  static late FileCacheStore _cache;
  static late Dio _core;

  static Future<void> init() async {
    final dir = await getApplicationSupportDirectory();
    final cachePath = path.join(dir.path, 'http_caches');
    debugPrint('Http 缓存路径 $cachePath');
    _cache = FileCacheStore(cachePath);
    final options = CacheOptions(
      // A default store is required for interceptor.
      store: _cache,

      // All subsequent fields are optional.

      // Default.
      policy: CachePolicy.request,
      // Returns a cached response on error but for statuses 401 & 403.
      // Also allows to return a cached response on network errors (e.g. offline usage).
      // Defaults to [null].
      hitCacheOnErrorExcept: [401, 403],
      // Overrides any HTTP directive to delete entry past this duration.
      // Useful only when origin server has no cache config or custom behaviour is desired.
      // Defaults to [null].
      maxStale: Duration(days: 7),
      // Default. Allows 3 cache sets and ease cleanup.
      priority: CachePriority.normal,
      // Default. Body and headers encryption with your own algorithm.
      cipher: null,
      // Default. Key builder to retrieve requests.
      keyBuilder: CacheOptions.defaultCacheKeyBuilder,
      // Default. Allows to cache POST requests.
      // Overriding [keyBuilder] is strongly recommended when [true].
      allowPostMethod: false,
    );

// Add cache interceptor with global/default options
    _core = Dio()..interceptors.add(DioCacheInterceptor(options: options));
  }

  static Future<void> clear() => _cache.clean();
}
