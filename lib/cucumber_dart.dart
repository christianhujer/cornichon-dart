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

abstract class ContainsExecutables<T extends Executable> extends Executable {
  List<T> executables = [];
  void run() {
    executables.forEach((executable) => executable.run());
  }
}

class Feature extends ContainsExecutables<Scenario> {
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
            currentScenario!.executables.add(Step(line.substring(stepPrefix.length).trim()));
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

class Scenario extends ContainsExecutables<Step> {
  String title;

  Scenario(this.title);
}

class Step extends Executable {
  String text;
  Step(this.text);
  void run() {
    var stepFunction = stepDefinitions[text];
    if (stepFunction == null) throw Exception("Undefined step: ${text}");
    stepFunction();
  }
}
