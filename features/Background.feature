Feature: Background
  Background:
    Given feature background

  Scenario: Scenario outside Rule
    When scenario step

  Rule: Some Rule
    Background:
      Given rule background

    Scenario: Some Scenario
      When scenario step

    Scenario: Some other Scenario
      When scenario step
