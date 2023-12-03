import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: false),
      title: 'Movie Titles',
      home: const MovieTitleList(),
    );
  }
}

class MovieTitleList extends StatefulWidget {
  const MovieTitleList({super.key});

  @override
  MovieTitleListState createState() => MovieTitleListState();
}

class MovieTitleListState extends State<MovieTitleList> {
  List<String> movieTitles = <String>[];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final http.Response response = await http.get(Uri.parse('https://yts.mx/api/v2/list_movies.json'));
    if (response.statusCode == 200) {
      /// cast decoded as Map<String, dynamic>
      final Map<String, dynamic> decoded = jsonDecode(response.body) as Map<String, dynamic>;

      /// cast decoded['data'] as Map<String, dynamic> (because it is subtype
      /// of dynamic
      final Map<String, dynamic> data = decoded['data'] as Map<String, dynamic>;

      /// cast data['movies'] to movies variable as List<dynamic>
      final List<dynamic> movies = data['movies'] as List<dynamic>;
      Map<String, dynamic> currentMovie;
      setState(() {
        for (final dynamic movie in movies) {
          currentMovie = movie as Map<String, dynamic>;
          movieTitles.add(currentMovie['title'] as String);
        }
      });

      if (kDebugMode) {
        print(movieTitles);
      }
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Movie Titles'),
      ),
      body: ListView.builder(
        itemCount: movieTitles.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text(movieTitles[index]),
          );
        },
      ),
    );
  }
}
