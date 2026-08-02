@smokeQuality
Feature: Inventory Test - Quality - Smoke

Background:
    * def data_validatioon = functions.getDataValidationJsonByName("inventory")
Scenario: Validate filter by id - GET (Filter by id)
    * call read('classpath:features/operations/inventory/inventory.feature@filter_by_id') {id_item: 3}
    * match notepad.get('response_filter_by_id') == data_validatioon.data