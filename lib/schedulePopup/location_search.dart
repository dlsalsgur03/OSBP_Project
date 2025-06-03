import 'package:flutter/material.dart';
import 'search_func.dart';

Future<Map<String, dynamic>?> showAddressSearchModal(BuildContext context) async {
  final TextEditingController searchController = TextEditingController();
  List<dynamic> results = [];

  return showModalBottomSheet<Map<String, dynamic>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          void onSearch() async {
            final query = searchController.text.trim();
            if (query.isEmpty) return;

            try {
              final res = await searchAddress(query);
              setState(() {
                results = res;
              });
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('검색 오류: $e')));
            }
          }

          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 16,
              right: 16,
              top: 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          hintText: '장소·주소 검색',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onSubmitted: (_) => onSearch(),
                      ),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: onSearch,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 25)
                      ),
                      child: Icon(Icons.search)
                    ),
                  ],
                ),
                SizedBox(height: 10),
                SizedBox(
                  height: 300,
                  child: results.isEmpty
                      ? Center(child: Text('검색 결과가 없습니다'))
                      : ListView.builder(
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final item = results[index];
                      final placeName = item['place_name'] ?? '';
                      final roadAddress = item['road_address']?['address_name'] ?? '';
                      final lat = item['y']; // 위도
                      final lng = item['x']; // 경도

                      return ListTile(
                        title: Text(roadAddress.isNotEmpty ? roadAddress : placeName),
                        subtitle: Text(placeName),
                        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey,),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)
                        ),
                        onTap: () {
                          Navigator.of(context).pop({
                            'address': roadAddress.isNotEmpty ? roadAddress : placeName,
                            'lat': double.tryParse(lat) ?? 0,
                            'lng': double.tryParse(lng) ?? 0,
                          });
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
