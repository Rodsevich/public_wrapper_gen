import 'dart:async';
import 'dart:developer';
import 'dart:io' show File, Platform;
import 'package:analyzer/dart/element/element.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:mustache4dart/mustache4dart.dart';
import 'package:resource/resource.dart';
import "package:source_gen/source_gen.dart";
import 'package:source_gen/src/annotation.dart';
import 'package:source_gen/src/utils.dart';
import "package:mustache4dart/utils_io.dart";
import "../../annotations.dart";
import '../generator_utils.dart' as gen_utils;
import "../analysis_utils.dart";

class PublicWrapperGenerator extends GeneratorForAnnotation<PublicWrapper> {
  const PublicWrapperGenerator();

  @override
  Future<String> generateForAnnotatedElement(
      Element element, PublicWrapper annotation, BuildStep buildStep) {
    if (element is! ClassElement) {
      var friendlyName = friendlyNameForElement(element);
      throw new InvalidGenerationSourceError(
          'Generator cannot target `$friendlyName`.',
          todo: 'Remove the PublicWrapper annotation from `$friendlyName`.');
    }
    Completer ret = new Completer();
    new Future(() {
      Map vars = {};
      ClassElement classElement = element as ClassElement;
      vars["className"] = classElement.name;
      vars["publicClassName"] = annotation.publicClassName;

      // Get all of the fields that need to be assigned
      // TODO: support overriding the field set with an annotation option
      vars["fields"] =
          generatableFieldsList(classElement).map((f) => new Field(f)).toList();
      vars["methods"] = generatableMethodsList(classElement)
          .map((m) => new Method(m))
          .toList();
      var construc = classElement.constructors.where((ConstructorElement c) =>
          c.name == "from${annotation.publicClassName}");
      if (construc.length == 1)
        vars["generateConstructor"] = new Constructor(construc.single);
      // debugger();
      new Resource(
              "package:public_wrapper_gen/src/PublicWrapper/template.mustache")
          .readAsString()
          .then((String template) {
        gen_utils.partialSearchFunction().then((Function func) {
          ret.complete(render(template, vars, partial: func) as String);
        });
      });
    });
    return ret.future;
  }
}
