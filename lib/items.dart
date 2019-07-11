import 'package:flutter/material.dart';

class Item {
  String name;
  MaterialColor color;
  IconData icon;
  Item(this.name, this.color, this.icon);
}

List<Item> items = [
  Item('壹', Colors.amber, Icons.adjust),
  Item('贰', Colors.cyan, Icons.airport_shuttle),
  Item('叁', Colors.indigo, Icons.android),
  Item('肆', Colors.green, Icons.beach_access),
  Item('伍', Colors.pink, Icons.attach_file),
  Item('陸', Colors.blue, Icons.bug_report)
];
