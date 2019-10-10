import 'dart:math';

import 'package:flutter/material.dart';
import 'package:left_scroll_actions/left_scroll_actions.dart';

class ListPage extends StatefulWidget {
  @override
  _ListPageState createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
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
      body: ListView(
        children: list
            .map<Widget>(
              (id) => LeftScroll(
                closeOnPop: false,
                key: Key(id), // Note:Important,Must add key;
                buttonWidth: 80,
                child: Container(
                  height: 60,
                  padding: EdgeInsets.only(left: 20),
                  color: Colors.white,
                  alignment: Alignment.centerLeft,
                  child: Text('($id)Scroll Left To Delete'),
                ),
                buttons: <Widget>[
                  LeftScrollItem(
                    text: 'delete',
                    color: Colors.red,
                    onTap: () {
                      print('delete');
                      if (list.contains(id)) {
                        list.remove(id);
                        setState(() {});
                      }
                    },
                  ),
                ],
                onTap: () {
                  print('tap row');
                  list.add((Random().nextDouble() * 10000000 ~/ 1).toString());
                  setState(() {});
                },
              ),
            )
            .toList(),
      ),
    );
  }
}
