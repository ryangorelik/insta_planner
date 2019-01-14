import 'package:flutter/material.dart';
import 'dart:collection';

void main() => runApp(new MyApp());

class ImageData extends InheritedWidget {
  final HashMap<int, DragImage> images;
  ImageData({this.images, Widget child}) : super(child:child);
  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;
  static ImageData of(BuildContext context) => context.inheritFromWidgetOfExactType(ImageData);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ImageData(
      images: new HashMap<int, DragImage>(),
      child: new MaterialApp(
          title: 'InstaPlanner',
          theme: new ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: new MyHomePage(title: 'Flutter Demo Home Page'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static bool equals(int k1, int k2) {
    return (k1==k2);
  }
  static int hash(int k) {
    return k;
  }

  List<int> selected = new List<int>();
  ImageData data;
  HashMap<int, DragImage> images;
  List<ImageTarget> toGrid = new List<ImageTarget>();

  @override
  void didChangeDependencies() {
    print("***didChangeDependencies***");
    super.didChangeDependencies();
    data = ImageData.of(context);
    images = data.images;
    for (int i = 25; i >= 1; i--) {
      String file = 'assets/' + i.toString() + '.jpg';
      images.putIfAbsent(i, () => DragImage(ImageTile(file, i, _remove, _select)));
      toGrid.add(ImageTarget(images[i]));
    }
  }
  void _remove(int num) {
    print("removing: $num");
    setState(() {
      images.remove(num);
    });
  }
  void _swap() {
    if (selected.length == 2) {
      int s1 = selected[0];
      int s2 = selected[1];
      print("Swapping: $s1 and $s2");
      setState(() {
        selected.clear();
        int i1 = toGrid.indexWhere((i) => i.image.image.num == s1);
        int i2 = toGrid.indexWhere((i) => i.image.image.num == s2);
        ImageTarget oldi1 = toGrid[i1];
        ImageTarget oldi2 = toGrid[i2];

        toGrid.removeAt(i1);
        toGrid.insert(i1, oldi2);
        toGrid.removeAt(i2);
        toGrid.insert(i2, oldi1);
      });
    }
  }
  void _select(int num) {
    for (int i in selected) {
      if (i==num) {
        selected.remove(num);
      }
    }
    if (selected.length == 2) {
      return;
    }
    selected.add(num);
    print("selected: $num");
  }
  @override
  Widget build(BuildContext context) {
    print("BUILDING");
    List<ImageTarget> newGrid = new List<ImageTarget>();
    for (int i = 0; i<toGrid.length; i++) {
      print(toGrid[i].image.image.file);
      newGrid.add(toGrid[i]);
    }
    print(newGrid[0].image.image.file);
    return new Scaffold(
      appBar: new AppBar(
        title: Row(children: <Widget>[Text('assets/' + 5.toString() + '.jpg'), Text(images.length.toString())]),
      ),
      body: GridView.count(crossAxisCount: 3, children: newGrid,),
      floatingActionButton: new FloatingActionButton(
        onPressed: _swap,
        tooltip: 'Swap',
        child: new Icon(Icons.swap_horizontal_circle),
      ),
    );
  }
}

class ImageTarget extends StatefulWidget {
  DragImage image;
  ImageTarget(this.image);
  @override
  _TargetState createState() => new _TargetState(image);
}
class _TargetState extends State<ImageTarget> {
  DragImage image;
  int val;
  _TargetState(this.image);

  void update(DragImage i) {
    setState(() {
      image = i;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      child: DragTarget<int>(
        builder: (context, List<int> candidateData, rejectedData) {
          return image;
        },
        onWillAccept: (data) {
          print("deciding...");
          return true;
        },
        onAccept: (data) {
          setState(() {
            val = data;
            print(val);
            print(image.image.num);
            image = ImageData.of(context).images[val];
          });
          print("accepted!!!");
        },
      ),
    );
  }
}

class DragImage extends StatelessWidget{
  final ImageTile image;
  DragImage(this.image);

  @override
  Widget build(BuildContext context) {
    return Draggable<int>(
      child: image,
      feedback: Text("MOVING"),
      childWhenDragging: Container(color: Colors.yellowAccent),
      data: image.num,
      maxSimultaneousDrags: 1,
    );
  }
}
class ImageTile extends StatelessWidget{
  final String file;
  final int num;
  final Function _remove;
  final Function _select;
  ImageTile(this.file, this.num, this._remove, this._select);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        _select(num);
      },
      child: Container(
          padding: EdgeInsets.all(1.5),
          child: Stack(children: <Widget>[Image.asset(file, width: 200.0, height:200.0), Text(num.toString(), style: new TextStyle(fontSize: 60.0, color: Colors.white),)]),
      ),
    );
  }
}
