import 'package:cucumber_dart/cucumber_dart.dart';
import 'package:test/test.dart';

import 'stepdefinition_steps.dart';

void main() {
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
}
