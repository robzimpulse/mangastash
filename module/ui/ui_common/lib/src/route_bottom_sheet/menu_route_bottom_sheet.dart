import 'package:core_environment/core_environment.dart';
import 'package:core_route/core_route.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:flutter/material.dart';
import 'package:service_locator/service_locator.dart';

import '../bottom_sheet/menu_bottom_sheet.dart';

class MenuRouteBottomSheet extends BottomSheetRoute {
  MenuRouteBottomSheet({
    super.key,
    super.name,
    required ServiceLocator locator,
    bool? isOnLibrary,
  }) : super(
          child: (context, controller) => MenuBottomSheet(
            content: [
              isOnLibrary?.let(
                (value) => ListTile(
                  title: Text('${value ? 'Remove from' : 'Add to'} Library'),
                  leading: Icon(
                    value ? Icons.favorite_border : Icons.favorite,
                  ),
                  onTap: () => context.pop(MangaMenu.library),
                ),
              ),
              ListTile(
                title: const Text('Prefetch'),
                leading: const Icon(Icons.cloud_download),
                onTap: () => context.pop(MangaMenu.prefetch),
              ),
              ListTile(
                title: const Text('Download'),
                leading: const Icon(Icons.download),
                onTap: () => context.pop(MangaMenu.download),
              ),
            ].nonNulls.toList(),
          ),
          draggable: true,
          elevation: 16,
        );
}
