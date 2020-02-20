import 'package:example/list.dart';
import 'package:example/row.dart';
import 'package:example/scrollList.dart';
import 'package:flutter/material.dart';
import 'package:left_scroll_actions/cupertinoLeftScroll.dart';
import 'package:left_scroll_actions/left_scroll_actions.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Left Scroll Actions'),
        ),
        backgroundColor: Color(0xFFf5f5f4),
        body: ListView(
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(12),
              child: MaterialButton(
                color: Colors.blue,
                child: Text(
                  'ListView Usage Demo',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ListPage(),
                  ));
                },
              ),
            ),
            // Container(
            //   padding: EdgeInsets.all(12),
            //   child: MaterialButton(
            //     color: Colors.blue,
            //     child: Text(
            //       'ClosableListView Usage Demo',
            //       style: TextStyle(color: Colors.white),
            //     ),
            //     onPressed: () {
            //       Navigator.of(context).push(MaterialPageRoute(
            //         builder: (context) => ClosableListPage(),
            //       ));
            //     },
            //   ),
            // ),
            Container(height: 50),
            Container(
              padding: EdgeInsets.only(top: 12, left: 8, bottom: 8),
              child: Text('These widget can scroll to actions.'),
            ),
            LeftScroll(
              buttonWidth: 80,
              child: Container(
                height: 60,
                color: Colors.white,
                alignment: Alignment.center,
                child: Text('👈 Try Scroll Left'),
              ),
              buttons: <Widget>[
                LeftScrollItem(
                  text: 'delete',
                  color: Colors.red,
                  onTap: () {
                    print('delete');
                  },
                ),
                LeftScrollItem(
                  text: 'Edit',
                  color: Colors.orange,
                  onTap: () {
                    print('edit');
                  },
                ),
              ],
              onTap: () {
                print('tap row');
              },
            ),

            LeftScroll(
              child: Container(
                height: 60,
                color: Colors.white.withOpacity(0.8),
                alignment: Alignment.center,
                child: Text('If opacity is not 1.0,may cause problem.'),
              ),
              buttons: <Widget>[
                LeftScrollItem(
                  text: 'delete',
                  color: Colors.red,
                ),
                LeftScrollItem(
                  text: 'Edit',
                  color: Colors.orange,
                ),
              ],
            ),
            Container(
              padding: EdgeInsets.only(top: 12, left: 8, bottom: 8),
              child: Text('CupertinoLeftScrollRow'),
            ),
            CupertinoLeftScroll(
              buttonWidth: 80,
              child: Container(
                height: 60,
                color: Colors.white,
                alignment: Alignment.center,
                child: Text('👈 Try Scroll Left(iOS style)'),
              ),
              buttons: <Widget>[
                LeftScrollItem(
                  text: 'delete',
                  color: Colors.red,
                  onTap: () {
                    print('delete');
                  },
                ),
                LeftScrollItem(
                  text: 'Edit',
                  color: Colors.orange,
                  onTap: () {
                    print('edit');
                  },
                ),
              ],
              onTap: () {
                print('tap row');
              },
            ),
            CupertinoLeftScroll(
              opacityChange: true,
              buttonWidth: 80,
              child: Container(
                height: 60,
                color: Colors.white,
                alignment: Alignment.center,
                child: Text('👈 Try iOS style with opa change'),
              ),
              buttons: <Widget>[
                LeftScrollItem(
                  text: 'delete',
                  textColor: Colors.red,
                  color: Colors.red.withOpacity(0),
                  onTap: () {
                    print('delete');
                  },
                ),
                LeftScrollItem(
                  text: 'Edit',
                  textColor: Colors.orange,
                  color: Colors.orange.withOpacity(0),
                  onTap: () {
                    print('edit');
                  },
                ),
              ],
              onTap: () {
                print('tap row');
              },
            ),
            Container(height: 50),
            Container(
              padding: EdgeInsets.only(top: 12, left: 8, bottom: 8),
              child:
                  Text('You can build widget like this if opacity is not 1.0.'),
            ),
            ExampleRow(
              onDelete: () {
                print('delete');
              },
              onTap: () {
                print('tap');
              },
              onEdit: () {
                print('edit');
              },
            ),
          ],
        ));
  }
}
