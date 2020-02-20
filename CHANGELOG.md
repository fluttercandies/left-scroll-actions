
## 1.4.0 Add CupertinoLeftScroll  

1. Add `CupertinoLeftScroll` widget,buttons will expand with iOS style.  
2. To fetch this style, just simple replace `LeftScroll` to `CupertinoLeftScroll`.  
3. Update example, remove deprecated demo.  

## 1.3.0 Add LeftScrollCloseTag,deprecated old list  

1. If you add same `LeftScrollCloseTag` tag to LeftScroll widget, widget will autoclose when other widget with same tag open;  
2. If you want close target row,just use such code:  
```dart
// 找到对应tag与key的row状态，改变状态即可
LeftScrollGlobalListener.instance.targetStatus(tag,key) = false;
```

## [1.2.1] - Fix bug.

Fix demo bug.
## [1.2.0] - Add LeftScrollList.

Add LeftScrollList,if you open a row in LeftScrollList, other row will auto close.

## [1.1.0] - Fix bug, Improve demo.

Add paramater to control pop event.
Add usage in listview on demo.
Add textColor paramater with LeftScrollItem.
Now use key but not GlobalKey.

## [1.0.0] - Init.

- init
