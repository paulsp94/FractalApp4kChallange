import 'dart:ui' as ui;
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
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
  var _img;

  Map<Offset, Color> getJuliaPoints(w, h, z) {
    Map<Offset, Color> points = Map();
    var cX = -0.7;
    var cY = 0.27015;
    var moveX = 0.0;
    var moveY = 0.0;
    var maxIter = 255;

    for (int x = 0; x < w; x++) {
      for (int y = 0; y < h; y++) {
        var zx = 1.5 * (x - w / 2) / (0.5 * z * w) + moveX;
        var zy = 1.0 * (y - h / 2) / (0.5 * z * h) + moveY;
        var i = maxIter;
        while (zx * zx + zy * zy < 4 && i > 1) {
          var tmp = zx * zx - zy * zy + cX;
          zy = 2.0 * zx * zy + cY;
          zx = tmp;
          i -= 1;
        }
        int colorInt = (i << 21) + (i << 10) + i * 8;
        points.addAll({
          Offset(x.toDouble(), y.toDouble()): Color(colorInt).withAlpha(255)
        });
      }
    }

    return points;
  }

  @override
  Widget build(BuildContext context) {
    var widget = _img != null ? Image.memory(_img) : Text('place click button');
    return Scaffold(
      appBar: AppBar(),
      body: Center(child: widget),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var width = MediaQuery.of(context).size.width.ceil();
          var height = MediaQuery.of(context).size.height.ceil();

          var pictureRecorder = ui.PictureRecorder();
          var canvas = Canvas(pictureRecorder);
          // drawJulia(canvas, 200, 200, 1);
          var paint = Paint();
          paint.isAntiAlias = true;
          Map<Offset, Color> points = getJuliaPoints(width, height, 1);
          points.forEach((p, c) =>
              canvas.drawPoints(ui.PointMode.points, [p], Paint()..color = c));

          // canvas.drawLine(Offset.zero, Offset(100, 100), paint);
          var pic = pictureRecorder.endRecording();
          ui.Image img = pic.toImage(width, height);
          var byteData = await img.toByteData(format: ui.ImageByteFormat.png);
          var buffer = byteData.buffer.asUint8List();
          setState(() {
            _img = buffer;
          });
        },
        tooltip: 'Draw image',
        child: Icon(Icons.add),
      ),
    );
  }
}
