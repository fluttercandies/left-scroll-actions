
## 2.3.0

1. Fix error whitch AnimationController use after dispose.
2. Add LeftScrollController API for edit row status.
3. Add LSTag class for shorter name of LeftScrollCloseTag.

## 2.2.0

1. Fix close with animation api.

## 2.1.2

1. Fix some gesture issue in Android.

## 2.1.1

1. Fix WidgetsBinding.instance warning in Flutter 3.0 .

## 2.1.0

1. Rename LeftScrollGlobalListener to GlobalLeftScroll.
2. Now can use GlobalLeftScroll.instance.removeRowWithAnimation to remove row with aniamtion.

## 2.0.1

1. Now closeOnPop value is default set to false when running on iOS platform to retain the left-scroll-back gesture.

## 2.0.0-nullsafety.0 

1. Add nullsafety support.
2. Remove LeftScrollList(deprecated).
## 1.5.3 Improve bounce style.

1. Change default k to 0.8.
2. Avaliable hot reload when adding bounce style.
  
## 1.5.2 Add Bounce Style

1. Fix other row close timing.Now other row will close when you start open target row.

## 1.5.1 Add Bounce Style

1. Fix bug of throw error when use opacity and bounce same time.
2. Fix BounceStyle builder function.

## 1.5.0 Add Bounce Style

1. Add `bounce` argument to class CupertinoLeftScroll to enable bounce style.
2. Use `bounceStyle` argument to control bounce style.

## 1.4.4 Fix bug

1. Fix `LeftScroll` can't open without `onScroll` argument.

## 1.4.3 Fix bug

1. Fix use `LeftScrollGlobalListener.instance.targetStatus(tag, key)=true;` fail at first time.

## 1.4.2 Fix bug, update readme

1. Fix bug.

## 1.4.0 Add CupertinoLeftScroll  

1. Add `CupertinoLeftScroll` widget,buttons will expand with iOS style.  
2. To fetch this style, just simple replace `LeftScroll` with `CupertinoLeftScroll`.  
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
