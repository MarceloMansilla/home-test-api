@ignore
Feature: Inventory

    Background:
        # baseUrl and api both come from karate-config.js for the active karate.env
        * url baseUrl

    # Each scenario ends on the call itself: Karate hands the caller back this
    # scenario's variables, so 'response' and 'responseStatus' are read from the
    # value that 'call read(...)' returns - no shared state in between.

    @validation_items
    Scenario: Validation keys items
        Given path api.inventory.getItems
        When method GET

    @filter_by_id
    Scenario: Filter by id
        Given path api.inventory.filterById
        And param id = id_item
        When method GET

    @add_new_item
    Scenario: Add new item
        Given path api.inventory.addItem
        And request body_item
        When method POST
