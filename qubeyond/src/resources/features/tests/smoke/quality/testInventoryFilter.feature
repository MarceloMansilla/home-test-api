@smokeQuality
Feature: Inventory Test - Quality - Smoke

Background:
    * def schema_validation = functions.getDataValidationJsonByName("inventory").data
    * def data_validation = functions.getDataValidationJsonByName("inventory")
    * def response_filter = call read('classpath:features/operations/inventory/inventory.feature@filter_by_id') {id_item: 3}

Scenario: Validate filter by id - GET (Filter by id)    
    * match notepad.get('response_filter_by_id') == data_validation.data

Scenario: Validate data filtered by id - GET
    * match response_filter.response ==  schema_validation