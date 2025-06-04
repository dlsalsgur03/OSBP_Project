import '../schedulePopup/search_func.dart';

Future<Map<String, dynamic>> findNearestStation() async {
  final busResults = await searchAddress('버스 터미널');
  final trainResults = await searchAddress('기차역');

  // 두 리스트를 합치고 거리 기준으로 정렬
  final allPlaces = [...busResults, ...trainResults];
  allPlaces.sort((a, b) => int.parse(a['distance']).compareTo(int.parse(b['distance'])));

  // 가장 가까운 결과 리턴
  return allPlaces.isNotEmpty ? allPlaces.first : {};
}
