import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'product_details.dart';

class ProductList extends StatefulWidget {
  @override
  _ProductListState createState() => _ProductListState();
}

class TranslationService {
  static const String apiKey = '2YGQXTD-RDR4ADW-HA7PHNN-PSJWXM8';
  static const String apiUrl = 'https://api.lecto.ai/v1/translate/text';

  Future<String> translate(String text) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'X-API-Key': apiKey,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(<String, dynamic>{
          'to': ["en"],
          'from': "ru",
          'texts': [text],
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse['translations'][0]['translated'][0];
      } else {
        throw Exception('Failed to translate text: ${response.statusCode}');
      }
    } catch (e) {
      print('Translation Error: $e');
      throw Exception('Failed to translate text');
    }
  }
}

class _ProductListState extends State<ProductList> {
  List<dynamic> _products = [];
  String _searchQuery = '';
  final TranslationService _translationService = TranslationService();

  @override
  void initState() {
    super.initState();
  }

  Future<void> _searchProducts() async {
    try {
      String translatedQuery = await _translationService.translate(_searchQuery);

      final response = await http.get(
        Uri.parse('https://api.edamam.com/api/food-database/v2/parser?ingr=$translatedQuery&app_id=1be8e70a&app_key=eeacee54fd2104a1f54a7b572ae4d8a3'),
      );

      if (response.statusCode == 200) {
        setState(() {
          _products = jsonDecode(response.body)['hints'];
        });
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      print('Search Error: $e');
      throw Exception('Failed to search products');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Справочник продуктов'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () async {
              var query = await showDialog<String>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('Поиск'),
                    content: TextField(
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(hintText: 'Введите запрос'),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('Отмена'),
                      ),
                      TextButton(
                        onPressed: () {
                          _searchProducts();
                          Navigator.pop(context);
                        },
                        child: Text('OK'),
                      ),
                    ],
                  );
                },
              );
              if (query != null) {
                setState(() {
                  _searchQuery = query;
                });
              }
            },
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: _products.isEmpty
              ? Center(
                  child: Text(
                    'Пусто, введи что-нибудь через кнопочку в левом верхнем углу',
                    style: TextStyle(color: Colors.black, fontSize: 20),
                  ),
                )
              : ListView.builder(
                  itemCount: _products.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: ListTile(
                        title: Text(_products[index]['food']['label'], style: TextStyle(color: Colors.black)),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductDetailScreen(foodId: _products[index]['food']['foodId']),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
