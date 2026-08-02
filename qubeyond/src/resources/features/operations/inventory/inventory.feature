@ignore
Feature: Inventory

Background:
    # baseUrl and api both come from karate-config.js for the active karate.env
    * url baseUrl


@validation_items
Scenario: Validation keys items
    Given path api.inventory.getItems
    When method GET
    * notepad.set('response_items', response)
