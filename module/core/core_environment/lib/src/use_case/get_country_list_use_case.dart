import '../entity/country.dart';

abstract class GetCountryListUseCase {
  List<Country> get countries;
}