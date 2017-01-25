// Copyright (c) 2017, Rodsevich. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library public_wrapper_gen.annotations;

/// Mark a class with this annotation in order to generate a wrapper class with
/// the provided name that could be exported as a Public Interface to the class
class PublicWrapper {
  final String publicClassName;
  final bool generateConstructor;

  const PublicWrapper(this.publicClassName, {generateConstructor: true})
      : this.generateConstructor = generateConstructor;
}

/// Handles the way in which the fields are generated
class PublicKey {
  final bool generateGetter, generateSetter;
  final String keyName;

  /// Set if this is gonna appear in the defaultConstructor that will be generated.
  ///
  /// (by default it will be null, so won't be generated). If this is a `number`, it will appear
  /// in it's respective position as required parameter. If it's `true` it will
  /// be generated with the generation name, and if it's a `String`, that given
  /// value will be used instead.
  final inDefaultConstructor;

  const PublicKey(this.keyName,
      {generateGetter: true, generateSetter: true, inDefaultConstructor: false})
      : this.generateGetter = generateGetter,
        this.generateSetter = generateSetter,
        this.inDefaultConstructor = inDefaultConstructor;
}

class OmitGeneration {
  const OmitGeneration();
}
