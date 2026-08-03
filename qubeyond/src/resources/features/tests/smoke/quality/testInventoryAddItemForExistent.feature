@smokeQuality 
Feature: Inventory Test - Quality - Smoke

  Background:
    * def response_inventory = call read('classpath:features/operations/inventory/inventory.feature@validation_items')
    * def items = response_inventory.response.data
    # copy, not def: def would bind a reference to the shared dataset object
    * copy body = functions.getDataSetJsonByName("inventory")
    # an id that already exists in the active environment, so the POST is rejected
    * set body.data.id = testData.existingItemId

  Scenario: Add new item for existent id - POST (Add new item for existent id )
    * def response_add_new_item = call read('classpath:features/operations/inventory/inventory.feature@add_new_item') {body_item: '#(body.data)'}
    * match notepad.get('response_add_new_item') == "Bad Request"
