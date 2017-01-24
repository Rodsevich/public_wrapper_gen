// Copyright (c) 2017, Rodsevich. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library gen_example;

import 'package:public_wrapper_gen/annotations.dart';
import 'package:public_wrapper_gen/public_wrapper.dart';
import 'package:source_gen/generators/json_serializable.dart';

part 'public_wrapper_example.public.dart';

// @JsonSerializable()
// class Person extends Object with _$PersonSerializerMixin {
//   final firstName, middleName, lastName;
//
//   @JsonKey('sorpi-of-lorpo')
//   final DateTime dateOfBirth;
//
//   Person(this.firstName, this.lastName, {this.middleName, this.dateOfBirth});
//
//   factory Person.fromJson(json) => _$PersonFromJson(json);
// }

@PublicWrapper("Book")
class Libro extends _$Libro {
  int paginas;
  String sorp = "sorpo";

  String _soyPrivado() => "Soy privado";
  int sumame(int a, int b) => a + b;
  String leer() {
    return "leeme, Willbert!";
  }
}
