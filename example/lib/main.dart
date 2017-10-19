import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterdux/flutterdux.dart';

void main() {
  runApp(new MyApp());
  FlutterDux.instance.loadUrl('https://run.plnkr.co/x6YJxqP8zHq8WG2t/');
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with FlutterDuxMixin{
  int _counter = 0;

  @override
  List<Property> get properties => [
    new Property(
      statePath: 'counter',
      onChanged: (v) => _counter = v,
      value: _counter,
    )
  ];

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Text(
              'You have pushed the button this many times:',
            ),
            new Text(
              '$_counter',
              style: Theme.of(context).textTheme.display1,
            ),
          ],
        ),
      ),
      floatingActionButton: new FloatingActionButton(
        //onPressed: () => dispatch('addTodo', ['Take out the trash']),
        onPressed: () => dispatch({'type': 'INCREMENT'}),
        tooltip: 'Increment',
        child: new Icon(Icons.add),
      ),
    );
  }
}


