import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const Sounds());
}

class Sounds extends StatelessWidget {
  const Sounds({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sounds',
      theme: ThemeData(useMaterial3: false),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> cardItems = <String>['bird', 'cow', 'goat', 'horse', 'kitty', 'monkey', 'sheep', 'wolf'];
  List<String> mp3Items = <String>['bird.mp3', 'cow.mp3', 'goat.mp3', 'horse.mp3', 'kitty.mp3', 'monkey.mp3', 'sheep.mp3', 'wolf.mp3'];

  // TO : DO CHECK IF PLAYER IS PLAYING AND DISPOSE OF PLAYER TO SAVE MEMORY
  final AudioPlayer player = AudioPlayer();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sounds'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 24,
            mainAxisSpacing: 24,
          ),
          itemCount: cardItems.length,
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              onTap: () async {
                await player.play(AssetSource(mp3Items[index]));
              },
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: <Color>[Colors.blue, Colors.green]),
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Center(
                  child: Text(cardItems[index]),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
