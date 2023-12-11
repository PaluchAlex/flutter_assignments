import 'dart:convert';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';
import 'package:url_launcher/url_launcher.dart';

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
  bool initialLoading = true;
  bool isLoading = true;
  int page = 1;
  String query = '';
  String color = '';

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
    final double screenHeight = MediaQuery.sizeOf(context).height;
    final double threshold = maxExtent - 2 * screenHeight;

    /// load items when scrolled past 80% of max
    if (!isLoading && offset > threshold) {
      loadItems();
    }
  }

  Future<void> loadItems() async {
    await dotenv.load();
    final String? accessKey = dotenv.env['UNSPLASH_API_KEY'];
    setState(() => isLoading = true);

    if (query.isEmpty && color.isEmpty) {
      final Client client = Client();
      final Response response = await client.get(
        Uri.parse('https://api.unsplash'
            '.com/photos/?page=$page'),
        headers: <String, String>{'Authorization': 'Client-ID $accessKey'},
      );
      if (response.statusCode == 200) {
        /// cast decoded as List<dynamic>
        final List<dynamic> decoded = jsonDecode(response.body) as List<dynamic>;

        /// add to items as a instance of Class Photo
        for (final dynamic item in decoded) {
          items.add(Photo(item as Map<String, dynamic>));
        }

        ///prepare for loading next page
        page++;
      }
    } else {
      page = 1;
      items.clear();
      final Client client = Client();
      final Response response = await client.get(
        Uri.parse('https://api.unsplash'
            '.com/search/photos/?page=$page&query=$query&color=$color'),
        headers: <String, String>{'Authorization': 'Client-ID $accessKey'},
      );
      if (response.statusCode == 200) {
        /// cast decoded as List<dynamic>
        final Map<String, dynamic> decoded = jsonDecode(response.body) as Map<String, dynamic>;

        final List<dynamic> results = decoded['results'] as List<dynamic>;

        /// add to items as a instance of Class Photo
        for (final dynamic item in results) {
          items.add(Photo(item as Map<String, dynamic>));
        }

        ///prepare for loading next page
        page++;
      }
    }

    await Future<void>.delayed(const Duration(seconds: 5));
    setState(
      () {
        isLoading = false;
        initialLoading = false;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Unsplash Gallery'),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search',
                    ),
                    onChanged: (String value) {
                      query = value;
                      if (value.isNotEmpty) {
                        loadItems();
                      }
                    },
                  ),
                ),
              ),
              Expanded(
                child: DropdownMenu<String>(
                  onSelected: (String? value) {
                    color = value ?? '';
                    if (color.isNotEmpty) {
                      loadItems();
                    }
                  },
                  dropdownMenuEntries: allColors.map(
                    (String item) {
                      return DropdownMenuEntry<String>(
                        value: item,
                        label: item,
                      );
                    },
                  ).toList(),
                ),
              )
            ],
          ),
          Expanded(
            child: Builder(
              builder: (BuildContext context) {
                if (initialLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                return CustomScrollView(
                  controller: controller,
                  slivers: <Widget>[
                    if (items.isEmpty)
                      const SliverToBoxAdapter(
                        child: Center(
                          child: Text('no items found'),
                        ),
                      ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
                        final Photo photo = items[index];

                        return Column(
                          children: <Widget>[
                            InkWell(
                              onTap: () {
                                final Map<String, dynamic> currentPhotoLinks =
                                    photo.user['links'] as Map<String, dynamic>;
                                _launchURL(Uri.parse(currentPhotoLinks['html']! as String));
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
                                subtitle: Center(child: Text(photo.altDescription)),
                              ),
                            ),
                          ],
                        );
                      }, childCount: items.length),
                    ),
                    if (isLoading)
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 16),
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
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

const List<String> allColors = <String>[
  'black_and_white',
  'black',
  'white',
  'yellow',
  'orange',
  'red',
  'purple',
  'magenta',
  'green',
  'teal',
  'blue'
];
