@smokeStability
Feature: Inventory Test - Stability - Smoke
Scenario: Validate filter by id - GET (Filter by id)
    * def response = call read('classpath:features/operations/inventory/inventory.feature@filter_by_id') {id_item: 3}
    * match response.responseStatus == 200