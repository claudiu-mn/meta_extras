# meta_extras 1.0.0

A Dart package that contains:
- `Info`, `Warning` and `Error` annotations
- an analyzer plugin for the annotations

## Installation

1. Add the dependency in `pubspec.yaml`, so you can use the annotations in code:
```yaml
dependencies:
  meta_extras:
    git:
      url: https://github.com/claudiu-mn/meta_extras.git
      ref: 1.0.0
```
2. Add the analyzer plugin in `analysis_options.yaml` (create the file alongside `pubspec.yaml` if absent), so the annotations actually do something:
```yaml
analyzer:
  plugins:
    - meta_extras
```

## Usage

Drop the `Info`, `Warnings` and `Error` on anything that can support annotations: classes, constructors, static/instance properties, local/toplevel variables, functions/methods, parameters, etc.

Here's an example to test if things are correctly set up:

```dart
// example_file.dart

import 'package:meta_extras/meta_extras.dart';

class AClass {
  @Error('An error message')
  static const anInt = 3;

  @Warning('A warning message')
  void aWarningFunction() {
    // Does something...
  }

  void aFunction(@Info('An info message') String aParam) {
    // Does something ...
  }
}

class AnotherClass {
  void anotherFunction() {
    final instance = AClass();

    // If everything is set up correctly, your IDE should:

    // - hightlight `aWarningFunction` and show you a warning that says 'A warning message'
    instance.aWarningFunction();

    // - highlight `anInt` and show you an error that says 'An error message'
    const _ = AClass.anInt;

    // - highlight `'aString'` and show you an info/hint that says 'An info message'
    instance.aFunction('aString');
  }
}
```