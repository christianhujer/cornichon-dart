import 'dart:io';

Map<String, Function> stepDefinitions = {};

void defineStep(String step, Function function) {
  stepDefinitions[step] = function;
}

const given = defineStep;
const when = defineStep;
const then = defineStep;
const and = defineStep;
const but = defineStep;

abstract class Executable {
  void run();
}

abstract class FeatureContent extends Executable {}

abstract class ContainsExecutables<T extends Executable> extends Executable {
  List<T> executables = [];
  void run() {
    executables.forEach((executable) => executable.run());
  }
}

class Feature extends ContainsExecutables<FeatureContent> {
  String title;

  Feature(this.title);

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
  String title;

  Rule(this.title);
}

class Scenario extends ContainsExecutables<Step> implements FeatureContent {
  String title;

  Scenario(this.title);
}

class Step extends Executable {
  String prefix;
  String text;
  Step(this.prefix, this.text);
  void run() {
    var stepFunction = stepDefinitions[text];
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
  Undefined step: ${step.text}.
  You can add this step with the following code:
  ${step.prefix.toLowerCase()}("${step.text}", {
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
