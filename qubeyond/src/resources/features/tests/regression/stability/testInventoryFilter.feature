@regressionStability
Feature: Inventory Test - Stability - Regression
Scenario: Validate filter by id - GET (Filter by id)
    * def response = call read('classpath:features/operations/inventory/inventory.feature@filter_by_id') {id_item: '#(testData.filterId)'}
    * match response.responseStatus == 200