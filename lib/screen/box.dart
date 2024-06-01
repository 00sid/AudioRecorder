import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:permission_handler/permission_handler.dart';

class Box extends StatefulWidget {
  const Box({super.key});

  @override
  State<Box> createState() => _BoxState();
}

class _BoxState extends State<Box> {
  final recorder = FlutterSoundRecorder();
  bool isStopped = false;
  bool isPlaying = false;
  Duration duration = Duration.zero;

  Duration postion = Duration.zero;
  final audioPlayer = AudioPlayer();
  Source? source;
  File? audioFile;
  @override
  void initState() {
    super.initState();

    initRecorder();

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
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    recorder.closeRecorder();
    audioPlayer.dispose();
  }

  Future initRecorder() async {
    try {
      final status = await Permission.microphone.request();
      if (status == PermissionStatus.granted) {
        await recorder.openRecorder();
        recorder.setSubscriptionDuration(const Duration(milliseconds: 500));
      } else if (status != PermissionStatus.granted ||
          status != PermissionStatus.permanentlyDenied ||
          status != PermissionStatus.restricted) {
        throw "Microphone permission not granted";
      }
    } catch (e) {
      print(e);
    }
  }

  Future record() async {
    await recorder.startRecorder(toFile: 'audio');
  }

  Future stop() async {
    final path = await recorder.stopRecorder();
    audioFile = File(path!);
    setState(() {
      isStopped = true;
      source = DeviceFileSource(audioFile!.path);
    });
    print("Audio file path: $audioFile");
    print(source);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0, 2),
            blurRadius: 6,
          ),
        ],
      ),
      child: Center(
        child: isStopped ? _audioPlayer() : _audioRecorder(),
      ),
    );
  }

  formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  Widget _audioPlayer() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Slider(
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formatTime(postion),
                ),
                Text(
                  formatTime(duration - postion),
                ),
              ],
            ),
          ),
          CircleAvatar(
            radius: 34,
            child: IconButton(
              icon: Icon(
                isPlaying ? Icons.pause : Icons.play_arrow,
                size: 50,
              ),
              onPressed: () async {
                if (isPlaying) {
                  await audioPlayer.pause();
                } else {
                  await audioPlayer.play(source!);
                }
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () async {
                  await audioPlayer.stop();
                  setState(() {
                    isStopped = false;
                  });
                },
                icon: const Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
              ),
              IconButton(
                onPressed: () async {
                  await audioPlayer.stop();
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pop();
                },
                icon: const Icon(
                  Icons.send,
                  color: Colors.green,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _audioRecorder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () async {
            if (recorder.isRecording) {
              await stop();
            } else {
              await record();
              setState(() {});
            }
          },
          child: Icon(
            recorder.isRecording ? Icons.stop : Icons.mic,
            size: 80,
          ),
        ),
        StreamBuilder<RecordingDisposition>(
          stream: recorder.onProgress,
          builder: (context, snapshot) {
            {
              final duration =
                  snapshot.hasData ? snapshot.data!.duration : Duration.zero;
              String twoDigits(int n) => n.toString().padLeft(2, '0');
              final minutes = twoDigits(duration.inMinutes.remainder(60));
              final seconds = twoDigits(duration.inSeconds.remainder(60));
              return Text(
                "$minutes:$seconds",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 50,
                  color: Colors.grey.shade500,
                ),
              );
            }
          },
        ),
      ],
    );
  }
}
