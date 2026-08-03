@regressionQuality
Feature: Inventory Test - Quality - Regression


Background:
    * def response_inventory = call read('classpath:features/operations/inventory/inventory.feature@validation_items')
    * def items = response_inventory.response.data

Scenario: Validate schema items - GET
    * def schemaValidation = functions.getSchemaJsonByName("inventory").schema_item
    # the list must not be empty, otherwise 'match each' would pass vacuously
    * assert items.length > 0
    # 'match each' applies the schema to every element of the array;
    # '==' means these are the ONLY keys allowed - an extra or missing key fails
    * match each items ==  schemaValidation

Scenario: Validate that the response contains the minimum expected items - GET

    # the catalogue size expected for the active environment, from its config YAML
    * assert items.length >= testData.minItemCount