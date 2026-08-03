@smokeQuality
Feature: Inventory Test - Quality - Smoke

Background:
    * def response_inventory = call read('classpath:features/operations/inventory/inventory.feature@validation_items')
    * def items = response_inventory.response.data
    * copy body = functions.getDataSetJsonByName("inventory")
    * def id_new = utils.get_new_id(items)
    * set body.data.id = id_new
    * def new_item = body.data
    * def response_add_new_item = call read('classpath:features/operations/inventory/inventory.feature@add_new_item') {body_item: '#(new_item)'}

Scenario: Add new item - POST (Add new item)
    * def response_inventory = call read('classpath:features/operations/inventory/inventory.feature@validation_items')
    * def list = response_inventory.response.data
    * def itemAddedValidation = utils.get_object_by_id(list, new_item.id)
    * match itemAddedValidation == new_item
