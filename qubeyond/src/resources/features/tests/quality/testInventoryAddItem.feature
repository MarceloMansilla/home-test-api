@smokeQuality @regressionQuality
Feature: Inventory Test - Quality

  Background:
    * def response_inventory = call read('classpath:features/operations/inventory/inventory.feature@validation_items')
    * def items = response_inventory.response.data

  Scenario Outline: Add new item (<description>) - POST (Add new item)
    # 'item' is this row's payload, straight from the dataset file.
    # copy, not def: def would only bind a reference to the shared dataset object
    * copy new_item = item
    * set new_item.id = utils.get_new_id(items)
    * def response_add_new_item = call read('classpath:features/operations/inventory/inventory.feature@add_new_item') {body_item: '#(new_item)'}
    * match response_add_new_item.response == "OK"
    # dynamic Examples: the single cell is an expression returning a list of
    # maps, and each map key becomes a variable - one row, one scenario.
    # It is evaluated before the Background and outside the config scope,
    # so it uses the built-in read() rather than the data loaders.
    Examples:
      | read('classpath:utils/data/dataset/inventory.json') |
