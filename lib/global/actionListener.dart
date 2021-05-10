import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class LeftScrollGlobalListener {
  // 工厂模式
  factory LeftScrollGlobalListener() => _getInstance()!;
  static LeftScrollGlobalListener? get instance => _getInstance();
  static LeftScrollGlobalListener? _instance;
  LeftScrollGlobalListener._internal() {
    // 初始化
  }
  static LeftScrollGlobalListener? _getInstance() {
    if (_instance == null) {
      _instance = new LeftScrollGlobalListener._internal();
    }
    return _instance;
  }

  Map<LeftScrollCloseTag?, Map<Key?, LeftScrollStatus>> map = {};

  bool removeListener(LeftScrollCloseTag tag) {
    if (map[tag] != null) {
      map.remove(tag);
      return true;
    }
    return false;
  }

  LeftScrollStatus? targetStatus(LeftScrollCloseTag tag, Key key) =>
      map[tag]![key];

  // 需要关闭同Tag的Row
  needCloseOtherRowOfTag(LeftScrollCloseTag? tag, Key? key) {
    if (tag == null) {
      return;
    }
    if (map[tag] == null) {
      return;
    }
    for (var otherKey in map[tag]!.keys) {
      if (otherKey == key) {
        continue;
      }
      if (map[tag]![otherKey]!.value == true) {
        map[tag]![otherKey]!.value = false;
      }
    }
  }
}

class LeftScrollCloseTag {
  final String tag;
  LeftScrollCloseTag(this.tag);

  @override
  int get hashCode => tag.hashCode;

  operator ==(dynamic other) {
    if (other is LeftScrollCloseTag) {
      if (other.tag == tag) {
        return true;
      }
    }
    return false;
  }
}

/// 左滑的状态
class LeftScrollStatus extends ValueNotifier<bool> {
  LeftScrollStatus() : super(false);
  bool get isClose => value;
  bool get isOpen => !value;
}


