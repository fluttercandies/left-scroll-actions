import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:left_scroll_actions/left_scroll_actions.dart';

class ClosableListPage extends StatefulWidget {
  const ClosableListPage({
    Key? key,
  }) : super(key: key);
  @override
  _ClosableListPageState createState() => _ClosableListPageState();
}

class _ClosableListPageState extends State<ClosableListPage> {
  List<String> list = [
    '123456',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Use In List'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              list.add((Random().nextDouble() * 10000000 ~/ 1).toString());
              setState(() {});
            },
          )
        ],
      ),
    );
  }
}
