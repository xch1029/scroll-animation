import 'package:flutter/material.dart';

class AnimatedBackground extends StatefulWidget {
  AnimatedBackground({Key key, this.controller}) : super(key: key);

  final ScrollController controller;

  @override
  _AnimatedBackgroundState createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground> {
  get offset => widget.controller.hasClients ? widget.controller.offset : 0;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (BuildContext context, Widget child) {
        return OverflowBox(
          maxWidth: double.infinity,
          alignment: Alignment(4, 3),
          child: Transform.rotate(
            angle: offset / -512,
            child: Icon(Icons.settings, size: 512, color: Colors.white),
          ),
        );
      },
    );
  }
}
