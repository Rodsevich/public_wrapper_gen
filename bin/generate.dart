import "package:public_wrapper_gen/generator_cli.dart" show GeneratorCli;
import "package:public_wrapper_gen/public_wrapper.dart";
import 'package:source_gen/generators/json_serializable_generator.dart';

main(List<String> plainArgs) async {
  GeneratorCli generator =
      new GeneratorCli([const PublicWrapperGenerator()], ".public.dart");
  generator.delegate(plainArgs);
}
