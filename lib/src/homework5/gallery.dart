import 'dart:convert';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import '../../config.dart';

void main() {
  runApp(const Gallery());
}

class Gallery extends StatelessWidget {
  const Gallery({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gallery',
      theme: ThemeData(useMaterial3: false),
      home: const Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final List<Photo> items = <Photo>[];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadItems();
  }

  Future<void> loadItems() async {
    const String accessKey = AppConfig.apiKey;

    final Client client = Client();
    final Response response = await client.get(
        Uri.parse('https://api'
            '.unsplash.com/photos/'),
        headers: <String, String>{'Authorization': 'Client-ID $accessKey'});
    if (response.statusCode == 200) {
      /// cast decoded as Map<String, dynamic>
      final List<dynamic> decoded = jsonDecode(response.body) as List<dynamic>;

      /// add to items
      for (final dynamic item in decoded) {
        items.add(Photo(item as Map<String, dynamic>));
      }

      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gallery'),
        centerTitle: true,
      ),
      body: Builder(
        builder: (BuildContext context) {
          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: items.length,
            itemBuilder: (BuildContext context, int index) {
              final Photo photo = items[index];

              return Column(
                children: <Widget>[
                  Image.network(photo.urls['raw'] as String),
                  ListTile(
                    title: Text('Likes: ${photo.likes}'),
                    subtitle: Text('Description: ${photo.altDescription}'),
                  )
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class Photo {
  Photo(Map<String, dynamic> json)
      : urls = json['urls'] as Map<String, dynamic>,
        altDescription = json['alt_description'] as String,
        likes = json['likes'] as int,
        user = json['user'] as Map<String, dynamic>;

  final Map<String, dynamic> urls;
  final String altDescription;
  final int likes;
  final Map<String, dynamic> user;
}
