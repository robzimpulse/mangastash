import 'package:flutter/foundation.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc_builder_with_child_base.dart';

class BlocBuilderWithChild<B extends StateStreamable<S>, S>
    extends BlocBuilderWithChildBase<B, S> {
  /// {@macro bloc_builder}
  /// {@macro bloc_builder_build_when}
  const BlocBuilderWithChild({
    required this.builder,
    Key? key,
    B? bloc,
    BlocBuilderCondition<S>? buildWhen,
  }) : super(key: key, bloc: bloc, buildWhen: buildWhen);

  /// The [builder] function which will be invoked on each widget build.
  /// The [builder] takes the `BuildContext` and current `state` and
  /// must return a widget.
  /// This is analogous to the [builder] function in [StreamBuilder].
  final BlocWidgetBuilderWithChild<S> builder;

  @override
  Widget build(BuildContext context, S state, Widget? child) {
    return builder(context, state, child);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      ObjectFlagProperty<BlocWidgetBuilderWithChild<S>>.has('builder', builder),
    );
  }
}