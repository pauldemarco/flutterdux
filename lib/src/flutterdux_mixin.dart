part of flutterdux;

class Property<T> {
  Property(
      {@required this.statePath, // String | function (state) => ();
      @required this.onChanged,
      this.value, // default value for the property
      });

  final dynamic statePath;
  ValueChanged<T> onChanged;
  T value;
}

abstract class FlutterDuxMixin extends State {
  List<Property> get properties;

  StreamSubscription stateSub;

  @override
  void initState() {
    super.initState();
    FlutterDux.instance.stateChanges.listen((state) {
      _update(state);
    });
    _update(FlutterDux.instance.state);
  }

  @override
  void dispose() {
    stateSub?.cancel();
    stateSub = null;
    super.dispose();
  }

  dispatch(dynamic action, [List args]) {
    FlutterDux.instance.dispatch(action, args);
  }

  _update(state) {
    var propertiesChanged = false;
    properties.forEach((p) {
      final statePath = p.statePath;
      final value =
          statePath is Function ? statePath(state) : Path.get(state, statePath);
      final changed = _setProperty(p, value);
      propertiesChanged = propertiesChanged || changed;
    });
    if (propertiesChanged) {
      setState(() {});
    }
  }

  _setProperty(Property p, value) {
    var changed = p.value != value;
    p.value = value;
    if (changed) {
      p.onChanged(p.value);
    }
    return changed;
  }

  Map<String, dynamic> getState() {
    return FlutterDux.instance.state;
  }
}
