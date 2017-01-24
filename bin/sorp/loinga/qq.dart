import 'dart:async';
import 'dart:io' show Platform;
import "package:public_wrapper_gen/public_wrapper.dart" show funcionSorp;
import 'package:resource/resource.dart';

Future main() async {
  // Get the URI of the script being run.
  var uri = Platform.script;
  // Convert the URI to a path.
  //var path = uri.toFilePath();
  print(uri);
  //print(path);
  print(Platform.executable);
  print(await new Resource(
          "package:public_wrapper_gen/src/PublicWrapper/template.mustache")
      .readAsString());
}
