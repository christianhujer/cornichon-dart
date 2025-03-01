import 'package:cornichon_dart/cornichon.dart';
import 'package:test/test.dart';

import 'stepdefinition_steps.dart';

void main() {
  setUp(() {
    executionDecorator = PlainExecutionDecorator();
    stepsExecuted = [];
    stepArguments = [];
  });

  test('single step', () {
    f() {}
    defineStep('I have a step', f);
    expect(stepDefinitions['I have a step'], f);
  });

  test('given when then and but', () {
    defineStepDefinitionSteps();
  });

  test('can parse and run a feature file', () {
    var features = Feature.parse('features/ExampleFeature.feature');
    Feature.runFeatures(features);
    expect(stepsExecuted, ['given', 'when', 'then', 'and', 'but', 'given', 'when', 'then', 'and', 'but']);
  });

  test('can work with rules', () {
    var features = Feature.parse('features/Rules.feature');
    Feature.runFeatures(features);
    expect(stepsExecuted, ['given', 'when', 'then', 'and', 'but', 'given', 'when', 'then', 'and', 'but']);
  });

  test('throws an exception with a good message for an undefined step', () {
    var features = Feature.parse('features/UndefinedStep.feature');
    expect(() => Feature.runFeatures(features), throwsA(allOf(
        isA<UndefinedStepException>(),
        predicate((e) => e.toString().contains(r"""
Undefined step: this step is not defined.
You can add this step with the following code:
given(r"^this step is not defined$", () {
  throw PendingException();
});
""")),
    )));
  });

  test('Runs the background of each rule and scenario', () {
    var features = Feature.parse('features/Background.feature');
    Feature.runFeatures(features);
    expect(stepsExecuted, ['feature background', 'scenario step', 'feature background', 'rule background', 'scenario step', 'feature background', 'rule background', 'scenario step']);
  });

  test('steps can have arguments', () {
    var features = Feature.parse('features/StepArguments.feature');
    Feature.runFeatures(features);
    expect(stepArguments, ['foo', 'bar', 'buzz']);
  });

}
