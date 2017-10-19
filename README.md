# FlutterDux

Flutter + Redux.js

Android only at the moment, iOS coming soon.

## Getting Started

Check out [this article](https://medium.com/@paulmdemarco/flutterdux-flutter-redux-js-3d1b5a6c33cb) for a description of how it works.

### Loading website

```dart
void main() {
  runApp(new MyApp());
  FlutterDux.instance.loadUrl('<YOUR WEBSITE RUNNING REDUX>');
}
```

### Binding widgets

```dart
class _MyWidgetState extends State<MyWidget> with FlutterDuxMixin{
  int _counter = 0;

  @override
  List<Property> get properties => [
    new Property(
      statePath: 'counter',
      onChanged: (v) => _counter = v
    )
  ];

  /// The widget's `setState` will be called automatically
  /// when state slice `counter` changes.
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Text('$_counter'),
      floatingActionButton: new FloatingActionButton(
        onPressed: () => dispatch({'type': 'INCREMENT'}),
        child: new Icon(Icons.add),
      ),
    );
  }
}
 ```

### Dispatching actions

```dart
/// Raw action
dispatch({'type': 'INCREMENT'});

/// Action creator
dispatch('incrementCounter');

/// Action creator with arguments
dispatch('addTodo', ['Take out the trash']);
 ```

