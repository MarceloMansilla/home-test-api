@smokeQuality
Feature: Inventory Test - Quality - Smoke

Background:
    * def response_inventory = call read('classpath:features/operations/inventory/inventory.feature@validation_items')
    * def items = response_inventory.response.data
    # copy, not def: def would only bind a reference to the shared dataset object
    * copy body = functions.getDataSetJsonByName("inventory")
    
Scenario: Add new item - POST (Add new item)
    * def id_new = utils.get_new_id(items)
    * set body.data.id = id_new
    * def new_item = body.data
    * def response_add_new_item = call read('classpath:features/operations/inventory/inventory.feature@add_new_item') {body_item: '#(new_item)'}
    * match notepad.get('response_add_new_item') == "OK"

Scenario: Add new item for existent id - POST (Add new item for existent id )
    * def response_add_new_item = call read('classpath:features/operations/inventory/inventory.feature@add_new_item') {body_item: '#(body.data)'}
    * match notepad.get('response_add_new_item') == "Bad Request"