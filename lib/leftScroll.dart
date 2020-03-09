import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:left_scroll_actions/global/actionListener.dart';

// 原始的组件
class LeftScroll extends StatefulWidget {
  final Key key;

  final LeftScrollCloseTag closeTag;

  final bool closeOnPop;
  final Widget child;

  final VoidCallback onTap;

  final double buttonWidth;
  final List<Widget> buttons;

  final Function(double) onScroll;

  final VoidCallback onSlideStarted;

  final VoidCallback onSlideCompleted;

  final VoidCallback onSlideCanceled;

  LeftScroll({
    this.key,
    @required this.child,
    @required this.buttons,
    this.closeTag,
    this.onSlideStarted,
    this.onSlideCompleted,
    this.onSlideCanceled,
    this.onTap,
    this.buttonWidth: 80.0,
    this.onScroll,
    this.closeOnPop: true,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return LeftScrollState();
  }
}

class LeftScrollState extends State<LeftScroll> with TickerProviderStateMixin {
  double _translateX = 0;

  double get translateX => _translateX;

  set translateX(double translateX) {
    widget.onScroll?.call(translateX / maxDragDistance * -1);
    _translateX = translateX;
  }

  double maxDragDistance;
  final Map<Type, GestureRecognizerFactory> gestures =
      <Type, GestureRecognizerFactory>{};

  AnimationController animationController;

  Map<LeftScrollCloseTag, Map<Key, LeftScrollStatus>> get globalMap =>
      LeftScrollGlobalListener.instance.map;

  LeftScrollStatus get _ct => globalMap[widget.closeTag][widget.key];

  setCloseListener() {
    if (widget.closeTag == null) return;
    if (globalMap[widget.closeTag] == null) {
      globalMap[widget.closeTag] = {};
    }
    var _controller = LeftScrollStatus();
    globalMap[widget.closeTag][widget.key] = _controller;
    globalMap[widget.closeTag][widget.key].addListener(handleChange);
  }

  handleChange() {
    if (globalMap[widget.closeTag][widget.key]?.value == true) {
      open();
    } else {
      close();
    }
  }

  @override
  void didUpdateWidget(LeftScroll oldWidget) {
    if (oldWidget.buttons.length != widget.buttons.length) {
      maxDragDistance = widget.buttonWidth * widget.buttons.length;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    super.initState();
    setCloseListener();
    maxDragDistance = widget.buttonWidth * widget.buttons.length;
    gestures[HorizontalDragGestureRecognizer] =
        GestureRecognizerFactoryWithHandlers<HorizontalDragGestureRecognizer>(
      () => HorizontalDragGestureRecognizer(debugOwner: this),
      (HorizontalDragGestureRecognizer instance) {
        instance
          ..onDown = onHorizontalDragDown
          ..onUpdate = onHorizontalDragUpdate
          ..onEnd = onHorizontalDragEnd;
      },
    );

    gestures[TapGestureRecognizer] =
        GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
      () => TapGestureRecognizer(debugOwner: this),
      (TapGestureRecognizer instance) {
        instance..onTap = widget.onTap;
      },
    );

    animationController = AnimationController(
        lowerBound: -maxDragDistance,
        upperBound: 0,
        vsync: this,
        duration: Duration(milliseconds: 300))
      ..addListener(() {
        translateX = animationController.value;
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    Widget body = Stack(
      children: <Widget>[
        Positioned.fill(
            child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: widget.buttons
              .map<Widget>((button) => Container(
                    child: button,
                    width: widget.buttonWidth,
                  ))
              .toList()
              .reversed
              .toList(),
        )),
        RawGestureDetector(
          gestures: gestures,
          child: Transform.translate(
            offset: Offset(translateX, 0),
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: widget.child,
                )
              ],
            ),
          ),
        )
      ],
    );
    return widget.closeOnPop
        ? WillPopScope(
            child: body,
            onWillPop: () async {
              if (translateX != 0) {
                close();
                return false;
              }
              return true;
            })
        : body;
  }

  void onHorizontalDragDown(DragDownDetails details) {
    if (widget.onSlideStarted != null) widget.onSlideStarted.call();
  }

  void onHorizontalDragUpdate(DragUpdateDetails details) {
    translateX = (translateX + details.delta.dx).clamp(-maxDragDistance, 0.0);

    setState(() {});
  }

  void onHorizontalDragEnd(DragEndDetails details) {
    animationController.value = translateX;
    if (details.velocity.pixelsPerSecond.dx > 200) {
      close();
    } else if (details.velocity.pixelsPerSecond.dx < -200) {
      open();
    } else {
      if (translateX.abs() > maxDragDistance / 2) {
        open();
      } else {
        close();
      }
    }
  }

  // 打开
  void open() {
    print('open');
    if (translateX != -maxDragDistance) {
      animationController.animateTo(-maxDragDistance).then((_) {
        if (widget.onSlideCompleted != null) widget.onSlideCompleted.call();
      });
    }
    if (widget.closeTag == null) return;
    if (_ct.value == false) {
      LeftScrollGlobalListener.instance
          .needCloseOtherRowOfTag(widget.closeTag, widget.key);
      _ct.value = true;
    }
  }

  // 关闭
  void close() {
    if (translateX != 0) {
      animationController.animateTo(0).then((_) {
        if (widget.onSlideCanceled != null) widget.onSlideCanceled.call();
      });
    }
    if (widget.closeTag == null) return;
    if (_ct.value == true) {
      _ct.value = false;
    }
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }
}

class LeftScrollItem extends StatelessWidget {
  final Function onTap;
  final String text;
  final Color textColor;
  final Color color;
  const LeftScrollItem({
    Key key,
    this.onTap,
    this.text,
    this.color,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        // width: 80,
        color: color,
        child: Text(
          text,
          style: TextStyle(
            color: textColor ?? Colors.white,
          ),
        ),
      ),
    );
  }
}
