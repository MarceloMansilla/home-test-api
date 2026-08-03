@smokeStability @regressionStability
Feature: Inventory Test - Stability

  Background:
    * def response_inventory = call read('classpath:features/operations/inventory/inventory.feature@validation_items')
    * def items = response_inventory.response.data
    # the dataset is a list of payloads - any row works here, what decides the
    # outcome is the missing key. copy, not def: def would bind a reference to it
    * copy body = functions.getDataSetJsonByName("inventory")[0].item

    Scenario Outline: Add new item with missing information (<key>) - POST (Add new item with missing "<key>" )
      * def body_with_missing_information = utils.remove_key(body, key)
      * def response_add_new_item = call read('classpath:features/operations/inventory/inventory.feature@add_new_item') {body_item: '#(body_with_missing_information)'}
      * match response_add_new_item.responseStatus == 400
      # dynamic Examples: the single cell is an expression returning a list of
      # maps, and each map key becomes a variable - one row, one scenario.
      # It is evaluated before the Background and outside the config scope,
      # so it uses the built-in read() rather than the data loaders.
      Examples:
        | read('classpath:utils/data/dataset/inventoryRequiredKeys.json') |
