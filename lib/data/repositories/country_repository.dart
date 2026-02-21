// 국가/도시 관련 Repository
// GET /api/v1/countries
// GET /api/v1/countries/{countryCode}/cities
import '../../core/network/dio_client.dart';
import '../models/country_model.dart';
import '../models/city_model.dart';

class CountryRepository {
  CountryRepository._();
  static final CountryRepository instance = CountryRepository._();

  /// 국가 목록 조회
  Future<List<CountryModel>> getCountries() async {
    final data = await DioClient.instance.get('/api/v1/countries');
    return (data as List)
        .map((e) => CountryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// 국가별 도시 목록 조회
  Future<List<CityModel>> getCities(String countryCode) async {
    final data = await DioClient.instance.get(
      '/api/v1/countries/$countryCode/cities',
    );
    return (data as List)
        .map((e) => CityModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}