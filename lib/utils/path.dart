part of flutterdux;

///
/// @license
/// Copyright (c) 2017 The Polymer Project Authors. All rights reserved.
/// This code may only be used under the BSD style license found at http://polymer.github.io/LICENSE.txt
/// The complete set of authors may be found at http://polymer.github.io/AUTHORS.txt
/// The complete set of contributors may be found at http://polymer.github.io/CONTRIBUTORS.txt
/// Code distributed by Google as part of the polymer project is also
/// subject to an additional IP rights grant found at http://polymer.github.io/PATENTS.txt
///
/// This code was ported from PolymerProject https://www.polymer-project.org/
class Path {

  ///
  ///Converts array-based paths to flattened path.  String-based paths
  ///are returned as-is.
  ///
  ///Example:
  ///
  ///```
  ///Polymer.Path.normalize(['foo.bar', 0, 'baz'])  // 'foo.bar.0.baz'
  ///Polymer.Path.normalize('foo.bar.0.baz')        // 'foo.bar.0.baz'
  ///```
  ///
  ///@memberof Polymer.Path
  ///@param {string | !Array<string|number>} path Input path
  ///@return {string} Flattened path
  ///
  static normalize(path) {
    if (path is List) {
      var parts = [];
      for (var i=0; i<path.length; i++) {
        var args = path[i].toString().split('.');
        for (var j=0; j<args.length; j++) {
          parts.add(args[j]);
        }
      }
      return parts.join('.');
    } else {
      return path;
    }
  }

  ///
  ///Splits a path into an array of property names. Accepts either arrays
  ///of path parts or strings.
  ///
  ///Example:
  ///
  ///```
  ///Polymer.Path.split(['foo.bar', 0, 'baz'])  // ['foo', 'bar', '0', 'baz']
  ///Polymer.Path.split('foo.bar.0.baz')        // ['foo', 'bar', '0', 'baz']
  ///```
  ///
  ///@memberof Polymer.Path
  ///@param {string | !Array<string|number>} path Input path
  ///@return {!Array<string>} Array of path parts
  ///@this {Path}
  ///@suppress {checkTypes}
  ///
  static split(path) {
    if (path is List) {
      return normalize(path).split('.');
    }
    return path.toString().split('.');
  }

  ///
  ///Reads a value from a path.  If any sub-property in the path is `undefined`,
  ///this method returns `undefined` (will never throw.
  ///
  ///@memberof Polymer.Path
  ///@param {Object} root Object from which to dereference path from
  ///@param {string | !Array<string|number>} path Path to read
  ///@param {Object=} info If an object is provided to `info`, the normalized
  /// (flattened) path will be set to `info.path`.
  ///@return {*} Value at path, or `undefined` if the path could not be
  /// fully dereferenced.
  ///@this {Path}
  ///
  static get(dynamic root, String path, [info]) {
    var prop = root;
    var parts = split(path);
    if(prop is! Map && path == '') {
      return prop;
    }
    if(prop is! Map && path != '') {
      throw new Exception('Root state is not a map, path should be null');
    }
    // Loop over path parts[0..n-1] and dereference
    for (var i=0; i<parts.length; i++) {
      if (prop == null) {
        return null;
      }
      var part = parts[i];
      prop = prop[part];
    }
    if (info != null) {
      info.path = parts.join('.');
    }
    return prop;
  }

  ///
  ///Sets a value to a path.  If any sub-property in the path is `undefined`,
  ///this method will no-op.
  ///
  ///@memberof Polymer.Path
  ///@param {Object} root Object from which to dereference path from
  ///@param {string | !Array<string|number>} path Path to set
  ///@param {*} value Value to set to path
  ///@return {string | undefined} The normalized version of the input path
  ///@this {Path}
  ///
  static set(root, path, value) {
    var prop = root;
    var parts = split(path);
    var last = parts[parts.length-1];
    if (parts.length > 1) {
      // Loop over path parts[0..n-2] and dereference
      for (var i=0; i<parts.length-1; i++) {
        var part = parts[i];
        prop = prop[part];
        if (!prop) {
          return null;
        }
      }
      // Set value to object at end of path
      prop[last] = value;
    } else {
      // Simple property set
      prop[path] = value;
    }
    return parts.join('.');
  }

  ///
  ///Returns the root property name for the given path.
  ///
  ///Example:
  ///
  ///```
  ///Polymer.Path.root('foo.bar.baz') // 'foo'
  ///Polymer.Path.root('foo')         // 'foo'
  ///```
  ///
  ///@memberof Polymer.Path
  ///@param {string} path Path string
  ///@return {string} Root property name
  ///
  static root(path) {
    var dotIndex = path.indexOf('.');
    if (dotIndex == -1) {
      return path;
    }
    return path.slice(0, dotIndex);
  }
}