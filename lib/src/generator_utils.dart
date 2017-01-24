library generator_utils;

import 'dart:async';
import 'dart:io';
import 'package:analyzer/dart/element/element.dart';
import "package:mustache4dart/utils_io.dart" show PartialsHandler;
import "package:path/path.dart" as path;
import 'package:public_wrapper_gen/annotations.dart';
import "package:resource/src/package_loader.dart" show PackageLoader;
import 'package:dart_config/default_server.dart';
import 'package:source_gen/src/annotation.dart';
import "./analysis_utils.dart";

PartialsHandler _cached;

Future<Function> partialSearchFunction(
    {failWhenNotFound: true, notFoundMessage: null}) async {
  if (_cached != null) return _cached.partialSearchFunction;

  Map config = await loadConfig("source_gen.yaml");
  List<String> extensions =
      (config["mustache"]["extensions"] as String).split(' ');
  List<String> dirs =
      (config["mustache"]["partials_dirs"] as String).split(' ');

  PartialsHandler partialsHandler = new PartialsHandler(
      directoriesPaths: dirs,
      extensions: extensions,
      failWhenNotFound: failWhenNotFound,
      notFoundMessage: notFoundMessage);
  _cached = partialsHandler;
  return _cached.partialSearchFunction;
}

int compareFields(Field a, Field b) => a.constructorOrder - b.constructorOrder;

// Method processMethodElement(MethodElement e) {
//   return e;
// }
//
// Field processFieldElement(FieldElement e) {
//   return e;
// }
