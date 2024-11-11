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

abstract class HasBackground {
  Background background = Background();
  void runBackground();
}

abstract class HasSteps extends ContainsExecutables<Step> {
  HasSteps(super.name);
  void runSteps() {
    executeChildren();
  }
}

class Background extends HasSteps implements BackgroundOrScenario {
  Background() : super('');
}

abstract class RuleOrScenario extends Executable {
  RuleOrScenario(super.name);
}

abstract class BackgroundOrScenario extends Executable {
  BackgroundOrScenario(super.name);
}

abstract class FeatureOrRule<T extends Executable> extends ContainsExecutables<T> {
  FeatureOrRule(super.name);
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
    executables.forEach((executable) {
      executable.run();
    });
  }
}

class Feature extends ContainsExecutables<RuleOrScenario> implements HasBackground, FeatureOrRule<RuleOrScenario> {
  @override
  Background background = Background();
  Feature(super.name);

  static List<Feature> parse(String path) {
    List<Feature> features = [];
    FeatureOrRule? currentFeatureOrRule;
    HasSteps? currentBackgroundOrScenario;
    Feature? currentFeature;
    Rule? currentRule;
    File(path).readAsLinesSync().forEach((line) {
      line = line.trim();
      print(line);
      if (line.startsWith("Feature:")) {
        currentFeature = Feature(line.substring(9).trim());
        currentFeatureOrRule = currentFeature;
        currentBackgroundOrScenario = null;
        features.add(currentFeature!);
      } else if (line.startsWith("Rule:")) {
        currentRule = Rule(line.substring(4).trim());
        currentFeature!.executables.add(currentRule!);
        currentFeatureOrRule = currentRule;
        currentBackgroundOrScenario = null;
      } else if (line.startsWith("Background:")) {
        currentBackgroundOrScenario = (currentFeatureOrRule as HasBackground).background = Background();
      } else if (line.startsWith("Scenario:")) {
        var scenario = Scenario(line.substring(9).trim());
        currentBackgroundOrScenario = scenario;
        scenario.executables.addAll(currentFeature!.background.executables);
        if (currentRule != null) {
          scenario.executables.addAll(currentRule!.background.executables);
        }
        currentFeatureOrRule!.executables.add(scenario);
      } else {
        const stepPrefixes = ["Given", "When", "Then", "And", "But"];
        stepPrefixes.forEach((stepPrefix) {
          if (line.startsWith(stepPrefix)) {
            currentBackgroundOrScenario!.executables.add(Step(stepPrefix, line.substring(stepPrefix.length).trim()));
          }
        });
      }
    });
    return features;
  }
  static void runFeatures(List<Feature> features) {
    features.forEach((feature) => feature.run());
  }
  @override
  void runBackground() {
    background.run();
  }
}

class Rule extends ContainsExecutables<Scenario> implements HasBackground, RuleOrScenario, FeatureOrRule<Scenario> {
  Background background = Background();
  Rule(super.name);
  @override
  void runBackground() {
    background.run();
  }
}

class Scenario extends HasSteps implements BackgroundOrScenario, RuleOrScenario {
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
