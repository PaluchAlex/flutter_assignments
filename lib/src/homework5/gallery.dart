import 'dart:convert';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:url_launcher/url_launcher.dart';
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
  final ScrollController controller = ScrollController();
  final List<Photo> items = <Photo>[];
  bool isLoading = true;
  int page = 1;

  @override
  void initState() {
    super.initState();
    controller.addListener(onScroll);
    loadItems();
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  Future<void> _launchURL(Uri url) async {
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  void onScroll() {
    final double offset = controller.offset;
    final double maxExtent = controller.position.maxScrollExtent;
    if (!isLoading && offset > maxExtent * 0.8) {
      loadItems();
    }
  }

  Future<void> loadItems() async {
    setState(() => isLoading = true);

    const String accessKey = AppConfig.apiKey;

    final Client client = Client();
    final Response response = await client.get(
        Uri.parse('https://api'
            '.unsplash.com/photos/?page=$page'),
        headers: <String, String>{'Authorization': 'Client-ID $accessKey'});
    if (response.statusCode == 200) {
      /// cast decoded as Map<String, dynamic>
      final List<dynamic> decoded = jsonDecode(response.body) as List<dynamic>;

      /// add to items
      for (final dynamic item in decoded) {
        items.add(Photo(item as Map<String, dynamic>));
      }
      page++;

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
          return ListView.separated(
            controller: controller,
            separatorBuilder: (BuildContext context, int index) {
              return const Divider();
            },
            padding: const EdgeInsets.all(8.0),
            itemCount: items.length,
            itemBuilder: (BuildContext context, int index) {
              final Photo photo = items[index];

              return Column(
                children: <Widget>[
                  InkWell(
                    onTap: () {
                      _launchURL(Uri.parse(
                          'https://images.unsplash.com/photo-1701836924089-7fb060024d88?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w1Mzc1MTF8MHwxfGFsbHw0fHx8fHx8Mnx8MTcwMTg2MTYwNXw&ixlib=rb-4.0.3&q=80&w=1080'));
                    },
                    child: Image.network(
                      photo.urls['small'] as String,
                      //height: 445,
                      loadingBuilder: (BuildContext context, Widget widget, ImageChunkEvent? progress) {
                        if (progress == null) {
                          return widget;
                        }
                        return SizedBox(
                          height: 345,
                          child: Center(
                            child: CircularProgressIndicator(
                              value: progress.cumulativeBytesLoaded / (progress.expectedTotalBytes ?? 1),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListTile(
                      title: Row(
                        children: <Widget>[
                          Text('Likes: ${photo.likes}'),
                          Expanded(child: Container()),
                          Text('Author: ${photo.user['name']}'),
                        ],
                      ),
                      subtitle: Text(photo.altDescription),
                    ),
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
