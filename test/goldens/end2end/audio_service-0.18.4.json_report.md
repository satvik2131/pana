## 30/30 Follow Dart file conventions

### [*] 10/10 points: Provide a valid `pubspec.yaml`


### [*] 5/5 points: Provide a valid `README.md`


### [*] 5/5 points: Provide a valid `CHANGELOG.md`


### [*] 10/10 points: Use an OSI-approved license

Detected license: `MIT`.

## 10/10 Provide documentation

### [*] 10/10 points: Package has an example


## 20/20 Platform support

### [*] 20/20 points: Supports 4 of 6 possible platforms (**iOS**, **Android**, **Web**, Windows, **MacOS**, Linux)

* ✓ Android
* ✓ iOS
* ✓ MacOS
* ✓ Web

These platforms are not supported:

<details>
<summary>
Package does not support platform `Windows`.
</summary>

Because:
* `package:audio_service/audio_service.dart` that declares support for platforms: `Android`, `iOS`, `macOS`, `Web`.
</details>
<details>
<summary>
Package does not support platform `Linux`.
</summary>

Because:
* `package:audio_service/audio_service.dart` that declares support for platforms: `Android`, `iOS`, `macOS`, `Web`.
</details>

These issues are present but do not affect the score, because they may not originate in your package:

<details>
<summary>
Package does not support platform `Web`.
</summary>

Because:
* `package:audio_service/audio_service.dart` that imports:
* `package:flutter_cache_manager/flutter_cache_manager.dart` that imports:
* `package:flutter_cache_manager/src/storage/cache_info_repositories/cache_info_repositories.dart` that imports:
* `package:flutter_cache_manager/src/storage/cache_info_repositories/json_cache_info_repository.dart` that imports:
* `package:path_provider/path_provider.dart` that declares support for platforms: `Android`, `iOS`, `Windows`, `Linux`, `macOS`.
</details>

## 20/30 Pass static analysis

### [~] 20/30 points: code has no errors, warnings, lints, or formatting issues

Found 23 issues. Showing the first 2:

<details>
<summary>
INFO: 'hashValues' is deprecated and shouldn't be used. Use Object.hash() instead. This feature was deprecated in v3.1.0-0.0.pre.897.
</summary>

`lib/audio_service.dart:301:23`

```
    ╷
301 │   int get hashCode => hashValues(
    │                       ^^^^^^^^^^
    ╵
```

