import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:left_scroll_actions/global/actionListener.dart';

class CupertinoLeftScroll extends StatefulWidget {
  final Key key;
  final Widget child;
  final LeftScrollCloseTag closeTag;
  final bool closeOnPop;
  final bool opacityChange;
  final VoidCallback onTap;
  final double buttonWidth;
  final List<Widget> buttons;

  CupertinoLeftScroll({
    this.key,
    @required this.child,
    @required this.buttons,
    this.closeTag,
    this.onTap,
    this.buttonWidth: 80.0,
    this.closeOnPop: true,
    this.opacityChange,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return CupertinoLeftScrollState();
  }
}

class CupertinoLeftScrollState extends State<CupertinoLeftScroll>
    with TickerProviderStateMixin {
  double translateX = 0;

  double get maxDragDistance => widget.buttonWidth * widget.buttons.length;
  double get progress => translateX / maxDragDistance * -1;

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
  void initState() {
    super.initState();
    setCloseListener();
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
  void didUpdateWidget(CupertinoLeftScroll oldWidget) {
    if (oldWidget.buttons.length != widget.buttons.length) {
      translateX = 0;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    Widget body = Stack(
      alignment: Alignment.centerRight,
      children: <Widget>[
        Positioned.fill(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Container(
                width: widget.buttonWidth * widget.buttons.length,
                child: _WxStyleButtonGroup(
                  opaChange: widget.opacityChange,
                  buttonWidth: widget.buttonWidth,
                  progress: progress,
                  children: widget.buttons ?? [],
                ),
              ),
            ],
          ),
        ),
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

  void onHorizontalDragDown(DragDownDetails details) {}

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
      animationController.animateTo(-maxDragDistance);
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
      animationController.animateTo(0);
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

class _WxStyleButtonGroup extends StatelessWidget {
  final List<Widget> children;
  final bool opaChange;
  final double buttonWidth;
  final double progress;

  double get offset => buttonWidth * progress;

  const _WxStyleButtonGroup({
    Key key,
    this.children,
    this.buttonWidth: 0,
    this.progress: 0,
    this.opaChange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> l = [];
    for (var i = 0; i < children.length; i++) {
      Widget btn = Padding(
        padding: EdgeInsets.only(
          right: offset * (i + 1),
        ),
        child: Container(
          width: buttonWidth,
          child: children[i],
        ),
      );
      if (opaChange == true) {
        btn = Opacity(
          opacity: progress,
          child: btn,
        );
      }
      l.add(btn);
    }
    return OverflowBox(
      alignment: Alignment.centerLeft,
      minWidth: buttonWidth * (children.length + 1),
      maxWidth: buttonWidth * (children.length + 1),
      child: Container(
        child: Stack(
          alignment: Alignment.centerRight,
          children: l.reversed.toList(),
        ),
      ),
    );
  }
}
