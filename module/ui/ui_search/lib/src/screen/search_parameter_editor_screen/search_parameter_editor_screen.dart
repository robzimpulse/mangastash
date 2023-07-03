import 'package:core_route/core_route.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:flutter/material.dart';
import 'package:safe_bloc/safe_bloc.dart';
import 'package:service_locator/service_locator.dart';
import 'package:ui_common/ui_common.dart';

import 'search_parameter_editor_screen_cubit.dart';
import 'search_parameter_editor_screen_cubit_state.dart';

class SearchParameterEditorScreen extends StatelessWidget
    with ResultProvider<SearchMangaParameter> {

  SearchParameterEditorScreen({super.key});

  static Widget create({
    required ServiceLocator locator,
    required SearchMangaParameter parameter,
    required ResultCallback<SearchMangaParameter>? callback,
  }) {
    return BlocProvider(
      create: (context) => SearchParameterEditorScreenCubit(
        listenListTagUseCase: locator(),
      ),
      child: SearchParameterEditorScreen()..initOnResult(callback),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchParameterEditorScreenCubit, SearchParameterEditorScreenCubitState>(
      builder: (context, state) {
        return ScaffoldScreen(
          onWillPop: () async {
            popWithResult(context, null);
            return false;
          },
          appBar: AppBar(
            title: const Text('Advanced Search Screen'),
          ),
          // TODO: add form builder
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
                        child: const Text('Reset'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => popWithResult(context, state.parameter),
                        child: const Text('Apply'),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
