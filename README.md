# FlutterDux

Flutter + Redux.js

## Getting Started

Check out this article for a description of how it works.

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

The widget's `setState` will be called automatically when state slice `counter` changes.

### Dispatching actions

```dart
/// Raw action
dispatch({'type': 'INCREMENT'});

/// Action creator
dispatch('incrementCounter');

/// Action creator with arguments
dispatch('addTodo', ['Take out the trash']);
 ```