To reproduce make sure you are using the [lints_core](https://pub.dev/packages/lints) and run `flutter analyze lib/audio_service.dart`
</details>
<details>
<summary>
INFO: 'hashList' is deprecated and shouldn't be used. Use Object.hashAll() or Object.hashAllUnordered() instead. This feature was deprecated in v3.1.0-0.0.pre.897.
</summary>

`lib/audio_service.dart:304:9`

```
    ╷
304 │         hashList(controls),
    │         ^^^^^^^^
    ╵
```

To reproduce make sure you are using the [lints_core](https://pub.dev/packages/lints) and run `flutter analyze lib/audio_service.dart`
</details>

## 20/20 Support up-to-date dependencies

### [*] 10/10 points: All of the package dependencies are supported in the latest version

|Package|Constraint|Compatible|Latest|
|:-|:-|:-|:-|
|[`audio_service_platform_interface`]|`^0.1.0`|0.1.0|0.1.0|
|[`audio_service_web`]|`^0.1.1`|0.1.1|0.1.1|
|[`audio_session`]|`^0.1.6+1`|0.1.10|0.1.10|
|[`clock`]|`^1.1.0`|1.1.1|1.1.1|
|[`flutter`]|`flutter`|0.0.0|0.0.0|
|[`flutter_cache_manager`]|`^3.0.1`|3.3.0|3.3.0|
|[`flutter_web_plugins`]|`flutter`|0.0.0|0.0.0|
|[`js`]|`^0.6.3`|0.6.4|0.6.5|
|[`rxdart`]|`>=0.26.0 <0.28.0`|0.27.5|0.27.5|

<details><summary>Transitive dependencies</summary>

|Package|Constraint|Compatible|Latest|
|:-|:-|:-|:-|
|[`async`]|-|2.9.0|2.9.0|
|[`characters`]|-|1.2.1|1.2.1|
|[`collection`]|-|1.16.0|1.17.0|
|[`crypto`]|-|3.0.2|3.0.2|
|[`ffi`]|-|2.0.1|2.0.1|
|[`file`]|-|6.1.4|6.1.4|
|[`http`]|-|0.13.5|0.13.5|
|[`http_parser`]|-|4.0.2|4.0.2|
|[`material_color_utilities`]|-|0.1.5|0.2.0|
|[`meta`]|-|1.8.0|1.8.0|
|[`path`]|-|1.8.2|1.8.2|
|[`path_provider`]|-|2.0.11|2.0.11|
|[`path_provider_android`]|-|2.0.20|2.0.20|
|[`path_provider_ios`]|-|2.0.11|2.0.11|
|[`path_provider_linux`]|-|2.1.7|2.1.7|
|[`path_provider_macos`]|-|2.0.6|2.0.6|
|[`path_provider_platform_interface`]|-|2.0.5|2.0.5|
|[`path_provider_windows`]|-|2.1.3|2.1.3|
|[`pedantic`]|-|1.11.1|1.11.1|
|[`platform`]|-|3.1.0|3.1.0|
|[`plugin_platform_interface`]|-|2.1.3|2.1.3|
|[`process`]|-|4.2.4|4.2.4|
|[`sky_engine`]|-|0.0.99|0.0.99|
|[`source_span`]|-|1.9.1|1.9.1|
|[`sqflite`]|-|2.1.0+1|2.1.0+1|
|[`sqflite_common`]|-|2.3.0|2.3.0|
|[`string_scanner`]|-|1.1.1|1.1.1|
|[`synchronized`]|-|3.0.0+3|3.0.0+3|
|[`term_glyph`]|-|1.2.1|1.2.1|
|[`typed_data`]|-|1.3.1|1.3.1|
|[`uuid`]|-|3.0.6|3.0.6|
|[`vector_math`]|-|2.1.2|2.1.4|
|[`win32`]|-|3.0.1|3.0.1|
|[`xdg_directories`]|-|0.2.0+2|0.2.0+2|
</details>

To reproduce run `dart pub outdated --no-dev-dependencies --up-to-date --no-dependency-overrides`.

[`audio_service_platform_interface`]: https://pub.dev/packages/audio_service_platform_interface
[`audio_service_web`]: https://pub.dev/packages/audio_service_web
[`audio_session`]: https://pub.dev/packages/audio_session
[`clock`]: https://pub.dev/packages/clock
[`flutter`]: https://pub.dev/packages/flutter
[`flutter_cache_manager`]: https://pub.dev/packages/flutter_cache_manager
[`flutter_web_plugins`]: https://pub.dev/packages/flutter_web_plugins
[`js`]: https://pub.dev/packages/js
[`rxdart`]: https://pub.dev/packages/rxdart
[`async`]: https://pub.dev/packages/async
[`characters`]: https://pub.dev/packages/characters
[`collection`]: https://pub.dev/packages/collection
[`crypto`]: https://pub.dev/packages/crypto
[`ffi`]: https://pub.dev/packages/ffi
[`file`]: https://pub.dev/packages/file
[`http`]: https://pub.dev/packages/http
[`http_parser`]: https://pub.dev/packages/http_parser
[`material_color_utilities`]: https://pub.dev/packages/material_color_utilities
[`meta`]: https://pub.dev/packages/meta
[`path`]: https://pub.dev/packages/path
[`path_provider`]: https://pub.dev/packages/path_provider
[`path_provider_android`]: https://pub.dev/packages/path_provider_android
[`path_provider_ios`]: https://pub.dev/packages/path_provider_ios
[`path_provider_linux`]: https://pub.dev/packages/path_provider_linux
[`path_provider_macos`]: https://pub.dev/packages/path_provider_macos
[`path_provider_platform_interface`]: https://pub.dev/packages/path_provider_platform_interface
[`path_provider_windows`]: https://pub.dev/packages/path_provider_windows
[`pedantic`]: https://pub.dev/packages/pedantic
[`platform`]: https://pub.dev/packages/platform
[`plugin_platform_interface`]: https://pub.dev/packages/plugin_platform_interface
[`process`]: https://pub.dev/packages/process
[`sky_engine`]: https://pub.dev/packages/sky_engine
[`source_span`]: https://pub.dev/packages/source_span
[`sqflite`]: https://pub.dev/packages/sqflite
[`sqflite_common`]: https://pub.dev/packages/sqflite_common
[`string_scanner`]: https://pub.dev/packages/string_scanner
[`synchronized`]: https://pub.dev/packages/synchronized
[`term_glyph`]: https://pub.dev/packages/term_glyph
[`typed_data`]: https://pub.dev/packages/typed_data
[`uuid`]: https://pub.dev/packages/uuid
[`vector_math`]: https://pub.dev/packages/vector_math
[`win32`]: https://pub.dev/packages/win32
[`xdg_directories`]: https://pub.dev/packages/xdg_directories


### [*] 10/10 points: Package supports latest stable Dart and Flutter SDKs


## 20/20 Support sound null safety

### [*] 20/20 points: Package and dependencies are fully migrated to null safety!
