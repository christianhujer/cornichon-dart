import 'dart:io';

import 'package:test/test.dart';

Map<String, Function> stepDefinitions = {};

void defineStep(String step, Function function) {
  stepDefinitions[step] = function;
}

const given = defineStep;
const when = defineStep;
const then = defineStep;
const and = defineStep;
const but = defineStep;

ExecutionDecorator executionDecorator = TestExecutionDecorator();

abstract class ExecutionDecorator {
  void decorateGroup(String name, Function function);
  void decorateScenario(String name, Function function);
}

class PlainExecutionDecorator implements ExecutionDecorator {
  @override
  void decorateGroup(String name, Function function) {
    function();
  }

  @override
  void decorateScenario(String name, Function function) {
    function();
  }
}

class TestExecutionDecorator implements ExecutionDecorator {
  @override
  void decorateGroup(String name, Function function) {
    group(name, () { function(); });
  }

  @override
  void decorateScenario(String name, Function function) {
    test(name, () { function(); });
  }
}

abstract class Executable {
  String name;
  Executable(this.name);
  void run();
}

abstract class FeatureContent extends Executable {
  FeatureContent(super.name);
}

abstract class ContainsExecutables<T extends Executable> extends Executable {
  List<T> executables = [];
  ContainsExecutables(super.name);
  @override
  void run() {
    decorateGroup(name, () { executeChildren(); });
  }
  void decorateGroup(String name, Function function) {
    executionDecorator.decorateGroup(name, function);
  }
  void executeChildren() {
    executables.forEach((executable) => executable.run());
  }
}

class Feature extends ContainsExecutables<FeatureContent> {
  Feature(super.name);

  static List<Feature> parse(String path) {
    List<Feature> features = [];
    Feature? currentFeature;
    Scenario? currentScenario;
    File(path).readAsLinesSync().forEach((line) {
      line = line.trim();
      if (line.startsWith("Feature:")) {
        currentFeature = Feature(line.substring(9).trim());
        features.add(currentFeature!);
      } else if (line.startsWith("Scenario:")) {
        currentScenario = Scenario(line.substring(10).trim());
        currentFeature!.executables.add(currentScenario!);
      } else {
        const stepPrefixes = ["Given", "When", "Then", "And", "But"];
        stepPrefixes.forEach((stepPrefix) {
          if (line.startsWith(stepPrefix)) {
            currentScenario!.executables.add(Step(stepPrefix, line.substring(stepPrefix.length).trim()));
          }
        });
      }
    });
    return features;
  }
  static void runFeatures(List<Feature> features) {
    features.forEach((feature) => feature.run());
  }
}

class Rule extends ContainsExecutables<Scenario> implements FeatureContent {
  Rule(super.name);
}

class Scenario extends ContainsExecutables<Step> implements FeatureContent {
  Scenario(super.name);
  @override
  void decorateGroup(String name, Function function) {
    executionDecorator.decorateScenario(name, function);
  }
}

class Step extends Executable {
  String prefix;
  Step(this.prefix, super.name);
  @override
  void run() {
    var stepFunction = stepDefinitions[name];
    if (stepFunction == null) throw UndefinedStepException(this);
    stepFunction();
  }
}

class UndefinedStepException implements Exception {
  final Step step;

  UndefinedStepException(this.step);

  @override
  String toString() =>
  """
  Undefined step: ${step.name}.
  You can add this step with the following code:
  ${step.prefix.toLowerCase()}("${step.name}", {
    throw PendingException();
  });
  """;
}

class PendingException implements Exception {
  final String message;

  PendingException([this.message = '']);

  @override
  String toString() => message.isEmpty ? 'PendingException' : 'PendingException: $message';
}
