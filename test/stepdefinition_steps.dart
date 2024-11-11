import 'package:cornichon_dart/cornichon.dart';

List<String> stepsExecuted = [];
List<String> stepArguments = [];

void defineStepDefinitionSteps() {
  given('I have a step', () {
    stepsExecuted.add('given');
  });
  when('I run the step', () {
    stepsExecuted.add('when');
  });
  then('I should see the result', () {
    stepsExecuted.add('then');
  });
  and('I should also see this result', () {
    stepsExecuted.add('and');
  });
  but('I should also see that result', () {
    stepsExecuted.add('but');
  });

  given('feature background', () {
    stepsExecuted.add('feature background');
  });
  given('rule background', () {
    stepsExecuted.add('rule background');
  });
  when('scenario step', () {
    stepsExecuted.add('scenario step');
  });

  given(r'I have "(\w+)" and "(\w+)" and "(\w+)"', (arg1, arg2, arg3) {
    stepArguments.add(arg1);
    stepArguments.add(arg2);
    stepArguments.add(arg3);
  });
}
