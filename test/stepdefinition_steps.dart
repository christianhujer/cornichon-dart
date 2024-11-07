import 'package:cornichon_dart/cornichon.dart';

List<String> stepsExecuted = [];

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
}
