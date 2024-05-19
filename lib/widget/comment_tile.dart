import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class CommentTile extends StatefulWidget {
  bool isAudio;
  CommentTile({super.key, this.isAudio = true});

  @override
  State<CommentTile> createState() => _CommentTileState();
}

class _CommentTileState extends State<CommentTile> {
  bool isPlaying = false;

  Duration duration = Duration.zero;

  Duration postion = Duration.zero;
  final audioPlayer = AudioPlayer();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //listen to states:playing,paused,stopped
    audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        isPlaying = state == PlayerState.playing;
      });
    });
    //listen to audio duration
    audioPlayer.onDurationChanged.listen((d) {
      setState(() {
        duration = d;
      });
    });
    //listen to audio position
    audioPlayer.onPositionChanged.listen((p) {
      setState(() {
        postion = p;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const CircleAvatar(
        radius: 25,
        backgroundImage: NetworkImage(
          "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRx-vjO0zJYwB_RcsSJySi9Ru2XEJ958dW20A&s",
        ),
      ),
      title: const Text('Username'),
      subtitle: widget.isAudio
          ? Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.grey.shade400,
                  radius: 23,
                  child: IconButton(
                    icon: Icon(
                      isPlaying ? Icons.pause : Icons.play_arrow,
                      size: 25,
                    ),
                    onPressed: () async {
                      if (isPlaying) {
                        await audioPlayer.pause();
                      } else {
                        String url =
                            "https://commondatastorage.googleapis.com/codeskulptor-demos/DDR_assets/Kangaroo_MusiQue_-_The_Neverwritten_Role_Playing_Game.mp3";
                        Source source = UrlSource(url);
                        await audioPlayer.play(source);
                      }
                    },
                  ),
                ),
                Column(
                  children: [
                    Slider(
                        activeColor: Colors.green,
                        inactiveColor: Colors.grey,
                        min: 0,
                        max: duration.inSeconds.toDouble(),
                        value: postion.inSeconds.toDouble(),
                        onChanged: (value) async {
                          final position = Duration(seconds: value.toInt());
                          await audioPlayer.seek(position);
                          await audioPlayer.resume();
                        }),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18.0),
                      child: Row(
                        children: [
                          Text(
                            formatTime(postion),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            )
          : const Text("Comment text goes here"),
    );
  }

  formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }
}
