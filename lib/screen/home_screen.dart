import 'package:audiorecord/screen/comment_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Comment'),
      ),
      body: SafeArea(
        child: Center(
          child: GestureDetector(
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (BuildContext context) {
                  return CommentScreen();
                },
              );
            },
            child: Container(
              width: 200,
              height: 200,
              color: Colors.grey,
              child: const Icon(
                Icons.comment,
                size: 100,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
