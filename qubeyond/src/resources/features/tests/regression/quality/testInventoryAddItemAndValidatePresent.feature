@regressionQuality
Feature: Inventory Test - Quality - Regression

Background:
    * def response_inventory = call read('classpath:features/operations/inventory/inventory.feature@validation_items')
    * def items = response_inventory.response.data

Scenario Outline: Add new item and validate it is present (<description>) - POST (Add new item)
    # the payload is built and posted inside the outline: the Examples variables
    # belong to the generated scenario, they are not visible from the Background.
    # copy, not def: def would only bind a reference to the shared dataset object
    * copy new_item = item
    * set new_item.id = utils.get_new_id(items)
    * def response_add_new_item = call read('classpath:features/operations/inventory/inventory.feature@add_new_item') {body_item: '#(new_item)'}
    * def response_after_add = call read('classpath:features/operations/inventory/inventory.feature@validation_items')
    * def list = response_after_add.response.data
    * def itemAddedValidation = utils.get_object_by_id(list, new_item.id)
    * match itemAddedValidation == new_item
    # dynamic Examples: the single cell is an expression returning a list of
    # maps, and each map key becomes a variable - one row, one scenario.
    # It is evaluated before the Background and outside the config scope,
    # so it uses the built-in read() rather than the data loaders.
    Examples:
      | read('classpath:utils/data/dataset/inventory.json') |
