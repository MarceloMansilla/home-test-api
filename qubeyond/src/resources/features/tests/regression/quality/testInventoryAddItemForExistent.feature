@regressionQuality
Feature: Inventory Test - Quality - Regression

  Background:
    * def response_inventory = call read('classpath:features/operations/inventory/inventory.feature@validation_items')
    * def items = response_inventory.response.data
    # the dataset is a list of payloads - any row works here, what decides the
    # outcome is the id. copy, not def: def would bind a reference to it
    * copy body = functions.getDataSetJsonByName("inventory")[0].item
    # an id that already exists in the active environment, so the POST is rejected
    * set body.id = testData.existingItemId

  Scenario: Add new item for existent id - POST (Add new item for existent id )
    * def response_add_new_item = call read('classpath:features/operations/inventory/inventory.feature@add_new_item') {body_item: '#(body)'}
    * match response_add_new_item.response == "Bad Request"
