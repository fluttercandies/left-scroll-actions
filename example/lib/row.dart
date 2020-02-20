import 'package:example/tapped.dart';
import 'package:flutter/material.dart';
import 'package:left_scroll_actions/left_scroll_actions.dart';

// 如果Row的背景必须是透明颜色的，就要做处理了：
class ExampleRow extends StatefulWidget {
  final Function onTap;
  final Function onEdit;
  final Function onDelete;

  const ExampleRow({
    Key key,
    this.onTap,
    this.onDelete,
    this.onEdit,
  }) : super(key: key);

  @override
  _ExampleRowState createState() => _ExampleRowState();
}

class _ExampleRowState extends State<ExampleRow> {
  double opa = 0;
  @override
  Widget build(BuildContext context) {
    Widget myDeviceStatus = Icon(Icons.supervised_user_circle);
    Widget body = Container(
      padding: EdgeInsets.fromLTRB(12, 0, 0, 0),
      height: 92,
      width: double.infinity,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Container(
              height: 66,
              width: 66,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(33),
              ),
              child: Placeholder(),
            ),
          ),
          Container(
            width: 44,
            height: double.infinity,
            child: Opacity(
              opacity: 1 - opa,
              child: Center(
                child: myDeviceStatus,
              ),
            ),
          )
        ],
      ),
    );

    List<Widget> actions = [
      Opacity(
        opacity: opa,
        child: Tapped(
          child: Container(
            color: Colors.white.withOpacity(0),
            alignment: Alignment.center,
            padding: EdgeInsets.all(20),
            child: Icon(Icons.delete, color: Colors.red),
          ),
          onTap: widget.onDelete,
        ),
      ),
      Opacity(
        opacity: opa,
        child: Tapped(
          child: Container(
            color: Colors.white.withOpacity(0),
            alignment: Alignment.center,
            padding: EdgeInsets.all(20),
            child: Icon(Icons.edit, color: Colors.blue),
          ),
          onTap: widget.onDelete,
        ),
      ),
    ];

    body = LeftScroll(
      child: body,
      buttonWidth: 70,
      buttons: actions,
      onTap: widget.onTap,
      onScroll: (a) {
        opa = a;
        setState(() {});
        print(a);
      },
      onSlideStarted: () {
        setState(() {});
      },
      onSlideCompleted: () {
        opa = 1;
        setState(() {});
      },
      onSlideCanceled: () {
        opa = 0;
        setState(() {});
      },
    );

    return body;
  }
}

class OVText {
  // 偏大文字
  static Widget main(title,
      {double fontsize, Color color, TextAlign align: TextAlign.left}) {
    return Text(
      title,
      maxLines: 1,
      textAlign: align,
      style: TextStyle(
        decoration: TextDecoration.combine([]),
        textBaseline: TextBaseline.alphabetic,
        fontSize: fontsize ?? 20,
        fontWeight: FontWeight.normal,
        // color: color ?? Colors.white,
      ),
    );
  }

  //  正文
  static Widget normal(title,
      {double fontsize: 14, Color color, TextAlign align: TextAlign.left}) {
    return Text(
      title,
      textAlign: align,
      style: TextStyle(
        fontSize: fontsize,
        decoration: TextDecoration.combine([]),
        // color: color ?? Colors.white,
      ),
    );
  }

  // 小提示文字
  static Widget small(title,
      {double fontsize: 12, TextAlign align: TextAlign.left}) {
    return Opacity(
      opacity: 0.8,
      child: Text(
        title,
        maxLines: 1,
        textAlign: align,
        style: TextStyle(
          fontSize: fontsize,
          decoration: TextDecoration.combine([]),
          // color: Colors.white,
        ),
      ),
    );
  }
}
