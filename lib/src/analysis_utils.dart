library analysis_utils;

import "../annotations.dart";
import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/src/annotation.dart';

List<MethodElement> generatableMethodsList(ClassElement classElement) {
  return classElement.methods
      .where((MethodElement method) =>
          false == method.metadata.any(isGenerationOmisionField))
      .toList();
}

List<FieldElement> generatableFieldsList(ClassElement classElement) {
  return classElement.fields
      .where((FieldElement field) =>
          false == field.metadata.any(isGenerationOmisionField))
      .toList();
}

bool isGenerationOmisionField(ElementAnnotation anon) {
  return matchAnnotation(OmitGeneration, anon);
}

abstract class _BaseElement {
  String name, newName, documentation, type;
  bool private;

  Element element;

  _BaseElement(Element e) {
    this.name = e.name;
    this.documentation = e.documentationComment;
    this.private = e.isPrivate;
  }
}

class Constructor extends _BaseElement {
  @override
  ConstructorElement element;
  List<ParameterElement> params;

  Constructor(this.element) : super(element) {
    this.params = element.parameters;
  }

  String get declarationParams =>
      params.map((p) => "${p.type.name} ${p.name}").toList().join(', ');

  String get usageParams => params.map((p) => p.name).toList().join(', ');
}

class Method extends _BaseElement {
  @override
  MethodElement element;

  Method(MethodElement m) : super(m) {
    this.element = m;
    var pk = m.metadata
        .firstWhere((m) => matchAnnotation(PublicKey, m), orElse: () => null);
    this.newName =
        pk?.constantValue?.getField("keyName")?.toStringValue() ?? this.name;
    this.type = m.returnType.name;
  }

  @override
  String get params {
    StringBuffer b = new StringBuffer('(');
    b.write(this.element.parameters.map((ParameterElement p) {
          StringBuffer buffer = new StringBuffer();
          p.appendToWithoutDelimiters(buffer);
          return buffer..toString();
        }).join(',') +
        ')');
    return b.toString();
  }
}

class Field extends _BaseElement {
  bool generateGetter, generateSetter, inConstructor;
  int constructorOrder;
  String constructorName;

  @override
  FieldElement element;

  Field(FieldElement f) : super(f) {
    this.element = f;
    this.type = f.type.name;
    var pk = f.metadata
        .firstWhere((m) => matchAnnotation(PublicKey, m), orElse: () => null);
    PublicKey publicKey;
    try {
      publicKey = instantiateAnnotation(pk) as PublicKey;
    } catch (w) {
      publicKey = new PublicKey(this.name);
    } finally {
      this.generateGetter = publicKey.generateGetter;
      this.generateSetter = publicKey.generateSetter;
      this.newName = publicKey.keyName;
      if (publicKey.inDefaultConstructor != null) {
        this.inConstructor = true;
        if (publicKey.inDefaultConstructor is int)
          this.constructorOrder = publicKey.inDefaultConstructor;
        else if (publicKey.inDefaultConstructor is String)
          this.constructorName = publicKey.inDefaultConstructor;
        else
          this.constructorName = this.newName;
      }
    }
  }
}
