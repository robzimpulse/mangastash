
import 'package:core_analytics/core_analytics.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import '../custom_cache_manager/custom_cache_manager.dart';
import 'file_service/custom_file_service.dart';

class ImagesCacheManager extends CustomCacheManager with ImageCacheManager {
  final LogBox _logBox;

  ImagesCacheManager({
    required CustomFileService fileService,
    required LogBox logBox,
  })  :_logBox = logBox,
        super(
          Config('image', fileService: fileService),
          onDeleteFile: (object, data) {
            logBox.log(
              '[Move] Image file to Database',
              extra: {'cache': object.toMap(setTouchedToNow: false)},
              name: 'ImageCacheManager',
            );
            /// TODO: save image data to folder images
            // imageByteDao.add(webUrl: object.url, data: data);
          },
        );

  /// TODO: intercept get file stream to fetch image from folder image
  // @override
  // Stream<FileResponse> getFileStream(
  //   String url, {
  //   String? key,
  //   Map<String, String>? headers,
  //   bool withProgress = false,
  // }) {
  //   final controller = StreamController<FileResponse>();
  //
  //   _logBox.log(
  //     '[Start] get file stream',
  //     name: runtimeType.toString(),
  //     extra: {'url': url},
  //   );
  //
  //   _imageByteDao
  //       .search(webUrls: [url])
  //       .then((results) => results.firstOrNull?.byte)
  //       .then<void>((data) async {
  //         if (data != null) {
  //           _logBox.log(
  //             '[Hit] Copy image file from Database to Cache',
  //             name: runtimeType.toString(),
  //             extra: {'url': url},
  //           );
  //
  //           controller.add(
  //             FileInfo(
  //               await putFile(url, data),
  //               FileSource.Cache,
  //               DateTime.now().add(Duration(days: 1)),
  //               url,
  //             ),
  //           );
  //         } else {
  //           _logBox.log(
  //             '[Miss] Using image file from Cache',
  //             name: runtimeType.toString(),
  //             extra: {'url': url},
  //           );
  //
  //           await controller.addStream(
  //             super.getFileStream(
  //               url,
  //               key: key,
  //               headers: headers,
  //               withProgress: withProgress,
  //             ),
  //           );
  //         }
  //       })
  //       .onError((e, st) async {
  //         _logBox.log(
  //           '[Error] Using image file from Cache',
  //           name: runtimeType.toString(),
  //           extra: {'url': url},
  //           error: e,
  //           stackTrace: st,
  //         );
  //
  //         await controller.addStream(
  //           super.getFileStream(
  //             url,
  //             key: key,
  //             headers: headers,
  //             withProgress: withProgress,
  //           ),
  //         );
  //       })
  //       .whenComplete(() {
  //         _logBox.log(
  //           '[Finish] get file stream',
  //           name: runtimeType.toString(),
  //           extra: {'url': url},
  //         );
  //
  //         controller.close();
  //       });
  //
  //   return controller.stream;
  // }
}
