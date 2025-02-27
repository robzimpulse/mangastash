import 'package:equatable/equatable.dart';
import 'package:text_similarity/text_similarity.dart';

abstract class BaseModel extends Equatable implements Similarity, Comparable {

  const BaseModel();

  @override
  int compareTo(other) {
    return (similarity(other) * 1000).toInt();
  }

  @override
  List<Object?> get props;

  @override
  double similarity(other);

}