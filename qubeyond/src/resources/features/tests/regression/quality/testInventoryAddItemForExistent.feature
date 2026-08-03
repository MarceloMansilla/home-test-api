@regressionQuality
Feature: Inventory Test - Quality - Regression

  Background:
    * def response_inventory = call read('classpath:features/operations/inventory/inventory.feature@validation_items')
    * def items = response_inventory.response.data
    * def body = functions.getDataSetJsonByName("inventory")

  Scenario: Add new item for existent id - POST (Add new item for existent id )
    * def response_add_new_item = call read('classpath:features/operations/inventory/inventory.feature@add_new_item') {body_item: '#(body.data)'}
    * match notepad.get('response_add_new_item') == "Bad Request"
