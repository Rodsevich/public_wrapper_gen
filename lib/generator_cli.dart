library generatorCli;

import 'dart:io';
import 'dart:async';
import 'package:args/args.dart';
import 'package:build_runner/build_runner.dart';
import 'package:source_gen/source_gen.dart';
import 'package:source_gen/generators/json_serializable_generator.dart';
import 'package:console/console.dart';
import 'package:dart_config/default_server.dart';

class GeneratorCli {
  ArgParser _parser;
  ArgResults _args;
  String _packageName;
  PhaseGroup _phases;
  List<Generator> _generators;
  Map<String, dynamic> _configs;
  List<String> _paths;
  TimeDisplay _timer;
  bool _timerRunning;
  String _generatedExtension;

  GeneratorCli(this._generators, [this._generatedExtension = ".g.dart"]);

  Future delegate(List<String> plainArgs) async {
    try {
      Console.init();
    } catch (e) {
      printError(e);
      exit(1);
    }
    _startTimer();
    _configureArgParser();

    try {
      _args = _parser.parse(plainArgs);
    } catch (e) {
      printError(e.toString());
      exit(2);
    }

    if (_args["help"]) {
      await _printUsage();
      exit(0);
    }

    try {
      _packageName = await _getPackageName();
    } catch (e) {
      printError(e.toString());
      exit(3);
    }

    try {
      _configs = await _getConfiguration(_args["config-file"]);
      _paths = (_configs["paths"] as String).split(" ");
      _paths.addAll(_args.rest);
    } catch (e) {
      printError(e.toString());
      exit(4);
    }

    if (_args["generated-extension"] != null)
      _generatedExtension = _args["generated-extension"];
    _phases = new PhaseGroup.singleAction(
        new GeneratorBuilder(_generators,
            generatedExtension: _generatedExtension),
        new InputSet(_packageName, _paths));
    _stopTimer();
    if (_args["watch"])
      watch(_phases, deleteFilesByDefault: true);
    else
      build(_phases, deleteFilesByDefault: true);
  }

  void _startTimer() {
    _timer ??= new TimeDisplay();
    Console.write("Loading... ");
    _timer.start();
    _timerRunning = true;
  }

  void _stopTimer() {
    Console.moveCursorBack(20);
    Console.eraseLine();
    _timer.stop();
    _timerRunning = false;
  }

  void _configureArgParser() {
    _parser = new ArgParser(); //add fancy options and flags support
    _parser
      ..addSeparator("Arguments:")
      ..addFlag("help", help: "Show this help", abbr: 'h', negatable: false)
      ..addFlag("watch",
          help: "Watch for changes for continuous building",
          abbr: 'w',
          negatable: false)
      ..addOption("config-file",
          help: "Name of the configuration file to load",
          abbr: 'c',
          defaultsTo: "source_gen.yaml")
      ..addOption("generated-extension",
          help: "Extension of the generated file by this generator",
          abbr: 'e',
          defaultsTo: _generatedExtension);
  }

  Future<Map> _getConfiguration([String path = "source_gen.yaml"]) async {
    Map conf = await loadConfig(path);
    if (conf.containsKey("source_gen")) conf = conf["source_gen"];
    return conf;
  }

  Future<String> _getPackageName() async {
    Map conf = await loadConfig("pubspec.yaml");
    return conf['name'];
  }

  void print(String s) {
    if (_timerRunning) _stopTimer();
    stdout.writeln(s);
  }

  void printError(String s) {
    if (_timerRunning) _stopTimer();
    StringBuffer buf = new StringBuffer();
    TextPen pen = new TextPen(buffer: buf); //print with colors
    pen.red();
    pen(s);
    pen.normal();
    pen('');
    stderr.writeln(pen.toString());
  }

  Future _printUsage() async {
    String pkgName = await _getPackageName();
    print('''
This is source_gen's generators runner.

  Usage: pub run $pkgName:generator [arguments] [<path>...]
''');
    print(_parser.usage);
  }
}
