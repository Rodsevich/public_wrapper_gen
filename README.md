# public_wrapper_gen

A code generator based on source_gen to easily make APIs for libraries.

## Use case

 - You have a library that is a mess, or is written in another language, or whatever... And you want to show a clean API to your clients.
 - You want an easy way of fighting against the not so straightforward *_private* "to the library" (that in reality is not much like that) Dart feature and avoiding the tedious parts of the library.

## Usage

A simple usage example:

    // your_package/lib/src/ClaseInterna.dart

    import 'package:public_wrapper_gen/public_wrapper_gen.dart';

    library your_library;

    part "this_file.g.dart";

    @PublicWrapper("PublicClass")
    class TuClaseInterna { //TuClaseInterna = yourInternalClass
      @PublicKey("salutation", inDefaultConstructor: true)
      String saludo = "Hola";

      TuClaseInterna(this.saludo);

      /// documentation will be copied
      String salutation() => generarSaludo();

      @OmitGeneration
      String generarSaludo() => this.saludo;
    }

Generate by running: ` pub run public_wrapper_gen:generate your_file.dart `

    // your_package/lib/src/ClaseInterna.g.dart

    part of "your_library";

    /// Generated from [TuClaseInterna]
    class PublicClass {
      TuClaseInterna _wrapped;

      String get salutation => _wrapped.saludo;
      void set salutation(String x){ _wrapped.saludo = x}

      PublicClass(salutation) : _wrapped = new TuClaseInterna(salutation);

      /// documentation will be copied
      String salutation() => _wrapped.salutation();
    }

Now in your library export file:

    // your_package/lib/your_library.dart

    export 'src/ClaseInterna.dart show PublicClass';


## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: http://github.com/Rodsevich/plublic_wrapper_gen/issues
