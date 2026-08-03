@regressionQuality
Feature: Inventory Test - Quality - Regression

Background:
    * def schema_validation = functions.getDataValidationJsonByName("inventory").data
    * def data_validation = functions.getDataValidationJsonByName("inventory")
    # the id and its expected record both come from the active environment
    * def response_filter = call read('classpath:features/operations/inventory/inventory.feature@filter_by_id') {id_item: '#(testData.filterId)'}

Scenario: Validate filter by id - GET (Filter by id)    
    * match notepad.get('response_filter_by_id') == data_validation.data

Scenario: Validate data filtered by id - GET
    * match response_filter.response ==  schema_validation