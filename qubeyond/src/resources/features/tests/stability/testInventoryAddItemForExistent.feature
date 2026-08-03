# @destructive: the POST is expected to be rejected, but it is still a write
# attempt - if testData.existingItemId is wrong for the environment the item
# is created, so this must be excluded wherever writes are not allowed
@smokeStability @regressionStability @destructive
Feature: Inventory Test - Stability

Background:
    # no GET here: this scenario only needs a payload and an id that already
    # exists, both known up front - the catalogue is never read
    # the dataset is a list of payloads - any row works here, what decides the
    # outcome is the id. copy, not def: def would bind a reference to it
    * copy body = functions.getDataSetJsonByName("inventory")[0].item
    # an id that already exists in the active environment, so the POST is rejected
    * set body.id = testData.existingItemId
Scenario: Add new item for existent id - POST (Add new item for existent id )
    * def response_add_new_item_for_existent_id = call read('classpath:features/operations/inventory/inventory.feature@add_new_item') {body_item: '#(body)'}
    * match response_add_new_item_for_existent_id.responseStatus == 400