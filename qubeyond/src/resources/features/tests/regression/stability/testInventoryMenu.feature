@regressionStability
Feature: Inventory Test - Stability - Regression

Scenario: Validation Status Code - GET menu items
    * def response_inventory = call read('classpath:features/operations/inventory/inventory.feature@validation_items')
    * match response_inventory.responseStatus == 200