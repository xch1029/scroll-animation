## Flutter滚动动画

> 现在的Flutter正是如火中天，昨天Google官方正式发布了`Flutter1.7`版本，主要包含了对Android X的支持和Play Store的一些更新，一些新的和增强的组件，以及一些问题的修复。

本篇文章我们一起开发一个炫炫的列表展示，伴随着滚动，背景做一些相应的动画效果。先看下效果图:

![](http://pt2k23f08.bkt.clouddn.com/blogscreenanimation1.gif)

![](https://user-images.githubusercontent.com/8186664/44953195-581e3d80-aec4-11e8-8dcb-54b9db38ec11.png)

<img src="http://pt2k23f08.bkt.clouddn.com/blogscreenanimation1.gif" />

### 思路
列表滚动的时候，获取垂直方向的滚动距离，再将这个值转化成角度单位带动齿轮的滚动

### 入口文件
Flutter的项目都是从`lib/main.dart`开始：

``` dart
import 'package:flutter/material.dart';
import 'demo-card.dart';
import 'items.dart';
import 'animated-bg.dart';

void main() => runApp(AnimationDemo());

class AnimationDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MyHomePage(title: '列表滚动'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ScrollController _controller = new ScrollController();

  List<DemoCard> get _cards =>
      items.map((Item _item) => DemoCard(_item)).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: Text(widget.title)),
      body: Stack(
        alignment: AlignmentDirectional.topStart,
        children: <Widget>[
          AnimatedBackground(controller: _controller),
          Center(
            child: ListView(controller: _controller, children: _cards),
          )
        ],
      ),
    );
  }
}

```
在`main.dart`文件中，有几个import进来的文件：
- `demo-card.dart` 卡片widget，列表就是循环的这个widget
- `items.dart` 卡片展示的数据放在这个文件中，本项目我们写了点mock数据，真实生产项目的数据更多是从http请求
- `animated-bg.dart` 背景齿轮的widget


这个文件主要使用了一些Flutter的基础widget，有不清楚的同学可以去官网查下使用方法，
另外，列表渲染的时候需要注意下，我们会使用`ScrollController _controller = new ScrollController();`从而获取垂直方向滚动的距离

### 卡片的mock数据
为了省事，我们直接将数据放在`lib/items.dart`里，我们模拟了六条数据，main.dart里的listView的children就是使用这六条数据生成的:

``` dart
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

```
三个字段：
- name 卡片左边的名字
- color 卡片的背景颜色
- icon 卡片右边的图标

### 卡片Widget
我们在`main.dart`里这么生成列表的children：`items.map((Item _item) => DemoCard(_item)).toList();`对DemoCard传入参数_item，其实就是React或者Vue里面的props。不同之处在于，flutter传入的参数既可以是匿名的也可以是具名的，这里我们用的是匿名传参。看下卡片Widget怎么接收参数：
``` dart
import 'package:flutter/material.dart';
import 'items.dart';

class DemoCard extends StatelessWidget {
  DemoCard(this.item);
  final Item item;

  static final Shadow _shadow =
      Shadow(offset: Offset(2.0, 2.0), color: Colors.black26);
  final TextStyle _style = TextStyle(color: Colors.white70, shadows: [_shadow]);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        side: BorderSide(width: 1, color: Colors.black26),
        borderRadius: BorderRadius.circular(32),
      ),
      color: item.color.withOpacity(.7),
      child: Container(
        constraints: BoxConstraints.expand(height: 256),
        child: RawMaterialButton(
          onPressed: () {},
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Text(item.name, style: _style.copyWith(fontSize: 64)),
                  Icon(item.icon, color: Colors.white70, size: 72),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

```
定义了一个StatelessWidget，对应React或者Vue就是无状态组件，接收参数的方式是在构造器上声明，这种方式和ES6一致：
```
DemoCard(this.item);
final Item item;
```
使用Card组件可以快速的还原一张卡片样式
- `elevation`参数控制卡片悬浮高度
- `shape`参数控制卡片圆角
- `color`参数控制卡片背景，`item.color.withOpacity(.7)`让背景透明化30%

然后就是使用Column和Row来控制布局的展示

### 背景齿轮的转动
先看下背景组件的源码，再一一解释：
``` dart
import 'package:flutter/material.dart';

class AnimatedBackground extends StatefulWidget {
  AnimatedBackground({Key key, this.controller}) : super(key: key);

  final ScrollController controller;

  @override
  _AnimatedBackgroundState createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground> {
  get offset => widget.controller.hasClients ? widget.controller.offset : 0;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (BuildContext context, Widget child) {
        return OverflowBox(
          maxWidth: double.infinity,
          alignment: Alignment(4, 3),
          child: Transform.rotate(
            angle: offset / -512,
            child: Icon(Icons.settings, size: 512, color: Colors.white),
          ),
        );
      },
    );
  }
}

```
这个`controller`是在main.dart里传下来的，它是ListView的controller，我们用`widget.controller.offset`即可拿到垂直方向上的滚动距离。
列表滚动时我们要不停的刷新齿轮的转动角度，所以我们选用`AnimatedBuilder`组件，组件有两个重要参数:
- animation 将widget.controller传给animation
- builder 每次animation改变时，都会重新执行渲染，这就实现了联动效果

OverflowBox组件可以通过alignment(锚点)很好的控制子组件的显示位置，这里我们使用`Alignment(4, 3)`将齿轮定位到屏幕左下方。
让齿轮真正动起来的是`Transform.rotate`组件，这里有个弧长公式要用到：L=α（弧度）× r(半径)，所以我们这么使用:`angle: offset / -512`
- 为什么是512呢，因为我们的齿轮的`size: 512`
- 为什么带有负号呢，这样我们就能实现列表向上滚动时齿轮逆时针转动，列表向下滚动时齿轮顺时针滚动

### 用到的Widget
篇幅有限，不能一一展开讲解使用到的组件，有问题的同学自行去官网查看用法哦
- MaterialApp
- Scaffold
- AppBar
- Stack
- Center
- ListView
- Card
- RawMaterialButton
- Column
- Row
- AnimatedBuilder
- OverflowBox
- Transform
- Icon

### 相关链接
本篇文章能学到Flutter很多知识，包括：StatelessWidget/StatefulWidget的创建、本地数据的创建和使用、列表的展示和控制、垂直水平布局等等，想看效果的同学可以直接跑源码哦
- [源码地址](https://github.com/xch1029/scroll-animation)
- [博客本文地址](https://jser.tech/2019/07/11/flutter-scroll-animation)
- [掘金本文地址](https://juejin.im/post/5d26e4fff265da1b7c614326)

