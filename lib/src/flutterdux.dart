part of flutterdux;

class FlutterDux {
  final MethodChannel _channel = const MethodChannel('flutterdux');

  FlutterDux._() {
    _channel.setMethodCallHandler((MethodCall call) {
      if (call.method == 'State') {
        final state = JSON.decode(call.arguments);
        print('New state received from JS: $state');
        _stateChanges.add(state);
        this.state = state;
      } else if( call.method == 'onPageFinished') {
        _subscribe();
      }
    });
  }

  static FlutterDux _instance = new FlutterDux._();
  static FlutterDux get instance => _instance;

  static final StreamController _stateChanges =
      new StreamController.broadcast();
  Stream<Map<String, dynamic>> get stateChanges => _stateChanges.stream;

  Map<String, dynamic> state = new Map();

  String basePath;
  String storeVar;

  Future<String> loadUrl(String url, {String basePath, String storeVar = 'store'}) {
    this.basePath = basePath;
    this.storeVar = storeVar;
    return _channel
        .invokeMethod('loadUrl', url);
  }

  Future _evalJavascript(String js) {
    print(js);
    return _channel.invokeMethod('evaluateJavascript', js);
  }

  /// #dispatch(<name>, [args, ...]) -  name String, action name in the actions list. arg... *, Arguments to pass to action function.
  /// #dispatch(<fn>) - fn Function, Redux middleware dispatch function.
  /// #dispatch(<action>) - action Map, the action map.
  void dispatch(dynamic action, [List args]) {
    var encoded;
    if (action is String) {
      final arguments = args.map((a) => JSON.encode(a)).join(',');
      encoded = '${_baseRef(action)}($arguments)';
    } else {
      encoded = JSON.encode(action);
    }
    final js = '${_baseRef(storeVar)}.dispatch(eval($encoded))';
    _evalJavascript(js);
  }

  void _subscribe() {
    _evalJavascript('${_baseRef(storeVar)}.subscribe(() => Mobile.sendState(JSON.stringify(${_baseRef(storeVar)}.getState())));');
    _evalJavascript('Mobile.sendState(JSON.stringify(${_baseRef(storeVar)}.getState()))');
  }

  String _baseRef(variable) {
    return (basePath != null) ? '$basePath.$variable' : variable;
  }
}
