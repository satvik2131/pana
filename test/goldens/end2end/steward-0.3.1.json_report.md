## 30/30 Follow Dart file conventions

### [*] 10/10 points: Provide a valid `pubspec.yaml`


### [*] 5/5 points: Provide a valid `README.md`


### [*] 5/5 points: Provide a valid `CHANGELOG.md`


### [*] 10/10 points: Use an OSI-approved license

Detected license: `MIT`.

## 10/10 Provide documentation

### [*] 10/10 points: Package has an example


## 20/20 Platform support

### [*] 20/20 points: Supports 3 of 6 possible platforms (iOS, Android, Web, **Windows**, **MacOS**, **Linux**)

* ✓ Windows
* ✓ Linux
* ✓ MacOS

These platforms are not supported:

<details>
<summary>
Package not compatible with platform Android
</summary>

Because:
* `package:steward/steward.dart` that imports:
* `package:steward/app/app.dart` that imports:
* `package:steward/router/router.dart` that imports:
* `package:steward/controllers/route_utils.dart` that imports:
* `dart:mirrors`
</details>
<details>
<summary>
Package not compatible with platform iOS
</summary>

Because:
* `package:steward/steward.dart` that imports:
* `package:steward/app/app.dart` that imports:
* `package:steward/router/router.dart` that imports:
* `package:steward/controllers/route_utils.dart` that imports:
* `dart:mirrors`
</details>
<details>
<summary>
Package not compatible with platform Web
</summary>

Because:
* `package:steward/steward.dart` that imports:
* `package:steward/app/app.dart` that imports:
* `package:steward/config/config_reader.dart` that imports:
* `dart:io`
</details>

## 20/30 Pass static analysis

### [~] 20/30 points: code has no errors, warnings, lints, or formatting issues

Found 24 issues. Showing the first 2:

<details>
<summary>
INFO: Name non-constant identifiers using lowerCamelCase.
</summary>

`lib/controllers/route_utils.dart:79:7`

```
   ╷
79 │ final GetAnnotation = reflectClass(Get);
   │       ^^^^^^^^^^^^^
   ╵
```

To reproduce make sure you are using the [lints_core](https://pub.dev/packages/lints) and run `dart analyze lib/controllers/route_utils.dart`
</details>
<details>
<summary>
INFO: Name non-constant identifiers using lowerCamelCase.
</summary>

`lib/controllers/route_utils.dart:82:7`

```
   ╷
82 │ final PutAnnotation = reflectClass(Put);
   │       ^^^^^^^^^^^^^
   ╵
```

To reproduce make sure you are using the [lints_core](https://pub.dev/packages/lints) and run `dart analyze lib/controllers/route_utils.dart`
</details>

## 20/20 Support up-to-date dependencies

### [*] 10/10 points: All of the package dependencies are supported in the latest version

|Package|Constraint|Compatible|Latest|
|:-|:-|:-|:-|
|[`bosun`]|`^0.2.1`|0.2.2|0.2.2|
|[`flat`]|`^0.4.0`|0.4.1|0.4.1|
|[`mustache_template`]|`^2.0.0`|2.0.0|2.0.0|
|[`path_to_regexp`]|`^0.4.0`|0.4.0|0.4.0|
|[`recase`]|`^4.0.0`|4.1.0|4.1.0|
|[`yaml`]|`^3.1.0`|3.1.1|3.1.1|

<details><summary>Transitive dependencies</summary>

|Package|Constraint|Compatible|Latest|
|:-|:-|:-|:-|
|[`collection`]|-|1.17.0|1.17.0|
|[`path`]|-|1.8.2|1.8.2|
|[`source_span`]|-|1.9.1|1.9.1|
|[`string_scanner`]|-|1.1.1|1.1.1|
|[`term_glyph`]|-|1.2.1|1.2.1|
|[`tree_iterator`]|-|2.0.0|2.0.0|
</details>

To reproduce run `dart pub outdated --no-dev-dependencies --up-to-date --no-dependency-overrides`.

[`bosun`]: https://pub.dev/packages/bosun
[`flat`]: https://pub.dev/packages/flat
[`mustache_template`]: https://pub.dev/packages/mustache_template
[`path_to_regexp`]: https://pub.dev/packages/path_to_regexp
[`recase`]: https://pub.dev/packages/recase
[`yaml`]: https://pub.dev/packages/yaml
[`collection`]: https://pub.dev/packages/collection
[`path`]: https://pub.dev/packages/path
[`source_span`]: https://pub.dev/packages/source_span
[`string_scanner`]: https://pub.dev/packages/string_scanner
[`term_glyph`]: https://pub.dev/packages/term_glyph
[`tree_iterator`]: https://pub.dev/packages/tree_iterator


### [*] 10/10 points: Package supports latest stable Dart and Flutter SDKs


## 20/20 Support sound null safety

### [*] 20/20 points: Package and dependencies are fully migrated to null safety!
