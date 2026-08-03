@regressionQuality
Feature: Inventory Test - Quality - Regression

  Background:
    * def response_inventory = call read('classpath:features/operations/inventory/inventory.feature@validation_items')
    * def items = response_inventory.response.data
    # copy, not def: def would only bind a reference to the shared dataset object
    * copy body = functions.getDataSetJsonByName("inventory")

  Scenario: Add new item with missing information (id) - POST (Add new item with missing "id" )
    * def body_with_missing_information = utils.remove_key(body.data, "id")
    * def response_add_new_item = call read('classpath:features/operations/inventory/inventory.feature@add_new_item') {body_item: '#(body_with_missing_information)'}
    * match notepad.get('response_add_new_item') == "Not all requirements are met"

  Scenario: Add new item with missing information (name) - POST (Add new item with missing "name" )
    * def body_with_missing_information = utils.remove_key(body.data, "name")
    * def response_add_new_item = call read('classpath:features/operations/inventory/inventory.feature@add_new_item') {body_item: '#(body_with_missing_information)'}
    * match notepad.get('response_add_new_item') == "Not all requirements are met"

  Scenario: Add new item with missing information (image) - POST (Add new item with missing "image" )
    * def body_with_missing_information = utils.remove_key(body.data, "image")
    * def response_add_new_item = call read('classpath:features/operations/inventory/inventory.feature@add_new_item') {body_item: '#(body_with_missing_information)'}
    * match notepad.get('response_add_new_item') == "Not all requirements are met"

  Scenario: Add new item with missing information (price) - POST (Add new item with missing "price" )
    * def body_with_missing_information = utils.remove_key(body.data, "price")
    * def response_add_new_item = call read('classpath:features/operations/inventory/inventory.feature@add_new_item') {body_item: '#(body_with_missing_information)'}
    * match notepad.get('response_add_new_item') == "Not all requirements are met"