@regressionQuality
Feature: Inventory Test - Stability - Regression

Background:
    * def response_inventory = call read('classpath:features/operations/inventory/inventory.feature@validation_items')
    * def items = response_inventory.response.data
    * def body = functions.getDataSetJsonByName("inventory")
Scenario: Add new item for existent id - POST (Add new item for existent id )
    * def response_add_new_item_for_existent_id = call read('classpath:features/operations/inventory/inventory.feature@add_new_item') {body_item: '#(body.data)'}
    * match response_add_new_item_for_existent_id.responseStatus == 400