import 'package:equatable/equatable.dart';

class AdvancedScreenState extends Equatable {

  const AdvancedScreenState({this.cookies = const []});

  final List<Map<String, dynamic>> cookies;

  @override
  List<Object?> get props => [cookies];

  AdvancedScreenState copyWith({List<Map<String, dynamic>>? cookies}) {
    return AdvancedScreenState(cookies: cookies ?? this.cookies);
  }

}