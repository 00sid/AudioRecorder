import 'package:audiorecord/screen/box.dart';
import 'package:audiorecord/widget/comment_tile.dart';
import 'package:flutter/material.dart';

class CommentScreen extends StatefulWidget {
  @override
  _CommentScreenState createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  double _sheetHeight = 0.5; // Initial height of the sheet
  // final recorder = FlutterSoundRecorder();
  // @override
  // void initState() {
  //   // TODO: implement initState
  //   super.initState();
  //   initRecorder();
  // }

  // @override
  // void dispose() {
  //   // TODO: implement dispose
  //   super.dispose();
  //   recorder.closeRecorder();
  // }

  // Future initRecorder() async {
  //   try {
  //     final status = await Permission.microphone.request();
  //     if (status != PermissionStatus.granted) {
  //       throw "Microphone permission not granted";
  //     }
  //     await recorder.openRecorder();
  //   } catch (e) {
  //     print(e);
  //   }
  // }

  // Future record() async {
  //   await recorder.startRecorder(toFile: 'audio');
  // }

  // Future stop() async {
  //   await recorder.stopRecorder();
  // }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragUpdate: (details) {
        setState(() {
          // Adjusting the height based on drag position
          _sheetHeight -=
              details.primaryDelta! / MediaQuery.of(context).size.height;
          if (_sheetHeight < 0.25) _sheetHeight = 0.25; // Minimum height
          if (_sheetHeight > 1.0) _sheetHeight = 1.0; // Maximum height
        });
      },
      onVerticalDragEnd: (details) {
        if (details.primaryVelocity! > 0) {
          Navigator.pop(
              context); // Pop the modal bottom sheet if dragged downward
        }
      },
      child: FractionallySizedBox(
        heightFactor: _sheetHeight,
        child: Container(
          padding: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            color: Colors.grey.shade300,
          ),
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //  crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        height: 5,
                        width: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      const Text(
                        "Comments",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(
                        thickness: 2,
                      )
                    ],
                  ),
                  Expanded(
                    child: ListView.builder(
                        itemCount: 6,
                        itemBuilder: (context, index) {
                          return CommentTile();
                        }),
                  ),
                  const SizedBox(
                    height: 60,
                  ),
                  // Add more comments as needed
                ],
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: SizedBox(
                  height: 60,
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: TextFormField(
                            decoration: InputDecoration(
                              hintText: 'Add a comment...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.mic),
                                onPressed: () {
                                  _showDialogFromBottom(context);
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDialogFromBottom(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (BuildContext buildContext, Animation<double> animation,
          Animation<double> secondaryAnimation) {
        return Center(
          child: Material(
            type: MaterialType.transparency,
            child: ScaleTransition(
              scale: CurvedAnimation(
                parent: animation,
                curve: Curves.fastOutSlowIn,
              ),
              child: const Box(),
            ),
          ),
        );
      },
    );
  }
}
