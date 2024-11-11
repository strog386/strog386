import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:test_app/models/item.dart';

class DatabaseService {
  final String baseUrl;

  DatabaseService(this.baseUrl);

  Future<List<Item>> fetchData(int orderNr) async {
    final response = await http.post(
      Uri.parse('$baseUrl/data'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, int>{
        'orderNr': orderNr,
      }),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => Item.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load data');
    }
  }
}
